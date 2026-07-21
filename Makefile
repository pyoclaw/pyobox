.PHONY: all setup teardown build test check clean fmt clippy \
        fork-agent destroy-agent list-agents inject-env \
        build-templates start-services stop-services \
        init-submodules update-submodules \
        generate-configs install-dotfiles install-prompts

# ── Top-level ────────────────────────────────────────────────────────────

all: build test

setup:
	./bootstrap/setup.sh

teardown:
	./bootstrap/teardown.sh

# ── Build ────────────────────────────────────────────────────────────────

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

# ── Test ─────────────────────────────────────────────────────────────────

test:
	cargo test --workspace

test-bats:
	@echo "Running Bats integration tests..."
	./tests/setup.bats
	./tests/agent-context.bats
	./tests/services.bats

# ── Agent lifecycle ──────────────────────────────────────────────────────

fork-agent:
	./scripts/fork-agent-vm.sh $(NAME) $(BRANCH)

destroy-agent:
	./scripts/destroy-agent-vm.sh $(NAME)

list-agents:
	./scripts/list-agents.sh

inject-env:
	./scripts/inject-env.sh $(NAME) $(filter-out $@,$(MAKECMDGOALS))

# ── Configuration ────────────────────────────────────────────────────────

generate-configs:
	./scripts/generate-agent-configs.sh

install-dotfiles:
	./bootstrap/dotfiles/install.sh

install-prompts:
	@mkdir -p $(HOME)/.pi/agent/prompts
	@cp agent-context/prompts/*.md $(HOME)/.pi/agent/prompts/ 2>/dev/null || true
	@echo "  ✓ Prompt templates installed"

# ── Services ─────────────────────────────────────────────────────────────

start-services:
	./services/start.sh

stop-services:
	./services/stop.sh

# ── Templates ────────────────────────────────────────────────────────────

build-templates:
	./templates/dev/build.sh
	./templates/dev/warm.sh

# ── Submodules ───────────────────────────────────────────────────────────

init-submodules:
	git submodule init
	git submodule update --depth 1

update-submodules:
	git submodule update --remote

# ── Clean ────────────────────────────────────────────────────────────────

clean:
	cargo clean
	rm -rf ../pyobox-worktrees/
	rm -f .pyobox/worktrees.toml
