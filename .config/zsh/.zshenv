[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"
if [[ -n "$XDG_RUNTIME_DIR" && ! -d "$XDG_RUNTIME_DIR" ]]; then
  mkdir -p "$XDG_RUNTIME_DIR"
fi
