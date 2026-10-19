# dotfiles: instructions for an agent

This repo is the bash setup, the Ghostty theme and the login banner for the user's Macs. Everything is symlinked
into `~` by `install.sh`, so an edit here takes effect in the next new shell. It is the source of truth on these
Macs: change files here, not the links in `~`.

## Branches

**One branch per Mac, named after it (`hostname -s`), and each stands alone.** This branch, `omnibytes`, is this
work laptop's and nothing else's: it isn't a template for other Macs, and this file describes this Mac only. Work
on it, commit and push to it, and **never merge into `main`** or into another branch. Don't suggest merging or
opening pull requests.

What a Mac gets once it's applied:

1. **The Ghostty theme Lab Sunset Rally**: a plum background (`#1b1026`), warm text, a sunset-orange cursor
   (`#ff8a3d`).
2. **The lab banner** in every new Ghostty tab: the host name in big pink-to-violet letters, a tagline, and a live
   readout (chip, macOS, uptime and load, battery, memory, disk, network).
3. **The bash setup**: the prompt `user at host in dir on branch [+!?$]`, with `user at host` in the banner's
   gradient, `✘ <status>` after a failure and `took <time>` after a command of 5 s or more; a desktop notification
   when a command of 30 s or more finishes; history (32k lines, deduped, timestamped, saved after every command);
   `autocd`, `globstar`, typo-tolerant `cd`; readline settings; aliases (`..`, `ll`, `la`…), `mkd`; fzf, eza, bat,
   bash-completion when installed; 1Password shell plugins, OrbStack and fnm when present; `~/.secrets` loaded.

## Layout

| In the repo | Linked to | Notes |
|---|---|---|
| `.bash_profile`, `.bashrc`, `.bash_prompt`, `.aliases`, `.functions`, `.exports`, `.inputrc` | `~/.<same>` | the bash setup |
| `.gitconfig`, `.globalignore` | `~/.<same>` | git |
| `ghostty/themes/Lab Sunset Rally` | `~/.config/ghostty/themes/Lab Sunset Rally` (under `$XDG_CONFIG_HOME` instead, if set) | the name, spaces included, is what `theme =` refers to |
| `banner/lab-banner` | `~/bin/lab-banner` | runs in each new Ghostty tab (`.bash_profile`) |
| `banner/hosts/omnibytes/{banner.conf,art.txt,art-small.txt}` | `~/.config/lab-banner/` | this Mac's banner; the folder name is hardcoded in `install.sh` |
| `Brewfile` | | packages the setup uses |
| | `~/.hushlogin` | created if missing: silences macOS's "Last login" line, which the banner replaces |
| `install.sh` | | does all of the above; safe to run again |

`.bash_profile` loads, in order: Homebrew's environment and bash completion, `~/bin` on PATH, then
`~/.{path,bash_prompt,exports,aliases,functions,extra,secrets}` if they exist, then the history, fzf, bat and
`shopt` settings, 1Password plugins, OrbStack, the banner, and fnm. `~/.path`, `~/.extra` and `~/.secrets` are
per-machine files, not in the repo. Settings in `~/.extra` that `.bash_profile` sets again later (history, `FZF_DEFAULT_OPTS`,
`BAT_THEME`, `shopt`s) are overridden.

`.bashrc` only sources `.bash_profile` (for non-login shells); every Ghostty tab is a login shell.

All the shell's colours come from the terminal's ANSI palette (the banner's and the prompt's names excepted), so
fzf (`--color=16`), bat (`BAT_THEME=ansi`), completion colours and the prompt follow whatever Ghostty theme is active.

### Using it

- **Prompt markers** after the branch: `+` staged, `!` unstaged, `?` untracked, `$` stashed. In a huge, slow repo,
  `git config bash.showDirtyState false` turns them off for that repo (the branch still shows).
- **fzf**: Ctrl-R fuzzy history, Ctrl-T fuzzy file paths, Alt-C fuzzy cd. ↑/↓ search history by what's typed
  (`.inputrc`).
