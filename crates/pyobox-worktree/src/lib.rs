//! Git worktree management for agent isolation.
//!
//! Creates, tracks, and destroys isolated git worktrees for each agent.
//! Uses git worktree internally + a TOML metadata file for tracking.

use pyobox_types::{PyoboxConfig, Result, WorktreeInfo};

/// Create a new worktree for an agent.
pub fn create_worktree(_config: &PyoboxConfig, name: &str, branch: &str) -> Result<WorktreeInfo> {
    // TODO: git worktree add, register in metadata
    Ok(WorktreeInfo {
        id: uuid_v4(),
        name: name.to_string(),
        path: format!("../pyobox-worktrees/{name}"),
        branch: branch.to_string(),
        vm_id: None,
        agent_kind: None,
        created_at: iso_now(),
    })
}

/// Destroy a worktree by agent name.
pub fn destroy_worktree(_config: &PyoboxConfig, _name: &str) -> Result<()> {
    // TODO: git worktree remove, clean metadata
    Ok(())
}

/// List all registered worktrees.
pub fn list_worktrees(_config: &PyoboxConfig) -> Result<Vec<WorktreeInfo>> {
    // TODO: read .pyobox/worktrees.toml
    Ok(vec![])
}

fn uuid_v4() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let ts = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    format!("wt-{ts:x}")
}

fn iso_now() -> String {
    use std::time::{SystemTime, UNIX_EPOCH};
    let d = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap_or_default();
    let secs = d.as_secs();
    // Simple ISO-like timestamp
    format!("2024-{:02}-{:02}T{:02}:{:02}:{:02}Z",
        (secs / 86400 / 30) % 12 + 1,
        (secs / 86400) % 30 + 1,
        (secs / 3600) % 24,
        (secs / 60) % 60,
        secs % 60)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_worktree() {
        let config = PyoboxConfig::default();
        let wt = create_worktree(&config, "test-agent", "feature/test").unwrap();
        assert_eq!(wt.name, "test-agent");
        assert_eq!(wt.branch, "feature/test");
        assert!(wt.id.starts_with("wt-"));
    }
}
