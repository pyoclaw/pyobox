#!/usr/bin/env bash
# Deploy pyobox dotfiles
# Works with GNU Stow (preferred) or manual symlinks
# Supports: bash, zsh, git, tmux, ssh, starship, herdr, nano

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "  Deploying dotfiles..."

# Build a mapping of source dirs to target locations
# Format: sourcedir:targetdir
DOTFILE_DIRS=(
    "bash:$HOME"
    "zsh:$HOME"
    "git:$HOME"
    "starship:$HOME/.config"
    "tmux:$HOME"
)

if command -v stow &>/dev/null; then
    # Use GNU Stow — clean symlink farm
    for entry in "${DOTFILE_DIRS[@]}"; do
        sourcedir="${entry%%:*}"
        targetdir="${entry##*:}"
        if [ -d "$SCRIPT_DIR/$sourcedir" ]; then
            mkdir -p "$targetdir"
            stow -R -t "$targetdir" -d "$SCRIPT_DIR" "$sourcedir" 2>/dev/null || true
            echo "  ✓ stow: $sourcedir → $targetdir"
        fi
    done

    # Stow SSH separately (permission-sensitive)
    if [ -d "$SCRIPT_DIR/ssh" ]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        stow -R -t "$HOME" -d "$SCRIPT_DIR" "ssh" 2>/dev/null || true
    fi
else
    # Manual symlink fallback
    for f in "$SCRIPT_DIR/bash/.bashrc" "$SCRIPT_DIR/bash/.bash_profile"; do
        [ -f "$f" ] && ln -sf "$f" "$HOME/$(basename "$f")"
    done
    for f in "$SCRIPT_DIR/zsh/.zshrc" "$SCRIPT_DIR/zsh/.zshenv"; do
        [ -f "$f" ] && ln -sf "$f" "$HOME/$(basename "$f")"
    done
    [ -f "$SCRIPT_DIR/git/.gitconfig" ] && ln -sf "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig"
    [ -f "$SCRIPT_DIR/starship/starship.toml" ] && {
        mkdir -p "$HOME/.config"
        ln -sf "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    }
    [ -f "$SCRIPT_DIR/tmux/.tmux.conf" ] && ln -sf "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    echo "  ✓ Dotfiles deployed (manual symlinks)"
fi

# Deploy agent integrations
if [ -d "$SCRIPT_DIR/../../agent-context/integrations" ]; then
    AGENT_INTEGRATIONS="$SCRIPT_DIR/../../agent-context/integrations"

    # Pi integration
    if [ -f "$AGENT_INTEGRATIONS/pi/settings.json" ]; then
        mkdir -p "$HOME/.pi/agent"
        cp "$AGENT_INTEGRATIONS/pi/settings.json" "$HOME/.pi/agent/settings.json" 2>/dev/null || true
        echo "  ✓ Pi agent settings deployed"
    fi

    # Claude integration
    if [ -f "$AGENT_INTEGRATIONS/claude/settings.json" ]; then
        mkdir -p "$HOME/.claude"
        cp "$AGENT_INTEGRATIONS/claude/settings.json" "$HOME/.claude/settings.json" 2>/dev/null || true
        echo "  ✓ Claude agent settings deployed"
    fi

    # Herdr hooks
    if [ -f "$AGENT_INTEGRATIONS/herdr/herdr-hooks.sh" ]; then
        mkdir -p "$HOME/.claude/hooks"
        cp "$AGENT_INTEGRATIONS/herdr/herdr-hooks.sh" "$HOME/.claude/hooks/herdr-agent-state.sh" 2>/dev/null || true
        chmod +x "$HOME/.claude/hooks/herdr-agent-state.sh"
        echo "  ✓ Herdr hooks deployed"
    fi

    # Workflow settings
    if [ -f "$AGENT_INTEGRATIONS/../../agent-context/workflows/settings.json" ]; then
        mkdir -p "$HOME/.pi/workflows"
        cp "$AGENT_INTEGRATIONS/../../agent-context/workflows/settings.json" "$HOME/.pi/workflows/settings.json" 2>/dev/null || true
        echo "  ✓ Workflow settings deployed"
    fi
fi

echo "  ✓ All dotfiles deployed"