- **History** is flushed after every command, so it survives a crash and new tabs see other tabs' commands.
  `ls`, `ll`, `la`, `cd`, `pwd`, `clear` and `history` aren't kept, nor is a command typed with a leading space.
- `LAB_NOTIFY_AFTER=<seconds>` changes when the desktop notification fires (default 30). Editors, pagers, `ssh`,
  `claude`, followed logs and the like never notify.

### Git (`.gitconfig`, `.globalignore`)

- Every commit is SSH-signed through 1Password (`op-ssh-sign`), so a commit **fails if 1Password is locked or
  missing**. Unlock it rather than turning signing off.
- `https://github.com/` URLs are rewritten to SSH. `push` sets up the upstream itself, `fetch` prunes, `rebase`
  autostashes, `rerere` replays conflict resolutions, and merges use `zdiff3` conflict markers.
- The pager is delta (line numbers, moved code shown distinctly). Meld is the difftool and mergetool.
- Aliases: `st` (short status), `co`, `ci`, `br`, `cl`, `cf` (files changed in a commit), `cleanup` (prune, gc,
  `clean -df`, **and drops every stash**), and `assume`/`unassume`/`assumed`/`assumeall`/`unassumeall` to ignore
  local changes to tracked files.
- `.globalignore` is the global gitignore (`.DS_Store`, IDE folders, `.claude/settings.local.json`).

### Secrets

- `~/.secrets` exports API tokens at shell startup (`.bash_profile` sources it). It's a plain file in `~`, mode
  600, and **never in this repo**: nothing in `.gitignore` would stop git committing it. Copy it to a new Mac by
  hand, and never print it. `install.sh` moves an old `~/.dotfiles/.secrets` (linked from `~`) out to `~/.secrets`.
- Other secrets live in the 1Password item **"dotfiles secrets"** in the Private vault, fetched only when needed:
  `op read 'op://Private/dotfiles secrets/<field>'` (for example `ghcr_pat`). `gh` authenticates through the
  1Password shell plugin (Touch ID when used).
- `.exports` is for non-secret variables only.

## Setting up this Mac from scratch

If omnibytes is ever wiped. The user does the steps that need a password, `sudo` or a sign-in. An agent can do
the rest.

