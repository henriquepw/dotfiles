# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

# Aliases
alias gf="sh $HOME/dotfiles/scripts/git-fetch.sh"
alias gz="lazygit"
alias c="clear"
alias vim="nvim"
alias ls="ls --color -a"
alias air='$(go env GOPATH)/bin/air'

source $HOME/fzf-tab-completion/bash/fzf-bash-completion.sh
bind -x '"\t": fzf_bash_completion'

eval "$(zoxide init bash)"

