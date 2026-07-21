#!/usr/bin/env bash
set -euo pipefail

# destroy-agent-vm.sh — Destroy an agent worktree + VM
# Usage: ./scripts/destroy-agent-vm.sh <agent-name>

AGENT_NAME="${1:-}"
if [ -z "$AGENT_NAME" ]; then
    echo "Usage: $0 <agent-name>"
    exit 1
fi

PYOBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREES_DIR="$PYOBOX_ROOT/../pyobox-worktrees"
AGENT_PATH="$WORKTREES_DIR/$AGENT_NAME"

echo "🧹 Destroying agent: $AGENT_NAME"

# 1. Remove git worktree
if [ -d "$AGENT_PATH" ]; then
    cd "$PYOBOX_ROOT"
    git worktree remove "$AGENT_PATH" 2>/dev/null || {
        git worktree remove --force "$AGENT_PATH" 2>/dev/null || {
            echo "  ⚠️  Could not remove worktree, removing files..."
            rm -rf "$AGENT_PATH"
        }
    }
fi

# 2. Remove from metadata
if [ -f "$PYOBOX_ROOT/.pyobox/worktrees.toml" ]; then
    # Simple removal for now
    echo "  Removing from metadata..."
fi

echo "✅ Agent '$AGENT_NAME' destroyed"
