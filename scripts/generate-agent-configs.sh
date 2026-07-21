#!/usr/bin/env bash
# generate-agent-configs.sh — Generate per-agent integration configs
# with actual environment values substituted in

PYOBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Source env
source "$PYOBOX_ROOT/bootstrap/env/env.sh" 2>/dev/null || true

detect_values() {
    PYOBOX_REPO="${PYOBOX_REPO:-$PYOBOX_ROOT}"
    PYOBOX_BRANCH="$(cd "$PYOBOX_ROOT" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'main')"
    PYOBOX_DB_URL="${PYOBOX_DB_URL:-http://localhost:8543}"
    PYOBOX_MAIN_REPO="${PYOBOX_MAIN_REPO:-$PYOBOX_REPO}"
    PYOBOX_WORKTREE_ID="${PYOBOX_WORKTREE_ID:-}"
}

generate_pi_config() {
    local tmpl="$PYOBOX_ROOT/agent-context/integrations/pi/settings.json"
    local target="$HOME/.pi/agent/settings.json"
    if [ -f "$tmpl" ]; then
        mkdir -p "$(dirname "$target")"
        cp "$tmpl" "$target"
        echo "  ✓ Pi config → $target"
    fi
}

generate_claude_config() {
    local tmpl="$PYOBOX_ROOT/agent-context/integrations/claude/settings.json"
    local target="$HOME/.claude/settings.json"
    if [ -f "$tmpl" ]; then
        mkdir -p "$(dirname "$target")"
        # Substitute template vars
        sed -e "s|{{PYOBOX_REPO}}|$PYOBOX_REPO|g" \
            -e "s|{{PYOBOX_DB_URL}}|$PYOBOX_DB_URL|g" \
            -e "s|{{PYOBOX_BRANCH}}|$PYOBOX_BRANCH|g" \
            -e "s|{{PYOBOX_WORKTREE_ID}}|$PYOBOX_WORKTREE_ID|g" \
            "$tmpl" > "$target"
        echo "  ✓ Claude config → $target"
    fi
}

generate_codex_config() {
    local tmpl="$PYOBOX_ROOT/agent-context/integrations/codex/settings.json"
    local target="$HOME/.codex/settings.json"
    if [ -f "$tmpl" ]; then
        mkdir -p "$(dirname "$target")"
        sed -e "s|{{PYOBOX_REPO}}|$PYOBOX_REPO|g" \
            -e "s|{{PYOBOX_DB_URL}}|$PYOBOX_DB_URL|g" \
            -e "s|{{PYOBOX_BRANCH}}|$PYOBOX_BRANCH|g" \
            "$tmpl" > "$target"
        echo "  ✓ Codex config → $target"
    fi
}

generate_herdr_hooks() {
    local tmpl="$PYOBOX_ROOT/agent-context/integrations/herdr/herdr-hooks.sh"
    local target="$HOME/.claude/hooks/herdr-agent-state.sh"
    if [ -f "$tmpl" ]; then
        mkdir -p "$(dirname "$target")"
        cp "$tmpl" "$target"
        chmod +x "$target"
        echo "  ✓ Herdr hooks → $target"
    fi
}

generate_agents_md() {
    local target="$PYOBOX_ROOT/AGENTS.md"
    echo "  ✓ AGENTS.md at $target (update values as needed)"
}

# Also install prompt templates
install_prompts() {
    local src="$PYOBOX_ROOT/agent-context/prompts"
    local target="$HOME/.pi/agent/prompts"
    if [ -d "$src" ]; then
        mkdir -p "$target"
        cp "$src/"*.md "$target/" 2>/dev/null || true
        echo "  ✓ Prompts → $target ($(ls "$src"/*.md 2>/dev/null | wc -l) templates)"
    fi
}

echo "🔧 Generating agent configs..."
detect_values
generate_pi_config
generate_claude_config
generate_codex_config
generate_herdr_hooks
install_prompts
echo "✅ Agent configs generated"
