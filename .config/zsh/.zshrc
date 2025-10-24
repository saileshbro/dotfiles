HISTSIZE=10000
SAVEHIST=10000

# Options
setopt EXTENDED_HISTORY         # Write the history file in the ':start:elapsed;command' format.
setopt SHARE_HISTORY            # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST   # Expire a duplicate event first when trimming history.
setopt HIST_IGNORE_DUPS         # Do not record an event that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS     # Delete an old recorded event if a new event is a duplicate.
setopt HIST_FIND_NO_DUPS        # Do not display a previously found event.
setopt HIST_IGNORE_SPACE        # Do not record an event starting with a space.
setopt HIST_SAVE_NO_DUPS        # Do not write a duplicate event to the history file.
setopt HIST_VERIFY              # Do not execute immediately upon history expansion.
setopt APPEND_HISTORY           # Append to history file.
setopt INC_APPEND_HISTORY       # Write to the history file immediately, not when the shell exits.
setopt AUTO_PUSHD               # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS        # Do not store duplicates in the stack.
setopt PUSHD_SILENT             # Do not print the directory stack after pushd or popd.

# TTY for GPG pinentry in interactive shells
export GPG_TTY=$(tty)

# Development paths
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
    $path
)
export PATH

# PNPM PATH (only if not already in PATH)
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) path=("$PNPM_HOME" $path) ;;
esac

# Load essential tools
[[ -f "$ZDOTDIR/.alias" ]] && source "$ZDOTDIR/.alias"
[[ -f "$ZDOTDIR/.functions" ]] && source "$ZDOTDIR/.functions"

# Key bindings
bindkey '  ' autosuggest-accept
bindkey '^ ' autosuggest-execute

# Initialize tools that require compilation
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit
    compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
fi

# Tool initialization
eval "$(starship init zsh)"

# Source plugins
if type brew &>/dev/null; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=$(brew --prefix)/share/zsh-syntax-highlighting/highlighters
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source <(fzf --zsh)
fi

# Oh-My-Zsh configuration and loading
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 7
source $ZSH/oh-my-zsh.sh

# Load completions for installed tools
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# Dart CLI completion
[[ -f "$XDG_CONFIG_HOME/.dart-cli-completion/zsh-config.zsh" ]] && source "$XDG_CONFIG_HOME/.dart-cli-completion/zsh-config.zsh"

# bun completions
[ -s "/opt/homebrew/Cellar/bun/$(bun --version)/share/zsh/site-functions/_bun" ] && source "/opt/homebrew/Cellar/bun/$(bun --version)/share/zsh/site-functions/_bun"

[ -s ~/.orbstack/shell/init.zsh ] && source ~/.orbstack/shell/init.zsh 2>/dev/null

[[ -f /Users/saileshbro/.config/.dart-cli-completion/zsh-config.zsh ]] && . /Users/saileshbro/.config/.dart-cli-completion/zsh-config.zsh || true

