//! Shared types for the pyobox ecosystem.
//!
//! Every crate in the workspace depends on this crate.
//! It defines the vocabulary: Config, Error, AgentInfo, VmInfo, OsInfo, WorktreeInfo, etc.

pub mod config;
pub mod error;
pub mod types;

pub use config::PyoboxConfig;
pub use error::{Error, Result};
pub use types::*;
