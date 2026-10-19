#!/usr/bin/env bash
# Links the dotfiles, the Ghostty theme and the banner into ~, points Ghostty at the theme and (unless --no-brew)
# installs the Brewfile. Safe to run again. Runs under macOS's bash 3.2, as a fresh Mac has no other yet.
# Nothing in ~ is deleted: a file in the way is moved to <file>.pre-dotfiles (.2, .3… if taken), and a file that
# gets edited is first copied to <file>.bak-dotfiles. An identical copy, or a link already pointing here, is just
# replaced.

set -e

brew=1
for arg in "$@"; do
    case "$arg" in
        --no-brew) brew=0 ;;
        *) echo "usage: $0 [--no-brew]" >&2; exit 2 ;;
    esac
done

echo "Installing dotfiles"

DOTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
THEME='Lab Sunset Rally'
HOST=omnibytes   # this branch is this Mac's only, so the banner folder is fixed (banner/hosts/omnibytes)

# the first of <path>, <path>.2, <path>.3… that doesn't exist
free_name() {
    local p=$1 n=1
    while [ -e "$p" ] || [ -L "$p" ]; do n=$((n + 1)); p="$1.$n"; done
    echo "$p"
}

# link <source> <target>: make <target> a symlink to <source>, keeping whatever was there
link() {
    local src=$1 dst=$2 kept
    [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ] && return 0
    if [ -f "$dst" ] && [ ! -L "$dst" ] && cmp -s "$src" "$dst"; then
        rm "$dst"
    elif [ -e "$dst" ] || [ -L "$dst" ]; then
        kept=$(free_name "$dst.pre-dotfiles")
        mv "$dst" "$kept"
        echo "  kept the old $dst as $kept"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  linked $dst"
}

# --- dotfiles ---------------------------------------------------------------------------------------------------
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
    link "$DOTDIR/$file" ~/"$file"
done

# ~/.secrets is per Mac and never in the repo. Older installs kept it here, linked from ~: move it out, as nothing
# stops git from picking it up any more.
if [ -L ~/.secrets ] && [ "$(readlink ~/.secrets)" = "$DOTDIR/.secrets" ] && [ -f "$DOTDIR/.secrets" ]; then
    mv "$DOTDIR/.secrets" ~/.secrets
    chmod 600 ~/.secrets
    echo "  moved $DOTDIR/.secrets to ~/.secrets"
fi
[ -f ~/.secrets ] || echo "  no ~/.secrets: copy it over from another Mac (it isn't in this repo)"

# --- the banner: in every new Ghostty tab (.bash_profile); its colours also shade the prompt (.bash_prompt) --------
link "$DOTDIR/banner/lab-banner" ~/bin/lab-banner
if [ -d "$DOTDIR/banner/hosts/$HOST" ]; then
    for f in banner.conf art.txt art-small.txt; do
        [ -e "$DOTDIR/banner/hosts/$HOST/$f" ] && link "$DOTDIR/banner/hosts/$HOST/$f" ~/.config/lab-banner/"$f"
    done
else
    echo "  no banner/hosts/$HOST: the banner shows the plain host name and the prompt keeps the theme's colours"
fi
# macOS's "Last login: … on ttys…" line, which the banner replaces
[ -e ~/.hushlogin ] || { touch ~/.hushlogin; echo "  created ~/.hushlogin"; }

# --- Ghostty: the theme, and `theme = …` in the config file that wins --------------------------------------------
xdg="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"   # where Ghostty looks for themes and its first config files
link "$DOTDIR/ghostty/themes/$THEME" "$xdg/themes/$THEME"

# Ghostty on macOS reads these in order, so a later one wins
app="$HOME/Library/Application Support/com.mitchellh.ghostty"
configs=()
for f in "$xdg/config" "$xdg/config.ghostty" "$app/config" "$app/config.ghostty"; do
    [ -f "$f" ] && configs+=("$f")
