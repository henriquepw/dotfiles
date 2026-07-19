#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")/.." && pwd)"
HOST="${1:-citadel}"

echo "▶ Dotfiles: $DOTFILES"
echo "▶ Host: $HOST"

# Nix config references the repo via ~/.dotfiles, so the clone can live anywhere
ln -sfn "$DOTFILES" "$HOME/.dotfiles"

# ── 1. Hardware configuration ────────────────────────────────────────────────
HARDWARE_SRC="/etc/nixos/hardware-configuration.nix"
HARDWARE_DEST="$DOTFILES/nix/hosts/$HOST/hardware-configuration.nix"

if [ ! -f "$HARDWARE_DEST" ]; then
	if [ ! -f "$HARDWARE_SRC" ]; then
		echo "▶ Generating hardware-configuration.nix"
		sudo nixos-generate-config --no-filesystems
	fi
	echo "▶ Copying hardware-configuration.nix"
	cp "$HARDWARE_SRC" "$HARDWARE_DEST"
	# flakes in a git repo only see tracked files
	git -C "$DOTFILES" add "$HARDWARE_DEST"
else
	echo "▶ hardware-configuration.nix already present, skipping"
fi

# ── 2. Nix flakes ────────────────────────────────────────────────────────────
if ! grep -q "experimental-features.*flakes" /etc/nix/nix.conf 2>/dev/null; then
	echo "▶ Enabling flakes for this bootstrap"
	mkdir -p ~/.config/nix
	echo "experimental-features = nix-command flakes" >>~/.config/nix/nix.conf
fi

# ── 3. Apply NixOS configuration ─────────────────────────────────────────────
echo "▶ Running nixos-rebuild switch (this will take a while)"
sudo nixos-rebuild switch --flake "$DOTFILES/nix#$HOST"

echo ""
echo "✓ Done! Reboot recommended."
