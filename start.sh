#!/usr/bin/env bash
if [[ $OSTYPE =~ "darwin" ]]; then

# Ask for the administrator password upfront
sudo -v

source ./script/bootstrap.sh

# Make sure that the bootstrap succeeded before trying to install the rest
if [ $? -ne 1 ]; then
  source ./alacritty/install.sh
  source ./editorconfig/install.sh
  source ./git/install.sh
  source ./gnupg/install.sh
  source ./python/install.sh
  source ./tmux/install.sh
  source ./vim/install.sh
  source ./zsh/install.sh
  source ./dock/install.sh
  source ./osx/install.sh
  e_success "Dotfiles has finished installing."
fi

else

echo "Sorry. I've only tested these on OSX"

fi
