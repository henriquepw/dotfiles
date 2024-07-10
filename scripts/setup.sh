#!/bin/bash

./instant-font.sh

# change wallpaper
gsettings set org.gnome.desktop.background picture-uri file://$(pwd)/wallpaper.png
gsettings set org.gnome.desktop.background picture-uri-dark file://$(pwd)/wallpaper.png

gsettings set org.gnome.desktop.background show-desktop-icons false

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

cd .. && stow .

