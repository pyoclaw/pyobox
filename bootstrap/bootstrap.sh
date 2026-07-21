#!/usr/bin/env bash
# pyobox bootstrap — unified setup & teardown
# Usage: bootstrap.sh [--setup|--teardown]
# Idempotent, platform-aware (Termux/Linux/macOS)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYOBOX_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Detect platform ──
detect_os() {
  ARCH="$(uname -m)"
  if [ -n "${TERMUX_VERSION:-}" ]; then
    PLATFORM="termux"; PKG_MANAGER="apt"; OS="android"
  elif [ "$(uname)" = "Linux" ]; then
    OS="linux"
    command -v apt &>/dev/null && PKG_MANAGER="apt" || \
    command -v dnf &>/dev/null && PKG_MANAGER="dnf" || \
    command -v apk &>/dev/null && PKG_MANAGER="apk" || \
    PKG_MANAGER="unknown"
  elif [ "$(uname)" = "Darwin" ]; then
    OS="macos"; PKG_MANAGER="brew"
  else
    OS="unknown"; PKG_MANAGER="unknown"
  fi
}

# ── Install dependencies ──
install_deps() {
  echo "── Phase 1: Installing packages ──"
  if [ "$PLATFORM" = "termux" ]; then
    pkg install -y git zsh bash curl wget openssh openssl-tool \
      python nodejs rust make cmake clang pkg-config \
      fzf zoxide starship lazygit just curlie watchexec \
      duf htop tldr man aria2 2>/dev/null || true
    cargo install eza bat fd-find ripgrep du-dust procs \
      hyperfine grex 2>/dev/null || true
  elif command -v "install_packages_$PKG_MANAGER" &>/dev/null; then
    "install_packages_$PKG_MANAGER"
  fi
}

# ── Deploy dotfiles ──
deploy_dotfiles() {
  echo "── Phase 2: Dotfiles ──"
  local DOTFILES="$PYOBOX_ROOT/bootstrap/dotfiles"

  if command -v stow &>/dev/null; then
    stow -R -t "$HOME" -d "$DOTFILES" bash git zsh config 2>/dev/null || true
  else
    [ -f "$DOTFILES/bash/.bashrc" ]  && ln -sf "$DOTFILES/bash/.bashrc" "$HOME/.bashrc"
    [ -f "$DOTFILES/zsh/.zshrc" ]    && ln -sf "$DOTFILES/zsh/.zshrc" "$HOME/.zshrc"
    [ -f "$DOTFILES/git/.gitconfig" ] && ln -sf "$DOTFILES/git/.gitconfig" "$HOME/.gitconfig"
    [ -f "$DOTFILES/herdr/config.toml" ] && {
      mkdir -p "$HOME/.config/herdr"
      ln -sf "$DOTFILES/herdr/config.toml" "$HOME/.config/herdr/config.toml"
    }
  fi
  # Deploy starship config
  mkdir -p "$HOME/.config"
  ln -sf "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml"

  # Deploy agent integration configs
  local INTEGRATIONS="$PYOBOX_ROOT/agent-context/integrations"
  mkdir -p "$HOME/.pi/agent" "$HOME/.claude/hooks" "$HOME/.pi/workflows"
  [ -f "$INTEGRATIONS/pi/settings.json" ] && \
    cp "$INTEGRATIONS/pi/settings.json" "$HOME/.pi/agent/settings.json" 2>/dev/null || true
  [ -f "$INTEGRATIONS/claude/settings.json" ] && \
    cp "$INTEGRATIONS/claude/settings.json" "$HOME/.claude/settings.json" 2>/dev/null || true
  [ -f "$INTEGRATIONS/herdr/herdr-hooks.sh" ] && {
    cp "$INTEGRATIONS/herdr/herdr-hooks.sh" "$HOME/.claude/hooks/herdr-agent-state.sh"
    chmod +x "$HOME/.claude/hooks/herdr-agent-state.sh"
  }
  [ -f "$PYOBOX_ROOT/agent-context/workflows/settings.json" ] && \
    cp "$PYOBOX_ROOT/agent-context/workflows/settings.json" "$HOME/.pi/workflows/settings.json" 2>/dev/null || true
}

# ── Install prompt templates ──
install_prompts() {
  echo "── Phase 3: Agent prompt templates ──"
  local src="$PYOBOX_ROOT/agent-context/prompts"
  local target="$HOME/.pi/agent/prompts"
  if [ -d "$src" ]; then
    mkdir -p "$target"
    cp "$src/"*.md "$target/" 2>/dev/null || true
    echo "  ✓ $(ls "$src"/*.md 2>/dev/null | wc -l) templates deployed"
  fi
}

# ── Build Rust workspace ──
build_rust() {
  echo "── Phase 4: Build Rust workspace ──"
  cd "$PYOBOX_ROOT"
  cargo build --workspace
  echo "  ✓ Workspace built"
}

# ── Init submodules ──
init_submodules() {
  echo "── Phase 5: Submodules ──"
  git submodule init 2>/dev/null || true
  git submodule update --depth 1 2>/dev/null || true
  echo "  ✓ Submodules ready"
}

# ── Install env injection ──
install_env_injection() {
  local inject="$PYOBOX_ROOT/agent-context/init.sh"
  [ -f "$inject" ] || return
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] && grep -q "pyobox" "$rc" && continue || true
    { echo ""; echo "# pyobox environment injection"; echo "source $inject"; } >> "$rc" 2>/dev/null || true
  done
  echo "  ✓ Environment injection installed"
}

# ── Setup ──
do_setup() {
  echo "╔═══════════════════════════════════╗"
  echo "║  pyobox setup  —  $OS/$PLATFORM  ║"
  echo "╚═══════════════════════════════════╝"
  detect_os
  install_deps
  deploy_dotfiles
  install_prompts
  build_rust
  init_submodules
  install_env_injection
  "$PYOBOX_ROOT/scripts/generate-agent-configs.sh" 2>/dev/null || true
  "$PYOBOX_ROOT/services/start.sh" 2>/dev/null || true
  echo ""
  echo "✅ Setup complete. Run 'exec zsh' or 'exec bash' to activate."
}

# ── Teardown ──
do_teardown() {
  echo "🧹 pyobox teardown"
  "$PYOBOX_ROOT/services/stop.sh" 2>/dev/null || true
  rm -rf "$PYOBOX_ROOT/../pyobox-worktrees" "$PYOBOX_ROOT/.pyobox/worktrees.toml" 2>/dev/null || true
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] && sed -i '/# pyobox environment/,/# end pyobox/d' "$rc" 2>/dev/null || true
  done
  echo "✅ Teardown complete"
}

# ── Main ──
case "${1:---setup}" in
  --setup|setup)   do_setup ;;
  --teardown|teardown) do_teardown ;;
  --help|-h)       echo "Usage: bootstrap.sh [--setup|--teardown]" ;;
  *)               echo "Unknown: $1. Use --setup or --teardown"; exit 1 ;;
esac
