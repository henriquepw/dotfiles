#!/usr/bin/env bash
set -euo pipefail

hyprctl output remove HEADLESS-1

CONF="${HOME}/.config/sunshine/sunshine.conf"
sed -i '/^output_name/d' "$CONF"
echo "output_name = DP-2" >>"$CONF"
