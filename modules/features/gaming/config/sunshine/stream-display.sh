#!/usr/bin/env bash
# Enable the dummy-plug display for Sunshine at the client's resolution/refresh; the physical monitor is never touched
set -uo pipefail

# SEAT_DISPLAY = real monitor (never reconfigured); STREAM_DISPLAY = dummy plug (EDID override + KWin custom modes)
SEAT_DISPLAY="${SEAT_DISPLAY:-DP-2}"
STREAM_DISPLAY="${STREAM_DISPLAY:-DP-3}"
SEAT_WIDTH="${SEAT_WIDTH:-2560}"

# Resolution/fps requested by Moonlight (fallback: 4K60)
W="${SUNSHINE_CLIENT_WIDTH:-3840}"
H="${SUNSHINE_CLIENT_HEIGHT:-2160}"
FPS="$(printf '%.0f' "${SUNSHINE_CLIENT_FPS:-60}")"

log() { printf '[stream-display] %s\n' "$*" >&2; }

# Guard against the seat/stream mix-up that once left the desk monitor disabled
if [[ "$STREAM_DISPLAY" == "$SEAT_DISPLAY" ]]; then
	log "STREAM_DISPLAY == SEAT_DISPLAY (${SEAT_DISPLAY}) — recusando mexer no monitor físico"
	exit 0
fi
if [[ "$(cat /sys/class/drm/card*-"${STREAM_DISPLAY}"/status 2>/dev/null)" != connected ]]; then
	log "${STREAM_DISPLAY} não está conectado — nada a fazer"
	exit 0
fi

# Available modes for the stream display, as reported by kscreen (e.g. "3840x2160@120")
stream_modes() {
	kscreen-doctor -o 2>/dev/null |
		sed 's/\x1b\[[0-9;]*m//g' |
		awk -v out="$STREAM_DISPLAY" '/^Output:/ { p = ($0 ~ " " out " ") } p' |
		grep -oE '[0-9]+x[0-9]+@[0-9]+'
}

case "${1:-}" in
do)
	log "ativando ${STREAM_DISPLAY} para ${W}x${H}@${FPS} (${SEAT_DISPLAY} permanece ligado)"
	kscreen-doctor output."${STREAM_DISPLAY}".enable || true

	if kscreen-doctor output."${STREAM_DISPLAY}".mode."${W}x${H}@${FPS}"; then
		log "modo ${W}x${H}@${FPS} aplicado"
	else
		# Highest refresh at the requested resolution; a 4K60 client on a 120Hz output is an exact 2:1 divide
		fallback="$(stream_modes | grep -E "^${W}x${H}@" | sort -t@ -k2 -n | tail -1)"
		if [[ -n "$fallback" ]] && kscreen-doctor output."${STREAM_DISPLAY}".mode."$fallback"; then
			log "modo ${W}x${H}@${FPS} indisponível — usando ${fallback}"
		else
			log "nenhum modo ${W}x${H} disponível em ${STREAM_DISPLAY} — mantendo o atual"
		fi
	fi

	# Scale 1:1, else KWin streams the scaled logical area instead of native resolution
	kscreen-doctor output."${STREAM_DISPLAY}".scale.1 || true
	# Park it beside the seat display so the layout never overlaps
	kscreen-doctor output."${STREAM_DISPLAY}".position."${SEAT_WIDTH},0" || true
	# Primary, so Steam and any new window opens on the streamed output
	kscreen-doctor output."${STREAM_DISPLAY}".primary || true
	;;
undo)
	log "desativando ${STREAM_DISPLAY} e devolvendo o primário para ${SEAT_DISPLAY}"
	kscreen-doctor output."${SEAT_DISPLAY}".enable || true
	kscreen-doctor output."${SEAT_DISPLAY}".primary || true
	kscreen-doctor output."${STREAM_DISPLAY}".disable || true
	;;
*)
	echo "uso: $0 {do|undo}" >&2
	exit 1
	;;
esac
