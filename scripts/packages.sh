#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

echo "▶ Installing NVM"
if ! command -v nvm >/dev/null 2>&1; then
	curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

echo "▶ Installing paru"
if ! command -v paru >/dev/null 2>&1; then
	sudo pacman -S --needed --noconfirm base-devel git
	paru_build_dir="$(mktemp -d)"
	git clone https://aur.archlinux.org/paru.git "$paru_build_dir/paru"
	(
		cd "$paru_build_dir/paru"
		makepkg -si --noconfirm
	)
fi

echo "▶ Installing fzf-tab-completion"
if [ ! -d "$HOME/fzf-tab-completion" ]; then
	git clone https://github.com/lincheney/fzf-tab-completion "$HOME/fzf-tab-completion"
fi

echo "▶ Installing packages"
# Omarchy is based on Arch Linux. paru handles packages from both the official
# repositories and the AUR.
arch_packages=(
	# Base and dotfiles
	meson systemd git dbus libinih gcc pkgconf stow make

	# Shell and terminal
	zsh foot tmux starship bat btop fzf ripgrep fd jq fastfetch
	git-delta tree unzip zoxide chafa libsixel

	# Development
	npm bun go zig rustup watchexec neovim clang gcc

	# Android development
	android-tools android-udev android-sdk-cmdline-tools-latest
	android-sdk-build-tools android-platform jdk17-openjdk

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
	protonplus kdeconnect

	# Desktop applications
	brave-origin-bin freecad orca-slicer onlyoffice-bin hushmic-bin
	sable-bin hydra-launcher-bin

	# Services used by the NixOS modules
	podman tailscale syncthing keyd networkmanager bluez
	pipewire wireplumber power-profiles-daemon openssh
)

if ! command -v paru >/dev/null 2>&1; then
	echo "✖ paru is required to install packages on Omarchy/Arch Linux." >&2
	exit 1
fi

paru -S --needed --noconfirm "${arch_packages[@]}"

echo "▶ Setting Zsh as the default login shell"
if command -v zsh >/dev/null 2>&1 && command -v chsh >/dev/null 2>&1; then
	current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
	zsh_path="$(command -v zsh)"
	if [ "$current_shell" != "$zsh_path" ]; then
		chsh -s "$zsh_path" "$(id -un)"
	fi
fi

chmod +x "$REPO_ROOT/.config/sunshine/start-vmon.sh" "$REPO_ROOT/.config/sunshine/stop-vmon.sh"
