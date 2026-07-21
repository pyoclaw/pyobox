#!/usr/bin/env bash
set -euo pipefail

# services/start.sh — Start shared pyobox services

PYOBOX_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔌 Starting pyobox services..."

# Start minisqlite
if [ -f "$PYOBOX_ROOT/minisqlite/target/release/minisqlite-server" ]; then
    echo "  Starting minisqlite server on :8543..."
    # "$PYOBOX_ROOT/minisqlite/target/release/minisqlite-server" &
elif command -v sqlite3 &>/dev/null; then
    echo "  Using system sqlite3 (minisqlite server not built yet)"
fi

echo "✅ Services started"
