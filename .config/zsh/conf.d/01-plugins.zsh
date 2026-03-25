# conf.d/01-plugins.zsh — brew-managed shell plugins
# Loaded first so the widgets they register (autosuggest-accept, etc.)
# exist before keybindings reference them in 03-keybindings.zsh.

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
[[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
  && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── zsh-syntax-highlighting ───────────────────────────────────────────────────
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/highlighters"
[[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] \
  && source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
