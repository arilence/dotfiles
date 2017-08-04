#!/usr/bin/env bash
if [[ $OSTYPE =~ "darwin" ]]; then

./script/bootstrap.sh

./script/install-all.sh

else

echo "Sorry. I've only tested these on OSX"

fi
