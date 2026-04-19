# .zshrc — interactive shells only.
# Loaded after .zshenv (always) and .zprofile (login shells).
# HOMEBREW_PREFIX, XDG_*, and all tool homes are already set in .zshenv.
#
# Structure:
#   .zshrc          — history, PATH, env (foundational, must run first)
#   .alias          — all aliases and small helper functions
#   .functions      — larger functions
#   conf.d/*.zsh    — topic files, sourced in alphabetical order:
#                       01-plugins.zsh     zsh-autosuggestions, syntax-highlighting
#                       02-completion.zsh  compinit, zstyle, tool completions
#                       03-keybindings.zsh bindkey
#                       04-tools.zsh       fzf, starship, zoxide, vscode, ...
#
# To disable a conf.d file without deleting it, prefix its name with `_`.
# Example: mv conf.d/04-tools.zsh conf.d/_04-tools.zsh

######################################
# History
######################################
# Re-assert HISTFILE here because /etc/zshrc (which runs before this file)
# resets it to ${ZDOTDIR}/.zsh_history with HISTSIZE=2000.
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=1000000
SAVEHIST=1000000

setopt EXTENDED_HISTORY       # save timestamp + duration with each entry
setopt SHARE_HISTORY          # write + import history across all live sessions
setopt HIST_EXPIRE_DUPS_FIRST # evict duplicates before unique entries when trimming
setopt HIST_IGNORE_DUPS       # don't record a command identical to the previous one
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate if the same command is run again
setopt HIST_FIND_NO_DUPS      # skip duplicates when searching
setopt HIST_IGNORE_SPACE      # don't record commands that start with a space
setopt HIST_SAVE_NO_DUPS      # don't write duplicates to the history file
setopt HIST_VERIFY            # show the substituted command before running !! etc.
setopt HIST_REDUCE_BLANKS     # strip superfluous whitespace before saving
setopt AUTO_CD                # type a directory path to cd into it (enables ../somedir)
setopt AUTO_PUSHD             # cd pushes the old directory onto the stack
setopt PUSHD_IGNORE_DUPS      # don't push duplicate directories
setopt PUSHD_SILENT           # don't print the directory stack after pushd/popd
setopt CORRECT                # suggest corrections for mistyped commands
setopt INTERACTIVE_COMMENTS   # allow # comments in interactive shell
setopt LONG_LIST_JOBS         # show PID in job listings
setopt NOTIFY                 # report job status immediately, not at next prompt
setopt MULTIOS                # allow multiple redirections (cmd > a > b)
setopt GLOB_DOTS              # include dotfiles in glob patterns (ls * shows .files)
setopt NO_BEEP                # silence terminal bell on errors/no-completions
setopt ALWAYS_TO_END          # move cursor to end of word after completion
setopt COMPLETE_IN_WORD       # tab-complete from the middle of a word
unsetopt FLOW_CONTROL         # disable Ctrl+S / Ctrl+Q terminal freeze
setopt EXTENDED_GLOB          # ^pat (negate), pat# (zero+), **/*.dart (recursive glob)


######################################
# PATH (interactive additions)
######################################
if [[ -z "${__ZSH_INTERACTIVE_PATH_BUILT:-}" ]]; then
  typeset -U path PATH
  path=(
    "$HOMEBREW_PREFIX/opt/ccache/libexec"
    "$XDG_DATA_HOME/cargo/bin"
    "$BUN_INSTALL/bin"
    "$XDG_DATA_HOME/fvm/default/bin"
    "$PUB_CACHE/bin"
    "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_HOME/tools"
    "$ANDROID_HOME/emulator"
    "$XDG_CONFIG_HOME/shorebird/bin"
    "$XDG_DATA_HOME/npm/bin"
    "$VOLTA_HOME/bin"
    "$HOMEBREW_PREFIX/opt/ruby/bin"
    "$HOMEBREW_PREFIX/share/google-cloud-sdk/bin"
    "$HOME/.antigravity/antigravity/bin"
    "$HOME/.local/bin"
    "$HOME/.maestro/bin"
    $path
  )

  # PNPM — only prepend if not already present
  [[ ":$PATH:" != *":$PNPM_HOME:"* ]] && path=("$PNPM_HOME" $path)

  export PATH
  export __ZSH_INTERACTIVE_PATH_BUILT=1
fi


######################################
# Environment
######################################
if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
  # zsh already exposes the current TTY path via $TTY.
  export GPG_TTY="$TTY"
fi

# ccache compiler wrappers — env vars only, no subprocess
if [[ -x "$HOMEBREW_PREFIX/opt/ccache/libexec/clang" ]]; then
  export CC="ccache clang"
  export CXX="ccache clang++"
fi


######################################
# conf.d — topic files
######################################
for _f in "$ZDOTDIR/conf.d"/*.zsh(N); do
  source "$_f"
done
unset _f


######################################
# Aliases & Functions
# Sourced after conf.d so compinit (and compdef) are already available.
######################################
[[ -f "$ZDOTDIR/.alias" ]]     && source "$ZDOTDIR/.alias"
[[ -f "$ZDOTDIR/.functions" ]] && source "$ZDOTDIR/.functions"


######################################
# Benchmarking helper
######################################
zsh-bench() {
  local runs=${1:-5}
  local timeout_s=${2:-3}
  echo "Timing $runs shell startups..."
  for i in $(seq 1 $runs); do
    # Always enforce a timeout (outer) so a broken init can't hang.
    if (( $+commands[gtimeout] )); then
      /usr/bin/time gtimeout "${timeout_s}s" zsh -i -c exit </dev/null 2>&1
    else
      # macOS has no `timeout` by default; use perl alarm.
      /usr/bin/time perl -e 'alarm shift; exec @ARGV' "$timeout_s" zsh -i -c exit </dev/null 2>&1
    fi
  done
  echo ""
  echo "Tip: run 'zsh -i -c zprof' to see a per-function breakdown."
}
