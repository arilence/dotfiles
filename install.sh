#!/bin/bash

########################
# Install Homebrew
########################
# Check if homebrew is already installed
if ! brew="$(type -p "brew")" || [ -z "$brew" ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install brew applications
brew bundle

########################
# Create symbolic links
########################
# Make sure that our symlinks work
CWD=$(pwd)

ln -sf ${CWD}/vim/vimrc ~/.vimrc
ln -sf ${CWD}/vim/* ~/.vim/
#rm ~/.vim/vimrc

ln -sf ${CWD}/oh-my-zsh/zshenv ~/.zshenv
ln -sf ${CWD}/oh-my-zsh/zshrc ~/.zshrc
ln -sf ${CWD}/oh-my-zsh/themes/ ~/.oh-my-zsh/custom/

ln -sf ${CWD}/git/gitconfig ~/.gitconfig

# Because of limitations, we need to create the symbolic link a little
# differently in side the application support folder
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
ln -s ${CWD}/sublime-text-3/User/
