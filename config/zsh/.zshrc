# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

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
# rtx version manager (alternative to asdf)
eval "$(rtx activate zsh)"

###
# Git
alias gs='git status'
alias gc='git commit'
alias ga='git add'

###
# Starship.rs prompt
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
eval "$(starship init zsh)"
