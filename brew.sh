#!/usr/bin/env bash

# Install command-line tools using Homebrew.
# Run this manually on a new Mac after bootstrap.sh.

# Make sure we're using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Install GNU core utilities (macOS versions are outdated).
# Provides `gls` with full LS_COLORS support.
brew install coreutils

# Install GNU utilities
brew install moreutils   # useful extras like `sponge`
brew install findutils   # GNU find, locate, xargs (g-prefixed)
brew install gnu-sed     # GNU sed, overrides macOS sed

# Install newer versions of macOS tools
brew install git
brew install git-lfs
brew install openssh
brew install grep

# Shell
brew install bash
brew install bash-completion@2

# Terminal multiplexer
brew install tmux

# Editor
brew install neovim

# Languages
brew install python3

# Useful tools
brew install tree        # directory tree viewer (used by tre() function)
brew install tldr        # simplified man pages
brew install ssh-copy-id # copy SSH keys to remote hosts
brew install nmap        # network scanner
brew install xz          # compression
brew install p7zip       # 7-zip compression
brew install pigz        # parallel gzip
brew install pv          # monitor pipe progress
brew install ack         # code search
brew install jq          # JSON processor

# Remove outdated versions from the cellar.
brew cleanup
