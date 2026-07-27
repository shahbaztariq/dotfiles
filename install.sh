#!/usr/bin/env bash

set -e

echo "Installing dotfiles"

DOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

files=(
    .aliases
    .bash_profile
    .bash_prompt
    .bashrc
    .exports
    .functions
    .gitconfig
    .globalignore
    .inputrc
)

for file in "${files[@]}"; do
    rm -rf ~/"$file"
    ln -nfs "$DOTDIR/$file" ~/
done

# install packages if homebrew is available
if command -v brew > /dev/null 2>&1; then
    echo "Installing Brewfile packages"
    brew bundle --file="$DOTDIR/Brewfile"
else
    echo "Homebrew not found - install it, then run: brew bundle --file=$DOTDIR/Brewfile"
fi

echo "Done. Remaining manual steps (see README.md):"
echo "  1. Add homebrew bash to /etc/shells and chsh to it"
echo "  2. Sign in to 1Password and enable CLI integration (Settings > Developer)"
