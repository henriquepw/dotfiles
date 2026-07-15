#!/usr/bin/env bash
# "Steam V" — abordagem de DISPLAY VIRTUAL (sem dummy plug físico).
#
# Cria um monitor virtual no KWin via krfb-virtualmonitor na resolução pedida
# pelo Moonlight, desliga os monitores físicos (real + dummy) e deixa o Sunshine
# capturar só o virtual. É a contraparte de stream-display.sh (que usa o dummy
# físico no DP-3 com EDID 4K60 forçado). Serve pra COMPARAR as duas abordagens.
#
# Requer capture = kwin no sunshine.conf (kms não enxerga output virtual).
#
# Uso: stream-virtual.sh do | undo
set -uo pipefail

SEAT_DISPLAY="${SEAT_DISPLAY:-DP-1}"     # monitor real
DUMMY_DISPLAY="${DUMMY_DISPLAY:-DP-3}"   # dummy plug físico (desligar se ligado)
SEAT_MODE="${SEAT_MODE:-2560x1440@165}"
VMON_NAME="${VMON_NAME:-sunshine-virtual}"
VNC_PORT="${VNC_PORT:-5905}"             # krfb exige porta/senha; não abrimos no firewall
VNC_PASS="${VNC_PASS:-sunshine}"

# Resolução pedida pelo Moonlight (fallback 4K). O virtual nasce já nessa
# resolução com scale 1 (1:1 real, sem área lógica escalada).
W="${SUNSHINE_CLIENT_WIDTH:-3840}"
H="${SUNSHINE_CLIENT_HEIGHT:-2160}"

log() { printf '[stream-virtual] %s\n' "$*" >&2; }

# nomes de output do kscreen (ANSI removido)
kscreen_outputs() {
	kscreen-doctor -o 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' \
		| grep -oE 'Output:[[:space:]]+[0-9]+[[:space:]]+[^[:space:]]+' \
		| awk '{ print $NF }'
}

case "${1:-}" in
	do)
		before="$(kscreen_outputs | sort -u)"
		log "criando monitor virtual ${VMON_NAME} em ${W}x${H} (scale 1)"
		krfb-virtualmonitor --name "$VMON_NAME" --resolution "${W}x${H}" \
			--scale 1 --port "$VNC_PORT" --password "$VNC_PASS" >/dev/null 2>&1 &

		# espera o KWin registrar o output novo (até ~10s)
		VIRT=""
		for _ in $(seq 1 20); do
			sleep 0.5
			after="$(kscreen_outputs | sort -u)"
			VIRT="$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after") | head -1)"
			[[ -n "$VIRT" ]] && break
		done
		if [[ -z "$VIRT" ]]; then
			log "output virtual não apareceu — Sunshine vai capturar a tela atual"
			exit 0
		fi

		log "virtual = ${VIRT}; posicionando e desligando os físicos"
		kscreen-doctor output."$VIRT".scale.1 || true
		kscreen-doctor output."$VIRT".position.0,0 || true
		sleep 1
		kscreen-doctor output."$SEAT_DISPLAY".disable || true
		kscreen-doctor output."$DUMMY_DISPLAY".disable 2>/dev/null || true
		;;
	undo)
		log "restaurando ${SEAT_DISPLAY} e encerrando o monitor virtual"
		kscreen-doctor output."$SEAT_DISPLAY".enable || true
		kscreen-doctor output."$SEAT_DISPLAY".mode."$SEAT_MODE" || true
		kscreen-doctor output."$SEAT_DISPLAY".position.0,0 || true
		sleep 1
		pkill -f "krfb-virtualmonitor.*${VMON_NAME}" 2>/dev/null \
			|| pkill -f krfb-virtualmonitor 2>/dev/null || true
		;;
	*)
		echo "uso: $0 {do|undo}" >&2
		exit 1
		;;
esac
