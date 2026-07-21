#!/usr/bin/env bash
set -euo pipefail

# services/inject-env.sh — Inject environment variables into a running agent VM
# Usage: ./scripts/inject-env.sh <agent-name> <key=value> [key=value ...]

AGENT_NAME="${1:-}"
if [ -z "$AGENT_NAME" ]; then
    echo "Usage: $0 <agent-name> <key=value> ..."
    exit 1
fi
shift

for var in "$@"; do
    echo "  Injecting: $var"
    # TODO: send via vsock to agent VM
done
