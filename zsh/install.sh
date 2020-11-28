#!/usr/bin/env bash

# Install or Update Prezto
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
#else
  # TODO: Trigger Prezto update. this function is only available in an interactive shell.
  # I think?? I'm able to run it manually, but not when inside a script.
  #zprezto-update
fi

# Change default shell to Zsh
if [ $SHELL != '/bin/zsh' ]; then
  chsh -s /bin/zsh
fi
