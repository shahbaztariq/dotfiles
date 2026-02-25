# required for bash on mac
eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# silence zsh warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# add `~/bin` to path
export PATH="$HOME/bin:$PATH";

# araxis merge
export PATH="/Applications/Araxis\ Merge.app/Contents/Utilities:$PATH"

# mysql utils
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

# ansible
export PATH="/opt/homebrew/opt/ansible@10/bin:$PATH"

# load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$path`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# append to the bash history file, rather than overwriting it
shopt -s histappend;

# enable some bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
    shopt -s "$option" 2> /dev/null;
done;

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# BEGIN SNIPPET: Magento Cloud CLI configuration
HOME=${HOME:-'/Users/shahbaz'}
export PATH="$HOME/"'.magento-cloud/bin':"$PATH"
if [ -f "$HOME/"'.magento-cloud/shell-config.rc' ]; then . "$HOME/"'.magento-cloud/shell-config.rc'; fi
# END SNIPPET
