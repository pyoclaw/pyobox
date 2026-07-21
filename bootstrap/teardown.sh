#!/usr/bin/env bash
set -euo pipefail

# pyobox teardown — remove all traces

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYOBOX_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧹 pyobox teardown"

# Stop services
"$PYOBOX_ROOT/services/stop.sh" 2>/dev/null || true

# Destroy agent worktrees
if [ -d "$PYOBOX_ROOT/../pyobox-worktrees" ]; then
    echo "  Removing worktrees..."
    rm -rf "$PYOBOX_ROOT/../pyobox-worktrees"
fi

# Remove tracking metadata
rm -f "$PYOBOX_ROOT/.pyobox/worktrees.toml"

# Remove env injection from shell profiles
for profile in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$profile" ]; then
        sed -i '/# === pyobox environment ===/,/# === end pyobox ===/d' "$profile" 2>/dev/null || true
    fi
done

echo "✅ pyobox teardown complete"
