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

# Default branches take work through a PR: never pushed to straight, never committed on.
echo "$COMMAND" | grep -qE "$G +push( +[^ ;&|]+)* +([^ ;&|]*:)?(refs/heads/)?(dev|main|master)( |$|[;&|])" &&
  block "git push to dev/main (push your fix/ or feat/ branch and open a PR)"

if echo "$COMMAND" | grep -qE "$G +commit( |$)"; then
  # The repo the commit runs in: `git -C <dir>`, else the last `cd <dir>` before it, else the session cwd.
  BEFORE=$(echo "$COMMAND" | sed -E 's/(git( +-C +[^ ]+| +-c +[^ ]+)* +commit).*/\1/')
  DIR=$(echo "$BEFORE" | grep -oE 'git +-C +[^ ]+ +commit' | tail -1 | awk '{print $3}')
  [ -z "$DIR" ] && DIR=$(echo "$BEFORE" | grep -oE '(^|[;&|] *)cd +[^ ;&|]+' | tail -1 | sed -E 's/.*cd +//')
  [ -z "$DIR" ] && DIR=$(echo "$INPUT" | jq -r '.cwd // empty')
  DIR="${DIR/#\~/$HOME}"
  BRANCH=$(git -C "${DIR:-.}" symbolic-ref --short -q HEAD 2>/dev/null)
  case "$BRANCH" in
    dev | main | master) block "git commit on $BRANCH (branch to fix/<slug> or feat/<slug> first)" ;;
  esac
fi

exit 0
