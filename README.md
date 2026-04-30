`curl -fsSL https://raw.githubusercontent.com/keisks/dotfiles/main/initial_scripts/setup_01.sh | bash`


mac homebrew update procedure

  `brew bundle dump --global --force`
  
  `chezmoi re-add .Brewfile`
  
  `git add`
  
  `git push`
  
