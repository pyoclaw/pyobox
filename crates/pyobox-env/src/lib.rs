//! Environment injection engine.
//!
//! Generates shell profiles that inject PYOBOX_* variables into every terminal
//! session. Supports bash, zsh, fish. Cross-compiles to WASM for web dashboard.

use pyobox_types::{Result, ShellKind};

/// Generate a shell profile that injects pyobox environment variables.
///
/// Returns shell script content that should be sourced by the user's shell.
/// On WASM targets, returns pure string content (no file I/O).
pub fn generate_profile(shell: ShellKind) -> Result<String> {
    match shell {
        ShellKind::Bash => generate_bash_profile(),
        ShellKind::Zsh => generate_zsh_profile(),
        ShellKind::Fish => generate_fish_profile(),
        ShellKind::Sh => generate_sh_profile(),
    }
}

/// Install the profile into the appropriate shell config file.
/// Not available on WASM targets (no file system access).
#[cfg(not(target_arch = "wasm32"))]
pub fn install_profile(shell: ShellKind) -> Result<()> {
    let (content, config_path) = match shell {
        ShellKind::Bash => {
            let path = dirs::home_dir()
                .ok_or_else(|| pyobox_types::Error::Env("No home dir".into()))?
                .join(".bashrc");
            (generate_bash_profile()?, path)
        }
        ShellKind::Zsh => {
            let path = dirs::home_dir()
                .ok_or_else(|| pyobox_types::Error::Env("No home dir".into()))?
                .join(".zshrc");
            (generate_zsh_profile()?, path)
        }
        _ => return Err(pyobox_types::Error::Env("Unsupported shell".into())),
    };

    let existing = std::fs::read_to_string(&config_path).unwrap_or_default();
    if !existing.contains("pyobox") {
        let mut full = existing;
        full.push_str("\n# === pyobox environment ===\n");
        full.push_str(&content);
        full.push_str("# === end pyobox ===\n");
        std::fs::write(&config_path, full)?;
    }
    Ok(())
}

fn generate_bash_profile() -> Result<String> {
    Ok(r#"# pyobox environment — injected by pyobox-env
export PYOBOX_ENV=1
export PYOBOX_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd 2>/dev/null || echo '')"

# Detect worktree context
if command -v git &>/dev/null; then
    export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
    export PYOBOX_MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null || echo '')"
fi

# PROMPT_COMMAND: update branch on every prompt
__pyobox_update_branch() {
    if command -v git &>/dev/null; then
        export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$PYOBOX_BRANCH")"
    fi
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__pyobox_update_branch"
"#.to_string())
}

fn generate_zsh_profile() -> Result<String> {
    Ok(r#"# pyobox environment — injected by pyobox-env
export PYOBOX_ENV=1
export PYOBOX_REPO="${0:A:h}"

# Detect worktree context
if command -v git &>/dev/null; then
    export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')"
    export PYOBOX_MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null || echo '')"
fi

# precmd: update branch before every prompt
__pyobox_precmd() {
    if command -v git &>/dev/null; then
        export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$PYOBOX_BRANCH")"
    fi
}
precmd_functions+=(__pyobox_precmd)
"#.to_string())
}

fn generate_fish_profile() -> Result<String> {
    Ok(r#"# pyobox environment — injected by pyobox-env
set -gx PYOBOX_ENV 1
set -gx PYOBOX_REPO (status dirname)

if command -v git &>/dev/null
    set -gx PYOBOX_BRANCH (git rev-parse --abbrev-ref HEAD 2>/dev/null; or echo 'unknown')
    set -gx PYOBOX_MAIN_REPO (git rev-parse --show-toplevel 2>/dev/null; or echo '')
end
"#.to_string())
}

fn generate_sh_profile() -> Result<String> {
    Ok(r#"# pyobox environment — POSIX sh compatible
PYOBOX_ENV=1; export PYOBOX_ENV
"#.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generate_bash_profile() {
        let content = generate_profile(ShellKind::Bash).unwrap();
        assert!(content.contains("PYOBOX_ENV=1"));
        assert!(content.contains("PYOBOX_BRANCH"));
    }

    #[test]
    fn test_generate_zsh_profile() {
        let content = generate_profile(ShellKind::Zsh).unwrap();
        assert!(content.contains("PYOBOX_ENV=1"));
        assert!(content.contains("precmd"));
    }

    #[test]
    fn test_generate_fish_profile() {
        let content = generate_profile(ShellKind::Fish).unwrap();
        assert!(content.contains("PYOBOX_ENV"));
    }
}
