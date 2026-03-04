#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function copyAndApplySysctl() {
	echo "Copy and apply sysctl config ..."
    unameOut="$(uname -s)"
    case "${unameOut}" in

#       Linux*)
#       sudo cp sysctl/sysctl.conf.linux /etc/sysctl.conf
#       sudo sysctl -p
#       ;;

        Darwin*)
        sudo cp sysctl/sysctl.conf.osx /etc/sysctl.conf
        cat /etc/sysctl.conf | xargs sudo sysctl
        ;;
    esac
	echo "Done."
}

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

	# Install/update plugins via TPM (works without a running tmux session)
	echo "Installing tmux plugins ..."
	"$tpm_dir/bin/install_plugins"
	echo "Done."
}

function doIt() {
    # Note: neovim plugins (lazy.nvim) self-bootstrap on first `nvim` launch.
    # No manual plugin setup needed.
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		--exclude "todo.txt" \
		--exclude "musttodo.txt" \
        --exclude "sysctl/" \
		-avh --no-perms . ~;
	source ~/.bash_profile;

    copyAndApplySysctl;
    setupTmuxPlugins;
}

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
unset copyAndApplySysctl;
unset setupTmuxPlugins;
