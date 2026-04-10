# conf.d/04-tools.zsh — external tool initialisation
# All tools that need an `eval` or `source` to integrate with the shell.
# Loaded last so the prompt (starship) wraps everything that came before.
# _zsh_cache_eval is defined in 00-cache.zsh (must load before 02-completion.zsh).

######################################
# fzf
######################################
export FZF_DEFAULT_OPTS="
  --height=50%
  --layout=reverse
  --border=rounded
  --cycle
  --bind='ctrl-/:toggle-preview'
"

# Ctrl+R — full history search
export FZF_CTRL_R_OPTS="
  --scheme=history
  --preview='echo {}'
  --preview-window='bottom:3:wrap:hidden'
  --bind='ctrl-/:toggle-preview'
  --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color=header:italic
  --header='ctrl-y: copy  |  ctrl-/: preview  |  ctrl-r: toggle sort'
"

# Ctrl+T — file picker (fd-powered)
if (( $+commands[fd] )); then
  export FZF_CTRL_T_COMMAND='fd --type f --hidden --follow --exclude .git'
fi
export FZF_CTRL_T_OPTS="
  --preview='bat --color=always --line-range=:50 {} 2>/dev/null || cat {}'
  --preview-window='right:55%:wrap'
"

# Alt+C — directory jump (fd-powered)
if (( $+commands[fd] )); then
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi
export FZF_ALT_C_OPTS="
  --preview='lsd --tree --depth=2 {} 2>/dev/null || ls -la {}'
  --preview-window='right:45%:wrap'
"

# Shell integration (Ctrl+R, Ctrl+T, Alt+C)
# For first-prompt performance, defer loading fzf widgets until first use.
if [[ "$TERM" != "dumb" ]] && [[ -o zle ]] && [[ -x "$HOMEBREW_PREFIX/bin/fzf" ]]; then
  typeset -gi _zsh_fzf_loaded=0

  _zsh_load_fzf() {
    (( _zsh_fzf_loaded )) && return 0
    _zsh_fzf_loaded=1
    _zsh_cache_eval \
      "$XDG_CACHE_HOME/zsh/fzf_init.zsh" \
      "$HOMEBREW_PREFIX/bin/fzf" \
      fzf --zsh
  }

  _zsh_fzf_history_widget() { _zsh_load_fzf; zle fzf-history-widget; }
  _zsh_fzf_file_widget()    { _zsh_load_fzf; zle fzf-file-widget; }
  _zsh_fzf_cd_widget()      { _zsh_load_fzf; zle fzf-cd-widget; }

  zle -N _zsh_fzf_history_widget
  zle -N _zsh_fzf_file_widget
  zle -N _zsh_fzf_cd_widget

  bindkey '^R' _zsh_fzf_history_widget
  bindkey '^T' _zsh_fzf_file_widget
  bindkey '\ec' _zsh_fzf_cd_widget
fi


######################################
# starship prompt
######################################
if [[ "$TERM" != "dumb" ]] && [[ -o zle ]] && (( $+commands[starship] )); then
  _zsh_cache_eval \
    "$XDG_CACHE_HOME/zsh/starship_init.zsh" \
    "$commands[starship]" \
    starship init zsh
fi


######################################
# zoxide + fuzzy j()
######################################
if (( $+commands[zoxide] )); then
  _zsh_cache_eval \
    "$XDG_CACHE_HOME/zsh/zoxide_init.zsh" \
    "$commands[zoxide]" \
    zoxide init zsh --cmd j
fi

# Override the plain `j` zoxide registered above with an fzf-powered picker.
# Passing a query pre-filters; --select-1 auto-jumps on a single match.
j() {
  local dir
  dir=$(zoxide query -l | fzf --query="$*" --select-1 --exit-0)
  [[ -n "$dir" ]] && cd "$dir"
}


######################################
# Deferred integrations
######################################
# Load slower/non-essential integrations only when the first command is run.
# This keeps startup-to-first-prompt fast while preserving behavior afterward.
autoload -Uz add-zsh-hook
typeset -gi _zsh_deferred_integrations_loaded=0

_zsh_load_deferred_integrations() {
  (( _zsh_deferred_integrations_loaded )) && return 0
  _zsh_deferred_integrations_loaded=1

  [[ -f "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh" 2>/dev/null
  [[ -f "$HOME/.vite-plus/env" ]] && source "$HOME/.vite-plus/env"
}
add-zsh-hook preexec _zsh_load_deferred_integrations


######################################
# VS Code shell integration
######################################
# `code --locate-shell-integration-path` outputs a *file path*, not shell code,
# so we cache the path string and source the script it points to.
# Using _zsh_cache_eval here would try to `source` the path as shell code —
# which breaks because the path contains spaces ("Visual Studio Code.app").
if [[ "$TERM_PROGRAM" == "vscode" ]] && (( $+commands[code] )); then
  _vscode_path_cache="$XDG_CACHE_HOME/zsh/vscode_shell_integration_path"
  if [[ ! -f "$_vscode_path_cache" || "$commands[code]" -nt "$_vscode_path_cache" ]]; then
    mkdir -p "${_vscode_path_cache:h}"
    code --locate-shell-integration-path zsh >| "$_vscode_path_cache" 2>/dev/null
  fi
  _vscode_script="$(<$_vscode_path_cache)"
  [[ -f "$_vscode_script" ]] && source "$_vscode_script"
  unset _vscode_path_cache _vscode_script
fi


zsh-load-deferred-integrations() {
  _zsh_load_deferred_integrations
}
