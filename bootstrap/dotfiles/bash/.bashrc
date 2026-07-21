# pyobox bash configuration
# Mirrors the zsh setup for bash users

# --- History ---
HISTFILE="$HOME/.bash_history"
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# --- Completion ---
if command -v fzf &>/dev/null; then
  source /data/data/com.termux/files/usr/share/fzf/completion.bash 2>/dev/null || true
fi

# === pyobox environment ===
export PYOBOX_ENV=1
export PYOBOX_REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd 2>/dev/null || echo '')"
if command -v git &>/dev/null; then
  export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  export PYOBOX_MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null || echo '')"
fi
__pyobox_update_branch() {
  if command -v git &>/dev/null; then
    export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$PYOBOX_BRANCH")"
  fi
}
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__pyobox_update_branch"
# === end pyobox ===

# --- Modern tool aliases ---
alias ls='eza --icons=auto'
alias ll='eza -l --icons=auto --git'
alias la='eza -la --icons=auto --git'
alias cat='bat --paging=never'
alias fd='fd --color=always'
alias grep='rg --color=auto'
alias ..='cd ..'
alias copy='termux-clipboard-set'
alias paste='termux-clipboard-get'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'

# Tool aliases
alias lg='lazygit'
alias j='just'
alias http='curlie'
alias help='tldr'
alias df='duf'
alias top='htop'
