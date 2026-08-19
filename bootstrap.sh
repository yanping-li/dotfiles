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

function generateSshConfig() {
    echo "Generating ~/.ssh/config ..."
    mkdir -p ~/.ssh
    cat .ssh/config ".ssh/config.$MACHINE_TYPE" > ~/.ssh/config
    chmod 600 ~/.ssh/config
    echo "Done."
}

function installNvimBinary() {
    if command -v nvim &>/dev/null; then
        local ver
        ver=$(nvim --version | head -1 | sed 's/NVIM v//')
        local major minor
        major=$(echo "$ver" | cut -d. -f1)
        minor=$(echo "$ver" | cut -d. -f2)
        if [ "$major" -gt 0 ] || [ "$minor" -ge 7 ]; then
            echo "nvim $ver already installed, skipping."
            return
        fi
        echo "nvim $ver is too old, reinstalling ..."
    fi
    echo "Installing nvim to ~/.local/bin ..."
    mkdir -p ~/.local/bin
    local tmp=$(mktemp -d)
    curl -L --silent --show-error \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" \
        -o "$tmp/nvim.tar.gz"
    tar -xzf "$tmp/nvim.tar.gz" -C ~/.local --strip-components=1
    rm -rf "$tmp"
    echo "Installed $(nvim --version | head -1)"
}


