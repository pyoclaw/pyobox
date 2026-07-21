#!/usr/bin/env bash
# teardown.sh — delegates to unified bootstrap.sh --teardown
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/bootstrap.sh" --teardown
