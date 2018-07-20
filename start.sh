#!/usr/bin/env bash
if [[ $OSTYPE =~ "darwin" ]]; then

./script/bootstrap.sh

./script/install-all.sh

# Do this last to set default terminal to oh-my-zsh
chsh -s $(which zsh)

else

echo "Sorry. I've only tested these on OSX"

fi
