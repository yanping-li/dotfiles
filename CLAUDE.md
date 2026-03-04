# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles for macOS (Bash shell). Files are symlinked/rsynced into `$HOME` via `bootstrap.sh`.

## Deploying

```bash
# Apply dotfiles to $HOME (interactive, asks for confirmation)
./bootstrap.sh

# Force apply without prompt
./bootstrap.sh --force
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
| `.aliases` | Shell aliases (macOS-centric: Finder, clipboard, networking) |
| `.functions` | Shell functions — notably `ta()` for fuzzy tmux attach/create |
| `.exports` | Environment variables |
| `.bash_prompt` | Custom PS1 prompt |
| `.tmux.conf` | tmux config with TPM plugins (tmux-resurrect); vi mode keys |
| `.ssh/config` | SSH host groups and global options (ForwardAgent, UseKeychain) |
| `.ssh/rc` | SSH post-login commands (e.g., socket symlinking for agent forwarding in tmux) |
| `.vimrc` / `.vim/` | Legacy Vim config (kept, untouched) |
| `.config/nvim/init.lua` | Neovim entry point: bootstraps lazy.nvim, loads modules |
| `.config/nvim/lua/settings.lua` | Neovim options, autocmds, colorscheme |
| `.config/nvim/lua/keymaps.lua` | Neovim key bindings |
| `.config/nvim/lua/plugins.lua` | lazy.nvim plugin spec (telescope, nvim-tree, treesitter, etc.) |
| `.gitconfig` | Git settings |
| `.macos` / `.osx` | macOS system preference automation scripts (run once manually) |
| `sysctl/` | Kernel tuning configs for macOS and Linux |

## Key conventions

- The default SSH user for all dev servers is `lexli` (set in `.ssh/config`).
- tmux SSH agent forwarding relies on a symlink at `~/.ssh/ssh_auth_sock` (configured in `.tmux.conf` and `.ssh/rc`).
- `musttodo.txt` is gitignored; `.extra`, `.path`, and `.user_pass_and_jtac_servers_and_jtac_dirs` are sensitive local-only files.
- Neovim plugins are managed by **lazy.nvim**, which self-bootstraps on first `nvim` launch — no manual setup needed. Config lives in `.config/nvim/lua/plugins.lua`.
- Vim (`.vimrc`) is kept untouched as a fallback; its plugins used Vundle (now unused).
- tmux plugins are managed by TPM (bootstrapped by `bootstrap.sh`).
