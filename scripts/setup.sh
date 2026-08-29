#!/bin/bash

set +e
echo "▶ Remove unused packages"
echo "TODO"
set -e

echo "▶ Installing NVM"
if ! command -v nvm >/dev/null 2>&1; then
	curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo "▶ Installing fzf-tab-completion"
if [ ! -d "$HOME/fzf-tab-completion" ]; then
	git clone https://github.com/lincheney/fzf-tab-completion "$HOME/fzf-tab-completion"
fi

echo "▶ Installing packages"
# Omarchy is based on Arch Linux. yay handles packages from both the official
# repositories and the AUR.
arch_packages=(
	# Base and dotfiles
	meson systemd git dbus libinih gcc pkgconf stow make

	# Shell and terminal
	zsh foot tmux starship bat btop fzf ripgrep fd jq fastfetch
	git-delta tree unzip zoxide chafa libsixel

	# Development
	nodejs npm bun go zig rustup watchexec neovim clang gcc

	# Git and Neovim tooling
	gh lazygit gopls revive gofumpt gotools tectonic
	nix nil nixfmt statix efm-langserver tree-sitter
	bash-language-server shellcheck shfmt rust-analyzer
	lua-language-server stylua cpplint biome vtsls
	tailwindcss-language-server mermaid-cli

	# Graphics and media
	libva-utils

	# Gaming and remote desktop
	steam lutris mangohud gamemode gamescope sunshine discord
	protonup-qt kdeconnect

	# Desktop applications
	brave freecad orca-slicer onlyoffice-bin

	# Services used by the NixOS modules
	podman tailscale syncthing keyd networkmanager bluez
	pipewire wireplumber power-profiles-daemon openssh
)

if ! command -v yay >/dev/null 2>&1; then
	echo "✖ yay is required to install packages on Omarchy/Arch Linux." >&2
	exit 1
fi

yay -S --needed "${arch_packages[@]}"

echo "▶ Setting Zsh as the default login shell"
if command -v zsh >/dev/null 2>&1 && command -v chsh >/dev/null 2>&1; then
	current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
	zsh_path="$(command -v zsh)"
	if [ "$current_shell" != "$zsh_path" ]; then
		chsh -s "$zsh_path" "$(id -un)"
	fi
fi

chmod +x ../.config/sunshine/start-vmon.sh ../.config/sunshine/stop-vmon.sh

# Run stow
echo "▶ Running stow"
cd "$(dirname "$0")/.."
stow -v -t "$HOME" */

# firewall-cmd --zone=public --permanent --add-port=47984/tcp --add-port=47989/tcp --add-port=47990/tcp --add-port=48010/tcp --add-port=47998/udp --add-port=47999/udp --add-port=48000/udp --add-port=48002/udp --add-port=48010/udp && firewall-cmd --reload
