# Zsh Setup — Agent Reference

This file documents the zsh configuration for AI agents and future contributors.
It covers architecture, key decisions, gotchas, and how to extend the setup safely.

---

## Repo Structure

```
~/.config/ is itself a symlink → ~/dotfiles/.config/
~/.zshenv  is a direct symlink → ~/dotfiles/.config/zsh/.zshenv
```

Every edit inside `dotfiles/.config/` is immediately live. No stow re-run needed.
The only reason `~/.zshenv` is a separate symlink is that zsh looks for it
specifically in `$HOME`, not in `$ZDOTDIR`.

```
dotfiles/.config/zsh/
├── .zshenv          # env vars — runs for EVERY zsh process (scripts, subshells, etc.)
├── .zprofile        # PATH + dir creation — login shells only
├── .zshrc           # thin orchestrator — history, PATH, env, then sources conf.d/
├── .alias           # all aliases + small helper functions (take, d, ll, flutter, etc.)
├── .functions       # larger named functions (add here rather than bloating .alias)
└── conf.d/
    ├── 01-plugins.zsh     # zsh-autosuggestions, zsh-syntax-highlighting
    ├── 02-completion.zsh  # compinit (smart cache), zstyle, dart/bun/ngrok completions
    ├── 03-keybindings.zsh # all bindkey
    └── 04-tools.zsh       # _zsh_cache_eval, fzf, starship, zoxide, orbstack, vscode, vite+
```

---

## Load Order

Each file is sourced in this order on every interactive shell start:

```
/etc/zshenv
~/.zshenv           (.zshenv — env vars, no subprocesses)
  └─ sets ZDOTDIR=$HOME/.config/zsh

/etc/zprofile
~/.config/zsh/.zprofile   (login shells only)

/etc/zshrc          ← resets HISTFILE + HISTSIZE — we override this in .zshrc
~/.config/zsh/.zshrc
  ├── sets HISTFILE, HISTSIZE, setopts
  ├── builds PATH
  ├── sets GPG_TTY, CC/CXX
  ├── sources conf.d/01-plugins.zsh
  ├── sources conf.d/02-completion.zsh
  ├── sources conf.d/03-keybindings.zsh
  ├── sources conf.d/04-tools.zsh
  ├── sources .alias
  └── sources .functions
```

**Critical ordering rules:**
- `conf.d/` files are globbed alphabetically — the `01/02/03/04` prefixes enforce order.
- Plugins (`01`) must load before keybindings (`03`) so the `autosuggest-accept` widget exists.
- Completions (`02`) must load before aliases (`post-conf.d`) so `compdef` is available.
- Tools (`04`) load last so starship wraps everything that came before.
- `.alias` and `.functions` are sourced *after* the conf.d loop for the same reason — `compdef` in `.alias` requires `compinit` to have already run.

---

## Key Architectural Decisions

### HOMEBREW_PREFIX is hardcoded

`/opt/homebrew` is hardcoded in `.zshenv` instead of running `brew --prefix`.
Each `brew --prefix` call costs ~25ms. It was being called 3× in the old setup.
If Homebrew ever moves, update the single `HOMEBREW_PREFIX` line in `.zshenv`.

### `_zsh_cache_eval` — cached eval pattern

Tools like `starship`, `zoxide`, and `fzf` generate shell init scripts via
`eval "$(tool init zsh)"`. Running that subprocess on every shell start is wasteful.

`_zsh_cache_eval` (defined in `conf.d/04-tools.zsh`) generates the script once,
writes it to `~/.cache/zsh/<tool>_init.zsh`, and only regenerates it when the
binary's mtime is newer than the cache file (i.e. after `brew upgrade`).

```zsh
_zsh_cache_eval <cache-file> <binary-path> <cmd> [args...]
```

**Do not use this for `code --locate-shell-integration-path zsh`.** That command
outputs a file *path*, not shell code. Sourcing a bare path causes word-splitting
on spaces in "Visual Studio Code.app". That one has its own dedicated logic in
`conf.d/04-tools.zsh` that caches the path string and sources the target file.

### compinit — skip security audit on warm starts

`compinit` by default runs `compaudit` (a filesystem security scan) on every
shell start. This was 93% of total startup time. The fix in `conf.d/02-completion.zsh`:

- If the zcompdump is **older than 24 hours** → run full `compinit` (rebuilds dump, runs audit)
- Otherwise → run `compinit -C` (skips audit, uses cached dump)

