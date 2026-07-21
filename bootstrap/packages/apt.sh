#!/usr/bin/env bash
# APT package installation (Debian/Ubuntu)

install_packages_apt() {
    echo "  Installing APT packages..."

    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        git \
        zsh \
        curl \
        wget \
        openssh-client \
        python3 \
        python3-pip \
        nodejs \
        npm \
        cargo \
        make \
        cmake \
        build-essential \
        libssl-dev \
        pkg-config \
        stow \
        2>/dev/null || true

    # Install Rust if not present
    if ! command -v rustc &>/dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi

    echo "  ✓ APT packages installed"
}
