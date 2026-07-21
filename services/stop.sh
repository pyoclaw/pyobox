#!/usr/bin/env bash
set -euo pipefail

# services/stop.sh — Stop shared pyobox services

echo "🔌 Stopping pyobox services..."
# Kill minisqlite server
pkill -f "minisqlite-server" 2>/dev/null || true
echo "✅ Services stopped"
