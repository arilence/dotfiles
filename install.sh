#!/bin/bash

########################
# TO-DO
########################
# - automate installation of applications

########################
# Create symbolic links
########################
CWD=$(pwd)

ln -s vimrc ~/.vimrc
ln -s zshrc ~/.zshrc
ln -s vim/* ~/.vim/
ln -s oh-my-zsh/alias.zsh ~/.oh-my-zsh/custom/
ln -s oh-my-zsh/themes/ ~/.oh-my-zsh/custom/
ln -s gitconfig ~/.gitconfig

# Because of limitations, we need to create the symbolic link a little
# differently in side the application support folder
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
ln -s ${CWD}/sublime-text-3/User/