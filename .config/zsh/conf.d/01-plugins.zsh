# conf.d/01-plugins.zsh — brew-managed shell plugins
# Loaded first so the widgets they register (autosuggest-accept, etc.)
# exist before keybindings reference them in 03-keybindings.zsh.

# ── zsh-autosuggestions ───────────────────────────────────────────────────────
[[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] \
  && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── zsh-syntax-highlighting ───────────────────────────────────────────────────
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/highlighters"
# Keep startup fast: these two give most value at low overhead.
typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
# Deferred until just after the first prompt is drawn (~8ms off startup).
# /dev/null is always readable, so `zle -F` fires the callback as soon as zle
# goes idle; the handler unregisters itself, so it runs exactly once. Loading
# last is also what zsh-syntax-highlighting asks for (it wraps every widget).
_zsh_highlight_script="$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
if [[ -f "$_zsh_highlight_script" ]]; then
  if [[ -o zle ]]; then
    _zsh_load_highlighting() {
      local fd=$1
      zle -F $fd
      exec {fd}<&-
      source "$_zsh_highlight_script"
      unset _zsh_highlight_script
      unfunction _zsh_load_highlighting
    }
    typeset -gi _zsh_highlight_fd
    exec {_zsh_highlight_fd}</dev/null
    zle -F $_zsh_highlight_fd _zsh_load_highlighting
  else
    source "$_zsh_highlight_script"
  fi
fi
