# dotfiles

Bash configuration for macOS: Solarized-style prompt with git status, colored CLI tools, fuzzy search, and git/readline settings. Everything is symlinked into `~` so edits in this repo take effect immediately.

## Fresh machine setup

1. **Install [Homebrew](https://brew.sh)**

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Clone and install**

   ```bash
   git clone git@github.com:shahbaztariq/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles && ./install.sh
   ```

   `install.sh` symlinks the dotfiles into `~` and runs `brew bundle` against the [`Brewfile`](Brewfile), which installs everything the config depends on (bash 5, fzf, git-delta, eza, bat, 1Password, …).

3. **Switch the login shell to Homebrew's bash 5** — macOS ships bash 3.2 from 2007 and several config features need 4+:

   ```bash
   sudo sh -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
   chsh -s /opt/homebrew/bin/bash
   ```

4. **Sign in to 1Password** (app + CLI integration under Settings → Developer), then wire up the GitHub CLI plugin:

   ```bash
   op plugin init gh
   ```

   Secrets live in the **"dotfiles secrets"** item in the Private vault — nothing secret is stored in this repo, on disk, or in shell env vars. `gh` authenticates transparently via the plugin (Touch ID only when actually used); anything else can fetch ad hoc, e.g. `op read 'op://Private/dotfiles secrets/ghcr_pat'`.

## What's inside

| File | Purpose |
|---|---|
| `.bash_profile` | PATH setup, sources the other dotfiles, history tuning, fzf, colored man pages |
| `.bash_prompt` | prompt: `user at host in dir on branch [+!?$]` |
| `.aliases` | navigation shortcuts, `eza`/`bat` aliases, colored grep |
| `.exports` | non-secret env vars; secrets are never exported at startup |
| `.functions` | `mkd` — mkdir and cd in one step |
| `.inputrc` | readline: prefix history search on ↑/↓, smarter tab completion |
| `.gitconfig` | identity + commit signing (1Password), delta pager, aliases (`st`, `co`, `assume`, …) |
| `.globalignore` | global gitignore |
| `Brewfile` | packages/apps the config depends on; `brew bundle dump` for a full machine snapshot |

### Daily-driver features

- **Git prompt markers** — `+` staged, `!` unstaged, `?` untracked, `$` stashed. Disable per-repo in huge/slow repos with `git config bash.showDirtyState false`.
- **fzf** — `Ctrl-R` fuzzy history search, `Ctrl-T` fuzzy file paths, `Alt-C` fuzzy cd.
- **History** — 32k lines, deduped, timestamped, flushed after every command (survives crashes; new tabs see other tabs' commands).
- **delta** — colored side-by-side-capable `git diff` with line numbers.
- **Commit signing** — all commits SSH-signed via 1Password; commits fail if the app is locked/missing.

Machine-specific overrides can go in `~/.path` (extra PATH entries) or `~/.extra` (anything you don't want committed) — both are sourced automatically if they exist.
