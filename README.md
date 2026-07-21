# pyobox

**Polyglot, multiplatform agent-environment box** — bootstraps reproducible Linux systems, injects agent-aware context into every terminal session, and orchestrates isolated worktrees for AI coding agents.

## Quick start

```bash
git clone --recursive https://github.com/pyoclaw/pyobox.git
cd pyobox
make setup                    # or: just setup
```

## What this is

pyobox is an **agent orchestrator**. It gives every CLI agent (Pi, Claude Code, Codex, Gemini) a shared context — worktree, branch, DB URL, session ID — so they cooperate instead of colliding.

### Core ideas

- **Rust core** — safe, fast, cross-compiles to Android (Termux), WASM, and Linux
- **Bash bootstrap** — zero-dependency setup works everywhere, chicken-and-egg proof
- **Clone VMM** — pyoclaw/clone submodule, KVM Shadow Clone fork in <20ms (Linux)
- **Minisqlite** — cursor/minisqlite submodule, SQLite-compatible shared DB
- **Agent context protocol** — every agent knows its worktree, branch, main repo, and shared services via environment vars
- **Unsafe-free** — `#![forbid(unsafe_code)]` in all library crates

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     pyobox-facade                        │
│              Pyobox::new() → setup/fork/destroy          │
├──────┬──────┬──────┬──────┬──────┬──────┬──────┬───────┤
│ types│bootstrap│ env │agent-│work-│server │ vmm │ wasm  │
│      │        │     │context│ tree│-ices  │     │(web)  │
└──────┴──────┬──┴─────┴──────┴──────┴──────┴──┬───┴──────┘
              │                                  │
         bash scripts                     clone/ + minisqlite/
    (bootstrap/setup.sh)                   (git submodules)
```

## Directory layout

```
pyobox/
├── .cargo/config.toml         # Build optimizations
├── .github/workflows/ci.yml   # CI pipeline
├── Cargo.toml                 # Rust workspace (8 crates, edition 2024)
├── Justfile                   # Modern command runner
├── Makefile                   # Legacy recipes (delegates to just patterns)
├── bootstrap/
│   ├── bootstrap.sh           # Unified setup/teardown (platform-aware)
│   ├── dotfiles/              # zsh, bash, git, starship, herdr configs
│   ├── env/env.sh             # PYOBOX_* defaults
│   └── packages/              # termux.sh, apt.sh, cargo.sh
├── clone/ → pyoclaw/clone     # KVM VMM submodule
├── minisqlite/ → cursor/…     # SQLite-compatible DB submodule
├── agent-context/
│   ├── init.sh / detect.sh    # Env injection + agent detection
│   ├── prompts/               # 9 agent prompt templates
│   ├── integrations/           # Pi, Claude, Codex, Herdr settings
│   ├── workflows/settings.json
│   └── completions/_pyobox    # Zsh completion
├── crates/                    # 8 Rust crates
├── scripts/                   # fork-agent, destroy-agent, list-agents
├── services/                  # minisqlite start/stop + migrations
├── docs/                      # architecture.md, environment.md
├── templates/                 # Clone VM build/warm scripts
└── tests/                     # bats integration tests
```

## Platform tiers

| Tier | Platform | VMM | Status |
|------|----------|-----|--------|
| 🥇 | Android (Termux) | Process isolation | ✅ Active |
| 🥈 | Web (WASM) | N/A (env-only) | ⏳ Planned |
| 🥉 | Linux (Desktop) | KVM + Clone | ⏳ Planned |

## Agent context protocol

Every managed session exports:

| Variable | Description |
|----------|-------------|
| `PYOBOX_ENV=1` | Managed session marker |
| `PYOBOX_REPO` | Monorepo root |
| `PYOBOX_BRANCH` | Current git branch |
| `PYOBOX_MAIN_REPO` | Main repo path |
| `PYOBOX_WORKTREE_ID` | Worktree ID (if any) |
| `PYOBOX_DB_URL` | Shared minisqlite URL |
| `PYOBOX_DB_TYPE=minisqlite` | DB backend |
| `PYOBOX_SESSION` | Unique session UUID |
| `PYOBOX_AGENT` | Auto-detected agent name |

## Requirements

- **Rust** 1.85+ (edition 2024)
- **Git** 2.30+
- **Platform deps**: see `bootstrap/packages/`

### Optional but recommended

- `just` — fast command runner (`cargo install just`)
- `eza`, `bat`, `fd`, `rg` — modern CLI tools (installed by bootstrap)

## Development

```bash
cargo check --workspace      # Quick check
cargo test --workspace       # All tests
make clippy                  # Lints (deny warnings)
just build-release           # Optimized build
./bootstrap/bootstrap.sh --setup   # Full bootstrap
```

## License

MIT
