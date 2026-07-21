# ~/.zshenv — Zsh env vars (loaded for ALL shells)
# pyobox managed — minimal, no interactive-shell overlap

export PATH="$HOME/.local/bin:$HOME/bin:/data/data/com.termux/files/usr/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LANG="en_US.UTF-8"

# Termux API detection
[ -n "${TERMUX_VERSION:-}" ] && export TERMUX_API_APP="com.termux.api"
