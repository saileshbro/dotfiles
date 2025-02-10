HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
mkdir -p "$(dirname "$HISTFILE")"

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


# Development tool configurations
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
export ESLINT_USE_FLAT_CONFIG=false

# XDG path configurations
declare -A xdg_configs=(
    [FVM_CACHE_PATH]="$XDG_DATA_HOME/fvm"
    [RBENV_ROOT]="$XDG_DATA_HOME/rbenv"
    [CARGO_HOME]="$XDG_DATA_HOME/cargo"
    [DOCKER_HOME]="$XDG_DATA_HOME/docker"
    [GOPATH]="$XDG_DATA_HOME/go"
    [GRADLE_USER_HOME]="$XDG_DATA_HOME/gradle"
    [RUSTUP_HOME]="$XDG_DATA_HOME/rustup"
    [PNPM_HOME]="$XDG_DATA_HOME/pnpm"
    [CP_HOME_DIR]="$XDG_DATA_HOME/cocoapods"
    [GNUPGHOME]="$XDG_DATA_HOME/gnupg"
    [VOLTA_HOME]="$XDG_DATA_HOME/volta"
    [DOCKER_CONFIG]="$XDG_CONFIG_HOME/docker"
    [WAKATIME_HOME]="$XDG_CONFIG_HOME/wakatime"
    [JAVA_HOME]="$HOME/Applications/Android Studio.app/Contents/jbr/Contents/Home"
    [NPM_CONFIG_USERCONFIG]="$XDG_CONFIG_HOME/npm/npmrc"
    [STARSHIP_CONFIG]="$XDG_CONFIG_HOME/starship/starship.toml"
    [HOMEBREW_BUNDLE_FILE]="$XDG_CONFIG_HOME/homebrew/Brewfile"
    [ZSH]="$XDG_DATA_HOME/oh-my-zsh"
)
for key value in ${(kv)xdg_configs}; do
    export $key=$value
done

# Android SDK configurations
export ANDROID_SDK_HOME="$XDG_DATA_HOME/android"
export ANDROID_AVD_HOME="$ANDROID_SDK_HOME/avd"
export ANDROID_NDK_ROOT="$ANDROID_SDK_HOME/ndk"

# Bundle configurations
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_PATH="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"

# Cache and state directories
export CCACHE_DIR="$XDG_CACHE_HOME/ccache"
export PUB_CACHE="$XDG_CACHE_HOME/pub-cache"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export M2_HOME="$XDG_CACHE_HOME/maven"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=""

# Development paths
typeset -U path PATH
path=(
    "$HOMEBREW_PREFIX/opt/cache/libexec"
    "$XDG_DATA_HOME/cargo/bin"
    "$HOME/.yarn/bin"
    "$XDG_DATA_HOME/fvm/default/bin"
    "$XDG_CACHE_HOME/pub-cache/bin"
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    "$ANDROID_SDK_HOME/platform-tools"
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
eval "$(gh copilot alias -- zsh)"
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
