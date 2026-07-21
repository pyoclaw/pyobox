//! Shared service orchestration.
//!
//! Manages the minisqlite shared database server lifecycle: start, stop, health,
//! schema migrations, and connection configuration.

use pyobox_types::{PyoboxConfig, Result};

/// Start all shared services (minisqlite server, etc.).
pub fn start_services(_config: &PyoboxConfig) -> Result<()> {
    println!("🔌 Starting services...");
    // TODO: spawn minisqlite server
    Ok(())
}

/// Stop all shared services.
pub fn stop_services(_config: &PyoboxConfig) -> Result<()> {
    println!("🔌 Stopping services...");
    // TODO: graceful shutdown
    Ok(())
}

/// Check health of all services.
pub fn health_check(_config: &PyoboxConfig) -> Result<bool> {
    // TODO: ping minisqlite
    Ok(true)
}

/// Run pending database migrations.
pub fn run_migrations(_config: &PyoboxConfig) -> Result<()> {
    println!("📦 Running migrations...");
    // TODO: read migration files, apply in order
    Ok(())
}
