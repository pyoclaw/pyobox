use serde::{Deserialize, Serialize};

/// Detected operating system information.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OsInfo {
    pub os: String,         // "android", "linux", "macos", "windows"
    pub distro: String,     // "termux", "ubuntu", "arch", etc.
    pub arch: String,       // "aarch64", "x86_64", etc.
    pub is_termux: bool,    // Running in Termux on Android
    pub has_kvm: bool,      // /dev/kvm available
}

/// Information about a detected or configured agent.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentInfo {
    pub name: String,
    pub kind: AgentKind,
    pub vm_id: Option<String>,
    pub pid: Option<u32>,
    pub worktree_id: Option<String>,
    pub status: AgentStatus,
}

/// Supported agent kinds.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum AgentKind {
    Claude,
    Codex,
    Pi,
    Gemini,
    Other(String),
}

/// Agent lifecycle status.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum AgentStatus {
    Idle,
    Working,
    Blocked,
    Done,
    Unknown,
}

/// VM information (from Clone VMM).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VmInfo {
    pub vm_id: String,
    pub template_path: String,
    pub agent_name: String,
    pub worktree_id: String,
    pub branch: String,
    pub forked_at: String,
    pub mem_mb: u32,
}

/// Git worktree metadata.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WorktreeInfo {
    pub id: String,
    pub name: String,
    pub path: String,
    pub branch: String,
    pub vm_id: Option<String>,
    pub agent_kind: Option<String>,
    pub created_at: String,
}

/// Shell kind for env injection.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum ShellKind {
    Bash,
    Zsh,
    Fish,
    Sh,
}

/// Platform target for cross-compilation.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum Platform {
    Android,
    Web,
    Desktop,
}
