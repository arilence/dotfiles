#!/usr/bin/env bash
if [[ $OSTYPE =~ "darwin" ]]; then

./script/bootstrap.sh

# Do this lsat to set default terminal to oh-my-zsh
env zsh -l

else

echo "Sorry. I've only tested these on OSX"

fi
