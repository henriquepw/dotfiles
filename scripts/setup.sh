#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
brew install alacritty zoxide wget lazygit tmux stow starship
brew install --cask font-jetbrains-mono-nerd-font

cd .. && stow .
