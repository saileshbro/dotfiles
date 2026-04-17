# .zshenv — loaded for EVERY zsh process (interactive, non-interactive, scripts).
# Keep this file fast: no subprocesses, no sourcing, no mkdir calls.

# ── Disable macOS per-window session history ───────────────────────────────────
# Without this, /etc/zshrc_Apple_Terminal fragments history into
# ~/.zsh_sessions/<UUID>.session files — one per terminal window — so
# Ctrl+R only ever searches the current window's past, not your full history.
export SHELL_SESSIONS_DISABLE=1

# ── Core XDG dirs ─────────────────────────────────────────────────────────────
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="$HOME/.run"

# ── Zsh config location ────────────────────────────────────────────────────────
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# ── Homebrew (hardcoded — avoids a 25ms `brew --prefix` subprocess call) ──────
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="$HOMEBREW_PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$HOMEBREW_PREFIX"
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME/homebrew/Brewfile"

# ── Language / compiler flags (for brew-managed ruby etc.) ────────────────────
export LDFLAGS="-L$HOMEBREW_PREFIX/opt/ruby/lib"
export CPPFLAGS="-I$HOMEBREW_PREFIX/opt/ruby/include"
export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/ruby/lib/pkgconfig"

# ── Java ───────────────────────────────────────────────────────────────────────
export JAVA_HOME="/Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home"

# ── Node / JS tooling ─────────────────────────────────────────────────────────
export VOLTA_HOME="$XDG_DATA_HOME/volta"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NODE_REPL_HISTORY="$XDG_DATA_HOME/node_repl_history"

# ── Rust ───────────────────────────────────────────────────────────────────────
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# ── Flutter / Dart / Android ───────────────────────────────────────────────────
export FVM_CACHE_PATH="$XDG_DATA_HOME/fvm"
export PUB_CACHE="$XDG_CACHE_HOME/pub-cache"
export ANDROID_SDK_HOME="$XDG_DATA_HOME/android"
export ANDROID_HOME="$ANDROID_SDK_HOME"
export ANDROID_USER_HOME="$XDG_DATA_HOME/android"
export ANDROID_AVD_HOME="$ANDROID_SDK_HOME/avd"
export ANDROID_NDK_HOME="$ANDROID_SDK_HOME/ndk"

# ── Ruby / CocoaPods ──────────────────────────────────────────────────────────
export RBENV_ROOT="$XDG_DATA_HOME/rbenv"
export CP_HOME_DIR="$XDG_DATA_HOME/cocoapods"
export GEM_SPEC_CACHE="$XDG_CACHE_HOME/gem"

# ── Ruby bundler ───────────────────────────────────────────────────────────────
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME/bundle"
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME/bundle"
export BUNDLE_PATH="$XDG_CACHE_HOME/bundle"
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME/bundle"

# ── Docker ────────────────────────────────────────────────────────────────────
export DOCKER_HOME="$XDG_DATA_HOME/docker"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# ── Build / cache tools ───────────────────────────────────────────────────────
export GRADLE_USER_HOME="$XDG_DATA_HOME/gradle"
export CCACHE_DIR="$XDG_CACHE_HOME/ccache"

# ── Python ────────────────────────────────────────────────────────────────────
export MPLCONFIGDIR="$XDG_CONFIG_HOME/matplotlib"

# ── Misc tools ────────────────────────────────────────────────────────────────
export WAKATIME_HOME="$XDG_CONFIG_HOME/wakatime"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
