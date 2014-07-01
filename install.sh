#!/usr/bin/env bash

echo "Installing DotFiles"

DOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf ~/.gitconfig
rm -rf ~/.githelpers
rm -rf ~/.globalignore

ln -nfs $DOTDIR/.gitconfig ~/
ln -nfs $DOTDIR/.githelpers ~/
ln -nfs $DOTDIR/.globalignore ~/
