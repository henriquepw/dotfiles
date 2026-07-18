#!/usr/bin/env bash
# Alterna o desktop para o "dummy plug" (monitor falso 4K60) durante o streaming
# do Sunshine e restaura o monitor real ao desconectar.
#
# Por que: no KDE Wayland não dá pra criar display virtual como no Hyprland.
# O dummy plug resolve isso aparecendo como um monitor físico de verdade —
# capaz de 4K60 — que o KWin renderiza e o Sunshine captura.
#
# Uso: stream-display.sh do   (início do stream)
#      stream-display.sh undo (fim do stream)
#
# Sunshine exporta a resolução pedida pelo cliente (Moonlight) via:
#   SUNSHINE_CLIENT_WIDTH / SUNSHINE_CLIENT_HEIGHT / SUNSHINE_CLIENT_FPS
set -uo pipefail

# --- Configuração --------------------------------------------------------
# SEAT_DISPLAY  = monitor onde você senta (real). STREAM_DISPLAY = dummy plug.
# Deixe STREAM_DISPLAY vazio para autodetectar (primeiro output conectado que
# não seja o SEAT). Descubra os nomes com: kscreen-doctor -o
SEAT_DISPLAY="${SEAT_DISPLAY:-DP-1}"
STREAM_DISPLAY="${STREAM_DISPLAY:-}"
SEAT_MODE="${SEAT_MODE:-2560x1440@165}"

# Resolução/fps pedidos pelo Moonlight (fallback: 4K60)
W="${SUNSHINE_CLIENT_WIDTH:-3840}"
H="${SUNSHINE_CLIENT_HEIGHT:-2160}"
FPS="$(printf '%.0f' "${SUNSHINE_CLIENT_FPS:-60}")"
# -------------------------------------------------------------------------

log() { printf '[stream-display] %s\n' "$*" >&2; }

# Lista conectores conectados a partir do sysfs (nomes batem com o kscreen no
# Wayland: DP-1, HDMI-A-1, ...). Evita parsear a saída colorida do kscreen.
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

# Autodetecta o dummy: primeiro conectado que não é o SEAT
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
	# Scale 1:1 — sem isso o KDE captura a área lógica escalada (ex.: 1423x800)
	# em vez do 4K nativo. Não precisa restaurar: o dummy é desligado no undo.
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
