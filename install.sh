#!/bin/bash

echo '####################'
echo 'Setting OSX Defaults'
echo 'This part requires root, so you will be asked for your password'
echo '####################'
./osx/set-defaults.sh


echo '########################################'
echo 'Installing Applications with Homebrew...'
echo '########################################'
# Check if homebrew is already installed
if ! brew="$(type -p "brew")" || [ -z "$brew" ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Install brew applications
brew bundle


echo '##########################'
echo 'Creating Symbolic Links...'
echo '##########################'
# Make sure that our symlinks work
CWD=$(pwd)

ln -sf ${CWD}/vim/vimrc ~/.vimrc
ln -sf ${CWD}/vim/* ~/.vim/
ln -sf ${CWD}/oh-my-zsh/zshenv ~/.zshenv
ln -sf ${CWD}/oh-my-zsh/zshrc ~/.zshrc
ln -sf ${CWD}/oh-my-zsh/themes/ ~/.oh-my-zsh/custom/
ln -sf ${CWD}/git/gitconfig ~/.gitconfig

# For some odd reason, I can't use the ${CWD} variable in this command.
ln -sf ~/dotfiles/sublime-text-3/* ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/User/
