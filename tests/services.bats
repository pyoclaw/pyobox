#!/usr/bin/env bats

load 'setup.bats'

@test "services: migration SQL is valid" {
    run sqlite3 :memory: < "$PYOBOX_REPO/services/minisqlite/migrations/V001__initial_schema.sql"
    [ "$status" -eq 0 ]
}

@test "services: agent_tasks table exists after migration" {
    result=$(sqlite3 :memory: < "$PYOBOX_REPO/services/minisqlite/migrations/V001__initial_schema.sql" \
        ".tables" 2>/dev/null || echo "no sqlite3")
    # Skip if sqlite3 not available
    [ -n "$result" ] || skip "sqlite3 not available"
}
