#!/usr/bin/env bash

echo "Installing DotFiles"

DOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf $DOTDIR/.gitconfig
rm -rf $DOTDIR/.githelpers
rm -rf $DOTDIR/.globalignore

ln -nfs $DOTDIR/.gitconfig ~/
ln -nfs $DOTDIR/.githelpers ~/
ln -nfs $DOTDIR/.globalignore ~/
