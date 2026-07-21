# pyobox

> **A polyglot, multiplatform agent-environment box.**
> Android-first · Web-capable · Desktop-ready

**pyobox** bootstraps reproducible Linux development environments, injects agent-aware context into every terminal session, and orchestrates isolated worktrees for AI coding agents — powered by Clone VMM for KVM-level isolation on desktop or direct process management on Android/Web.

---

## Quick Start

```bash
# Clone + setup
git clone https://github.com/pyoclaw/pyobox.git
cd pyobox
make setup

# Fork an agent (desktop: KVM VM, android: process)
make fork-agent NAME=agent-x BRANCH=feature/auth

# Destroy when done
make destroy-agent NAME=agent-x

# Full teardown
make teardown
```

## Platform Support

| Platform | Isolation | Env Injection | Agent Context | Shared DB |
|---|---|---|---|---|
| **Android** (Termux) | Process | ✅ | ✅ | ✅ minisqlite |
| **Web** (WASM) | N/A | ✅ (generation) | ✅ (dashboard) | ❌ |
| **Desktop** (Linux) | Clone KVM VM | ✅ | ✅ | ✅ minisqlite |

## Architecture

```
pyobox daemon  ──►  fork agent VM/inject env ──►  agent works in worktree ──►  destroy
       │                      │                          │
       └── minisqlite ◄───────┴──── all agents hit same DB
```

See [`docs/architecture.md`](docs/architecture.md) for details.

## Repository Structure

```
pyobox/
├── crates/           # Rust workspace (8 crates)
│   ├── pyobox-types/ # Shared types, config, errors
│   ├── pyobox-env/   # Environment injection (bash/zsh/fish, WASM-compatible)
│   ├── pyobox-vmm/   # Clone VMM integration (Linux) / process launch (Android)
│   └── ...           # bootstrap, agent-context, worktree, services, facade
├── clone/            # Git submodule — pyoclaw/clone (VMM engine)
├── minisqlite/       # Git submodule — cursor/minisqlite (shared DB)
├── bootstrap/        # Shell scripts for system bootstrap
├── agent-context/    # Agent awareness protocol
├── services/         # Shared service scripts
├── scripts/          # Agent lifecycle scripts
└── docs/             # Documentation
```

## Environment Variables

Every managed session gets `PYOBOX_*` variables injected:

```bash
PYOBOX_ENV=1            # Managed session marker
PYOBOX_BRANCH=feat/a    # Current git branch (auto-updated)
PYOBOX_DB_URL=:8543     # Shared minisqlite database
PYOBOX_REPO=/.../pyobox # Monorepo path
PYOBOX_WORKTREE_ID=wt-3 # Worktree ID (if applicable)
```

## Agent Integration

CLI agents automatically know they're in a managed worktree:

| Agent | Config File | Format |
|---|---|---|
| Claude Code | `agent-context/integrations/claude/` | JSON |
| Codex | `agent-context/integrations/codex/` | JSON |
| Pi | `agent-context/integrations/pi/` | Markdown |
| Gemini | `agent-context/integrations/gemini/` | Text |

## License

MIT
