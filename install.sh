#!/bin/bash
set -e

echo "=== Dotfiles installer ==="

# Install neovim if not present
if ! command -v nvim &>/dev/null; then
    echo "Installing Neovim..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y neovim
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y neovim
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm neovim
    elif command -v brew &>/dev/null; then
        brew install neovim
    else
        echo "No package manager found, installing from prebuilt binary..."
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
        mkdir -p ~/.local
        tar xzf nvim-linux-x86_64.tar.gz -C ~/.local --strip-components=1
        rm nvim-linux-x86_64.tar.gz
        export PATH="$HOME/.local/bin:$PATH"
        grep -q '.local/bin' ~/.bashrc 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi
    echo "Neovim installed: $(nvim --version | head -1)"
else
    echo "Neovim already installed: $(nvim --version | head -1)"
fi

# Install dependencies
for tool in git gcc make curl; do
    if ! command -v "$tool" &>/dev/null; then
        echo "WARNING: $tool is not installed. Some plugins may not work."
    fi
done

# Symlink nvim config
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
NVIM_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"

if [ -e "$NVIM_CONFIG" ]; then
    if [ -L "$NVIM_CONFIG" ]; then
        echo "Removing existing symlink at $NVIM_CONFIG"
        rm "$NVIM_CONFIG"
    else
        BACKUP="$NVIM_CONFIG.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up existing config to $BACKUP"
        mv "$NVIM_CONFIG" "$BACKUP"
    fi
fi

mkdir -p "$(dirname "$NVIM_CONFIG")"
ln -sf "$DOTFILES_DIR/nvim" "$NVIM_CONFIG"
echo "Linked $DOTFILES_DIR/nvim -> $NVIM_CONFIG"

# Bootstrap plugins (headless)
echo "Installing plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo "Run 'nvim' to start. Plugins will finish installing on first launch."
echo "Run ':Mason' inside nvim to manage LSP servers."
