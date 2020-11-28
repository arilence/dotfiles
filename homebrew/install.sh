#!/usr/bin/env bash
if test ! $(which gcc) || test ! $(which brew); then
  return
fi

brew update
brew upgrade
brew bundle --file=$DOTFILES_HOME/homebrew/Brewfile
brew cleanup
