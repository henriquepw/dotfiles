#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

OMARCHY_THEME="${OMARCHY_THEME:-Matte Black}"
WALLPAPER="${OMARCHY_WALLPAPER:-$REPO_ROOT/assets/wallpaper.png}"

if ! command -v omarchy >/dev/null 2>&1; then
	echo "✖ This setup requires Omarchy." >&2
	exit 1
fi

echo "▶ Removing Omarchy preinstalled applications"
omarchy remove preinstalls

echo "▶ Installing packages"
"$SCRIPT_DIR/packages.sh"

echo "▶ Installing dotfiles"
cd "$REPO_ROOT"
stow -v -t "$HOME" .config .local
ln -sfn "$REPO_ROOT/.zshrc" "$HOME/.zshrc"

echo "▶ Applying Omarchy theme: $OMARCHY_THEME"
omarchy theme set "$OMARCHY_THEME"

if [ -f "$WALLPAPER" ]; then
	echo "▶ Applying wallpaper: $WALLPAPER"
	omarchy theme bg set "$WALLPAPER"
else
	echo "⚠ Wallpaper not found, skipping: $WALLPAPER" >&2
fi

echo "▶ Installing Omarchy system monitor plugin"
omarchy plugin add "https://github.com/Harshith292002/omarchy-system-monitor.git" --enable --yes

echo "✔ Omarchy setup complete"
