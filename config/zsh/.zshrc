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

# macOS and Linux
if [[ "$(uname)" == "Darwin" || "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  if [[ -d "$HOME/.fly" ]]; then
    export FLYCTL_INSTALL="$HOME/.fly"
    export PATH="$FLYCTL_INSTALL/bin:$PATH"
  fi
fi

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

# Linux only
else
  fpath+=/home/linuxbrew/.linuxbrew/share/zsh/site-functions
fi

# WSL Only
if [[ ! -z "${WSL_DISTRO_NAME}" ]]; then
  alias ssh='ssh.exe'
  alias op='op.exe'
fi

# Some applications install themselves inside here
export PATH="$HOME/.local/bin:$PATH"

###
# Miscellaneous Aliases
alias ls='eza --group-directories-first'
alias c='clear'

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

# Must be called before zoxide init
autoload -Uz compinit && compinit

###
# fzf
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

###
# zoxide "a smarter cd command"
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh --cmd j)"
fi

###
# Atuin - shell history recorded to a SQLite database
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi

###
# pnpm - node package manager
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

###
# Helper functions

# Reminder to update at least once a week
LAST_UPDATE_TIME_FILE="$HOME/.last_update_time_file"
dotfiles-update() {
  echo "Running brew upgrade"; brew upgrade || exit $?
  echo "Running zprezto update"; zprezto-update || exit $?
  echo "Running nvim plugin update"; nvim --headless "+Lazy! update" +qa || exit $?
  echo "Running mise upgrade"; mise upgrade || exit $?

  # Update the last run timestamp
  date +%s >! "$LAST_UPDATE_TIME_FILE"
}
# Check if it's been 7 days or more since last running the update command
if [ ! -f "$LAST_UPDATE_TIME_FILE" ] || [ $(( $(date +%s) - $(cat "$LAST_UPDATE_TIME_FILE") )) -gt $(( 7 * 24 * 60 * 60 )) ]; then
  echo "It's been over a week since the last update check.\nRun $ dotfiles-update to check for updates."
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
