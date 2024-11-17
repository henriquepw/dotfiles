# Path
export PATH=$PATH:$HOME/bin:$HOME/.local/bin

# Java and Android
export JAVA_HOME=`/usr/libexec/java_home`
export ANDROID_HOME="$HOME/android/sdk"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Go lang
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# Docker
export DOCKER_DEFAULT_PLATFORM="linux/amd64"

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

# fzf
export PATH=$PATH:$HOME/.fzf/bin
[[ ! -f ~/.fzf.zsh ]] || source ~/.fzf.zsh

# Aliases
alias gf="sh ~/dotfiles/scripts/git-fetch.sh"
alias gz="lazygit"
alias c="clear"
alias vim="nvim"
alias ls="ls --color -a"
alias air='$(go env GOPATH)/bin/air'

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
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(zoxide init --cmd cd zsh)"
eval "$(starship init zsh)"

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# bun completions
[ -s "/Users/henrique/.bun/_bun" ] && source "/Users/henrique/.bun/_bun"
