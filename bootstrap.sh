#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

MACHINE_TYPE="$1"

if [[ "$MACHINE_TYPE" != "personal" && "$MACHINE_TYPE" != "work" && "$MACHINE_TYPE" != "devserver" ]]; then
    echo "Usage: ./bootstrap.sh <machine-type> [--force]"
    echo "  machine-type: personal | work | devserver"
    exit 1
fi

git pull origin master;

function setupTmuxPlugins() {
    echo "Setting up tmux plugins ..."
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [ ! -d "$tpm_dir" ]; then
        echo "Installing TPM (Tmux Plugin Manager) ..."
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    else
        echo "TPM already installed, updating ..."
        git -C "$tpm_dir" pull
    fi

    echo "Installing tmux plugins ..."
    "$tpm_dir/bin/install_plugins"
    echo "Done."
}

function generateGitconfig() {
    echo "Generating ~/.gitconfig ..."
    local identity_file=""
    case "$MACHINE_TYPE" in
        personal)  identity_file=".gitconfig-personal" ;;
        work)      identity_file=".gitconfig-work" ;;
        devserver) identity_file=".gitconfig-work" ;;
    esac
    cat .gitconfig "$identity_file" > ~/.gitconfig
    echo "Done."
}

function generateCronjobs() {
    echo "Generating ~/.cronjobs ..."
    cat .cronjobs ".cronjobs.$MACHINE_TYPE" > ~/.cronjobs
    crontab ~/.cronjobs
    echo "Done."
}

function deployNvim() {
    echo "Deploying nvim config to ~/.config/nvim ..."
    mkdir -p ~/.config/nvim
    # Remove legacy init.vim shim that conflicts with init.lua
    rm -f ~/.config/nvim/init.vim
    rsync --exclude ".DS_Store" \
        --delete -avh --no-perms nvim/ ~/.config/nvim/

    local lazypath="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [ ! -d "$lazypath" ]; then
        echo "Bootstrapping lazy.nvim ..."
        git clone --filter=blob:none --branch=stable \
            https://github.com/folke/lazy.nvim.git "$lazypath"
    fi

    echo "Installing nvim plugins ..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null
    echo "Done."
}

function doIt() {
    rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "README.md" \
        --exclude "CLAUDE.md" \
        --exclude "LICENSE-MIT.txt" \
        --exclude "plan.md" \
        --exclude "words.md" \
        --exclude "personal-access-token" \
        --exclude "todo.txt" \
        --exclude "musttodo.txt" \
        --exclude "sysctl/" \
        --exclude "brew.sh" \
        --exclude ".claude/" \
        --exclude "nvim/" \
        --exclude ".gitconfig" \
        --exclude ".gitconfig-personal" \
        --exclude ".gitconfig-work" \
        --exclude ".cronjobs.*" \
        -avh --no-perms . ~;

    deployNvim;

    # Write machine type before sourcing shell config
    echo "export MACHINE_TYPE=$MACHINE_TYPE" > ~/.machine_type;
    generateGitconfig;
    generateCronjobs;
    source ~/.bash_profile;

    setupTmuxPlugins;  # tmux plugins work on all platforms
}

# Shift past machine-type arg so --force check works
shift

if [ "$1" == "--force" -o "$1" == "-f" ]; then
    doIt;
else
    read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        doIt;
    fi;
fi;

unset doIt;
unset deployNvim;
unset setupTmuxPlugins;
unset generateGitconfig;
unset generateCronjobs;
