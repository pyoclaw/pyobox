#!/usr/bin/env bash
# Detect current worktree, branch, and repo context

detect_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

detect_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || echo ""
}

detect_worktree_id() {
    local repo_root
    repo_root="$(detect_repo_root)"
    if [ -n "$repo_root" ]; then
        # Check if we're in a worktree
        local main_repo
        main_repo="$(cd "$repo_root/.." && git rev-parse --show-toplevel 2>/dev/null || echo "")"
        if [ "$main_repo" != "$repo_root" ] && [ -n "$main_repo" ]; then
            echo "$(basename "$repo_root")"
        fi
    fi
    echo ""
}

main() {
    local branch repo worktree
    branch="$(detect_branch)"
    repo="$(detect_repo_root)"
    worktree="$(detect_worktree_id)"

    echo "PYOBOX_BRANCH=$branch"
    echo "PYOBOX_MAIN_REPO=$repo"
    echo "PYOBOX_WORKTREE_ID=$worktree"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main
fi
