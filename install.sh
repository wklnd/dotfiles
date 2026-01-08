#!/usr/bin/env sh

set -e

OS="$(uname -s)"

echo "==> Detecting OS"
case "$OS" in
    Darwin)
        PLATFORM="macos"
        ;;
    Linux)
        if [ -f /etc/fedora-release ]; then
            PLATFORM="fedora"
        else
            echo "Unsupported Linux distro. Only Fedora is supported currently. "
            exit 1
        fi
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "==> Platform: $PLATFORM"

install_zsh() {
    if command -v zsh >/dev/null 2>&1; then
        echo "zsh already installed, skipping"
        return
    fi

    echo "==> Installing zsh"
    case "$PLATFORM" in
        macos)
            if ! command -v brew >/dev/null 2>&1; then
                echo "Homebrew not found. Install it first:"
                echo "https://brew.sh"
                exit 1
            fi
            brew install zsh
            ;;
        fedora)
            sudo dnf install -y zsh
            ;;
    esac
}

install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "oh-my-zsh already installed, skipping"
        return
    fi

    echo "==> Installing oh-my-zsh"
    RUNZSH=no CHSH=no sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_starship() {
    if command -v starship >/dev/null 2>&1; then
        echo "starship already installed, skipping"
        return
    fi

    echo "==> Installing starship"
    curl -sS https://starship.rs/install.sh | sh
}

install_plugins() {
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    PLUGINS_DIR="$ZSH_CUSTOM/plugins"

    mkdir -p "$PLUGINS_DIR"

    echo "==> Installing zsh plugins"

    if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$PLUGINS_DIR/zsh-autosuggestions"
    else
        echo "zsh-autosuggestions already exists, skipping"
    fi

    if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting \
            "$PLUGINS_DIR/zsh-syntax-highlighting"
    else
        echo "zsh-syntax-highlighting already exists, skipping"
    fi
}

echo "==> Starting setup"

install_zsh
install_oh_my_zsh
install_starship
install_plugins

echo
echo "==> Done"
echo
echo "Left todo: "
echo "  1) Set default shell:"
echo "     chsh -s \$(which zsh)"
echo
echo "  2) In ~/.zshrc:"
echo "     plugins=(git zsh-autosuggestions zsh-syntax-highlighting)"
echo "     eval \"\$(starship init zsh)\""
