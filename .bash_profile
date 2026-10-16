# The bash setup for every machine: the Macs link to this file, the servers get a copy. Managed by the lab repo
# (role dotfiles). Where macOS and Linux differ: on macOS Homebrew (its shell environment and bash completion),
# Ansible's path, 1Password's shell plugins, OrbStack and the lab banner in each new Ghostty tab; on Linux the system bash completion and ~/.local/bin, which
# the distro's own ~/.profile (kept there as ~/.profile.distro) used to provide.

if [[ "${OSTYPE}" == darwin* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)";
    [[ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]] && . /opt/homebrew/etc/profile.d/bash_completion.sh;
    export PATH="$HOME/bin:/opt/homebrew/opt/ansible@10/bin:$PATH";
else
    [[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion;
    export PATH="$HOME/bin:$HOME/.local/bin:$PATH";
fi;

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

if [[ "${OSTYPE}" == darwin* ]]; then
    # 1password shell plugins (created by `op plugin init <tool>`, e.g. gh)
    [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh;
    # OrbStack: command-line tools and integration
    source ~/.orbstack/shell/init.bash 2>/dev/null || :;
    # the lab banner in every new Ghostty tab (role mac): a login shell, so not again for a bash started inside one;
    # not in tmux, nor in other apps' terminals (Zed, VS Code)
    if [[ $- == *i* && "${TERM_PROGRAM:-}" == ghostty && -z "${TMUX:-}" ]] && shopt -q login_shell \
        && command -v lab-banner > /dev/null 2>&1; then
        lab-banner;
    fi;
fi;

# fnm (Fast Node Manager)
command -v fnm > /dev/null 2>&1 && eval "$(fnm env --use-on-cd)";
