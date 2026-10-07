#!/usr/bin/env bash
# steam runs inside pressure-vessel, where /usr/share/icons is the runtime's,
# so the cursor theme must also live in $HOME for steam to find it
set -euo pipefail

theme=Bibata-Modern-Ice
src="/usr/share/icons/$theme"
dest="$HOME/.local/share/icons/$theme"

[ -d "$src" ] || exit 0
mkdir -p "$(dirname "$dest")"
rm -rf "$dest"
cp -r "$src" "$dest"
