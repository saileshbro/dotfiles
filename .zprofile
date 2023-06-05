export ZDOTDIR="$HOME"/.config/zsh

eval "$(/opt/homebrew/bin/brew shellenv)"

# export XDG_RUNTIME_DIR="/run/user/$UID"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export FVM_HOME="$XDG_DATA_HOME"/fvm
export FLUTTER_ROOT="$FVM_HOME/default"
export PATH="$PATH":"$XDG_DATA_HOME/cargo/bin"
export PATH="$PATH":"$FLUTTER_ROOT/bin"
export PATH="$PATH":"$HOME/.yarn/bin"
export PATH="$PATH":"$HOME/Library/Android/sdk/platform-tools"
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH="$PATH":"$HOME/Library/Application Support/JetBrains/Toolbox/scripts"

export JAVA_HOME=$(/usr/libexec/java_home)

export ANDROID_USER_HOME="$XDG_DATA_HOME"/android
export ANDROID_AVD_HOME="$ANDROID_USER_HOME"/avd
export ANDROID_HOME="$ANDROID_USER_HOME"/sdk
export ANDROID_NDK_ROOT="$ANDROID_HOME"/ndk
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DOCKER_HOME="$XDG_DATA_HOME"/docker
export GEM_HOME="$XDG_DATA_HOME"/gem
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export GRADLE_USER_HOME="$XDG_DATA_HOME"/gradle
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME"/bundle
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME"/bundle
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME"/bundle
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history

export GEM_SPEC_CACHE="$XDG_CACHE_HOME"/gem
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export ZSH_COMPDUMP="$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"
export M2_HOME="$XDG_CACHE_HOME"/maven
export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export STARSHIP_CONFIG="$XDG_CONFIG_HOME"/starship/starship.toml
export HOMEBREW_BUNDLE_FILE="$XDG_CONFIG_HOME"/homebrew/Brewfile
export CHROME_EXECUTABLE="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="djno-znmp-ztnn-uceb"
export ZSH="$XDG_DATA_HOME/oh-my-zsh"
export JAVA_HOME="$HOME/Library/Java/JavaVirtualMachines/jdk/Contents/Home"
