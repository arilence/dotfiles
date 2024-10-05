# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Fixes slow tab completion on WSL
# See: https://github.com/sorin-ionescu/prezto/issues/1820
unsetopt PATH_DIRS

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

# macOS Only
if [[ "$(uname)" == "Darwin" ]]; then
  # Yubikey GPG Agent (For SSH)
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent

  # Merge + Diff tool
  if [[ -d "/Applications/Araxis Merge.app/Contents/Utilities" ]]; then
    # Provides a custom `compare` command using Araxis Merge
    export PATH=$PATH:"/Applications/Araxis Merge.app/Contents/Utilities"
  fi
fi

# macOS and Linux
if [[ "$(uname)" == "Darwin" || "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  if [[ -d "$HOME/.fly" ]]; then
    export FLYCTL_INSTALL="$HOME/.fly"
    export PATH="$FLYCTL_INSTALL/bin:$PATH"
  fi

  if [[ -d "$HOME/.rye" && -f "$HOME/.rye/env" ]]; then
    source "$HOME/.rye/env"
  fi

  # Navigate faster
  eval "$(jump shell zsh)"
fi

# Linux only
if [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  fpath+=/home/linuxbrew/.linuxbrew/share/zsh/site-functions
fi

# WSL Only
if [[ ! -z "${WSL_DISTRO_NAME}" ]]; then
  alias ssh='ssh.exe'
  alias op='op.exe'
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
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
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
# Atuin - shell history recorded to a SQLite database
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

# This function must be declared after all aliases that are referenced inside it
zprezto-build-completion() {
  local completion_dir="${ZDOTDIR:-$HOME}/.zprezto/modules/completion/external/src"
  local check-command-exists() {
    command -v $1 >/dev/null 2>&1
  }

  check-command-exists flux && flux completion zsh >| "${completion_dir}/_flux"
  check-command-exists kubecm && kubecm completion zsh >| "${completion_dir}/_kubecm"
  check-command-exists kubectl && kubectl completion zsh >| "${completion_dir}/_kubectl"
  check-command-exists op && op completion zsh >| "${completion_dir}/_op"
  check-command-exists rye && rye self completion -s zsh >| "${completion_dir}/_rye"
  check-command-exists sops && curl -s -o "${completion_dir}/_sops" https://raw.githubusercontent.com/zchee/zsh-completions/main/src/go/_sops

  compinit
}

###
# Starship.rs prompt
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/starship/starship.toml"
eval "$(starship init zsh)"
