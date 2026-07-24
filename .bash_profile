# required for bash on mac
eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# silence zsh warning
export BASH_SILENCE_DEPRECATION_WARNING=1

# add `~/bin` to path
export PATH="$HOME/bin:$PATH";

# ansible
export PATH="/opt/homebrew/opt/ansible@10/bin:$PATH"

# load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$path`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# colored man pages
export LESS_TERMCAP_mb=$'\e[1;31m'    # begin blinking
export LESS_TERMCAP_md=$'\e[1;34m'    # begin bold (headings)
export LESS_TERMCAP_me=$'\e[0m'       # end mode
export LESS_TERMCAP_se=$'\e[0m'       # end standout
export LESS_TERMCAP_so=$'\e[1;33;44m' # standout (search hits, status bar)
export LESS_TERMCAP_ue=$'\e[0m'       # end underline
export LESS_TERMCAP_us=$'\e[1;32m'    # underline (options, args)
export GROFF_NO_SGR=1                 # required for the above on newer groff

# append to the bash history file, rather than overwriting it
shopt -s histappend;

# history: keep lots of it, deduped and timestamped
export HISTSIZE=32768;
export HISTFILESIZE="${HISTSIZE}";
export HISTCONTROL='ignoreboth:erasedups'; # no dupes or space-prefixed commands
export HISTTIMEFORMAT='%F %T  ';

# flush history after every command so it survives crashes and new tabs see it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a";

# fzf: fuzzy ctrl-r history search, ctrl-t file search, alt-c cd
command -v fzf > /dev/null 2>&1 && eval "$(fzf --bash)";

# 1password shell plugins (created by `op plugin init <tool>`, e.g. gh)
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh;

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
