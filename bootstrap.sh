#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE}")";

git pull origin master;

function copyAndApplySysctl() {
	echo "Copy and apply sysctl config ..."
    unameOut="$(uname -s)"
    case "${unameOut}" in
        Linux*)
        sudo cp sysctl/sysctl.conf.linux /etc/sysctl.conf
        sudo sysctl -p
        ;;

        Darwin*)
        cp sysctl/sysctl.conf.osx /etc/sysctl.conf
        cat /etc/sysctl.conf | xargs sudo sysctl
        ;;
    esac
	echo "Done."
}

function doIt() {
    git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	rsync --exclude ".git/" \
		--exclude ".DS_Store" \
		--exclude ".osx" \
		--exclude "bootstrap.sh" \
		--exclude "README.md" \
		--exclude "LICENSE-MIT.txt" \
		--exclude "todo.txt" \
        --exclude "sysctl/" \
		-avh --no-perms . ~;
	source ~/.bash_profile;

    copyAndApplySysctl;
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
