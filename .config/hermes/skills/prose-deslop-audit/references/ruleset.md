# Consolidated anti-slop ruleset

Merged from: humanizer (41 patterns), deslop, unslop (31), anti-slop tell catalog, avoid-ai-writing tiers, slopbeth, anti-ai-slop-writing. The repo-local copies live in `.agents/skills/` / `.claude/skills/` of saileshdahal.com.np.

## 1. Vocab — replace on sight

| Replace | With |
|---|---|
| delve into | look at, dig into |
| testament to | shows, proves |
| robust | strong, reliable |
| comprehensive | full, thorough |
| cutting-edge | latest |
| leverage (verb) | use |
| pivotal / crucial | key, important |
| seamless(ly) | smooth, easy |
| game-changer | say what changed |
| deep dive / unpack | examine, explain |
| holistic, actionable, impactful | plain equivalents |
| utilize / facilitate / foster / empower / streamline | use / help / encourage / enable / simplify |
| navigate (figurative) | work through, handle |
| myriad / plethora | many (or a number) |
| cornerstone / paramount / transformative | foundation / top priority / say what changed |
| underscore / showcase / boast / serve as | highlight / show / has / is |
| nestled / vibrant / thriving | sits in / busy (say what) / growing |
| learnings / best practices / thought leadership | findings / what works / expert |

## 2. Structures

- "not just X, but Y" / "not X. Y." — state Y directly; keep only single load-bearing contrasts
- Rule-of-three padding; vary list length
- Throat-clearing ("It's worth noting...", "There is a failure mode worth naming...")
- Demonstrative kickers ("That instinct backfires." tacked on)
- Importance-flagging ("This matters.", "Make no mistake.")
- Significance inflation ("marks a pivotal moment", "underscores the importance")
- Superficial -ing tails ("highlighting...", "ensuring...")
- Vague attributions ("experts say") — name the source or cut
- Section-closing summaries restating the paragraph
- Generic conclusions ("The future looks bright.")
- Rhetorical self-Q&A ("The result? Devastating."); dramatic fragmentation ("Speed. That's it.")
- Three consecutive same-length sentences; parataxis chains

## 3. Punctuation / format

- Em dashes: ZERO in saileshdahal.com.np rendered copy (house rule); use comma/period/parenthesis
- Curly quotes → straight
- Title-case headings → sentence case
- Bold-first bullets where label restates the line; emoji bullets; unicode arrows in prose

## 4. Keep (voice, not slop)

Earned fragments after long sentences (sparingly); deliberate parallelism; strong closing lines; first-person conviction. Test: could the author defend it? Slop can't be defended.

## 5. Hard guardrails

Never change facts, numbers, names, URLs, citations, code blocks, quoted material, frontmatter data, or technical claims during a phrasing pass. Never invent anecdotes or specifics to replace vague ones. Over-editing already-strong text is a failure.
