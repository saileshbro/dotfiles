export ZDOTDIR="$HOME/.config/zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$HOME/.run"

# Create XDG directories if they don't exist
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"
if [[ -n "$XDG_RUNTIME_DIR" && ! -d "$XDG_RUNTIME_DIR" ]]; then
  mkdir -p "$XDG_RUNTIME_DIR"
fi

