#!/bin/bash
set -euo pipefail

if [ -f ~/.bashrc ]; then
    cp ~/.bashrc ~/.bashrc.original
else
    touch ~/.bashrc.original
fi

if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.original
else
    touch ~/.zshrc.original
fi

chezmoi init git@github.com:keisks/dotfiles.git
chezmoi apply

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Install bundles for Homebrew."
    NONINTERACTIVE=1 brew bundle
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Start install zellij"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env"
    export CARGO_TARGET_DIR=$HOME/.cargo/target
    ulimit -n 65536 2>/dev/null || true
    MAX=10
    for i in $(seq 1 $MAX); do
      echo "Attempt $i/$MAX..."
      if cargo install zellij --locked -j4; then
        echo "✅ zellij installed"
        exit 0
      fi
      sleep 5
    done
    echo "❌ Failed to install zellij after $MAX attempts"
    exit 1
fi
