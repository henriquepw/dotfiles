#!/usr/bin/env bash
set -euo pipefail

hyprctl output create headless
sleep 1

CONF="${HOME}/.config/sunshine/sunshine.conf"
sed -i '/^output_name/d' "$CONF"
echo "output_name = HEADLESS-1" >>"$CONF"
