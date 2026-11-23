#!/bin/bash
# Blocks git commands the user's rules forbid for agents (working-with-sailesh.md):
# they rewrite or discard work another agent may have in the same checkout.
# Plain pushes and --force-with-lease stay allowed; agents push their own branches.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
[ -z "$COMMAND" ] && exit 0

G='git( +-C +[^ ]+| +-c +[^ ]+)*'

block() {
  echo "BLOCKED: '$COMMAND' matches '$1'. The user's rules forbid this command for agents. Use a WIP commit, git show :2:<path>, or ask the user." >&2
  exit 2
}

echo "$COMMAND" | grep -qE "$G +stash( +(push|pop|apply|drop|clear|save|-u|-k|--)| *($|[;&|]))" && block "git stash"
echo "$COMMAND" | grep -qE "$G +reset +(.* )?--hard" && block "git reset --hard"
echo "$COMMAND" | grep -qE "$G +checkout +(.* )?--( |$)" && block "git checkout --"
echo "$COMMAND" | grep -qE "$G +checkout +(.* )?--(ours|theirs)" && block "git checkout --ours/--theirs"
echo "$COMMAND" | grep -qE "$G +checkout +\.( |$)" && block "git checkout ."
if echo "$COMMAND" | grep -qE "$G +restore( |$)"; then
  echo "$COMMAND" | grep -qE "$G +restore +--staged( +[^-][^ ]*)+ *($|[;&|])" || block "git restore (only --staged is allowed)"
fi
echo "$COMMAND" | grep -qE "$G +clean +(.* )?-[a-zA-Z]*f" && block "git clean -f"
echo "$COMMAND" | grep -qE "$G +branch +(.* )?-D( |$)" && block "git branch -D"
echo "$COMMAND" | grep -qE "$G +merge( |$)" && block "git merge (rebase only)"
echo "$COMMAND" | grep -qE "$G +push +(.* )?(-f|--force)( |$)" && block "git push --force (use --force-with-lease)"

# The repo a git subcommand runs in: `git -C <dir>`, else the last `cd <dir>` before it, else the session cwd.
repo_dir() {
  local BEFORE DIR
  BEFORE=$(echo "$COMMAND" | sed -E "s/(git( +-C +[^ ]+| +-c +[^ ]+)* +$1).*/\\1/")
  DIR=$(echo "$BEFORE" | grep -oE "git +-C +[^ ]+ +$1" | tail -1 | awk '{print $3}')
  [ -z "$DIR" ] && DIR=$(echo "$BEFORE" | grep -oE '(^|[;&|] *)cd +[^ ;&|]+' | tail -1 | sed -E 's/.*cd +//')
  [ -z "$DIR" ] && DIR=$(echo "$INPUT" | jq -r '.cwd // empty')
  DIR="${DIR/#\~/$HOME}"; DIR="${DIR%\'}"; DIR="${DIR#\'}"
  echo "${DIR:-.}"
}

# Exception (user-approved 2026-11-23): in LeoCutsHQ, data and notes files that change daily may be
# committed on main and pushed straight to it. Code, AGENTS.md and docs/ still go through a PR.
LEOCUTS="$HOME/Projects/LeoCutsHQ"
DATA_FILES='^(scoreboard\.csv|learning\.md|log\.md|layouts\.json|handles\.json|payouts\.csv|idea-bank\.md|watchlist\.md|campaigns[^/]*\.md|takedowns\.md|facts\.md|research/.+)$'
is_leocuts() { [ "$(git -C "$1" rev-parse --show-toplevel 2>/dev/null)" = "$LEOCUTS" ]; }
only_data() { local f; f=$(cat); [ -n "$f" ] && ! echo "$f" | grep -qvE "$DATA_FILES"; }

# Default branches take work through a PR: never pushed to straight, never committed on.
if echo "$COMMAND" | grep -qE "$G +push( +[^ ;&|]+)* +([^ ;&|]*:)?(refs/heads/)?(dev|main|master)( |$|[;&|])"; then
  PDIR=$(repo_dir push)
  if is_leocuts "$PDIR" && echo "$COMMAND" | grep -qE "$G +push( +-u)?( +origin)? +main *($|[;&|])" &&
     [ "$(git -C "$PDIR" symbolic-ref --short -q HEAD 2>/dev/null)" = "main" ] &&
     git -C "$PDIR" rev-parse -q --verify origin/main >/dev/null &&
     git -C "$PDIR" log --format= --name-only origin/main..main | sed '/^$/d' | sort -u | only_data; then
    :
  else
    block "git push to dev/main (push your fix/ or feat/ branch and open a PR)"
  fi
fi

if echo "$COMMAND" | grep -qE "$G +commit( |$)"; then
  DIR=$(repo_dir commit)
  BRANCH=$(git -C "$DIR" symbolic-ref --short -q HEAD 2>/dev/null)
  case "$BRANCH" in
    dev | main | master)
      if is_leocuts "$DIR" && [ "$BRANCH" = "main" ] &&
         ! echo "$COMMAND" | grep -qE "$G +commit.* (-a|--all|-i|--include|-o|--only|-[a-zA-Z]*a[a-zA-Z]*)( |$)" &&
         git -C "$DIR" diff --cached --name-only | only_data; then
        :
      else
        block "git commit on $BRANCH (branch to fix/<slug> or feat/<slug> first)"
      fi ;;
  esac
fi

exit 0
