# conf.d/02-completion.zsh — completion system + all tool completions
# Runs after 01-plugins.zsh so syntax-highlighting is already active,
# but before 03-keybindings.zsh so menu-select keymap exists for binding.

######################################
# Completion system
######################################
# Extend FPATH with brew-managed completions before compinit sees it.
FPATH="$HOMEBREW_PREFIX/share/zsh-completions:$HOMEBREW_PREFIX/share/zsh/site-functions:$FPATH"

autoload -Uz compinit

typeset -gi _zsh_completion_inited=0

_zsh_init_completion_system() {
  (( _zsh_completion_inited )) && return 0

  # Only run the slow compaudit security scan when the dump is >24 h old.
  # -C skips the audit entirely (uses the cached dump as-is).
  # (N) = null-glob, . = regular file, mh+24 = modified >24 hours ago
  local _zcompdump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
  if [[ ! -f "$_zcompdump" || -n "$_zcompdump"(#qN.mh+24) ]]; then
    compinit -d "$_zcompdump"        # missing/stale — full rebuild + security audit
  else
    compinit -C -d "$_zcompdump"     # fresh — skip audit
  fi
  local _compinit_status=$?
  (( _compinit_status == 0 )) || return _compinit_status
  _zsh_completion_inited=1

  ######################################
  # Completion styles
  ######################################
  zstyle ':completion:*' menu select
  zstyle ':completion:*' verbose no
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
  zstyle ':completion:*:descriptions' format ''
  zstyle ':completion:*:warnings'     format 'No matches for: %d'
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/compcache"

  ######################################
  # Tool completions
  ######################################
  # Dart CLI
  [[ -f "$XDG_CONFIG_HOME/.dart-cli-completion/zsh-config.zsh" ]] \
    && source "$XDG_CONFIG_HOME/.dart-cli-completion/zsh-config.zsh"

  # Bun — glob instead of $(bun --version) subprocess
  () {
    local f=("$HOMEBREW_PREFIX/Cellar/bun"/*/share/zsh/site-functions/_bun(N[1]))
    [[ -f "$f" ]] && source "$f"
  }

  # ngrok — cached; only regenerated when the binary changes
  if (( $+commands[ngrok] )); then
    _zsh_cache_eval \
      "$XDG_CACHE_HOME/zsh/ngrok_completion.zsh" \
      "$commands[ngrok]" \
      ngrok completion
  fi

  return 0
}

# Default: initialize completion during startup for reliability.
: "${ZSH_LAZY_COMPINIT:=0}"
if (( ZSH_LAZY_COMPINIT )) && [[ -o zle ]]; then
  autoload -Uz add-zle-hook-widget

  _zsh_lazy_complete() {
    _zsh_init_completion_system
    zle .complete-word
  }

  zle -N _zsh_lazy_complete
  bindkey '^I' _zsh_lazy_complete
else
  _zsh_init_completion_system
  # Ensure Tab uses the standard completion widget once initialized.
  bindkey '^I' expand-or-complete
fi
