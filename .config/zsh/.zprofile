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
  $BUN_INSTALL/bin
  $HOME/.config/git/bin   # git subcommands (git stack)
  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $path
)
# Stand-in for /etc/zprofile's path_helper (GLOBAL_RCS is off, see .zshenv):
# same files, same order, read with $(<file) which doesn't fork.
for _f in /etc/paths /etc/paths.d/*(N); do path+=(${(f)"$(<$_f)"}); done
unset _f

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