Cache lives at `~/.cache/zsh/zcompdump-$ZSH_VERSION`.

### macOS session history is disabled

`SHELL_SESSIONS_DISABLE=1` is set in `.zshenv`.

Without it, `/etc/zshrc_Apple_Terminal` fragments history into per-window
`~/.config/zsh/.zsh_sessions/<UUID>.session` files. Each terminal window only
sees its own past in Ctrl+R. With it disabled, all sessions share the single
canonical history file.

### HISTFILE is re-asserted in .zshrc

`/etc/zshrc` (which runs before `~/.zshrc`) resets `HISTFILE` to
`${ZDOTDIR}/.zsh_history` and `HISTSIZE` to 2000. The first thing `.zshrc` does
is re-assert both to our values. Do not remove these lines.

---

## How to Add a New Tool

### Tool that needs `eval "$(tool init zsh)"`:

Add to `conf.d/04-tools.zsh`:

```zsh
_zsh_cache_eval \
  "$XDG_CACHE_HOME/zsh/mytool_init.zsh" \
  "$commands[mytool]" \
  mytool init zsh
```

### Tool that only needs completions:

Add to the bottom of `conf.d/02-completion.zsh`:

```zsh
if (( $+commands[mytool] )); then
  _zsh_cache_eval \
    "$XDG_CACHE_HOME/zsh/mytool_completion.zsh" \
    "$commands[mytool]" \
    mytool completion zsh
fi
```

### New aliases:

Add to `.alias`. Group with related aliases and add a section comment if it's a
new topic. Functions that need `compdef` are safe here because `.alias` is sourced
after `compinit` runs.

### New environment variable:

Add to `.zshenv` under the appropriate section. Never add subprocesses, `source`,
or `mkdir` calls there — `.zshenv` runs for every zsh process including scripts.

### New directory that must exist:

Add to the `_dirs` array in `.zprofile`. That block runs once per login shell.

---

## Disabling a conf.d File

Prefix the filename with `_` — the `*.zsh` glob won't match it:

```zsh
mv conf.d/04-tools.zsh conf.d/_04-tools.zsh   # disable
mv conf.d/_04-tools.zsh conf.d/04-tools.zsh   # re-enable
```

---

## Performance

### Benchmarking startup time

```zsh
zsh-bench          # times 5 runs (default)
zsh-bench 10       # times 10 runs
```

### Profiling which function is slow

```zsh
zsh -i -c zprof
```

Add `zmodload zsh/zprof` at the very top of `.zshrc` to get full detail.
Remove it after profiling — it adds ~5ms overhead.

### Baseline (warm, caches populated)

~70–80ms on Apple Silicon. First run after `brew upgrade <tool>` will be slightly
slower as affected caches are regenerated.

### Cache files

All generated caches live under `~/.cache/zsh/`:

```
fzf_init.zsh
starship_init.zsh
zoxide_init.zsh
ngrok_completion.zsh
vscode_shell_integration_path
zcompdump-<zsh-version>
compcache/
```

To force a full rebuild of all caches:

```zsh
rm -rf ~/.cache/zsh && exec zsh
```

---

## Known Gotchas

| Gotcha | Where it's handled |
|---|---|
| `/etc/zshrc` resets `HISTFILE` + `HISTSIZE` | Top of `.zshrc` re-asserts both |
| macOS per-window history fragmentation | `SHELL_SESSIONS_DISABLE=1` in `.zshenv` |
| `brew --prefix` is slow (~25ms each call) | `HOMEBREW_PREFIX` hardcoded in `.zshenv` |
| `compaudit` runs on every shell (was 93% of startup) | `compinit -C` when dump is <24h old |
| `code --locate-shell-integration-path` outputs a path, not shell code | Custom logic in `04-tools.zsh` |
| `fnm env` mints a unique per-shell `FNM_MULTISHELL_PATH` — caching it leaks `fnm use` across windows | Direct `eval "$(fnm env --use-on-cd)"`, **not** `_zsh_cache_eval`, in `04-tools.zsh` |
| `compdef` not available when `.alias` loads | `.alias` sourced after `conf.d/` loop |
| `$(command -v tool)` spawns a subshell | Use `$commands[tool]` instead |
| Duplicate PATH entries | `typeset -U path PATH` deduplicates automatically |

---

## History

