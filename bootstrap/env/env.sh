#!/usr/bin/env bash
# pyobox environment variables (defaults)

export PYOBOX_ENV=1
export PYOBOX_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export PYOBOX_DB_URL="http://localhost:8543"
export PYOBOX_DB_TYPE="minisqlite"
export PYOBOX_SERVICES="minisqlite:8543"
export PYOBOX_SESSION="$(date +%s)-$$"
