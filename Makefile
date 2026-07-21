.PHONY: all setup teardown build check test fmt clippy \
        fork-agent destroy-agent list-agents \
        generate-configs install-prompts \
        start-services stop-services \
        init-submodules update-submodules clean

# ── Top ──
all: build test

setup:
	./bootstrap/bootstrap.sh --setup

teardown:
	./bootstrap/bootstrap.sh --teardown

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
fork-agent:
	./scripts/fork-agent-vm.sh $(NAME) $(BRANCH)

destroy-agent:
	./scripts/destroy-agent-vm.sh $(NAME)

list-agents:
	./scripts/list-agents.sh

# ── Config ──
generate-configs:
	./scripts/generate-agent-configs.sh

install-prompts:
	@mkdir -p $(HOME)/.pi/agent/prompts
	@cp agent-context/prompts/*.md $(HOME)/.pi/agent/prompts/ 2>/dev/null || true
	@echo "  ✓ Prompt templates installed"

# ── Services ──
start-services:
	./services/start.sh

stop-services:
	./services/stop.sh

# ── Submodules ──
init-submodules:
	git submodule update --init --depth 1

update-submodules:
	git submodule update --remote

# ── Clean ──
clean:
	cargo clean
	rm -rf ../pyobox-worktrees/
	rm -f .pyobox/worktrees.toml
