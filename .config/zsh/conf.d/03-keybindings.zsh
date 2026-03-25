# conf.d/03-keybindings.zsh — all key bindings
# Loaded after 01-plugins.zsh so zsh-autosuggestions widgets exist.

# ── Line editing mode ─────────────────────────────────────────────────────────
bindkey -e   # emacs-style (Ctrl+A, Ctrl+E, Ctrl+R, etc.)

# ── History navigation ────────────────────────────────────────────────────────
bindkey '^[[A' history-search-backward   # ↑ search history by current prefix
bindkey '^[[B' history-search-forward    # ↓ search history by current prefix

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
bindkey '  '  autosuggest-accept         # double-space: accept suggestion
bindkey '^ '  autosuggest-execute        # ctrl+space:   accept + run immediately
