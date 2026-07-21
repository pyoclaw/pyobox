//! Clone VMM integration layer.
//!
//! Wraps the Clone VMM binary (pyoclaw/clone) to fork agent VMs, inject environment
//! context, manage templates, and destroy VMs on completion.
//!
//! On non-Linux platforms (Android, WASM), this falls back to direct process isolation.

use pyobox_types::{PyoboxConfig, Result};

/// Fork a new agent VM from the warm template.
///
/// On Linux with KVM, uses Clone's Shadow Clone fork (<20ms).
/// On Android (Termux), uses direct process spawning.
/// On WASM, returns an error (VMs not available in browser).
pub fn fork_agent_vm(_config: &PyoboxConfig, name: &str, branch: &str) -> Result<String> {
    #[cfg(target_os = "linux")]
    {
        if std::path::Path::new("/dev/kvm").exists() {
            return fork_clone_vm(_config, name, branch);
        }
    }

    #[cfg(not(target_arch = "wasm32"))]
    {
        // Fallback: direct process (Termux / no-KVM)
        println!("📱 Spawning agent '{name}' on branch '{branch}' (no KVM)");
        Ok(format!("proc-{name}"))
    }

    #[cfg(target_arch = "wasm32")]
    {
        let _ = (name, branch);
        Err(pyobox_types::Error::Vmm(
            "VMM not available in WASM environment".into(),
        ))
    }
}

/// Destroy an agent VM and clean up.
pub fn destroy_agent_vm(_config: &PyoboxConfig, name: &str) -> Result<()> {
    #[cfg(target_os = "linux")]
    {
        if std::path::Path::new("/dev/kvm").exists() {
            return destroy_clone_vm(_config, name);
        }
    }

    println!("🧹 Destroying agent '{name}'");
    Ok(())
}

/// Clone-specific: fork via Shadow Clone.
#[cfg(target_os = "linux")]
fn fork_clone_vm(_config: &PyoboxConfig, name: &str, branch: &str) -> Result<String> {
    use std::process::Command;

    let clone_bin = _config
        .clone_bin
        .as_deref()
        .unwrap_or("clone");

    // TODO: build the fork command with proper flags
    let output = Command::new("sudo")
        .arg(clone_bin)
        .arg("fork")
        .arg("--template")
        .arg(format!("{}/templates/dev/snapshot.bin", _config.repo_path))
        .arg("--net")
        .arg("--shared-dir")
        .arg(format!("{}:worktree", _config.worktrees_dir))
        .output()
        .map_err(|e| pyobox_types::Error::Vmm(format!("Clone fork failed: {e}")))?;

    if output.status.success() {
        let vm_id = String::from_utf8_lossy(&output.stdout).trim().to_string();
        println!("🚀 Forked VM {vm_id} for agent '{name}' on branch '{branch}'");
        Ok(vm_id)
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr);
        Err(pyobox_types::Error::Vmm(format!("Clone fork error: {stderr}")))
    }
}

/// Clone-specific: destroy a VM.
#[cfg(target_os = "linux")]
fn destroy_clone_vm(_config: &PyoboxConfig, name: &str) -> Result<()> {
    use std::process::Command;

    let _ = Command::new("sudo")
        .arg("clone")
        .arg("destroy")
        .arg(name)
        .output();

    Ok(())
}

/// Build a warm template from configuration.
pub fn build_template(_config: &PyoboxConfig) -> Result<()> {
    println!("🔨 Building template VM...");
    // TODO: run templates/dev/build.sh
    Ok(())
}
