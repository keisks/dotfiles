#!/bin/bash
set -euo pipefail

# --- Helpers ---
have() { command -v "$1" >/dev/null 2>&1; }

# Make sure user bins are in PATH (common on Linux)
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# --- Backup existing shells' rc files ---
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

# --- Backup and recreate bash_profile ---
if [ -f "$HOME/.bash_profile" ]; then
    cp "$HOME/.bash_profile" "$HOME/.bash_profile.original"
fi
cat > "$HOME/.bash_profile" <<'EOF'
# Load .bashrc for interactive login shells
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

# --- Backup and recreate zprofile ---
if [ -f "$HOME/.zprofile" ]; then
    cp "$HOME/.zprofile" "$HOME/.zprofile.original"
fi
cat > "$HOME/.zprofile" <<'EOF'
# Load .zshrc for login shells
if [ -f ~/.zshrc ]; then
  . ~/.zshrc
fi
EOF


# --- Run chezmoi ---
chezmoi init git@github.com:keisks/dotfiles.git
chezmoi apply

# --- macOS: brew bundle (if available) ---
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Install bundles for Homebrew."
    NONINTERACTIVE=1 brew bundle
fi

# --- Linux: install zellij via cargo (robust loop) ---
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

echo "🎉 setup_02 completed! Please re-login to apply changes."
