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
sundo dnf install -y \
	meson systemd git dbus libinih gcc pkgconf \
	stow \
	fzf \
	zoxide \
	golang \
	zig \
	rust \
	bun \
	brave \
	steam \
	protonup-qt

chmod +x ../.config/sunshine/start-vmon.sh ../.config/sunshine/stop-vmon.sh

# Run stow
echo "▶ Running stow"
cd "$(dirname "$0")/.."
stow -v -t "$HOME" */

# firewall-cmd --zone=public --permanent --add-port=47984/tcp --add-port=47989/tcp --add-port=47990/tcp --add-port=48010/tcp --add-port=47998/udp --add-port=47999/udp --add-port=48000/udp --add-port=48002/udp --add-port=48010/udp && firewall-cmd --reload
