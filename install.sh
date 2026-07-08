#!/bin/bash

# Create backup of existing configs
backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir/.config"

# Backup existing configs if they exist
[ -d ~/.config/nvim ] && mv ~/.config/nvim "$backup_dir/.config/"
[ -d ~/.config/alacritty ] && mv ~/.config/alacritty "$backup_dir/.config/"
[ -f ~/.zshrc ] && mv ~/.zshrc "$backup_dir/"

# Create necessary directories
mkdir -p ~/.config/nvim
mkdir -p ~/.config/alacritty

# Determine system type
read -p "What type of system is this? (personal/work/hpc): " system_type

# Create zshrc based on system type
cat > ~/.zshrc << EOL
# This file is managed by dotfiles installer
source ~/dotfiles/zsh/zshrc_common
source ~/dotfiles/zsh/zshrc_${system_type}
EOL

# Create symlinks for config directories
ln -sf ~/dotfiles/config/nvim/* ~/.config/nvim/
ln -sf ~/dotfiles/config/alacritty/* ~/.config/alacritty/

# Symlink personal LaTeX class/style files into the TeX tree.
# TEXMFHOME is where TeX looks for user files; it defaults to ~/Library/texmf
# on macOS (MacTeX) and ~/texmf on Linux (TeX Live). Ask kpsewhich so this
# works on both. TeX searches tex/latex/ recursively and live (no mktexlsr
# needed), so any .cls/.sty added under ~/dotfiles/latex/ is picked up
# automatically with no further setup.
if command -v kpsewhich >/dev/null 2>&1; then
  texmfhome="$(kpsewhich -var-value=TEXMFHOME)"
  mkdir -p "$texmfhome/tex/latex"
  ln -sfn ~/dotfiles/latex "$texmfhome/tex/latex/dotfiles"
fi

echo "Installation complete! Please restart your shell."
