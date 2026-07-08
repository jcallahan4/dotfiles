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
  brew install zsh neovim zoxide powerlevel10k tree-sitter \
    zsh-autosuggestions zsh-syntax-highlighting

elif [ "$os" = "Linux" ]; then
  sudo apt-get update
  sudo apt-get install -y zsh git curl zoxide \
    zsh-autosuggestions zsh-syntax-highlighting \
    fd-find fzf build-essential unzip python3-venv python3-pip

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

  # apt's nodejs (v12, EOL) is too old for modern LSPs installed via Mason -
  # pyright requires Node >=14 and silently misbehaves at runtime even where
  # `npm install` only warns. Install the current LTS tarball into /opt,
  # mirroring the neovim install above.
  if ! command -v node >/dev/null 2>&1; then
    sudo apt-get purge -y nodejs npm libnode-dev libnode72 nodejs-doc 2>/dev/null
    node_version="$(curl -fsSL https://nodejs.org/dist/index.json \
      | python3 -c 'import json,sys; print(next(r["version"] for r in json.load(sys.stdin) if r["lts"]))')"
    case "$(uname -m)" in
      x86_64)        node_asset="node-${node_version}-linux-x64" ;;
      aarch64|arm64) node_asset="node-${node_version}-linux-arm64" ;;
      *) echo "No node tarball for arch $(uname -m); install node manually." >&2
         node_asset="" ;;
    esac
    if [ -n "$node_asset" ]; then
      tmp="$(mktemp -d)"
      curl -fsSL -o "$tmp/node.tar.xz" \
        "https://nodejs.org/dist/${node_version}/${node_asset}.tar.xz"
      sudo rm -rf /opt/node
      sudo tar -C /opt -xJf "$tmp/node.tar.xz"
      sudo mv "/opt/${node_asset}" /opt/node
      sudo ln -sf /opt/node/bin/node /usr/local/bin/node
      sudo ln -sf /opt/node/bin/npm /usr/local/bin/npm
      sudo ln -sf /opt/node/bin/npx /usr/local/bin/npx
      rm -rf "$tmp"
    fi
  fi

  # nvim-treesitter's `main` branch shells out to the `tree-sitter` CLI to
  # compile parsers (unlike the old master branch, which just needed cc).
  # It isn't packaged in apt. The prebuilt GitHub-release binaries are built
  # against a newer glibc than Ubuntu 22.04 ships, so they won't run here -
  # build it from source with cargo instead (needs libclang for bindgen).
  if ! command -v tree-sitter >/dev/null 2>&1 && [ ! -x /usr/local/bin/tree-sitter ]; then
    sudo apt-get install -y libclang-dev clang

    if ! command -v cargo >/dev/null 2>&1; then
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --profile minimal
      . "$HOME/.cargo/env"
    fi

    cargo install tree-sitter-cli
    # Symlink into a directory already on PATH so it works regardless of
    # which shell/rc files run - mirrors how nvim is linked above.
    sudo ln -sf "$HOME/.cargo/bin/tree-sitter" /usr/local/bin/tree-sitter
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
