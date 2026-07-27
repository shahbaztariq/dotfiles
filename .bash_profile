# required for bash on mac
eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# add `~/bin` to path
export PATH="$HOME/bin:$PATH";

# load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$path`.
# * ~/.extra can be used for other settings you don’t want to commit.
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# append to the bash history file, rather than overwriting it
shopt -s histappend;

# history: keep lots of it, deduped and timestamped
export HISTSIZE=32768;
export HISTFILESIZE="${HISTSIZE}";
export HISTCONTROL='ignoreboth:erasedups'; # no dupes or space-prefixed commands
export HISTTIMEFORMAT='%F %T  ';
export HISTIGNORE='ls:ll:la:cd:pwd:clear:history'; # keep noise commands out

# flush history after every command so it survives crashes and new tabs see it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a";

# fzf: fuzzy ctrl-r history search, ctrl-t file search, alt-c cd
# --color=16 makes fzf use the terminal theme's palette
export FZF_DEFAULT_OPTS='--color=16';
command -v fzf > /dev/null 2>&1 && eval "$(fzf --bash)";

# bat: use the terminal theme's palette instead of a bundled theme
export BAT_THEME='ansi';

# 1password shell plugins (created by `op plugin init <tool>`, e.g. gh)
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh;

# `autocd` (`**/qux` enters `./foo/bar/baz/qux`) and recursive globbing (`echo **/*.txt`)
shopt -s autocd globstar;

# tolerate minor typos in `cd` paths and directory-name completion
shopt -s cdspell dirspell;

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.bash 2>/dev/null || :

# fnm
eval "$(fnm env --use-on-cd)"