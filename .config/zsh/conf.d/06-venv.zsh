# 06-venv.zsh — auto-activate Python virtual environments on cd
#
# Searches for a venv in this order: .venv, venv, .env
# Deactivates any currently active venv when leaving a project dir.

_venv_auto_activate() {
  local venv_dirs=(.venv venv .env)
  local venv_dir

  for venv_dir in "${venv_dirs[@]}"; do
    if [[ -f "$PWD/$venv_dir/bin/activate" ]]; then
      # Already activated for this exact venv — skip
      if [[ "$VIRTUAL_ENV" == "$PWD/$venv_dir" ]]; then
        return
      fi
      # Deactivate any previous venv first
      if [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate 2>/dev/null
      fi
      source "$PWD/$venv_dir/bin/activate"
      return
    fi
  done

  # No venv found in this dir — deactivate if we were in one
  if [[ -n "$VIRTUAL_ENV" ]]; then
    deactivate 2>/dev/null
  fi
}

# Run on every directory change
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _venv_auto_activate

# Also run on shell startup in case we open a terminal inside a project dir
_venv_auto_activate
