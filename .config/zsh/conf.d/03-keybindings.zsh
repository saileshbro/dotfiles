# conf.d/03-keybindings.zsh — all key bindings
# Loaded after 01-plugins.zsh so zsh-autosuggestions widgets exist.

# ── Line editing mode ─────────────────────────────────────────────────────────
bindkey -e   # emacs-style (Ctrl+A, Ctrl+E, Ctrl+R, etc.)

# ── Terminfo keys (carried over from /etc/zshrc, skipped via GLOBAL_RCS) ──────
[[ -n "$terminfo[kdch1]" ]] && bindkey "$terminfo[kdch1]" delete-char
[[ -n "$terminfo[khome]" ]] && bindkey "$terminfo[khome]" beginning-of-line
[[ -n "$terminfo[kend]"  ]] && bindkey "$terminfo[kend]"  end-of-line
[[ -n "$terminfo[kcuu1]" ]] && bindkey "$terminfo[kcuu1]" up-line-or-search
[[ -n "$terminfo[kcud1]" ]] && bindkey "$terminfo[kcud1]" down-line-or-search

# ── History navigation ────────────────────────────────────────────────────────
bindkey '^[[A' history-search-backward   # ↑ search history by current prefix
bindkey '^[[B' history-search-forward    # ↓ search history by current prefix

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
bindkey '  '  autosuggest-accept         # double-space: accept suggestion
bindkey '^ '  autosuggest-execute        # ctrl+space:   accept + run immediately
