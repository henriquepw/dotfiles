#!/bin/bash

./instant-font.sh

# change wallpaper
gsettings set org.gnome.desktop.background picture-uri file://$(pwd)/wallpaper.png
gsettings set org.gnome.desktop.background picture-uri-dark file://$(pwd)/wallpaper.png

gsettings set org.gnome.desktop.background show-desktop-icons false

cd .. && stow .