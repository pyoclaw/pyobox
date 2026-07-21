#!/usr/bin/env bash
# Cargo tools installation (cross-platform)

install_cargo_tools() {
    echo "  Installing Cargo tools..."

    local tools=(
        "eza"
        "bat"
        "fd-find"
        "ripgrep"
        "du-dust"
        "procs"
        "hyperfine"
        "grex"
        "just"
    )

    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &>/dev/null && ! cargo install --list 2>/dev/null | grep -q "$tool"; then
            echo "    Installing $tool..."
            cargo install "$tool" 2>/dev/null || true
        fi
    done

    echo "  ✓ Cargo tools installed"
}
