#!/bin/bash
# cron-git-fetch.sh — run `git fetch` in a repo from cron with a working ssh-agent.
#
# WHY THIS EXISTS
#   The Bitbucket remote (ssh://git@bitbucket.paloaltonetworks.local:32778/...)
#   authenticates ONLY via ssh-agent — there is no on-disk private key in ~/.ssh.
#   cron runs with a minimal environment and no SSH_AUTH_SOCK, so `git fetch`
#   under cron fails with: "Permission denied (publickey)".
#
#   This wrapper locates a live ssh-agent socket at run time and exports it,
#   then fetches. If no live agent or the remote is unreachable, it logs and
#   exits 0 (so cron does not spam mail on transient outages).
#
# USAGE (in crontab):
#   0 0 * * * ~/.local/bin/cron-git-fetch.sh ~/pan/main >> ~/.cache/cron-git-fetch.log 2>&1

set -u

REPO="${1:-$HOME/pan/main}"
LOG_TS() { date '+%Y-%m-%dT%H:%M:%S%z'; }

log() { echo "[$(LOG_TS)] $*"; }

# --- locate a usable ssh-agent socket ---------------------------------------
find_agent_sock() {
    # 1) stable symlink maintained by ~/.ssh/rc (points at the newest session)
    if [ -S "$HOME/.ssh/ssh_auth_sock" ]; then
        echo "$HOME/.ssh/ssh_auth_sock"; return 0
    fi
    # 2) already in environment (e.g. run from an interactive shell)
    if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "${SSH_AUTH_SOCK}" ]; then
        echo "$SSH_AUTH_SOCK"; return 0
    fi
    # 3) scan for any live agent socket owned by us
    local s
    for s in $(find /tmp/ssh-* /run/user/"$(id -u)" -type s -name 'agent.*' 2>/dev/null); do
        if SSH_AUTH_SOCK="$s" ssh-add -l >/dev/null 2>&1; then
            echo "$s"; return 0
        fi
    done
    return 1
}

if [ ! -d "$REPO/.git" ] && [ ! -f "$REPO/.git" ]; then
    log "SKIP: '$REPO' is not a git repo"
    exit 0
fi

SOCK="$(find_agent_sock)" || {
    log "SKIP: no live ssh-agent socket found (interactive session likely closed); cannot fetch $REPO"
    exit 0
}
export SSH_AUTH_SOCK="$SOCK"

# verify the agent actually holds a key
if ! ssh-add -l >/dev/null 2>&1; then
    log "SKIP: agent at $SOCK has no keys loaded"
    exit 0
fi

log "fetch: repo=$REPO agent=$SOCK"
# fail fast on network problems; do not hang the cron slot
GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new" \
    git -C "$REPO" fetch --all --prune 2>&1
rc=$?
if [ "$rc" -ne 0 ]; then
    log "WARN: git fetch exited rc=$rc (network/VPN down or auth issue)"
else
    log "OK: git fetch completed"
fi
exit 0
