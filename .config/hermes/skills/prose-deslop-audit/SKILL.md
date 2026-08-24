---
name: prose-deslop-audit
description: Use when deslopping repo-wide prose with anti-slop skills.
---

# Repo-wide prose deslop audit

Workflow for applying the user's stable of anti-AI-writing skills (humanizer, deslop, unslop, anti-slop, slopbeth, avoid-ai-writing) across an entire repository.

## Workflow

1. **Read the skills once, dedupe into one ruleset** (pre-merged version in `references/ruleset.md`). The nine+ skill variants overlap ~90%. Merge into a single checklist:
   - Vocab tiers (delve, testament, seamless, leverage-as-verb, pivotal, showcase, …)
   - Structures: not-just-X contrasts, rule-of-three padding, throat-clearing, significance inflation, demonstrative kickers, section-closing summaries
   - Punctuation/format: em dashes, curly quotes → straight, title-case headings → sentence case, bold-first bullets
   - Guardrail from `anti-slop`: surgical phrasing-only edits; never alter facts, numbers, commands, code blocks, quoted material, frontmatter data; keep deliberate voice; a false positive that flattens a good sentence is worse than a surviving tell.
2. **Dispatch parallel audit subagents** over disjoint scopes (e.g. posts / docs / UI copy strings). Give each: the ruleset, explicit guardrails, and a strict output format (`path:line | tell | quoted span | suggested fix`). Instruct them to modify nothing. Have each write its full findings to `/tmp/<name>-findings.md`.
3. **Independently verify every finding before editing.** Subagent verdicts are self-reports. Run your own grep scans (banned vocab, em dash, curly quotes, title-case headings) and read each candidate span in context.
4. **Apply fixes with targeted patches**, then run the project's build/lint gates and re-scan the BUILT output.

## Pitfalls

- **Delegation logs truncate final reports.** The `live/<id>/task-0.log` caps `final summary:` lines (~120 chars visible) and `think` lines (~100 bytes); intermediate `result |` payloads are truncated too. Do NOT rely on reading the report back from the log — that is why step 2 has subagents write a findings file and step 3 re-derives findings independently.
- **Literal technical uses are false positives**: "eval harness", "navigate" as an actual tool/UI verb, framework class names (`ElevatedButton`). Carve these out explicitly in the subagent prompt.
- **Em dashes in source comments don't render** — only flag them where copy reaches a visitor. For rendered-copy truth, scan BUILD output (`dist/**/*.md|.txt|.json|.html`), including generated markdown twins; string-literal dashes in `.ts` generators are invisible to JSX linters but ship to `/*.md`.
- **House style wins over generic rules** (saileshdahal.com.np: zero em dashes anywhere rendered, zero bold in post bodies, numbered `##` sections). Check AGENTS.md first.
- Single load-bearing contrasts ("not X, it's Y" used once for a real distinction) are voice, not slop — keep them.

## Verification

After edits: project build + gates must pass, then grep built output for em dash, curly quotes (`’‘“”`), and top banned vocab. Expect zero hits.
