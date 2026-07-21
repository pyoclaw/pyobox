#!/usr/bin/env bash
set -euo pipefail

# fork-agent-vm.sh — Create a new agent worktree + VM
# Usage: ./scripts/fork-agent-vm.sh <agent-name> <branch>

AGENT_NAME="${1:-}"
BRANCH="${2:-}"

if [ -z "$AGENT_NAME" ] || [ -z "$BRANCH" ]; then
    echo "Usage: $0 <agent-name> <branch>"
    exit 1
fi

PYOBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREES_DIR="$PYOBOX_ROOT/../pyobox-worktrees"
AGENT_PATH="$WORKTREES_DIR/$AGENT_NAME"

echo "🚀 Forking agent: $AGENT_NAME (branch: $BRANCH)"

# 1. Create git worktree
mkdir -p "$WORKTREES_DIR"
cd "$PYOBOX_ROOT"
git worktree add "$AGENT_PATH" "$BRANCH" 2>/dev/null || {
    git branch "$BRANCH" 2>/dev/null || true
    git worktree add "$AGENT_PATH" "$BRANCH"
}

# 2. Register metadata
mkdir -p "$PYOBOX_ROOT/.pyobox"
cat >> "$PYOBOX_ROOT/.pyobox/worktrees.toml" << EOF
[[worktrees]]
id = "wt-$(date +%s)"
name = "$AGENT_NAME"
path = "$AGENT_PATH"
branch = "$BRANCH"
agent_kind = "unknown"
created_at = "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
EOF

# 3. Fork VM (if KVM available) or print instructions
if [ -e /dev/kvm ] && command -v clone &>/dev/null; then
    echo "  Forking Clone VM..."
    # clone fork --template /templates/dev --net --shared-dir "$AGENT_PATH:worktree"
fi

echo "✅ Agent '$AGENT_NAME' created at $AGENT_PATH"
echo "   cd $AGENT_PATH && source $PYOBOX_ROOT/agent-context/init.sh"
