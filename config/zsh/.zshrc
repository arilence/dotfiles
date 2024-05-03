# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# TODO: Check which applications are installed first
prezto_build_cache() {
  mise completion zsh >| "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_mise"
  kubectl completion zsh >| "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_kubectl"
  kubecm completion zsh >| "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_kubecm"
  docker completion zsh >| "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_docker"
  flux completion zsh >| "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_flux"
  curl -o "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_sops" https://raw.githubusercontent.com/zchee/zsh-completions/main/src/go/_sops
  op completion zsh >| "${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}/.zprezto/modules/completion/external/src/_op"
}

# Delete completion cache and then rebuild it
prezto_clear_cache() {
  rm -rf ~/.cache/prezto/*
  compinit
}

###
# Homebrew
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_PREFIX="/usr/local";
export HOMEBREW_CELLAR="/usr/local/Cellar";
export HOMEBREW_REPOSITORY="/usr/local/Homebrew";
export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}";
export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/usr/local/share/info:${INFOPATH:-}";

###
# Yubikey GPG Agent (For SSH)
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

###
# Merge + Diff tool
if [[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]]; then
  # Provides a custom `compare` command using Araxis Merge
  export PATH=$PATH:"/Applications/Araxis Merge.app/Contents/Utilities"
fi

###
# Miscellaneous Aliases
alias ls='eza --group-directories-first'

###
# Tmux
# Attaches tmux to the last session; creates a new session if none exists.
alias t='tmux attach || tmux new-session'

# Attaches tmux to a session (example: ta portal)
alias ta='tmux attach -t'

# Creates a new session
alias tn='tmux new-session'

# Lists all ongoing sessions
alias tl='tmux list-sessions'

###
# Neovim
alias vim="nvim"

###
# mise (formerly rtx, alternative to asdf)
alias mr='mise run --'
eval "$(/usr/local/bin/mise activate zsh)"

###
# Git
alias gs='git status'
alias gc='git commit'
alias ga='git add'
alias gd="git diff"
alias gl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias lg='lazygit'

###
# Starship.rs prompt
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
eval "$(starship init zsh)"
