# conf.d/00-cache.zsh — helpers that must exist before later conf.d files.
# Loaded first (alphabetically before 01-plugins.zsh).

######################################
# Cache-eval helper
# Generates a tool's shell init script once, caches it beside the binary's
# mtime, and re-generates automatically after a `brew upgrade`.
######################################
_zsh_cache_eval() {
  # Usage: _zsh_cache_eval <cache-file> <binary-path> <cmd> [args...]
  local cache="$1" bin="$2" tmp_cache rc; shift 2

  if [[ ! -f "$cache" || ( -n "$bin" && "$bin" -nt "$cache" ) ]]; then
    mkdir -p "${cache:h}"
    tmp_cache="${cache}.tmp.$$"
    "$@" >| "$tmp_cache"
    rc=$?
    if (( rc == 0 )) && [[ -s "$tmp_cache" ]]; then
      mv -f "$tmp_cache" "$cache"
      # Parsing large init scripts dominates warm-start time; zcompile reduces it.
      # Note: zsh automatically uses `file.zwc` when you `source file` and the
      # compiled file is newer, so we still `source "$cache"` below.
      zcompile -R -- "$cache" 2>/dev/null || true
    else
      rm -f "$tmp_cache"
      # If regeneration fails, keep using the previous cache when available.
      [[ -f "$cache" ]] || return "$rc"
    fi
  fi
  source "$cache"
}
