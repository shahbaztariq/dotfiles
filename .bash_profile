# required for bash on mac
eval "$(/opt/homebrew/bin/brew shellenv)"

# for bash completions
if type brew &>/dev/null
then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]
  then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*
    do
      [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
    done
  fi
fi

# add `~/bin` to path
export PATH="$HOME/bin:$PATH";

# add go to path
export PATH="/usr/local/go/bin:$PATH"

# araxis merge
export PATH="/Applications/Araxis\ Merge.app/Contents/Utilities:$PATH"

# mysql utils
export PATH="/opt/homebrew/opt/mysql-client@8.0/bin:$PATH"

# go home
export GOPATH=$HOME/go:/Users/shahbaz.tariq/tapjoy

# java home
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-15.jdk/Contents/Home"


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
HOME=${HOME:-'/Users/shahbaz.tariq'}
export PATH="$HOME/"'.magento-cloud/bin':"$PATH"
if [ -f "$HOME/"'.magento-cloud/shell-config.rc' ]; then . "$HOME/"'.magento-cloud/shell-config.rc'; fi # END SNIPPET
