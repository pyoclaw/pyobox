-- minisqlite migration: V001__initial_schema.sql
-- Creates the agent task coordination tables.

CREATE TABLE IF NOT EXISTS agent_tasks (
    task_id     TEXT PRIMARY KEY,
    agent       TEXT NOT NULL,
    status      TEXT NOT NULL DEFAULT 'active'
                CHECK (status IN ('active', 'blocked', 'done', 'failed')),
    branch      TEXT NOT NULL,
    description TEXT,
    started_at  TEXT NOT NULL DEFAULT (datetime('now')),
    completed_at TEXT
);

CREATE TABLE IF NOT EXISTS shared_state (
    key         TEXT PRIMARY KEY,
    value       TEXT NOT NULL,
    updated_by  TEXT NOT NULL,
    updated_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS schema_version (
    version     INTEGER PRIMARY KEY,
    applied_at  TEXT NOT NULL DEFAULT (datetime('now'))
);

INSERT OR IGNORE INTO schema_version (version) VALUES (1);
