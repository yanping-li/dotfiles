# Dotfiles Upgrade Plan

## 1. Machine-type parameter in `bootstrap.sh`

Make the machine type mandatory so the script knows what to apply.

**Machine types:**
- `personal` — personal macOS laptop
- `work` — company macOS laptop
- `devserver` — company Ubuntu dev server

**Changes to `bootstrap.sh`:**
- Add a required positional argument: `./bootstrap.sh <machine-type> [--force]`
- Validate it's one of the three types; exit with usage message if missing or invalid
- Set a `MACHINE_TYPE` env var and write it to `~/.machine_type` (a gitignored file sourced by shell config)
- Gate OS-specific steps on machine type (e.g., sysctl Linux path for `devserver`, macOS path for `personal`/`work`)
- Skip macOS-only steps (TPM, Vundle clone) on `devserver` if not applicable

**Shell config integration:**
- Source `~/.machine_type` early in `.bash_profile` / `.zshrc`
- Use `$MACHINE_TYPE` in `.extra` or conditional blocks to load machine-specific aliases/functions/exports

---

## 2. Upgrade Vim to Neovim

**Goals:**
- Replace `.vimrc` + Vundle with Neovim + a modern plugin manager (lazy.nvim)
- Keep the existing Vundle/Vim path working during transition (don't break devserver if Neovim isn't installed)
- Config lives at `~/.config/nvim/` (XDG standard)

**Changes:**
- Add `~/.config/nvim/init.lua` (or `init.vim` for a lighter migration) to the repo
- Bootstrap lazy.nvim in `bootstrap.sh` (clone if not present)
- Remove Vundle clone step from `bootstrap.sh` once fully migrated
- Add `nvim` to `brew.sh`
- Gate Neovim bootstrap on machine type or check if `nvim` is available

---

## 3. Machine-specific git identity via `bootstrap.sh`

Instead of relying on `includeIf "gitdir:"` path matching, `bootstrap.sh` will write a `~/.gitconfig-local` file with the correct `[user]` block for the machine type, then include it from `.gitconfig`.

**Changes:**
- `bootstrap.sh` writes `~/.gitconfig-local` with `name` and `email` based on machine type
- Add `[include] path = ~/.gitconfig-local` to `.gitconfig`
- Remove `[includeIf]` blocks from `.gitconfig` once implemented

---

## 4. Machine-specific cron jobs

Split cron jobs by machine type and merge during bootstrap.

**New files:**
- `.cronjobs.personal` — cron jobs for personal macOS laptop
- `.cronjobs.work` — cron jobs for work macOS laptop
- `.cronjobs.devserver` — cron jobs for Ubuntu dev server

**Changes to `bootstrap.sh`:**
- After rsync, append the machine-specific `.cronjobs.<type>` file to `.cronjobs`
- Load the merged file with `crontab ~/.cronjobs`

---

## 5. Simplify `.ssh/rc`

Remove hardcoded hostname whitelist — just always create the symlink when a valid SSH auth socket exists.

```bash
if [ -S "$SSH_AUTH_SOCK" ]; then
    ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
```

---

## 6. Machine-specific SSH config ✓

Generate `~/.ssh/config` in bootstrap.sh by concatenating base + machine-specific file, similar to `.gitconfig`.

- Moved `User` directive out of the shared `.ssh/config`
- Added `.ssh/config.personal` (`User yanpingli`), `.ssh/config.work`, `.ssh/config.devserver` (`User lexli`)
- `bootstrap.sh`: `cat .ssh/config ".ssh/config.$MACHINE_TYPE" > ~/.ssh/config`

---

## To be added

- Zsh support (`.zshrc`, `.shell_common` currently untracked)
- Machine-specific override structure (`.extra`, `.path` per machine)
- Linux compatibility pass (apt packages, missing macOS tools on devserver)
