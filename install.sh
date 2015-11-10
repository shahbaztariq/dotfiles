#!/usr/bin/env bash

echo "Installing DotFiles"

DOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf ~/.gitconfig
rm -rf ~/.globalignore
rm -rf ~/.bash_profile
rm -rf ~/.bash_prompt
rm -rf ~/.aliases
rm -rf ~/.inputrc

ln -nfs $DOTDIR/.gitconfig ~/
ln -nfs $DOTDIR/.globalignore ~/
ln -nfs $DOTDIR/.bash_profile ~/
ln -nfs $DOTDIR/.bash_prompt ~/
ln -nfs $DOTDIR/.aliases ~/
ln -nfs $DOTDIR/.inputrc ~/
