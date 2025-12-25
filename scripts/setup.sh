#!/bin/bash

set -e

echo "▶ Installing NVM"
if ! command -v nvm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo "▶ Installing fzf-tab-completion"
if [ ! -d "$HOME/fzf-tab-completion" ]; then
  git clone https://github.com/lincheney/fzf-tab-completion "$HOME/fzf-tab-completion"
fi

echo "▶ Installing theme"
THEME="aamis"
omarchy-theme-install https://github.com/vyrx-dev/omarchy-aamis-theme.git
mkdir -p "$HOME/.config/omarchy/$THEME/backgrounds"
if [ -f "./wallpaper.png" ]; then
  cp ./wallpaper.png "$HOME/.config/omarchy/$THEME/backgrounds/"
fi

echo "▶ Installing packages"
yay -S --noconfirm \
  stow \
  fzf \
  zoxide \
  go \
  zig \
  rust \
  bun \
  brave \
  protonplus \
  wine \
  lutris

# Run stow
echo "▶ Running stow"
cd "$(dirname "$0")/.."
stow -v -t "$HOME" */
