#!/usr/bin/env bash
# pyobox shared library — sourced by setup/teardown scripts

detect_os() {
    ARCH="$(uname -m)"
    
    if [ -n "${TERMUX_VERSION:-}" ]; then
        PLATFORM="termux"
        PKG_MANAGER="apt"
        OS="android"
    elif [ "$(uname)" = "Linux" ]; then
        OS="linux"
        if command -v apt &>/dev/null; then
            PKG_MANAGER="apt"
        elif command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
        elif command -v apk &>/dev/null; then
            PKG_MANAGER="apk"
        else
            PKG_MANAGER="unknown"
        fi
    elif [ "$(uname)" = "Darwin" ]; then
        OS="macos"
        PKG_MANAGER="brew"
    else
        OS="unknown"
        PKG_MANAGER="unknown"
    fi
}

install_env_injection() {
    local inject_script="$PYOBOX_ROOT/agent-context/init.sh"
    
    if [ ! -f "$inject_script" ]; then
        echo "  ⚠️  agent-context/init.sh not found, skipping"
        return
    fi

    # Install into bashrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "pyobox" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "# pyobox environment injection" >> "$HOME/.bashrc"
            echo "source $inject_script" >> "$HOME/.bashrc"
            echo "  ✓ Added to ~/.bashrc"
        fi
    fi

    # Install into zshrc
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "pyobox" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# pyobox environment injection" >> "$HOME/.zshrc"
            echo "source $inject_script" >> "$HOME/.zshrc"
            echo "  ✓ Added to ~/.zshrc"
        fi
    fi
}
