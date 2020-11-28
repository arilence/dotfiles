#!/usr/bin/env bash
if test -f $HOME/.gitconfig; then
  return
fi

printf "Git: Enter your fullname [ENTER]: "
read GIT_FULLNAME
printf "Git: Enter your email [ENTER]: "
read GIT_EMAIL

cp $DOTFILES_HOME/git/gitconfig.symlink.example $HOME/.gitconfig

# Double check the `cp` worked
if test -f $HOME/.gitconfig; then
  if [[ $OSTYPE =~ "darwin" ]]; then
    # sed's "in-place" editing doesn't work very well on macOS.
    # Instead .gitconfig.bak is created and then deleted after changes have finished.
    sed -i .bak "s/GIT_FULLNAME/$GIT_FULLNAME/g" $HOME/.gitconfig
    sed -i .bak "s/GIT_EMAIL/$GIT_EMAIL/g" $HOME/.gitconfig
    rm $HOME/.gitconfig.bak
  elif [[ $OSTYPE =~ "linux" ]]; then
    sed -i "s/GIT_FULLNAME/$GIT_FULLNAME/g" $HOME/.gitconfig
    sed -i .bak "s/GIT_EMAIL/$GIT_EMAIL/g" $HOME/.gitconfig
  fi
fi
