# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# TODO: Check which applications are installed first
zprezto-build-cache() {
  kubectl completion zsh >| "/usr/local/share/zsh/site-functions/_kubectl"
  kubecm completion zsh >| "/usr/local/share/zsh/site-functions/_kubecm"
  flux completion zsh >| "/usr/local/share/zsh/site-functions/_flux"
  curl -o "/usr/local/share/zsh/site-functions/_sops" https://raw.githubusercontent.com/zchee/zsh-completions/main/src/go/_sops
  op completion zsh >| "/usr/local/share/zsh/site-functions/_op"
}

# Delete completion cache and then rebuild it
zprezto-clear-cache() {
  rm -rf ~/.cache/prezto/*
  compinit
}

# Load Homebrew on both macOS and Linux
if [[ "$(uname)" == "Darwin" ]]; then
  export HOMEBREW_PREFIX="/usr/local";
  export HOMEBREW_CELLAR="/usr/local/Cellar";
  export HOMEBREW_REPOSITORY="/usr/local/Homebrew";
  export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}";
  export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="/usr/local/share/info:${INFOPATH:-}";
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi
export HOMEBREW_NO_ANALYTICS=1

# Yubikey GPG Agent on macOS (For SSH)
if [[ "$(uname)" == "Darwin" ]]; then
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent
fi

# Merge + Diff tool on macOS
if [[ "$(uname)" == "Darwin" ]]; then
  if [[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]]; then
    # Provides a custom `compare` command using Araxis Merge
    export PATH=$PATH:"/Applications/Araxis Merge.app/Contents/Utilities"
  fi
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
if [[ -f "/usr/local/bin/mise" ]]; then
  eval "$(/usr/local/bin/mise activate zsh)"
fi

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
