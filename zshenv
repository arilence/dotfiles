###
# Loads Prezto - The configuration framework for Zsh
# (https://github.com/sorin-ionescu/prezto)
#
# You can find my actual configuration in `$ZDOTDIR/.zshenv`
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"
export ZDOTDIR="${ZDOTDIR:=$XDG_CONFIG_HOME/zsh}"
source "$ZDOTDIR/.zshenv"
