#!/usr/bin/env bash
# setup.sh — delegates to unified bootstrap.sh --setup
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bootstrap.sh" --setup
