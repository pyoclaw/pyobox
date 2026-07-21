# pyobox Architecture

## Overview

pyobox orchestrates reproducible development environments for AI coding agents.
It uses a layered architecture with clear seams, inspired by cursor/minisqlite.

## Layers

### 1. Bootstrap Layer
System provisioning: OS detection, package installation, dotfile deployment.
Works on Android (Termux), Linux, macOS.

### 2. Environment Injection Layer
Generates shell profiles that inject `PYOBOX_*` variables into every terminal session.
Supports bash, zsh, fish. Cross-compiles to WASM.

### 3. Agent Context Layer
Auto-generates AGENTS.md and per-agent config files (Claude Code, Codex, Pi, Gemini).
Agents automatically know their worktree, branch, and shared services.

### 4. Worktree Layer
Git worktree management: create, track, destroy isolated worktrees per agent.

### 5. Service Layer
Shared service orchestration: minisqlite server, migrations, health checks.

### 6. VMM Layer (Desktop only)
Clone VMM integration: fork KVM VMs via Shadow Clone in <20ms, inject env via vsock.

## Platform Adaptation

| Feature | Android | Web (WASM) | Desktop |
|---|---|---|---|
| Bootstrap | Termux + pkg | N/A | apt/brew/dnf |
| Env Injection | Shell profiles | String generation | Shell profiles |
| Agent Context | Full | Dashboard display | Full |
| Worktrees | Git worktree | Read-only | Git worktree |
| Shared DB | minisqlite | N/A | minisqlite server |
| VMM | Process isolation | N/A | Clone KVM |

## Crate Architecture

See `Cargo.toml` for the full workspace. Key dependencies:

- `pyobox-types` ← every crate depends on this
- `pyobox-facade` ← public API
- `pyobox-env` ← WASM-compatible (no file I/O on wasm32)
- `pyobox-vmm` ← Linux-only (Clone integration)
