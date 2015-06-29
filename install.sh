#!/bin/bash

########################
# TO-DO
########################
# - automate installation of applications

########################
# Create symbolic links
########################
# Make sure that our symlinks work
CWD=$(pwd)

ln -s ${CWD}/vim/vimrc ~/.vimrc
ln -s ${CWD}/vim/* ~/.vim/
rm ~/.vim/vimrc

ln -s ${CWD}/oh-my-zsh/zshenv ~/.zshenv
ln -s ${CWD}/oh-my-zsh/zshrc ~/.zshrc
ln -s ${CWD}/oh-my-zsh/alias.zsh ~/.oh-my-zsh/custom/
ln -s ${CWD}/oh-my-zsh/themes/ ~/.oh-my-zsh/custom/

ln -s ${CWD}/git/gitconfig ~/.gitconfig

# Because of limitations, we need to create the symbolic link a little
# differently in side the application support folder
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
ln -s ${CWD}/sublime-text-3/User/