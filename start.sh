#!/usr/bin/env bash
if [[ $OSTYPE =~ "darwin" ]]; then

./script/bootstrap.sh

# Make sure that the bootstrap succeeded before trying to install the rest
if [ $? -ne 1 ]; then
    ./script/install-all.sh

    # Do this last to set default terminal to oh-my-zsh
    chsh -s $(which zsh)
fi

else

echo "Sorry. I've only tested these on OSX"

fi
