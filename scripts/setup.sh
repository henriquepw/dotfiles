#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

git clone https://github.com/lincheney/fzf-tab-completion $HOME/fzf-tab-completion

yay -Sy --noconfirm \
  stow \
  fzf \
  zoxide \
  go \
  zig \
  rust \
  bun \
  brave \
  protonplus \
  lutris \

cd .. && stow .
