# The bash setup for omnibytes, linked from ~/.dotfiles (see CLAUDE.md there): Homebrew's shell environment and
# bash completion, the other dotfiles, history, fzf, bat, 1Password's shell plugins, OrbStack, fnm and the banner
# in each new Ghostty tab.

eval "$(/opt/homebrew/bin/brew shellenv)";
[[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]] && . /opt/homebrew/etc/profile.d/bash_completion.sh;
case ":${PATH}:" in *":${HOME}/bin:"*) ;; *) export PATH="$HOME/bin:$PATH";; esac;   # once, even if sourced again

# load the shell dotfiles, and then some:
# * ~/.path can be used to extend `$path`.
# * ~/.extra can be used for other settings you don’t want to commit.
# * ~/.secrets holds tokens and keys (per Mac; never in this repo).
for file in ~/.{path,bash_prompt,exports,aliases,functions,extra,secrets}; do
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
[[ " ${PROMPT_COMMAND[*]:-} " == *"history -a"* ]] || PROMPT_COMMAND+=("history -a");   # once, even if sourced again

# fzf: fuzzy ctrl-r history search, ctrl-t file search, alt-c cd
# --color=16 makes fzf use the terminal theme's palette
export FZF_DEFAULT_OPTS='--color=16';
if fzf_init=$(fzf --bash 2>/dev/null); then eval "${fzf_init}"; fi; unset fzf_init;

# bat: use the terminal theme's palette instead of a bundled theme
export BAT_THEME='ansi';

# `autocd` (`**/qux` enters `./foo/bar/baz/qux`) and recursive globbing (`echo **/*.txt`)
shopt -s autocd globstar;

# tolerate minor typos in `cd` paths and directory-name completion
shopt -s cdspell dirspell;

# 1password shell plugins (created by `op plugin init <tool>`, e.g. gh)
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh;

# OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.bash 2>/dev/null || :;

# the banner in every new Ghostty tab: a login shell, so not again for a bash started inside one; not in other
# apps' terminals (Zed, VS Code)
if [[ $- == *i* && "${TERM_PROGRAM:-}" == ghostty ]] && shopt -q login_shell && command -v omnibytes-banner > /dev/null 2>&1; then
    omnibytes-banner;
fi;

# fnm (Fast Node Manager)
command -v fnm > /dev/null 2>&1 && eval "$(fnm env --use-on-cd)";
