#!/usr/bin/env bash
# Switch to the dummy-plug display for Sunshine streaming (KDE Wayland has no virtual display); restore real monitor on undo
set -uo pipefail

# SEAT_DISPLAY = real monitor; STREAM_DISPLAY = dummy plug (empty = autodetect first non-seat output)
SEAT_DISPLAY="${SEAT_DISPLAY:-DP-1}"
STREAM_DISPLAY="${STREAM_DISPLAY:-}"
SEAT_MODE="${SEAT_MODE:-2560x1440@165}"

# Resolution/fps requested by Moonlight (fallback: 4K60)
W="${SUNSHINE_CLIENT_WIDTH:-3840}"
H="${SUNSHINE_CLIENT_HEIGHT:-2160}"
FPS="$(printf '%.0f' "${SUNSHINE_CLIENT_FPS:-60}")"

log() { printf '[stream-display] %s\n' "$*" >&2; }

# List connected outputs from sysfs (names match kscreen on Wayland); avoids parsing kscreen's colored output
connected_outputs() {
	local path conn
	for path in /sys/class/drm/card*-*/status; do
		[[ -r "$path" ]] || continue
		[[ "$(<"$path")" == "connected" ]] || continue
		conn="${path%/status}" # .../card1-DP-3
		conn="${conn##*/}"     # card1-DP-3
		echo "${conn#card*-}"  # DP-3
	done
}

# Autodetect the dummy: first connected output that is not the seat
if [[ -z "$STREAM_DISPLAY" ]]; then
	while read -r out; do
		[[ "$out" == "$SEAT_DISPLAY" ]] && continue
		STREAM_DISPLAY="$out"
		break
	done < <(connected_outputs)
fi

case "${1:-}" in
do)
	if [[ -z "$STREAM_DISPLAY" ]]; then
		log "nenhum display de stream (dummy) conectado — capturando o monitor atual"
		exit 0
	fi
	log "ativando ${STREAM_DISPLAY} em ${W}x${H}@${FPS}, desativando ${SEAT_DISPLAY}"
	kscreen-doctor "output.${STREAM_DISPLAY}.enable" || true
	kscreen-doctor "output.${STREAM_DISPLAY}.mode.${W}x${H}@${FPS}" ||
		log "modo ${W}x${H}@${FPS} indisponível em ${STREAM_DISPLAY} — mantendo o atual"
	kscreen-doctor output."${STREAM_DISPLAY}".position.0,0 || true
	# Scale 1:1, else KDE captures the scaled logical area instead of native 4K
	kscreen-doctor output."${STREAM_DISPLAY}".scale.1 || true
	if [[ "$STREAM_DISPLAY" != "$SEAT_DISPLAY" ]]; then
		sleep 1
		kscreen-doctor output."${SEAT_DISPLAY}".disable || true
	fi
	;;
undo)
	log "restaurando ${SEAT_DISPLAY} (${SEAT_MODE})"
	kscreen-doctor output."${SEAT_DISPLAY}".enable || true
	kscreen-doctor output."${SEAT_DISPLAY}".mode."${SEAT_MODE}" || true
	kscreen-doctor output."${SEAT_DISPLAY}".position.0,0 || true
	if [[ -n "$STREAM_DISPLAY" && "$STREAM_DISPLAY" != "$SEAT_DISPLAY" ]]; then
		sleep 1
		kscreen-doctor output."${STREAM_DISPLAY}".disable || true
	fi
	;;
*)
	echo "uso: $0 {do|undo}" >&2
	exit 1
	;;
esac
