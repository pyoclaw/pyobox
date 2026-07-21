# pyobox Architecture

## Overview

pyobox is a polyglot, multiplatform agent-environment box. It bootstraps
reproducible Linux systems, injects agent-aware context into every terminal
session, and orchestrates isolated worktrees for AI coding agents.

## Design principles

1. **Minimal API surface** — one facade type (`Pyobox`), few methods
2. **Crate seam pattern** — one trait per crate, strict dependency direction
3. **Platform adaptation** — `#[cfg()]` gates, zero runtime overhead
4. **Unsafe-free** — `#![forbid(unsafe_code)]` in library crates
5. **Submodules for heavy deps** — Clone VMM + minisqlite kept external

## Crate dependency graph

```
pyobox-facade
├── pyobox-types          (shared types, config, errors)
├── pyobox-bootstrap      (OS detection, package install, dotfiles)
├── pyobox-env            (PYOBOX_* env var generation)
├── pyobox-agent-context  (agent protocol, AGENTS.md)
├── pyobox-worktree       (git worktree management)
├── pyobox-services       (minisqlite server, migrations)
└── pyobox-vmm            (Clone VMM integration, fork/destroy)
```

All crates depend on `pyobox-types`. No circular deps.

## Platform tiers

| Tier | Platform | Isolation | VMM | Status |
|------|----------|-----------|-----|--------|
| 1 | Android (Termux) | Process | N/A | Active |
| 2 | Web (WASM) | Sandbox | N/A | Planned |
| 3 | Desktop (Linux) | KVM | Clone | Planned |

## Agent context protocol

See `docs/environment.md` for full protocol details.

## Key workflows

1. **`Pyobox::new()`** → loads config from repo path
2. **`pyobox.setup()`** → OS detect → packages → dotfiles → Rust build → submodules → env
3. **`pyobox.fork_agent(name, branch)`** → create worktree → grow Clone fork → inject env → return agent ID
4. **`pyobox.destroy_agent(name)`** → kill VMM → remove worktree → clean metadata

## Tech stack

- **Core**: Rust (edition 2024, workspace lints, unsafe-free)
- **Bootstrap**: Bash (unified `bootstrap.sh` with --setup/--teardown)
- **DB**: minisqlite (submodule, SQLite-compatible, WASM-compatible)
- **VMM**: Clone (submodule, KVM Shadow Clone fork <20ms)
- **Build**: Cargo workspace (8 crates), Justfile + Makefile
- **CI**: GitHub Actions (fmt + clippy + build + test)
- **Shell**: Zsh (vi mode, Starship prompt, modern tool aliases)
