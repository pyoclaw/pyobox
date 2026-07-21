#!/usr/bin/env bats

load 'setup.bats'

@test "agent-context: init.sh exports PYOBOX_ENV" {
    source "$PYOBOX_REPO/agent-context/init.sh"
    [ "$PYOBOX_ENV" = "1" ]
}

@test "agent-context: detect.sh outputs branch" {
    cd "$PYOBOX_REPO"
    result="$(bash agent-context/detect.sh)"
    echo "$result" | grep -q "PYOBOX_BRANCH="
}

@test "agent-context: detect.sh outputs repo root" {
    cd "$PYOBOX_REPO"
    result="$(bash agent-context/detect.sh)"
    echo "$result" | grep -q "PYOBOX_MAIN_REPO="
}
