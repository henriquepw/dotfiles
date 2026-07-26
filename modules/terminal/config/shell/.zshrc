# Path
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

export YDOTOOL_SOCKET=/tmp/.ydotool_socket

# Aliases
alias gf="git-fetch.sh"
alias gz="lazygit"
alias c="clear"
alias vim="nvim"
alias ls="ls --color -a"
alias rebuild="sudo nixos-rebuild switch --flake ~/.dotfiles#citadel"
alias update="nix flake update --flake ~/.dotfiles && sudo nixos-rebuild switch --flake ~/.dotfiles#citadel"
alias cleanup-generations="sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system && sudo nix-collect-garbage && sudo nixos-rebuild boot --flake ~/.dotfiles#citadel"

ZINIT="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT ] && mkdir -p "$(dirname $ZINIT)"
[ ! -d $ZINIT/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT"
source "${ZINIT}/zinit.zsh"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

autoload -U compinit && compinit
zinit cdreplay -q

bindkey '^l' forward-char
bindkey '^k' history-search-backward
bindkey '^j' history-search-forward

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Shell integrations
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

if command -v tmux >/dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux new-session -A -s main
fi
