#!/usr/bin/env bash
#
# bellway-init.sh — one-shot in-place setup, run ON the bellway laptop console.
#
# Turns the existing (old-citadel) NixOS install into the bellway edge router:
# clones the dotfiles repo, fills the on-device placeholders (hardware config,
# NIC MACs, stateVersion), installs the Tailscale auth key, pre-builds the new
# system, then — after you move the cables — activates it.
#
# Safe to stop with Ctrl-C before the final "activate" gate. Nothing switches
# until you confirm the cutover.

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/henriquepw/dotfiles.git}"
BRANCH="${BRANCH:-nixos}"
REPO_DIR="${REPO_DIR:-$HOME/dotfiles}"
FLAKE_HOST="bellway"
HW_FILE_REL="modules/_hardware/bellway/hardware-configuration.nix"
GATEWAY_REL="modules/features/router/gateway.nix"
HOST_REL="modules/hosts/bellway.nix"
AUTHKEY_DEST="/etc/tailscale/bellway-authkey"

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
	BOLD=$(tput bold)
	DIM=$(tput dim)
	RST=$(tput sgr0)
	BLUE=$(tput setaf 4)
	GRN=$(tput setaf 2)
	YLW=$(tput setaf 3)
	RED=$(tput setaf 1)
else
	BOLD=""
	DIM=""
	RST=""
	BLUE=""
	GRN=""
	YLW=""
	RED=""
fi

say() { printf '  %s\n' "$1"; }
step() { printf '  %s•%s %s\n' "$BLUE" "$RST" "$1"; }
ok() { printf '  %s✓%s %s\n' "$GRN" "$RST" "$1"; }
warn() { printf '  %s⚠ %s%s\n' "$YLW" "$1" "$RST"; }
die() {
	printf '  %s✗ %s%s\n' "$RED" "$1" "$RST" >&2
	exit 1
}
hdr() { printf '\n%s%s▸ %s%s\n' "$BOLD" "$BLUE" "$1" "$RST"; }
confirm() {
	local r
	printf '  %s? %s [y/N] ' "$YLW" "$1"
	read -r r || true
	[[ "$r" =~ ^[Yy] ]]
}

# ── Preconditions ──────────────────────────────────────────────────────────
hdr "Preconditions"
[[ -e /etc/NIXOS ]] || die "This is not a NixOS system — run it on the bellway laptop."
[[ $EUID -ne 0 ]] || die "Run as your normal user (it calls sudo where needed), not root."
for c in git ip nixos-generate-config nixos-rebuild sudo; do
	command -v "$c" >/dev/null 2>&1 || die "missing required command: $c"
done
ok "NixOS host, tools present"

# ── Repo ───────────────────────────────────────────────────────────────────
hdr "Repository"
if [[ -d "$REPO_DIR/.git" ]]; then
	step "Updating existing checkout at $REPO_DIR"
	git -C "$REPO_DIR" fetch --quiet origin "$BRANCH"
	git -C "$REPO_DIR" checkout --quiet "$BRANCH"
	git -C "$REPO_DIR" pull --quiet --ff-only origin "$BRANCH" || warn "could not fast-forward — using local state"
else
	step "Cloning $REPO_URL ($BRANCH) → $REPO_DIR"
	git clone --quiet --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
fi
cd "$REPO_DIR"
HW_FILE="$REPO_DIR/$HW_FILE_REL"
GATEWAY="$REPO_DIR/$GATEWAY_REL"
HOST="$REPO_DIR/$HOST_REL"
for f in "$HW_FILE" "$GATEWAY" "$HOST"; do [[ -f "$f" ]] || die "expected file missing: $f"; done
ok "Repo ready at $REPO_DIR"

