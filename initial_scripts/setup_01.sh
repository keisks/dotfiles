#!/bin/bash

### NOTE: This script is intended for initial setup only!!!
set -euo pipefail

### github config
git config --global user.name "keisks"
git config --global user.email "keisks5@gmail.com"

### ssh-keygen
KEYFILE="$HOME/.ssh/id_ed25519"

if [[ -f "$KEYFILE" || -f "$KEYFILE.pub" ]]; then
  echo "Error: $KEYFILE already exists. Aborting to avoid overwrite." >&2
  exit 1
fi

ssh-keygen -t ed25519 -C "keisks5@gmail.com" -f ~/.ssh/id_ed25519 -N "" -q

cat <<'EOF' >> ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  IgnoreUnknown UseKeychain
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
chmod 600 ~/.ssh/config

### install chezmoi
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Install Homebrew ..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Install chezmoi ..."
    NONINTERACTIVE=1 brew install chezmoi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sh -c "$(curl -fsLS get.chezmoi.io)"
    ### or sh -c "$(wget -qO- get.chezmoi.io)"
else
    echo "Unknown OS: $OSTYPE, chezmoi not installed."
fi

###
echo "setup_01 completed!! Add the ssh key (pub) to github. https://github.com/settings/keys "
echo "Then run setup_02.sh by curl -fsSL https://raw.githubusercontent.com/keisks/dotfiles/main/initial_scripts/setup_02.sh | bash"
cat ~/.ssh/id_ed25519.pub

