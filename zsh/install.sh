#!/usr/bin/env bash
source ./script/utils.sh

e_header 'Installing Zsh'
if ! type_exists 'zsh'; then
    brew install zsh
    if [ $? -ne 0 ]; then
        e_error "Installation Failed!"
        exit 1
    fi
else
    e_success "You already have Zsh installed."
fi

e_header 'Trying to install Prezto'
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  if [ $? -ne 0 ]; then
    e_error "Installation Failed!"
    exit 1
  fi
  e_success "Success."
else
  e_success "Prezto is already installed."
fi

e_header 'Trying to configure Prezto'
CWD=$(pwd)
ln -sf ${CWD}/zsh/zlogin ~/.zlogin
ln -sf ${CWD}/zsh/zpreztorc ~/.zpreztorc
ln -sf ${CWD}/zsh/zprofile ~/.zprofile
ln -sf ${CWD}/zsh/zshenv ~/.zshenv
ln -sf ${CWD}/zsh/zshrc ~/.zshrc
if [ $? -ne 0 ]; then
  e_error "Configuration Failed!"
  exit 1
fi
e_success "Success."

e_header 'Trying to change default shell'
if [ $SHELL != '/bin/zsh' ]; then
  chsh -s /bin/zsh
  e_success "Success."
else
  e_success "Zsh is already default shell."
fi
