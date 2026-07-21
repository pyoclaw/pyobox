#!/usr/bin/env bash
set -euo pipefail

# pyobox setup — bootstrap a fresh Linux system
# Idempotent: safe to run multiple times.
# Platform-aware: adapts to Android (Termux), Linux, macOS.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYOBOX_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "╔══════════════════════════════════════════════╗"
echo "║  pyobox setup                                ║"
echo "║  $PYOBOX_ROOT"
echo "╚══════════════════════════════════════════════╝"

# Source environment
source "$SCRIPT_DIR/lib.sh"
source "$SCRIPT_DIR/env/env.sh" 2>/dev/null || true

# Detect platform
detect_os
echo "  Platform: $OS / $PLATFORM / $ARCH"

# ── Phase 1: Install system packages ──
echo ""
echo "── Phase 1: System packages ──"
if [ "$PLATFORM" = "termux" ] && [ -f "$SCRIPT_DIR/packages/termux/termux.sh" ]; then
    source "$SCRIPT_DIR/packages/termux/termux.sh"
    install_packages_termux
elif [ -f "$SCRIPT_DIR/packages/$PKG_MANAGER.sh" ]; then
    source "$SCRIPT_DIR/packages/$PKG_MANAGER.sh"
    install_packages_$PKG_MANAGER
fi

# ── Phase 2: Install language runtimes ──
echo ""
echo "── Phase 2: Language runtimes ──"
if [ -f "$SCRIPT_DIR/packages/cargo.sh" ]; then
    source "$SCRIPT_DIR/packages/cargo.sh"
    install_cargo_tools
fi

# ── Phase 3: Deploy dotfiles ──
echo ""
echo "── Phase 3: Dotfiles (zsh, bash, git, starship, herdr, agent integrations) ──"
if [ -f "$SCRIPT_DIR/dotfiles/install.sh" ]; then
    source "$SCRIPT_DIR/dotfiles/install.sh"
    deploy_dotfiles
fi

# ── Phase 4: Build Rust workspace ──
echo ""
echo "── Phase 4: Build Rust workspace (8 crates) ──"
cd "$PYOBOX_ROOT"
cargo build --workspace --release 2>/dev/null || cargo build --workspace
echo "  ✓ Rust workspace built"

# ── Phase 5: Init submodules ──
echo ""
echo "── Phase 5: Submodules (clone VMM + minisqlite DB) ──"
git submodule init 2>/dev/null || true
git submodule update --depth 1 2>/dev/null || true
echo "  ✓ Submodules initialized"

# ── Phase 6: Install environment injection ──
echo ""
echo "── Phase 6: Environment injection (PYOBOX_* vars) ──"
install_env_injection
echo "  ✓ Environment injection installed"

# ── Phase 7: Generate agent integration files ──
echo ""
echo "── Phase 7: Agent integration files ──"
"$PYOBOX_ROOT/scripts/generate-agent-configs.sh" 2>/dev/null || true

# ── Phase 8: Start shared services ──
echo ""
echo "── Phase 8: Shared services ──"
"$PYOBOX_ROOT/services/start.sh" 2>/dev/null || true

# ── Phase 9: Install prompt templates ──
echo ""
echo "── Phase 9: Agent prompt templates ──"
if [ -d "$PYOBOX_ROOT/agent-context/prompts" ]; then
    mkdir -p "$HOME/.pi/agent/prompts"
    cp "$PYOBOX_ROOT/agent-context/prompts/"*.md "$HOME/.pi/agent/prompts/" 2>/dev/null || true
    echo "  ✓ 9 prompt templates deployed (commit, explain, review, test, refactor, debug, docs, tldr, triage)"
fi

echo ""
echo "✅ pyobox setup complete"
echo "   Run 'exec zsh' or 'source ~/.zshrc' to activate your new environment"
echo "   Run 'make fork-agent NAME=myagent BRANCH=feature/x' to start an agent worktree"
