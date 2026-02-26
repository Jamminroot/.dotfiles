#!/bin/bash
set -e

echo "=== Dotfiles installer ==="

NVIM_MIN_VERSION="0.11"

nvim_version_ok() {
    if ! command -v nvim &>/dev/null; then
        return 1
    fi
    local ver
    ver=$(nvim --version | head -1 | grep -oP '\d+\.\d+')
    printf '%s\n%s' "$NVIM_MIN_VERSION" "$ver" | sort -V -C
}

install_nvim_binary() {
    local arch os url
    arch=$(uname -m)
    os=$(uname -s)
    if [ "$os" = "Darwin" ]; then
        url="https://github.com/neovim/neovim/releases/latest/download/nvim-macos-${arch}.tar.gz"
    elif [ "$os" = "Linux" ]; then
        case "$arch" in
            x86_64)  url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" ;;
            aarch64) url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-aarch64.tar.gz" ;;
            *)       echo "Unsupported architecture: $arch"; return 1 ;;
        esac
    else
        echo "Unsupported OS: $os"; return 1
    fi
    local tmpdir
    tmpdir=$(mktemp -d)
    curl -fsSL "$url" -o "$tmpdir/nvim.tar.gz"
    mkdir -p "$HOME/.local"
    tar xzf "$tmpdir/nvim.tar.gz" -C "$HOME/.local" --strip-components=1
    rm -rf "$tmpdir"
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *)
            export PATH="$HOME/.local/bin:$PATH"
            for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
                [ -f "$rc" ] && grep -q '.local/bin' "$rc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
            done
            ;;
    esac
}

if nvim_version_ok; then
    echo "Neovim already installed and >= $NVIM_MIN_VERSION: $(nvim --version | head -1)"
else
    echo "Installing Neovim >= $NVIM_MIN_VERSION from GitHub release..."
    install_nvim_binary
    if nvim_version_ok; then
        echo "Neovim installed: $(nvim --version | head -1)"
    else
        echo "ERROR: Failed to install Neovim >= $NVIM_MIN_VERSION"
        exit 1
    fi
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

# Enable pre-commit hook for secret detection
git -C "$DOTFILES_DIR" config core.hooksPath hooks
echo "Pre-commit secret detection hook enabled"

# Bootstrap plugins (headless)
echo "Installing plugins..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

echo ""
echo "=== Done! ==="
echo "Run 'nvim' to start. Plugins will finish installing on first launch."
echo "Run ':Mason' inside nvim to manage LSP servers."
