#!/usr/bin/env bash
# list-agents.sh — Show all active pyobox agents

PYOBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREES_DIR="$PYOBOX_ROOT/../pyobox-worktrees"

echo "📋 Active pyobox agents"
echo ""

if [ ! -d "$WORKTREES_DIR" ]; then
    echo "  No active agents (worktrees directory not found)"
    exit 0
fi

for agent_dir in "$WORKTREES_DIR"/*/; do
    if [ -d "$agent_dir" ]; then
        name="$(basename "$agent_dir")"
        branch="$(cd "$agent_dir" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
        echo "  $name  (branch: $branch)"
    fi
done