# ── NIC detection + selection ──────────────────────────────────────────────
hdr "Network interfaces"
mapfile -t IFACES < <(
	for d in /sys/class/net/*; do
		n=$(basename "$d")
		[[ "$n" == "lo" ]] && continue
		[[ -e "$d/device" ]] || continue # physical NICs only (skip virtual/tailscale0)
		echo "$n"
	done
)
[[ ${#IFACES[@]} -ge 2 ]] || die "found ${#IFACES[@]} physical NIC(s); need at least 2 (WAN + LAN). Plug in the USB adapter."

iface_mac() { ethtool -P "$1" 2>/dev/null | grep -oE '([0-9a-f]{2}:){5}[0-9a-f]{2}' || cat "/sys/class/net/$1/address"; }
iface_bus() { readlink -f "/sys/class/net/$1/device" 2>/dev/null || echo "?"; }
iface_drv() { basename "$(readlink -f "/sys/class/net/$1/device/driver" 2>/dev/null || echo '?')"; }
iface_usb() { [[ "$(iface_bus "$1")" == *"/usb"* ]] && echo "USB" || echo "onboard"; }

for i in "${!IFACES[@]}"; do
	n="${IFACES[$i]}"
	printf '  %s[%d]%s %-10s mac=%s  %s  driver=%s\n' \
		"$BOLD" "$i" "$RST" "$n" "$(iface_mac "$n")" "$(iface_usb "$n")" "$(iface_drv "$n")"
done
warn "WAN = onboard 1GbE (Intel I217-LM). LAN = USB 2.5GbE adapter."
printf '  %sWAN interface index:%s ' "$BOLD" "$RST"
read -r WI
printf '  %sLAN interface index:%s ' "$BOLD" "$RST"
read -r LI
[[ "$WI" =~ ^[0-9]+$ && "$LI" =~ ^[0-9]+$ && "$WI" != "$LI" ]] || die "invalid / identical indices"
[[ -n "${IFACES[$WI]:-}" && -n "${IFACES[$LI]:-}" ]] || die "index out of range"
WAN_MAC=$(iface_mac "${IFACES[$WI]}")
LAN_MAC=$(iface_mac "${IFACES[$LI]}")
ok "WAN ${IFACES[$WI]} = $WAN_MAC   |   LAN ${IFACES[$LI]} = $LAN_MAC"
confirm "Correct?" || die "aborted — re-run and pick again"

# ── stateVersion (keep the existing install's value) ───────────────────────
hdr "stateVersion"
SV=$(nixos-version --json 2>/dev/null | grep -oE '"nixosVersion":"[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+' | head -1 || true)
[[ -n "$SV" ]] || SV=$(grep -rhoE 'system\.stateVersion = "[0-9]+\.[0-9]+"' /etc/nixos 2>/dev/null | grep -oE '[0-9]+\.[0-9]+' | head -1 || true)
printf '  %sExisting install stateVersion%s [%s]: ' "$BOLD" "$RST" "${SV:-unknown}"
read -r SV_IN
SV="${SV_IN:-$SV}"
[[ "$SV" =~ ^[0-9]+\.[0-9]+$ ]] || die "need a stateVersion like 24.05 — reuse the value the box was installed with"
ok "Using stateVersion $SV"

# ── Generate hardware config ───────────────────────────────────────────────
hdr "Hardware configuration"
step "Running nixos-generate-config --show-hardware-config"
nixos-generate-config --show-hardware-config >"$HW_FILE"
grep -q "fileSystems" "$HW_FILE" || die "generated hardware config looks empty — aborting"
ok "Wrote real hardware config → $HW_FILE_REL"

# ── Apply placeholder edits ────────────────────────────────────────────────
hdr "Filling placeholders"
repl() { # file  from  to  label
	grep -qF "$2" "$1" || {
		warn "placeholder for '$4' not found (already set?) — skipping"
		return 0
	}
	sed -i "s|$2|$3|" "$1"
	ok "$4"
}
repl "$GATEWAY" '00:00:00:00:00:00' "$WAN_MAC" "WAN MAC → wan0"
repl "$GATEWAY" '00:00:00:00:00:01' "$LAN_MAC" "LAN MAC → lan0"
repl "$HOST" 'system.stateVersion = "26.05";' "system.stateVersion = \"$SV\";" "stateVersion → $SV"

# ── Tailscale auth key ─────────────────────────────────────────────────────
hdr "Tailscale auth key"
if sudo test -s "$AUTHKEY_DEST"; then
	ok "$AUTHKEY_DEST already present — leaving it"
else
	printf '  %sPath to the auth key file (blank = paste it):%s ' "$BOLD" "$RST"
	read -r KP
	sudo install -d -m 700 /etc/tailscale
	if [[ -n "$KP" ]]; then
		[[ -f "$KP" ]] || die "no such file: $KP"
		sudo install -m 600 -o root -g root "$KP" "$AUTHKEY_DEST"
	else
		printf '  %sPaste the key (tskey-auth-…), then Enter:%s ' "$BOLD" "$RST"
		read -rs KV
		printf '\n'
		[[ -n "$KV" ]] || die "empty key"
		printf '%s\n' "$KV" | sudo tee "$AUTHKEY_DEST" >/dev/null
		sudo chmod 600 "$AUTHKEY_DEST"
		sudo chown root:root "$AUTHKEY_DEST"
	fi
	ok "Installed $AUTHKEY_DEST (root 0600)"
fi

# ── Validate + pre-build (still on the OLD network, with internet) ─────────
hdr "Validate + build"
git -C "$REPO_DIR" add -A # ensure edits are visible to the flake (incl. any new files)
step "Evaluating the configuration (fast sanity check)"
nix eval --raw ".#nixosConfigurations.${FLAKE_HOST}.config.system.build.toplevel.drvPath" >/dev/null ||
	die "evaluation failed — fix the errors above before switching"
ok "Evaluates cleanly"
step "Building the system closure (no activation yet)"
sudo nixos-rebuild build --flake ".#${FLAKE_HOST}"
ok "Built — closure is local; activation no longer needs the network"

# ── Cutover gate ───────────────────────────────────────────────────────────
hdr "Physical cutover"
say "Move the cables NOW:"
step "ONU  → bellway WAN  (${IFACES[$WI]}, onboard)"
step "bellway LAN (${IFACES[$LI]}, USB) → TL-SG105E switch → Huawei Mesh (AP mode)"
warn "After activation this box becomes the gateway (10.10.0.1, DHCP, default-deny"
warn "firewall). Any SSH over the old network will drop — that's expected."
echo
confirm "Cables moved and ready to ACTIVATE the router config?" || {
	say "Stopped before activation. When ready, re-run and it will reuse the build."
	say "Or activate manually: sudo nixos-rebuild switch --flake $REPO_DIR#$FLAKE_HOST"
	exit 0
}

# ── Activate ───────────────────────────────────────────────────────────────
hdr "Activating"
sudo nixos-rebuild switch --flake ".#${FLAKE_HOST}"
ok "bellway is live as the edge router"

# ── Post-checks ────────────────────────────────────────────────────────────
hdr "Verify (give services a few seconds)"
sleep 5
ip -brief addr show lan0 2>/dev/null | grep -q 10.10.0.1 && ok "lan0 has 10.10.0.1" || warn "lan0 not 10.10.0.1 yet"
systemctl is-active --quiet kea-dhcp4-server 2>/dev/null && ok "kea DHCP running" || warn "kea not active yet"
systemctl is-active --quiet blocky 2>/dev/null && ok "blocky DNS running" || warn "blocky not active yet"
systemctl is-active --quiet tailscaled 2>/dev/null && ok "tailscaled running" || warn "tailscaled not active yet"
echo
say "${BOLD}Still to do by hand:${RST}"
step "Confirm WAN pulled DHCP from the ONU and internet works."
step "tailscale status — confirm it enrolled and is advertising 10.10.0.0/24."
step "In the Tailscale admin DNS page, add bellway's 100.x as the global"
step "  nameserver with 'Override local DNS' (the deferred ticket-19 step)."
step "Fill kea static reservations in $GATEWAY_REL once mesh/switch/printer"
step "  MACs are known (check leases in /var/lib/kea), then deploy from citadel."
echo
