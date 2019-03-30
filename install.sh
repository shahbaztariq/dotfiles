#!/usr/bin/env bash

echo "Installing DotFiles"

DOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -rf ~/.aliases
rm -rf ~/.bash_profile
rm -rf ~/.bash_prompt
rm -rf ~/.bashrc
rm -rf ~/.functions
rm -rf ~/.gitconfig
rm -rf ~/.globalignore
rm -rf ~/.inputrc

ln -nfs $DOTDIR/.aliases ~/
ln -nfs $DOTDIR/.bash_profile ~/
ln -nfs $DOTDIR/.bash_prompt ~/
ln -nfs $DOTDIR/.bashrc ~/
ln -nfs $DOTDIR/.functions ~/
ln -nfs $DOTDIR/.gitconfig ~/
ln -nfs $DOTDIR/.globalignore ~/
ln -nfs $DOTDIR/.inputrc ~/
