#!/usr/bin/env bash
# Termux package installation (Android)
# Source me from bootstrap/setup.sh

install_packages_termux() {
    echo "  Installing Termux packages..."

    # Core system tools
    pkg install -y \
        git \
        zsh \
        bash \
        curl \
        wget \
        openssh \
        openssl-tool \
        python \
        nodejs \
        rust \
        make \
        cmake \
        clang \
        pkg-config \
        2>/dev/null || true

    # Modern CLI tools (Rust replacements)
    cargo install \
        eza \
        bat \
        fd-find \
        ripgrep \
        du-dust \
        procs \
        hyperfine \
        grex \
        2>/dev/null || true

    # Additional Termux packages
    pkg install -y \
        fzf \
        zoxide \
        starship \
        lazygit \
        just \
        curlie \
        watchexec \
        duf \
        htop \
        tldr \
        man \
        aria2 \
        2>/dev/null || true

    echo "  ✓ Termux packages installed"
}
