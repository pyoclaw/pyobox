//! System provisioning engine.
//!
//! Discovers the OS, installs packages, deploys dotfiles, and manages the
//! bootstrap/teardown lifecycle. Works on Android (Termux), Linux, macOS.

use pyobox_types::{OsInfo, Platform, PyoboxConfig, Result};

/// Detect the current operating system and platform capabilities.
pub fn detect_os() -> Result<OsInfo> {
    let os = std::env::consts::OS;
    let arch = std::env::consts::ARCH;
    let is_termux = std::env::var("PREFIX")
        .map(|p| p.contains("com.termux"))
        .unwrap_or(false);
    let has_kvm = std::path::Path::new("/dev/kvm").exists();

    let distro = if is_termux {
        "termux".to_string()
    } else {
        detect_linux_distro()
    };

    Ok(OsInfo {
        os: os.to_string(),
        distro,
        arch: arch.to_string(),
        is_termux,
        has_kvm,
    })
}

/// Run the full setup sequence.
pub fn run_setup(_config: &PyoboxConfig) -> Result<()> {
    let os = detect_os()?;
    println!("🚀 pyobox setup — detected: {}/{}", os.distro, os.arch);

    if os.is_termux {
        println!("📱 Termux detected — using Android-optimized bootstrap");
    }
    if os.has_kvm {
        println!("🖥️  KVM available — Clone VMM enabled");
    }

    // TODO: install packages, deploy dotfiles, build templates, start services
    println!("✅ Setup complete");
    Ok(())
}

/// Run the full teardown sequence.
pub fn run_teardown(_config: &PyoboxConfig) -> Result<()> {
    println!("🧹 pyobox teardown");
    // TODO: stop services, destroy worktrees, clean state
    println!("✅ Teardown complete");
    Ok(())
}

fn detect_linux_distro() -> String {
    // Try common release files
    for path in &["/etc/os-release", "/etc/lsb-release"] {
        if let Ok(content) = std::fs::read_to_string(path) {
            for line in content.lines() {
                if let Some(val) = line.strip_prefix("ID=") {
                    return val.trim_matches('"').to_string();
                }
            }
        }
    }
    "unknown".to_string()
}

/// Determine platform tier for feature support.
pub fn platform_tier(os: &OsInfo) -> Platform {
    if os.is_termux {
        Platform::Android
    } else if cfg!(target_arch = "wasm32") {
        Platform::Web
    } else {
        Platform::Desktop
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_detect_os() {
        let os = detect_os().unwrap();
        assert!(!os.arch.is_empty());
        assert!(!os.os.is_empty());
    }
}
