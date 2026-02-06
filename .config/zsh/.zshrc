######################################
# History
######################################
HISTSIZE=10000
SAVEHIST=10000

setopt EXTENDED_HISTORY
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT


######################################
# Environment
######################################
export GPG_TTY=$(tty)

typeset -U path PATH
path=(
  "$HOMEBREW_PREFIX/opt/cache/libexec"
  "$XDG_DATA_HOME/cargo/bin"
  "$HOME/.yarn/bin"
  "$XDG_DATA_HOME/fvm/default/bin"
  "$XDG_CACHE_HOME/pub-cache/bin"
  "$XDG_CACHE_HOME/.bun/bin"
  "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
  "$ANDROID_SDK_HOME/platform-tools"
  "$ANDROID_AVD_HOME"
  "$ANDROID_SDK_HOME/tools"
  "$XDG_CONFIG_HOME/shorebird/bin"
  "$XDG_DATA_HOME/npm/bin"
  "$VOLTA_HOME/bin"
  "/opt/homebrew/opt/ccache/libexec"
  "/opt/homebrew/opt/ruby/bin"
  "$HOME/.pub-cache/bin"
  "$HOME/.antigravity/antigravity/bin"
  "$HOME/.local/bin"
  $path
)
export PATH

# PNPM
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) path=("$PNPM_HOME" $path) ;;
esac

# ccache - compiler cache for faster builds
if command -v ccache &>/dev/null; then
  export CC="ccache clang"
  export CXX="ccache clang++"
  # Set cache size to 10GB (adjust as needed)
  ccache --max-size=10G >/dev/null 2>&1
fi


######################################
# Aliases & Functions
######################################
[[ -f "$ZDOTDIR/.alias" ]] && source "$ZDOTDIR/.alias"
[[ -f "$ZDOTDIR/.functions" ]] && source "$ZDOTDIR/.functions"


######################################
# Key bindings
######################################
bindkey '  ' autosuggest-accept
bindkey '^ ' autosuggest-execute


######################################
# Completion system
######################################
if command -v brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit
  compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
fi


######################################
# Prompt
######################################
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi


######################################
# Plugins (brew-based)
######################################
if command -v brew &>/dev/null; then
  source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

  export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR="$(brew --prefix)/share/zsh-syntax-highlighting/highlighters"
  source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

  # fzf (modern, no ~/.fzf.zsh)
  source <(fzf --zsh)
fi


######################################
# Oh My Zsh
######################################
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
source "$ZSH/oh-my-zsh.sh"


######################################
# Tool completions
######################################
command -v ngrok &>/dev/null && eval "$(ngrok completion)"

[[ -f "$XDG_CONFIG_HOME/.dart-cli-completion/zsh-config.zsh" ]] \
  && source "$XDG_CONFIG_HOME/.dart-cli-completion/zsh-config.zsh"

[ -s "/opt/homebrew/Cellar/bun/$(bun --version)/share/zsh/site-functions/_bun" ] \
  && source "/opt/homebrew/Cellar/bun/$(bun --version)/share/zsh/site-functions/_bun"

[ -f ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null

[[ "$TERM_PROGRAM" == "vscode" ]] \
  && source "$(code --locate-shell-integration-path zsh)"


######################################
# zoxide (base init)
######################################
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd j)"
fi


######################################
# j → TRUE fuzzy jump (typo tolerant)
######################################
j() {
  local dir
  dir=$(zoxide query -l | fzf --query="$*" --select-1 --exit-0)
  [[ -n "$dir" ]] && cd "$dir"
}