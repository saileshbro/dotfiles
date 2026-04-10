# .zprofile — login shells only.
# Runs once when you open a terminal app (not for every subshell).
# Safe to do slightly more work here than in .zshenv, but still avoid
# slow subprocesses — brew shellenv alone costs ~25ms.

# ── PATH (login shells set the authoritative PATH) ────────────────────────────
# HOMEBREW_PREFIX is already exported from .zshenv as /opt/homebrew
typeset -U path PATH
path=(
  $HOMEBREW_PREFIX/bin
  $HOMEBREW_PREFIX/sbin
  $JAVA_HOME/bin
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)

# Mark PATH as initialized so interactive subshells can skip rebuilding it.
export __ZSH_PATH_BUILT=1

# ── Homebrew env (skip the slow `brew shellenv` subprocess) ───────────────────
# These are the only vars brew shellenv would add beyond what .zshenv covers.
export MANPATH="$HOMEBREW_PREFIX/share/man${MANPATH+:$MANPATH}:"
export INFOPATH="$HOMEBREW_PREFIX/share/info${INFOPATH:-}"

# ── Ensure critical XDG/tool dirs exist (login shell = fine to do once) ───────
local _dirs=(
  "$XDG_CONFIG_HOME"
  "$XDG_CACHE_HOME/zsh"
  "$XDG_DATA_HOME"
  "$XDG_STATE_HOME/zsh"
  "$XDG_RUNTIME_DIR"
  "$GNUPGHOME"
)
for _d in $_dirs; do
  [[ -d "$_d" ]] || mkdir -p "$_d"
done
unset _d _dirs
