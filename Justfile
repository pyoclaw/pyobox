# pyobox Justfile — modern command runner
# Replaces much of Makefile with faster `just` recipes
# Uses: https://github.com/casey/just

# ── Build ──
build:
    cargo build --workspace

build-release:
    cargo build --workspace --release

build-wasm:
    cargo build --target wasm32-unknown-unknown --workspace

check:
    cargo check --workspace

fmt:
    cargo fmt -- --check

clippy:
    cargo clippy --workspace -- -D warnings

# ── Test ──
test:
    cargo test --workspace

test-bats:
    bats tests/*.bats

# ── Agent lifecycle ──
fork-agent name branch:
    ./scripts/fork-agent-vm.sh {{name}} {{branch}}

destroy-agent name:
    ./scripts/destroy-agent-vm.sh {{name}}

list-agents:
    ./scripts/list-agents.sh

# ── Setup / Teardown ──
setup:
    ./bootstrap/bootstrap.sh --setup

teardown:
    ./bootstrap/bootstrap.sh --teardown

# ── Config ──
generate-configs:
    ./scripts/generate-agent-configs.sh

# ── Services ──
start-services:
    ./services/start.sh

stop-services:
    ./services/stop.sh

# ── Clean ──
clean:
    cargo clean
    rm -rf ../pyobox-worktrees/
    rm -f .pyobox/worktrees.toml

# ── Default ──
default: build test
