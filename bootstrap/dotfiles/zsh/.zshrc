# =============================================================================
# ~/.zshrc — Lean, fast Zsh config for pyobox managed environments
# No Oh My Zsh — just manual plugin loading for speed
# =============================================================================

# --- Options ----------------------------------------------------------------
setopt AUTO_CD              # cd by typing dir name
setopt NO_BEEP              # no beeps
setopt EXTENDED_GLOB        # # ~ ^ glob qualifiers
setopt NOMATCH              # error on failed glob
setopt NOTIFY               # report bg job status immediately
setopt INC_APPEND_HISTORY   # add commands incrementally
setopt SHARE_HISTORY        # share history across sessions
setopt HIST_IGNORE_DUPS     # don't record duplicates
setopt HIST_IGNORE_SPACE    # don't record commands starting with space
setopt HIST_REDUCE_BLANKS   # trim blanks

# --- History ----------------------------------------------------------------
HISTFILE="$HOME/.zhistory"
HISTSIZE=10000
SAVEHIST=10000

# --- Key bindings (vi mode with emacs-style line editing for convenience) ----
bindkey -v                  # vi mode
export KEYTIMEOUT=20        # reduce mode switch delay (ms)

# --- Completion system ------------------------------------------------------
autoload -Uz compinit
# Cache completion dump — regenerate daily if it exists, else create it
if [[ -f "$HOME/.zcompdump" ]]; then
  if [[ ! -z $HOME/.zcompdump(#qNmh+24) ]]; then
    compinit -d "$HOME/.zcompdump"
  else
    compinit -C -d "$HOME/.zcompdump"
  fi
else
  compinit -d "$HOME/.zcompdump"
fi

# Ensure cache directory exists
mkdir -p "$HOME/.zcompcache"

# Case-insensitive, partial-word, and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zcompcache"

# Load fpath completions
fpath=(
  "$HOME/.zsh/completions"
  /data/data/com.termux/files/usr/share/zsh/site-functions
  /data/data/com.termux/files/usr/share/zsh/vendor-completions
  "$fpath[@]"
)

# --- Plugin directory ------------------------------------------------------
typeset -g ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

# 1. zsh-autosuggestions — suggests commands based on history
if [ -f "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$ZSH_PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_USE_ASYNC=1
fi

# 2. zsh-history-substring-search — bind to up/down arrows
if [ -f "$ZSH_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then
  source "$ZSH_PLUGIN_DIR/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# 3. Starship prompt — loads before highlighting
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# 4. zoxide — smarter cd
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

# 5. fzf — fuzzy finder
if command -v fzf &>/dev/null; then
  source /data/data/com.termux/files/usr/share/fzf/key-bindings.zsh 2>/dev/null || true
  source /data/data/com.termux/files/usr/share/fzf/completion.zsh 2>/dev/null || true
fi

# 6. zsh-syntax-highlighting — MUST be loaded LAST
if [ -f "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# =============================================================================
# Aliases — modern tool replacements
# =============================================================================

# Modern ls replacement
alias ls='eza --icons=auto'
alias ll='eza -l --icons=auto --git'
alias la='eza -la --icons=auto --git'
alias lt='eza -T --icons=auto'
alias lta='eza -Ta --icons=auto'

# Modern cat replacement
alias cat='bat --paging=never'
alias catn='bat -n --paging=never'

# Modern find replacement
alias fd='fd --color=always'

# Modern grep replacement
alias grep='rg --color=auto'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Clipboard (platform-aware)
if command -v termux-clipboard-set &>/dev/null; then
  alias copy='termux-clipboard-set'
  alias paste='termux-clipboard-get'
elif command -v xclip &>/dev/null; then
  alias copy='xclip -selection clipboard'
  alias paste='xclip -selection clipboard -o'
elif command -v pbcopy &>/dev/null; then
  alias copy='pbcopy'
  alias paste='pbpaste'
fi

# Quick edit
alias zshrc="$EDITOR ~/.zshrc"
alias zshenv="$EDITOR ~/.zshenv"
alias starship-config="$EDITOR ~/.config/starship.toml"
alias reload='exec zsh'

# Safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'

# === pyobox environment ===
export PYOBOX_ENV=1
export PYOBOX_REPO="$(cd "$(dirname "${(%):-%x}")/../.." && pwd 2>/dev/null || echo '')"
if command -v git &>/dev/null; then
  export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  export PYOBOX_MAIN_REPO="$(git rev-parse --show-toplevel 2>/dev/null || echo '')"
fi

# precmd: update branch before every prompt
__pyobox_precmd() {
  if command -v git &>/dev/null; then
    export PYOBOX_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "$PYOBOX_BRANCH")"
  fi
}
precmd_functions+=(__pyobox_precmd)

# --- Tool aliases ---
alias lg='lazygit'
alias j='just'
alias jl='just --list'
alias http='curlie'
alias down='aria2c -x 4 -s 4'
alias bench='hyperfine'
alias we='watchexec'
alias help='tldr'
alias df='duf'
alias ps='procs'
alias top='htop'
alias rx='grex'

# --- Helper functions -------------------------------------------------------

# mkdir + cd in one step
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract any archive based on extension
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.gz|*.tgz) tar xzf "$1" ;;
      *.tar.bz2|*.tbz2) tar xjf "$1" ;;
      *.tar.xz|*.txz) tar xJf "$1" ;;
      *.zip) unzip "$1" ;;
      *.rar) unrar x "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "Unknown format: $1" ;;
    esac
  else
    echo "Not a file: $1"
  fi
}

# Quick HTTP file server
serve() {
  local port="${1:-8080}"
  python3 -m http.server "$port"
}
