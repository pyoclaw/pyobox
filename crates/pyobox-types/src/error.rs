use thiserror::Error;

/// Unified error type for the pyobox ecosystem.
#[derive(Debug, Error)]
pub enum Error {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Configuration error: {0}")]
    Config(String),

    #[error("Bootstrap error: {0}")]
    Bootstrap(String),

    #[error("Environment injection error: {0}")]
    Env(String),

    #[error("Agent context error: {0}")]
    AgentContext(String),

    #[error("Worktree error: {0}")]
    Worktree(String),

    #[error("Service error: {0}")]
    Service(String),

    #[error("VMM error: {0}")]
    Vmm(String),

    #[error("Subprocess error: {0}")]
    Subprocess(String),
}

/// Convenience result alias.
pub type Result<T> = std::result::Result<T, Error>;
