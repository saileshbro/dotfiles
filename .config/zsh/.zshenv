export ZDOTDIR="$HOME/.config/zsh"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$HOME/.run"

export HISTFILE="$XDG_STATE_HOME/zsh/history"
# Create XDG directories if they don't exist
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"
if [[ -n "$XDG_RUNTIME_DIR" && ! -d "$XDG_RUNTIME_DIR" ]]; then
  mkdir -p "$XDG_RUNTIME_DIR"
fi
mkdir -p "$(dirname "$HISTFILE")"

# Development tool configurations
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"

# XDG-related tool paths
declare -A xdg_configs=(
    [FVM_CACHE_PATH]="$XDG_DATA_HOME/fvm"
    [RBENV_ROOT]="$XDG_DATA_HOME/rbenv"
    [CARGO_HOME]="$XDG_DATA_HOME/cargo"
    [DOCKER_HOME]="$XDG_DATA_HOME/docker"
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
export ANDROID_SDK_HOME="$XDG_DATA_HOME/android/sdk"
export ANDROID_HOME="$ANDROID_SDK_HOME"
export ANDROID_AVD_HOME="$ANDROID_SDK_HOME/avd"
export ANDROID_NDK_HOME="$ANDROID_SDK_HOME/ndk"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"

# Bundle configurations
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_PATH="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"

# Cache and state directories
export CCACHE_DIR="$XDG_CACHE_HOME/ccache"
export PUB_CACHE="$XDG_CACHE_HOME/pub-cache"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

