setup_taskfile() {
    export PYOBOX_TEST_DIR="$(mktemp -d)"
    export PYOBOX_REPO="$PYOBOX_TEST_DIR/repo"
    export PYOBOX_WORKTREES_DIR="$PYOBOX_TEST_DIR/worktrees"

    # Init test repo
    mkdir -p "$PYOBOX_REPO"
    cd "$PYOBOX_REPO"
    git init
    git config user.email "test@pyobox.dev"
    git config user.name "Test"
    echo "# test" > README.md
    git add .
    git commit -m "init"
    git branch feature/test
}

teardown_taskfile() {
    rm -rf "${PYOBOX_TEST_DIR:-}"
}
