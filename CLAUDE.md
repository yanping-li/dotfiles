# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for macOS (personal + work) and Ubuntu (dev server), using Bash. Files are rsynced into `$HOME` via `bootstrap.sh`.

## Principles

- **Modular** — each file has a single responsibility; machine-specific or context-specific behavior lives in its own file or override, not scattered across shared files.
- **Never commit secrets** — credentials, tokens, passwords, and internal hostnames belong in gitignored local files (`.extra`, `.path`, `personal-access-token`). If something looks sensitive, it does not get committed.
- **Automatic environment setup** — `bootstrap.sh` should bring a machine to a working state with minimal manual steps after cloning. Tool installs, plugin managers, and OS config should all be bootstrapped automatically.
- **Cross-OS support** — code must work on macOS (personal laptop, work laptop) and Ubuntu (dev server). Gate OS-specific behavior on `$OSTYPE` or `$MACHINE_TYPE`. Avoid macOS-only assumptions in shared files.
- **Separate portable config from machine-specific config** — shared files contain only what works everywhere. Anything tied to a specific machine, OS, or work context belongs in an override file (`.extra`, `.path`, `.pan_rc`, or a machine-specific sourced file).
- **Avoid unnecessary churn** — don't reorganize, rename, or refactor working files without a clear reason. Stability in dotfiles matters; a broken shell config on a remote server is painful to recover from.
- **Minimize cleverness** — prefer simple, readable shell over terse one-liners or elaborate abstractions. The next reader (or Claude in a future session) should understand what a script does at a glance.
- **Fail gracefully** — source files with `[ -f file ] && . file` guards. Tool-specific setup should check if the tool exists before configuring it. A missing optional dependency should produce no error.

## Deploying

```bash
# Apply dotfiles to $HOME (interactive, asks for confirmation)
./bootstrap.sh <machine-type>   # personal | work | devserver

# Force apply without prompt
./bootstrap.sh <machine-type> --force
```

`bootstrap.sh` also:
- Installs Homebrew packages via `brew.sh` (not run automatically — invoke separately)
- Clones/updates TPM (Tmux Plugin Manager) and installs tmux plugins
- Copies and applies the appropriate `sysctl/sysctl.conf.*` for the OS

## File loading order

`.bash_profile` sources these files in order (if they exist):
```
~/.path → ~/.bash_prompt → ~/.exports → ~/.aliases → ~/.functions → ~/.extra → ~/.pan_rc
```

- `.extra` and `.path` are machine-local overrides that are **not** committed to this repo — use them for per-machine settings, secrets, or additional PATH entries.

## Architecture

| File | Purpose |
|------|---------|
| `.bash_profile` | Entry point; sources all other shell config |
| `.aliases` | Shell aliases (Finder, clipboard; macOS-only aliases are gated on `uname`) |
| `.functions` | Shell functions — notably `ta()` for fuzzy tmux attach/create |
| `.exports` | Environment variables |
| `.bash_prompt` | Custom PS1 prompt |
| `.bashrc` | Minimal bashrc (sources `.bash_profile`) |
| `.inputrc` | Readline config (bash completion, history search) |
| `.editorconfig` | Editor formatting defaults (indent, charset, trailing whitespace) |
| `.tmux.conf` | tmux config with TPM plugins (tmux-resurrect); vi mode keys |
| `.ssh/config` | SSH host groups and global options (ForwardAgent, UseKeychain macOS-only) |
| `.ssh/rc` | SSH post-login: symlinks `$SSH_AUTH_SOCK` for tmux agent forwarding |
| `.vimrc` / `.vim/` | Vim config with Vundle plugin manager, Solarized theme |
| `.gitconfig` | Git settings (no identity — appended by `bootstrap.sh`) |
| `.gitconfig-personal` | Git identity for personal machine |
| `.gitconfig-work` | Git identity for work/devserver |
| `.cronjobs` | Base cron jobs (all machines) |
| `.cronjobs.personal` | Personal-machine-specific cron jobs |
| `.cronjobs.work` | Work-machine-specific cron jobs |
| `.cronjobs.devserver` | Dev server-specific cron jobs |
| `.pan_rc` | Work-specific aliases and config (sourced only on work/devserver) |
| `.macos` | macOS system preference automation (run once manually) |
| `mac-terminal-profile.terminal` | Custom Terminal.app theme (applied by `.macos`) |
| `brew.sh` | Homebrew package installs (run manually) |
| `bootstrap.sh` | Deploys dotfiles; requires `personal \| work \| devserver` arg |
| `sysctl/` | Kernel tuning configs for macOS and Linux |

## Key conventions

- The default SSH user for all dev servers is `lexli` (set in `.ssh/config`).
- tmux SSH agent forwarding relies on a symlink at `~/.ssh/ssh_auth_sock` (set in `.ssh/rc`, referenced in `.tmux.conf`).
- Machine type is written to `~/.machine_type` by `bootstrap.sh` and sourced first in `.bash_profile`.
- Git identity (`[user]`) is not in `.gitconfig` — `bootstrap.sh` appends `.gitconfig-personal` or `.gitconfig-work` to produce `~/.gitconfig`.
- `.pan_rc` is sourced only when `MACHINE_TYPE` is `work` or `devserver`.
- `.extra` and `.path` are machine-local overrides not committed to this repo.
- Vim plugins are managed by Vundle (cloned during `bootstrap.sh`); tmux plugins by TPM.
