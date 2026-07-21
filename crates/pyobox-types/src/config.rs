use serde::{Deserialize, Serialize};

/// Top-level pyobox configuration.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PyoboxConfig {
    /// Path to the pyobox repository root.
    pub repo_path: String,
    /// Path to the worktrees directory (default: ../pyobox-worktrees).
    pub worktrees_dir: String,
    /// Shared database URL (minisqlite).
    pub db_url: String,
    /// Clone binary path (if VMM is available).
    pub clone_bin: Option<String>,
    /// Templates directory.
    pub templates_dir: String,
    /// Services configuration.
    pub services: ServicesConfig,
    /// Agent integration configuration.
    pub agents: AgentConfig,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ServicesConfig {
    pub minisqlite_port: u16,
    pub minisqlite_host: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentConfig {
    pub supported_kinds: Vec<String>,
    pub auto_detect: bool,
}

impl Default for PyoboxConfig {
    fn default() -> Self {
        Self {
            repo_path: String::new(),
            worktrees_dir: String::from("../pyobox-worktrees"),
            db_url: String::from("http://localhost:8543"),
            clone_bin: None,
            templates_dir: String::from("templates"),
            services: ServicesConfig {
                minisqlite_port: 8543,
                minisqlite_host: String::from("127.0.0.1"),
            },
            agents: AgentConfig {
                supported_kinds: vec![
                    "claude".into(),
                    "codex".into(),
                    "pi".into(),
                    "gemini".into(),
                ],
                auto_detect: true,
            },
        }
    }
}