# Install the CLI tools nvim relies on, into ~/.local/bin (no root needed):
#   - fd, rg : used by Telescope live_grep (,fg) and available to file finders.
#              (Note: ,ff uses `git ls-files`, which is fastest on huge repos;
#               fd/rg are primarily for content search and non-git trees.)
#   - clangd : C/C++ LSP fallback when a project-specific wrapper is not used.
# telescope-fzf-native (the C fuzzy sorter) is compiled automatically by lazy.nvim
# via its `build = "make"` hook during deployNvim, provided a C toolchain (make + cc)
# is present.
function installCliTools() {
    mkdir -p ~/.local/bin
    local tmp
    tmp=$(mktemp -d)

    if ! command -v fd &>/dev/null && [ ! -x ~/.local/bin/fd ]; then
        echo "Installing fd to ~/.local/bin ..."
        local fd_ver="10.2.0"
        if curl -fsSL -o "$tmp/fd.tgz" \
            "https://github.com/sharkdp/fd/releases/download/v${fd_ver}/fd-v${fd_ver}-x86_64-unknown-linux-musl.tar.gz"; then
            tar -xzf "$tmp/fd.tgz" -C "$tmp"
            cp "$tmp"/fd-*/fd ~/.local/bin/fd && chmod +x ~/.local/bin/fd
            echo "Installed fd $(~/.local/bin/fd --version)"
        else
            echo "WARN: fd download failed, skipping."
        fi
    else
        echo "fd already installed, skipping."
    fi

    if ! command -v rg &>/dev/null && [ ! -x ~/.local/bin/rg ]; then
        echo "Installing ripgrep (rg) to ~/.local/bin ..."
        local rg_ver="14.1.1"
        if curl -fsSL -o "$tmp/rg.tgz" \
            "https://github.com/BurntSushi/ripgrep/releases/download/${rg_ver}/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz"; then
            tar -xzf "$tmp/rg.tgz" -C "$tmp"
            cp "$tmp"/ripgrep-*/rg ~/.local/bin/rg && chmod +x ~/.local/bin/rg
            echo "Installed $(~/.local/bin/rg --version | head -1)"
        else
            echo "WARN: rg download failed, skipping."
        fi
    else
        echo "rg already installed, skipping."
    fi

    # clangd/clangd-indexer must be VERSION-MATCHED to the PAN-OS build container
    # (LLVM 16.0.6). clangd's on-disk index format is tied to the LLVM major
    # version, so panos.idx produced by clangd-indexer-16 is only readable by
    # clangd-16. We source both FROM the container (glibc-safe) rather than
    # downloading host tarballs. Requires docker + the kettle image.
    local kettle_img="docker-kettle.af.paloaltonetworks.local/kettle-panos:13.1.0-3056"
    local llvm16_ver="16.0.6"

    if [ ! -x ~/.local/bin/clangd-16 ] || [ ! -x ~/.local/bin/clangd-indexer-16 ]; then
        if ! command -v docker &>/dev/null; then
            echo "WARN: docker not found - cannot install version-matched clangd-16 /"
            echo "      clangd-indexer-16. Skipping (LSP index tooling unavailable)."
        else
            if [ ! -x ~/.local/bin/clangd-16 ]; then
                echo "Installing clangd-16 (LLVM ${llvm16_ver}) from build container ..."
                # Ephemeral dnf install inside a throwaway container; copy the
                # binary out to the bind-mounted home dir. Nothing persists.
                docker run --rm -v "$HOME:$HOME" "$kettle_img" bash -c \
                    "dnf install -y clang-tools-extra >/dev/null 2>&1 && \
                     cp /usr/bin/clangd $HOME/.local/bin/clangd-16" \
                    && chmod +x ~/.local/bin/clangd-16 \
                    && echo "Installed $(~/.local/bin/clangd-16 --version | head -1)" \
                    || echo "WARN: clangd-16 install failed."
            else
                echo "clangd-16 already installed, skipping."
            fi

            if [ ! -x ~/.local/bin/clangd-indexer-16 ]; then
                echo "Building clangd-indexer-16 (LLVM ${llvm16_ver}) in container - this can take several minutes ..."
                # Build ONLY the clangd-indexer target from matching LLVM source,
                # inside the container (links against llvm-static 16.0.6 present there).
                docker run --rm -v "$HOME:$HOME" "$kettle_img" bash -c "
                    set -e
                    bdir=\$(mktemp -d)
                    cd \$bdir
                    curl -fsSL -o llvm.tar.xz \
                      https://github.com/llvm/llvm-project/releases/download/llvmorg-${llvm16_ver}/llvm-project-${llvm16_ver}.src.tar.xz
                    tar -xf llvm.tar.xz
                    cmake -S llvm-project-${llvm16_ver}.src/llvm -B build -G Ninja \
                      -DCMAKE_BUILD_TYPE=Release \
                      -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' \
                      -DLLVM_TARGETS_TO_BUILD=X86 >/dev/null
                    ninja -C build clangd-indexer
                    cp build/bin/clangd-indexer $HOME/.local/bin/clangd-indexer-16
                    rm -rf \$bdir
                " \
                    && chmod +x ~/.local/bin/clangd-indexer-16 \
                    && echo "Built clangd-indexer-16" \
                    || echo "WARN: clangd-indexer-16 build failed."
            else
                echo "clangd-indexer-16 already installed, skipping."
            fi
        fi
    else
        echo "clangd-16 and clangd-indexer-16 already installed, skipping."
    fi

    rm -rf "$tmp"

    # Install our own LSP helper scripts into ~/.local/bin. These drive
    # clangd-16 / clangd-indexer-16 for per-platform PAN-OS LSP:
    #   lsp-panos       - build/collect/index per platform-role compile_commands.json
    #                     + panos.idx, and save/use a shared compile_commands cache
    #   lsp-panos-batch - prebuild that cache across many (version x platform) combos
    #   docker-clangd   - clangd wrapper that reads <repo>/.lsp/active and injects
    #                     --compile-commands-dir + --index-file for that target
    local dotdir
    dotdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -d "$dotdir/bin" ]; then
        echo "Installing LSP helper scripts to ~/.local/bin ..."
        for f in lsp-panos lsp-panos-batch docker-clangd; do
            if [ -f "$dotdir/bin/$f" ]; then
                install -m 755 "$dotdir/bin/$f" ~/.local/bin/"$f" \
                    && echo "  installed $f" \
                    || echo "  WARN: failed to install $f"
            fi
        done
    fi

    if ! command -v make &>/dev/null || ! command -v cc &>/dev/null; then
        echo "WARN: make/cc not found - telescope-fzf-native (C sorter) will not compile."
        echo "      Install a C toolchain (e.g. build-essential) for faster fuzzy matching."
    fi
}


function deployGhostty() {
    echo "Deploying ghostty config to ~/.config/ghostty ..."
    mkdir -p ~/.config/ghostty
    rsync --exclude ".DS_Store" \
        -avh --no-perms ghostty/ ~/.config/ghostty/
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
        --exclude "musttodo.txt" \
        --exclude "sysctl/" \
        --exclude "brew.sh" \
        --exclude ".claude/" \
        --exclude "nvim/" \
        --exclude "ghostty/" \
        --exclude ".gitconfig" \
        --exclude ".gitconfig-personal" \
        --exclude ".gitconfig-work" \
        --exclude ".cronjobs.*" \
        --exclude ".ssh/config" \
        --exclude ".ssh/config.*" \
        -avh --no-perms . ~;

    if [ "$MACHINE_TYPE" = "devserver" ]; then
        installNvimBinary;
        installCliTools;
    fi
    deployNvim;
    deployGhostty;

    # Write machine type before sourcing shell config
    echo "export MACHINE_TYPE=$MACHINE_TYPE" > ~/.machine_type;
    generateGitconfig;
    generateSshConfig;
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
unset deployGhostty;
unset installNvimBinary;
unset installCliTools;
unset setupTmuxPlugins;
unset generateGitconfig;
unset generateSshConfig;
unset generateCronjobs;
