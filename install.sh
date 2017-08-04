#!/bin/bash
source ./lib/utils.sh

# Make sure that the command line tools are installed before continuing
if ! type_exists 'gcc'; then
  if [[ $OSTYPE =~ "darwin" ]]; then
    e_error "You must install the Xcode command line tools before continuing"
  else
    e_error "Hmm.. gcc was not found on this machine, that's very strange"
  fi
  exit 1
fi

git submodule update --init --recursive


# '###############################################'
# 'Trying to install Applications with Homebrew...'
# '###############################################'
e_header "Trying to install Applications with Homebrew..."
seek_confirmation ""
if is_confirmed; then
  # Check if homebrew is installed
  if ! type_exists 'brew'; then
    e_header "Homebrew not found, Installing now..."
    # OS Dependant homebrew installation
    # darwin == osx
    if [[ $OSTYPE =~ "darwin" ]]; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
      e_header "Make sure Homebrew has writable access to /usr/local (Requires Root)"
      sudo chown -R $(whoami) /usr/local
    elif [[ $OSTYPE == "linux-gnu" ]]; then
      /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
      PATH="$HOME/.linuxbrew/bin:$PATH"
    fi
  fi

  # Install applications
  brew update
  brew bundle
else
  printf "Skipped installing applications with Homebrew\n\n"
fi


# '####################################'
# 'Trying to install NodeJS packages...'
# '####################################'
e_header "Trying to install NodeJS packages..."
seek_confirmation ""
if is_confirmed; then
  if ! type_exists 'npm'; then
    e_error "Aborting... npm was not found."
  else
    packages="n bower gulp"
    npm install $packages --global --quiet
  fi
else
  printf "Skipped installing NodeJS packages\n\n"
fi


# '####################################'
# 'Trying to install Python apps...'
# '####################################'
e_header "Trying to install Python apps..."
seek_confirmation ""
if is_confirmed; then
  if ! type_exists 'pip2'; then
    e_error "Aborting... pip2 was not found."
  else
    pip2 install -r ./python/requirements-2.txt
  fi

  if ! type_exists 'pip3'; then
    e_error "Aborting... pip3 was not found."
  else
    pip3 install -r ./python/requirements-3.txt
  fi
else
  printf "Skipped installing NodeJS packages\n\n"
fi


# '##########################################'
# 'Trying to set OSX Defaults (Requires Root)'
# '##########################################'
# OS Dependant homebrew installation
# darwin == osx
if [[ $OSTYPE =~ "darwin" ]]; then
  e_header "Trying to set OSX Defaults (Requires Root)..."
  seek_confirmation "Warning: This step may modify your OS X system defaults."
  if is_confirmed; then
    bash ./osx/set-defaults.sh
    e_success "Done. Note that some of these changes require a logout/restart to take effect."
  else
    printf "Skipped setting OSX Defaults\n\n"
  fi
fi


# '##########################'
# 'Trying to create Symbolic links...'
# '##########################'
e_header "Trying to create Symbolic links..."
seek_confirmation "This could overwrite pre-existing dotfiles"
if is_confirmed; then
  # Make sure that our symlinks work
  CWD=$(pwd)

  # Symlinks require folders to exist first
  mkdir -p ~/.config/nvim/
  mkdir -p ~/.vim/
  mkdir -p ~/.oh-my-zsh/custom/

  ln -sf ${CWD}/vim/* ~/.config/nvim/
  ln -sf ${CWD}/vim/* ~/.vim/
  ln -sf ${CWD}/vim/init.vim ~/.vimrc

  ln -sf ${CWD}/oh-my-zsh/zshrc ~/.zshrc
  ln -sf ${CWD}/oh-my-zsh/custom/* ~/.oh-my-zsh/custom/

  ln -sf ${CWD}/git/gitconfig ~/.gitconfig
  ln -sf ${CWD}/git/gitignore_global ~/.gitignore_global

  ln -sf ${CWD}/tmux/tmux.conf ~/.tmux.conf

  ln -sf ${CWD}/gnupg/*  ~/.gnupg/
fi
