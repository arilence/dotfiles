#!/usr/bin/env bash
if [[ $OSTYPE =~ "darwin" ]]; then

# Ask for the administrator password upfront
sudo -v

./script/bootstrap.sh

# Make sure that the bootstrap succeeded before trying to install the rest
if [ $? -ne 1 ]; then
    ./script/install-all.sh
fi

else

echo "Sorry. I've only tested these on OSX"

fi
