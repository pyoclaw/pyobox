# =============================================================================
# ~/.zshenv — Zsh environment variables (loaded for ALL shells)
# pyobox managed
# =============================================================================

# --- PATH ---
export PATH="$HOME/.local/bin:$HOME/bin:/data/data/com.termux/files/usr/bin:$PATH"

# --- Editor ---
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"

# --- Language ---
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# --- Termux-specific ---
if [ -n "${TERMUX_VERSION:-}" ]; then
    export TERMUX_API_APP="com.termux.api"
fi

# --- History ---
export HISTFILE="$HOME/.zhistory"
export HISTSIZE=10000
export SAVEHIST=10000

# --- pyobox ---
export PYOBOX_ENV=1