Single canonical file: `~/.local/state/zsh/history`

- Format: extended (`EXTENDED_HISTORY`) — each entry includes timestamp + duration
- Size: 1,000,000 entries in memory and on disk
- Sharing: `SHARE_HISTORY` writes and imports across all live sessions in real time
- Dedup: `HIST_IGNORE_ALL_DUPS` + `HIST_SAVE_NO_DUPS` keep it clean at scale
- Private commands: prefix with a space — `HIST_IGNORE_SPACE` won't record them

---

## fzf Keybindings

| Key | Action |
|---|---|
| `Ctrl+R` | Fuzzy history search |
| `Ctrl+T` | Fuzzy file picker (fd-powered) |
| `Alt+C` | Fuzzy directory jump (fd-powered) |
| `Ctrl+/` | Toggle preview pane (inside any fzf widget) |
| `Ctrl+Y` | Copy selected history entry to clipboard, abort |

---

## Custom Git Helpers

Defined in `.functions` (worktree-aware, so they need real shell logic — not
plain aliases).
| Command | Usage | Behavior |
|---|---|---|
| `gsw` | `gsw <branch>` | Switches to `<branch>`. If another worktree already has it checked out, `cd`s into that worktree instead of switching in place. |
| `gwrm` | `gwrm [-f] <branch>` | Removes the worktree checked out for `<branch>`. Prompts for confirmation unless `-f` is passed (`-f` also forces removal of a dirty worktree, git's `--force`). If your shell is currently inside the worktree being removed, hops back to the main worktree first so you aren't left in a deleted directory. |

Neither command deletes the git branch itself — only the worktree.

---

## XDG Compliance

| Variable | Path |
|---|---|
| `XDG_CONFIG_HOME` | `~/.config` |
| `XDG_CACHE_HOME` | `~/.cache` |
| `XDG_DATA_HOME` | `~/.local/share` |
| `XDG_STATE_HOME` | `~/.local/state` |
| `XDG_RUNTIME_DIR` | `~/.run` |

All tool homes (Cargo, Volta, Flutter, Android, Ruby, etc.) are redirected to XDG
paths in `.zshenv`. See that file for the full list.

---

## Hermes Agent

Hermes's home is relocated into this repo and symlinked, exactly like `.claude`:

```
~/.hermes  →  ~/dotfiles/.config/hermes   (real home, inside the repo)
~/.config is itself a symlink → ~/dotfiles/.config
```

`make setup-aliases` (which now runs `setup-hermes`) creates the symlink. The
launchd plist (`~/Library/LaunchAgents/ai.hermes.gateway.plist`) hardcodes
`/Users/saileshbro/.hermes/...` in three places, but every path resolves
*through* the symlink, so moving the home requires no plist edits. To relocate
the home again: stop the gateway (`launchctl unload ~/Library/LaunchAgents/ai.hermes.gateway.plist`),
move the directory, recreate the symlink, then `launchctl load` it.

### What is tracked vs. ignored

`.gitignore` ignores everything under `.config/hermes/` and re-includes only:

| Tracked | Ignored |
|---|---|
| `config.yaml` (settings — **no secrets, no machine paths**) | `.env` (API keys), `auth.json` (OAuth tokens) |
| `SOUL.md` (persona) | `state.db`, `sessions/`, `logs/`, `cron/`, `cache/`, `kanban.db` |
| `skills/` (SKILL.md + references only) | `hermes-agent/` (1.8 GB agent source) |
| | `skills/.*` runtime state (.usage.json, .curator_state, .bundled_manifest) |

### Hard rules (do not violate)

- **Never hand-edit `config.yaml`** — use `hermes config set <key> <val>`. A stray
  indent corrupts the file and breaks the running gateway.
- **Secrets live in `.env`, never `config.yaml`.** `config.yaml` is portable and
  committed; `.env` is git-ignored and never committed.
- **`hermes-agent/` is the agent source, not your config** — it is 1.8 GB and must
  stay git-ignored. Do not `git add` it.
- After editing a skill under `skills/`, commit it; the runtime `.` state files
  regenerate automatically and stay ignored.

### Re-linking on a fresh machine

```zsh
make setup-hermes          # idempotent: no-op if already linked
# If ~/.hermes is already a real directory, move it first:
#   mv ~/.hermes ~/dotfiles/.config/hermes && ln -sfn ~/dotfiles/.config/hermes ~/.hermes
```

