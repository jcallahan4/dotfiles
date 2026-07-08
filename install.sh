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

# ---------------------------------------------------------------------------
# Install dependencies
#
# The shell configs expect: zsh, neovim, zoxide, powerlevel10k, and the
# zsh-autosuggestions / zsh-syntax-highlighting plugins. macOS installs
# everything via Homebrew; Debian/Ubuntu uses apt, with a couple of tools
# that apt can't provide handled separately (see below).
# ---------------------------------------------------------------------------
os="$(uname -s)"

if [ "$os" = "Darwin" ]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install it from https://brew.sh, then re-run." >&2
    exit 1
  fi
  brew install zsh neovim zoxide powerlevel10k \
    zsh-autosuggestions zsh-syntax-highlighting

elif [ "$os" = "Linux" ]; then
  sudo apt-get update
  sudo apt-get install -y zsh git curl zoxide \
    zsh-autosuggestions zsh-syntax-highlighting

  # powerlevel10k isn't packaged in apt; clone it to a stable location that
  # zshrc_work knows to look in.
  p10k_dir="$HOME/.local/share/powerlevel10k"
  if [ ! -d "$p10k_dir" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
  fi

  # apt's neovim is far too old for the treesitter `main` config (needs
  # 0.12+). Install the official stable release tarball into /opt instead.
  if ! command -v nvim >/dev/null 2>&1; then
    case "$(uname -m)" in
      x86_64)        nvim_asset="nvim-linux-x86_64" ;;
      aarch64|arm64) nvim_asset="nvim-linux-arm64" ;;
      *) echo "No neovim tarball for arch $(uname -m); install nvim manually." >&2
         nvim_asset="" ;;
    esac
    if [ -n "$nvim_asset" ]; then
      tmp="$(mktemp -d)"
      curl -fsSL -o "$tmp/nvim.tar.gz" \
        "https://github.com/neovim/neovim/releases/download/stable/${nvim_asset}.tar.gz"
      sudo rm -rf /opt/nvim
      sudo tar -C /opt -xzf "$tmp/nvim.tar.gz"
      sudo mv "/opt/${nvim_asset}" /opt/nvim
      sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
      rm -rf "$tmp"
    fi
  fi

  # Use zsh for interactive sessions. We can't rely on chsh: on GCP OS Login
  # VMs the account is served via NSS and isn't in /etc/passwd, so chsh has
  # nothing to edit. Instead have bash exec zsh on interactive login. The
  # guards keep it out of non-interactive shells (scp, scripts) and stop it
  # looping once already in zsh.
  handoff_marker="# dotfiles: hand off to zsh"
  if ! grep -qF "$handoff_marker" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc << 'EOF'

# dotfiles: hand off to zsh for interactive sessions (chsh can't set the
# login shell on OS Login VMs, where the account isn't in /etc/passwd).
if [ -z "$ZSH_VERSION" ] && [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
  exec zsh -l
fi
EOF
  fi

else
  echo "Unsupported OS: $os (expected Darwin or Linux)" >&2
  exit 1
fi

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
