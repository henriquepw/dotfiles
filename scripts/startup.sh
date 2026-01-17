#!/bin/bash
# ~/.config/hypr/startup-apps.sh

# Workspace 1 - terminal
sleep 1
uwsm-app -- xdg-terminal-exec --dir="$(omarchy-cmd-terminal-cwd)"

# Workspace 2 - browser
sleep 1
hyprctl dispatch workspace 2
sleep 1
omarchy-launch-browser

sleep 2

# WOrkspace 4 - webapps
omarchy-launch-webapp Discord "https://discord.com/app"
sleep 1
omarchy-launch-webapp WhatsApp "https://web.whatsapp.com/"
sleep 1
omarchy-launch-webapp Music "https://music.youtube.com/"
