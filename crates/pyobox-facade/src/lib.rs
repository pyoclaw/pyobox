//! Public API facade for pyobox.
//!
//! This is the single entry point — one type, minimal methods.
//! Inspired by minisqlite's `Connection` pattern.

use pyobox_types::{PyoboxConfig, Result};

/// The pyobox orchestrator.
///
/// ```rust,no_run
/// use pyobox_facade::Pyobox;
///
/// let pyobox = Pyobox::new("/home/user/pyobox")?;
/// pyobox.setup()?;
/// pyobox.fork_agent("agent-x", "feature/auth")?;
/// # Ok::<_, pyobox_types::Error>(())
/// ```
pub struct Pyobox {
    config: PyoboxConfig,
}

impl Pyobox {
    /// Create a new pyobox instance from a repository path.
    pub fn new(repo_path: &str) -> Result<Self> {
        let config = PyoboxConfig {
            repo_path: repo_path.to_string(),
            ..Default::default()
        };
        Ok(Self { config })
    }

    /// Create a new pyobox instance with a custom config.
    pub fn with_config(config: PyoboxConfig) -> Self {
        Self { config }
    }

    /// Run the full system bootstrap.
    /// Discovers OS, installs packages, deploys dotfiles, builds templates.
    pub fn setup(&self) -> Result<()> {
        pyobox_bootstrap::run_setup(&self.config)
    }

    /// Tear down everything: stop services, destroy worktrees, clean state.
    pub fn teardown(&self) -> Result<()> {
        pyobox_bootstrap::run_teardown(&self.config)
    }

    /// Fork a new agent VM (or process on Android) with environment context.
    pub fn fork_agent(&self, name: &str, branch: &str) -> Result<String> {
        pyobox_vmm::fork_agent_vm(&self.config, name, branch)
    }

    /// Destroy an agent VM and clean up its worktree.
    pub fn destroy_agent(&self, name: &str) -> Result<()> {
        pyobox_vmm::destroy_agent_vm(&self.config, name)
    }

    /// Inject environment variables into the current session.
    pub fn inject_env(&self, shell: pyobox_types::ShellKind) -> Result<String> {
        pyobox_env::generate_profile(shell)
    }

    /// Generate AGENTS.md for agent awareness.
    pub fn generate_agents_md(&self, worktree_id: &str) -> Result<String> {
        pyobox_agent_context::generate_agents_md(&self.config, worktree_id)
    }

    /// List all active agent worktrees.
    pub fn list_agents(&self) -> Result<Vec<pyobox_types::WorktreeInfo>> {
        pyobox_worktree::list_worktrees(&self.config)
    }

    /// Get a reference to the current config.
    pub fn config(&self) -> &PyoboxConfig {
        &self.config
    }
}