1. **Homebrew** (user): `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
2. **Clone this branch**: `git clone -b omnibytes git@github.com:shahbaztariq/dotfiles.git ~/.dotfiles` (needs a
   GitHub SSH key, which 1Password's SSH agent provides once signed in. Otherwise clone over HTTPS).
3. **Install**: `cd ~/.dotfiles && ./install.sh`. This also runs `brew bundle`, so ask first, and on `omnibytes` use
   `--no-brew`. See "Applying it to a Mac" below.
4. **Login shell to Homebrew's bash 5** (user; `sudo`). macOS's bash 3.2 can't run this setup:

   ```sh
   sudo sh -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
   chsh -s /opt/homebrew/bin/bash
   ```

5. **1Password** (user): sign in to the app, turn on Settings → Developer → CLI integration and the SSH agent,
   then `op plugin init gh`.
6. **`~/.secrets`** (user): copy it over from another Mac, then `chmod 600 ~/.secrets`.

`Brewfile` lists only what the setup depends on. For a snapshot of everything on a Mac,
`brew bundle dump --file=Brewfile.full` (don't commit it).

## Applying it to a Mac

### Rules

- **Nothing the user has now may be lost.** `install.sh` moves a file in its way to `<file>.pre-dotfiles` (then
  `.pre-dotfiles.2`…), and copies a Ghostty config to `<file>.bak-dotfiles` before editing it. The one exception:
  a regular file identical to the repo's copy is replaced by the link without a backup, as nothing is lost. Do the
  same for anything you change by hand, such as `~/.extra`.
- **Never print secret values** (tokens, passwords, keys), from `~/.secrets` or anywhere else. Refer to them by
  variable name. To check one is set: `[ -n "${!v}" ] && echo "$v: set"`. Never copy `~/.secrets` into the repo.
- No `sudo`. Don't touch Ghostty settings other than `theme`, zsh files or system settings.
- **`omnibytes` is the employer's work laptop: install nothing there.** Run `./install.sh --no-brew`. On any other
  Mac, ask the user before running `./install.sh` without `--no-brew`, because `brew bundle` installs and upgrades
  packages.

### 0. Check first; stop and tell the user if any fails

```sh
ls -d /Applications/Ghostty.app                                          # Ghostty is installed
dscl . -read ~ UserShell                                                 # should be /opt/homebrew/bin/bash
"$(dscl . -read ~ UserShell | awk '{print $2}')" --version | head -1     # bash 5.x
ls /opt/homebrew/bin/brew                                                # .bash_profile loads Homebrew's environment from here
/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config | grep '^command '   # if set, it must be a bash 5 too
```

A login shell that isn't Homebrew's bash is fixed by the user (from-scratch step 4 needs `sudo`), not by you.

### 1. Read what's there now

Before running anything, look at `~/.bash_profile`, `~/.bashrc`, `~/.profile`, `~/.inputrc`, and any of
`~/.bash_prompt`, `~/.aliases`, `~/.functions`, `~/.exports`, `~/.path`, `~/.extra`, `~/.secrets` that exist. Note
for each whether it's a regular file or a link (and to where). If they're already links into this repo, the Mac is
set up and `install.sh` only adds what's missing. Otherwise, compare them with the repo's files
(`diff -u ~/.bash_profile ~/.dotfiles/.bash_profile`) and list what the user has that the repo doesn't.

Also check: is the user's history file longer than 32768 lines (`wc -l ~/.bash_history`)? `HISTFILESIZE` would trim
it, so copy it to `~/.bash_history.pre-dotfiles` first. Do they set `HISTFILE`? If so, carry that line over.

### 2. Run the installer

```sh
cd ~/.dotfiles && ./install.sh --no-brew     # without --no-brew only where the user agreed
```

It prints each link it makes, each file it keeps aside, the Ghostty config it edits, and notes about things it
leaves to the user: another config that also sets a theme, colours set directly in the config (`background`,
`palette`, `cursor-color`… override the theme), and `config-file =` includes. Don't remove those colour lines;
list them for the user and ask.

### 3. Carry over the user's own settings into `~/.extra`

From the files that were moved aside (`*.pre-dotfiles`), and `~/.profile` if it was in use, move into `~/.extra`
everything that sets up the user's work: PATH additions, environment variables, tool setup (nvm, pyenv, rbenv,
sdkman, conda, direnv, asdf, mise, gcloud, aws, kubectl completions…), their own aliases and functions, and
`source` lines for other files. Back up an existing `~/.extra` first. Leave these out and list them for the user:

- lines that source `~/.bashrc` or `~/.bash_profile`: `~/.bashrc` sources `~/.bash_profile`, which sources
  `~/.extra`, so a copy would loop;
- `PS1`, `PROMPT_COMMAND`, prompt frameworks (starship, oh-my-bash, bash-it, powerline): they'd replace this
  prompt. Ask the user;
- what `.bash_profile` already does: `brew shellenv`, Homebrew bash completion, fzf, 1Password `plugins.sh`,
  OrbStack's `init.bash`, fnm, and sourcing `~/.secrets`;
- history settings, except `HISTFILE`.

Old `~/.inputrc` lines the repo's doesn't have: append them to `~/.extra` as `bind '…'` lines, or ask the user
whether they belong in the repo's `.inputrc`.

### 4. Check

```sh
lb=$(dscl . -read ~ UserShell | awk '{print $2}')
for f in ~/.bash_profile ~/.bashrc ~/.bash_prompt ~/.aliases ~/.functions ~/.exports ~/.extra ~/.secrets; do
    [ -f "$f" ] && "$lb" -n "$f"
done
# stderr of a new Ghostty tab's shell: only "cannot set terminal process group" and "no job control" are expected
# (there's no terminal here); anything else is a real error
TERM_PROGRAM=ghostty "$lb" -l -i -c true 2>&1 >/dev/null
# the setup and the user's settings are present (names only, never values); no TERM_PROGRAM, so no banner
TERM_PROGRAM= "$lb" -l -i -c 'type -t mkd __lab_precmd; command -v lab-banner; echo "HISTSIZE=$HISTSIZE";
    for v in GITHUB_USERNAME ANTHROPIC_AUTH_TOKEN TRELLO_API_KEY; do [ -n "${!v}" ] && echo "$v: set" || echo "$v: MISSING"; done' 2>/dev/null