done
themed=()
for f in "${configs[@]}"; do
    grep -qE '^[[:space:]]*theme[[:space:]]*=' "$f" && themed+=("$f")
done

if [ ${#themed[@]} -gt 0 ]; then
    target=${themed[${#themed[@]} - 1]}
elif [ ${#configs[@]} -gt 0 ]; then
    target=${configs[${#configs[@]} - 1]}
else
    target="$xdg/config"
fi

# the last theme line is the one Ghostty uses
if [ -f "$target" ] && grep -E '^[[:space:]]*theme[[:space:]]*=' "$target" | tail -1 | grep -qE "=[[:space:]]*${THEME}[[:space:]]*\$"; then
    echo "  Ghostty already uses $THEME ($target)"
elif [ -f "$target" ]; then
    kept=$(free_name "$target.bak-dotfiles")
    cp -p "$target" "$kept"
    if grep -qE '^[[:space:]]*theme[[:space:]]*=' "$target"; then
        sed -E "s/^[[:space:]]*theme[[:space:]]*=.*/theme = $THEME/" "$kept" > "$target"   # through a symlink too
    else
        printf '\ntheme = %s\n' "$THEME" >> "$target"
    fi
    echo "  set theme = $THEME in $target (the old one is $kept)"
else
    mkdir -p "$xdg"
    echo "theme = $THEME" > "$target"
    echo "  created $target with theme = $THEME"
fi

# left for you to decide: other theme lines, colours set directly (they override the theme), included files
for f in "${configs[@]}"; do
    [ "$f" = "$target" ] && continue
    grep -qE '^[[:space:]]*theme[[:space:]]*=' "$f" && echo "  note: $f also sets a theme (overridden by $target)"
done
for f in "${configs[@]}"; do
    grep -nE '^[[:space:]]*(background|foreground|palette|cursor-color|cursor-text|selection-background|selection-foreground)[[:space:]]*=' "$f" \
        | sed "s|^|  note: overrides the theme's colours: $f:|" || true
    grep -nE '^[[:space:]]*config-file[[:space:]]*=' "$f" | sed "s|^|  note: includes another file (check it too): $f:|" || true
done

ghostty=/Applications/Ghostty.app/Contents/MacOS/ghostty
if [ -x "$ghostty" ]; then
    # captured, not passed through: with its output going to a file, ghostty truncates that file (a log of this run)
    if out=$("$ghostty" +validate-config 2>&1); then
        echo "  Ghostty accepts its config"
    else
        echo "  WARNING: Ghostty doesn't accept its config:"; echo "$out" | sed 's/^/    /'
    fi
else
    echo "  Ghostty isn't installed; the theme takes effect once it is"
fi

# --- packages ---------------------------------------------------------------------------------------------------
if ((!brew)); then
    echo "Skipping the Brewfile (--no-brew)"
elif command -v brew > /dev/null 2>&1; then
    echo "Installing Brewfile packages"
    brew bundle --file="$DOTDIR/Brewfile"
else
    echo "Homebrew not found - install it, then run: brew bundle --file=$DOTDIR/Brewfile"
fi

echo "Done. Still to do by hand (CLAUDE.md, 'Setting up this Mac from scratch', steps 4-6):"
# the login shell, unless it's Homebrew's bash already (dscl's output is "UserShell: /path")
shell=$(dscl . -read ~ UserShell 2>/dev/null | awk '{print $2}')
[ "$shell" = /opt/homebrew/bin/bash ] \
    || echo "  - login shell: Homebrew's bash (add /opt/homebrew/bin/bash to /etc/shells, then chsh to it; needs sudo)"
echo "  - 1Password: sign in, Settings > Developer > CLI integration and SSH agent, then: op plugin init gh"
[ -f ~/.secrets ] || echo "  - ~/.secrets: copy it over from a backup"
echo "  - reload Ghostty's config (Cmd+Shift+,) and open a new tab"
