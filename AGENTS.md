# Agent Instructions — pyobox Managed Environment

You are inside a **pyobox**-managed agent worktree. This file tells you everything you need to know about the environment.

---

## Environment Context

- **Managed by**: pyobox (reproducible dev environment box)
- **Env marker**: `PYOBOX_ENV=1` is set in every terminal session
- **Shared DB**: minisqlite at `$PYOBOX_DB_URL` — all agents share this database
- **Git branch**: `$PYOBOX_BRANCH` (auto-updated via precmd/PROMPT_COMMAND)
- **Main repo**: `$PYOBOX_MAIN_REPO`
- **Worktree ID**: `$PYOBOX_WORKTREE_ID` (if in a managed worktree)

---

## Location (Host Platform)

### Android (Termux)
- **OS**: Android (Termux terminal emulator)
- **Home**: `/data/data/com.termux/files/home`
- **Prefix**: `/data/data/com.termux/files/usr`
- **Shared storage**: `/storage/emulated/0` (Downloads, Documents, etc.)

### Linux (Desktop)
- **OS**: Linux (KVM-capable)
- **Home**: `~`
- **Clone VMM**: Available at `$PYOBOX_CLONE_BIN`

### Web (WASM)
- **OS**: Browser environment
- **Capabilities**: Limited to env generation and dashboard

---

## Platform-Specific Commands

### Opening URLs
```bash
# Android (Termux)
termux-open-url "https://example.com"

# Linux Desktop
xdg-open "https://example.com"

# macOS
open "https://example.com"
```

### Opening Files
```bash
# Android
termux-open file.pdf          # Opens with default app
termux-open --chooser image.jpg      # Choose app

# Linux Desktop
xdg-open file.pdf

# macOS
open file.pdf
```

### Clipboard
```bash
# Android (Termux)
termux-clipboard-set "text"   # Copy
termux-clipboard-get          # Paste

# Linux Desktop (X11)
xclip -selection clipboard    # Copy
xclip -selection clipboard -o # Paste

# Linux Desktop (Wayland)
wl-copy                       # Copy
wl-paste                      # Paste

# macOS
pbcopy                        # Copy
pbpaste                       # Paste
```

**Note**: Image clipboard is not supported on Termux.

### Notifications
```bash
# Android
termux-notification -t "Title" -c "Content"

# Linux Desktop
notify-send "Title" "Content"
```

### Device Info
```bash
termux-battery-status         # Battery info
termux-wifi-connectioninfo    # WiFi info
termux-telephony-deviceinfo   # Device info
```

### Sharing
```bash
termux-share -a send file.txt # Share file
```

---

## Shell Environment

Every managed session has these PYOBOX_* variables injected:

```bash
PYOBOX_ENV=1                  # Managed session marker
PYOBOX_REPO=/path/to/pyobox   # Monorepo root
PYOBOX_BRANCH=main            # Current git branch (auto-updated)
PYOBOX_MAIN_REPO=/path/to/repo   # Git toplevel
PYOBOX_WORKTREE_ID=wt-1       # Worktree ID (if applicable)
PYOBOX_DB_URL=http://localhost:8543  # Shared minisqlite
PYOBOX_DB_TYPE=minisqlite     # Database type
PYOBOX_SERVICES=minisqlite:8543  # Running services
PYOBOX_SESSION=<ts>-<pid>     # Session ID
PYOBOX_THEME=catppuccin-mocha # Terminal theme
PYOBOX_EDITOR=nvim            # Default editor
PYOBOX_SHELL=zsh              # Detected shell
```

### Alias Injection

In subshells (e.g., `sh -c` commands from agents), pyobox injects aliases via:

```bash
shopt -s expand_aliases
eval "$(grep '^alias ' ~/.zshrc 2>/dev/null || grep '^alias ' ~/.bashrc 2>/dev/null)"
```

This means all modern tool aliases (eza, bat, fd, rg, etc.) work everywhere.

---

## Agent Rules

1. **Do NOT create your own git worktrees.** The worktree is already managed for you.
2. **Do NOT modify `clone/` or `minisqlite/` submodules** unless explicitly told to.
3. **All code changes** go in the current worktree directory.
4. **The shared database** is at `$PYOBOX_DB_URL`. Coordinate with other agents there.
5. **When done**, run `make destroy-agent NAME=<your-name>` or `pyobox destroy-agent <name>`.
6. **Use modern tool aliases** — `ls` → `eza`, `cat` → `bat`, `grep` → `rg`, `fd` → `fd`, etc.
7. **Commit messages** follow conventional commits format (`feat:`, `fix:`, `chore:`, etc.).

---

## Available Commands

```bash
make setup                    # Bootstrap the environment
make build                    # Build all Rust crates
make test                     # Run all tests
make fmt                      # Check formatting
make clippy                   # Run clippy lints
make fork-agent NAME=x BRANCH=y   # Fork an agent VM/worktree
make destroy-agent NAME=x     # Destroy an agent
make list-agents              # List active agents
make start-services           # Start shared services
make stop-services            # Stop shared services
make teardown                 # Full teardown
```

---

## Troubleshooting

### Clipboard not working (Termux)
Ensure both apps are installed:
1. **Termux** (from [GitHub](https://github.com/termux/termux-app) or [F-Droid](https://f-droid.org/en/packages/com.termux/))
2. **Termux:API** (from [GitHub](https://github.com/termux/termux-api) or [F-Droid](https://f-droid.org/en/packages/com.termux.api/))

Then install the CLI tools:
```bash
pkg install termux-api
```

### Permission denied for shared storage
```bash
termux-setup-storage
```

### Node.js installation issues
```bash
npm cache clean --force
```

### KVM not available (Desktop)
Check if KVM is available:
```bash
ls -la /dev/kvm
```
If missing, install KVM:
- Ubuntu/Debian: `sudo apt install qemu-kvm`
- Arch: `sudo pacman -S qemu-desktop`
- Fedora: `sudo dnf install @virtualization`
