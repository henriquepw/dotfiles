export PATH=$HOME/bin:/usr/local/bin:$PATH

# Java and Android
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home"
export ANDROID_HOME="/Users/henrique/Library/Android/sdk"
export ANDROID_SDK_ROOT="/Users/henrique/Library/Android/sdk"

export PATH="$PATH:$HOME/Android/android-studio/bin"
export PATH="$PATH:$ANDROID_HOME/emulator"
export PATH="$PATH:$ANDROID_HOME/tools"
export PATH="$PATH:$ANDROID_HOME/tools/bin"
export PATH="$PATH:$ANDROID_HOME/platform-tools"
export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"

# Go lang
export PATH="$PATH:/Users/henrique/go/bin"

# Docker
export DOCKER_DEFAULT_PLATFORM="linux/amd64"

# Homebrew
export PATH=/opt/homebrew/bin:$PATH
export HOMEBREW_NO_INSTALL_FROM_API=1

# Yarn
export PATH="$PATH:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin"

# Node
export NODE_OPTIONS="--max_old_space_size=4096"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

# NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Alias
alias gf="sh ~/dotfiles/scripts/git-fetch.sh"
alias gz="lazygit"

# Init starship
eval "$(starship init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zinit
ZINIT=$HOME/.zinit 

if [[ ! -f $ZINIT/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$ZINIT" && command chmod g-rwX "$ZINIT"
    command git clone https://github.com/zdharma/zinit "$ZINIT/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$ZINIT/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light-mode for \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-bin-gem-node

zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions
zinit light buonomo/yarn-completion

# Init Tmux
[ -z "$TMUX" ] && exec tmux -a