/Applications/Ghostty.app/Contents/MacOS/ghostty +show-config | grep -E '^(theme|background|cursor-color) '
```

Expected: `theme = Lab Sunset Rally`, `background = #1b1026`, `cursor-color = #ff8a3d` (unless the config sets
colours directly). Add the variables from step 3 to the loop. If a line in `~/.extra` errors, fix it or comment it
out and tell the user; don't change the repo's files to suit one Mac.

Optional tools: `eza`, `bat`, `fzf`, `bash-completion@2`, `fnm` (`brew list --formula`). Don't install them on
`omnibytes`. Tell the user which are missing.

### 5. Report

Tell the user to reload Ghostty's config (Cmd+Shift+, in Ghostty) and open a new tab. They should see the plum
theme, the banner and the new prompt. `false` should show `✘ 1`, and `sleep 6` should show `took 6s`. The first
command of 30 s or more makes macOS ask whether Ghostty can send notifications.

List: each link made, each `.pre-dotfiles` and `.bak-dotfiles` kept, what went into `~/.extra`, what was left out
and why, and anything left for the user to decide.

## Changing the banner

Everything is in `banner/hosts/omnibytes/`, linked into `~/.config/lab-banner/`, so an edit shows in the next new
tab (the prompt's colours, in the next new shell):

- `banner.conf`: `BANNER_FROM` and `BANNER_TO` (`#rrggbb`, the gradient for the banner and the prompt's names),
  `BANNER_TAGLINE` and `BANNER_ROLE`.
- `art.txt` and `art-small.txt`: the name in the figlet fonts ANSI Shadow and small, lowercase `omnibytes` like
  the Mac's name (`scutil --get LocalHostName`). The big one is used when it fits the terminal (width + 4), then
  the small one, then the plain host name.

## Where the files came from

The theme, `banner/lab-banner` and the bash files (except `.exports`, `.gitconfig`, `.globalignore`, `Brewfile`)
started as copies from the user's lab repo, which manages their servers. **They are this repo's own now: there is
no sync with the lab repo in either direction**, so change them freely here. Their header comments still say
"Managed by the lab repo"; that's history, not a rule.

Leftovers from that origin, harmless on a Mac: Linux branches in `.bash_profile`, `.aliases` and `lab-banner`, the
tmux helpers in `.functions` (active only where tmux is installed). They can be stripped whenever convenient.

## Gotchas

- `install.sh` must keep running under macOS's `/bin/bash` 3.2, because a fresh Mac has no other bash yet: no
  `mapfile`, `${arr[-1]}`, `declare -A` or `${var,,}`.
- `ghostty +validate-config` truncates its stdout when that's a file, which wipes a log of the run. Capture its
  output (`out=$(…)`) rather than letting it through.
- Ghostty finds `~/Library/Application Support/com.mitchellh.ghostty/` from the real account, not `$HOME`. To test
  `install.sh` in a throwaway home, set both `HOME` and `XDG_CONFIG_HOME` to it. Ghostty still reads the real
  Application Support config.
- In these shells `cat` is `bat`. Use `command cat` when the exact bytes matter (`command cat -v`).

## Undoing it

Remove the links `install.sh` made (`find ~ -maxdepth 1 -lname "$HOME/.dotfiles/*"`, plus `~/bin/lab-banner`,
`~/.config/lab-banner/*` and `~/.config/ghostty/themes/Lab Sunset Rally`). Move each `.pre-dotfiles` back
(`mv ~/.bashrc.pre-dotfiles ~/.bashrc`), restore the Ghostty config from its `.bak-dotfiles` (or delete the config
if `install.sh` created it: its run printed `created … with theme`), remove what was added to `~/.extra`, and
delete `~/.hushlogin` if it didn't exist before. Then reload Ghostty.
