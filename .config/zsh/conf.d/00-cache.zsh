# conf.d/00-cache.zsh — helpers that must exist before later conf.d files.
# Loaded first (alphabetically before 01-plugins.zsh).

######################################
# Cache-eval helper
# Generates a tool's shell init script once, caches it beside the binary's
# mtime, and re-generates automatically after a `brew upgrade`.
######################################
_zsh_cache_eval() {
  # Usage: _zsh_cache_eval <cache-file> <binary-path> <cmd> [args...]
  local cache="$1" bin="$2"; shift 2
  if [[ ! -f "$cache" || "$bin" -nt "$cache" ]]; then
    mkdir -p "${cache:h}"
    "$@" >| "$cache"
  fi
  source "$cache"
}
