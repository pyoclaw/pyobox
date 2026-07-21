# Environment Variable Reference

## Standard Variables (set by `agent-context/init.sh`)

| Variable | Example | Description |
|---|---|---|
| `PYOBOX_ENV` | `1` | Marker: this session is managed by pyobox |
| `PYOBOX_REPO` | `/home/user/pyobox` | Absolute path to the pyobox monorepo |
| `PYOBOX_BRANCH` | `feature/auth` | Current git branch (auto-updated on every prompt) |
| `PYOBOX_MAIN_REPO` | `/home/user/pyobox` | Path to the main (non-worktree) repo |
| `PYOBOX_WORKTREE_ID` | `wt-3` | Unique worktree ID (empty if main repo) |
| `PYOBOX_SESSION` | `1700000000-12345` | Unique session ID (timestamp-PID) |
| `PYOBOX_DB_URL` | `http://localhost:8543` | Shared minisqlite server URL |
| `PYOBOX_DB_TYPE` | `minisqlite` | Database backend identifier |
| `PYOBOX_SERVICES` | `minisqlite:8543` | Comma-separated list of available services |
| `HERDR_ENV` | `1` | Pass-through for Herdr compatibility |

## Detection Variables

| Variable | Description |
|---|---|
| `PYOBOX_AGENT` | Detected agent type: `claude`, `codex`, `pi`, `gemini` |
| `PYOBOX_AGENT_PID` | PID of detected agent process |

## Platform Variables

| Variable | Description |
|---|---|
| `PYOBOX_PLATFORM` | `android`, `web`, `desktop` |
| `PYOBOX_ARCH` | `aarch64`, `x86_64`, etc. |
| `PYOBOX_HAS_KVM` | `true` if /dev/kvm is available |
