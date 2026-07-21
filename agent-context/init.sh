#!/usr/bin/env bash
# pyobox agent environment — source me at shell start
# Injects PYOBOX_* variables into every terminal session

export PYOBOX_ENV=1

# Detect repository root
if [ -n "${BASH_SOURCE:-}" ]; then
    export PYOBOX_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd 2>/dev/null || echo '')"
elif [ -n "${(%):-%x:-}" ]; then
    export PYOBOX_REPO="$(cd "$(dirname "${(%):-%x}")/.." && pwd 2>/dev/null || echo '')"
fi

# Detect worktree context via git
if command -v git &>/dev/null; then
    export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
    export PYOBOX_MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null || echo '')"

    # Check if we're in a pyobox worktree
    if [ -f "$PYOBOX_MAIN_REPO/../.pyobox/worktrees.toml" ] 2>/dev/null; then
        export PYOBOX_WORKTREE_ID="wt-1"  # TODO: parse from TOML
    else
        export PYOBOX_WORKTREE_ID=""
    fi
fi

# Session ID
export PYOBOX_SESSION="$(date +%s)-$$"

# Display context on first load
if [ -z "${PYOBOX_LOADED:-}" ]; then
    export PYOBOX_LOADED=1
    echo "📦 pyobox: $PYOBOX_BRANCH ($PYOBOX_REPO)" >&2
fi
