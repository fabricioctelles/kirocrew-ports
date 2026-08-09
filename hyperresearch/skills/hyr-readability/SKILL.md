---
name: hyr-readability
description: Step 16 (final) of HyperResearch V8 -- readability audit that spawns a recommender subagent to write JSON suggestions for paragraph merges, breaks, list/table conversions, bold injection; orchestrator applies selectively via Edit.
triggers: readability audit, readability recommendations, paragraph rhythm, visual structure, step 16, final step, polish report
---

# Step 16 — Readability Audit & Selective Apply (FINAL STEP)

**Tier gate:** Runs for ALL tiers. Every report gets a readability audit — readability is where small structural changes yield outsized scoring gains.

**Goal:** Improve the report's visual structure, paragraph rhythm, and scannability without changing substantive content. A recommender subagent writes JSON suggestions; YOU (the orchestrator) decide which to apply.

**Why split recommender + orchestrator-applied:** An Edit-based reformatter sometimes makes changes that hurt the argument — converting flowing prose to bullets when the prose was load-bearing. By having the recommender produce JSON and the orchestrator decide what to apply, we get pattern-matching speed plus judgment about which changes serve the research_query.

---

## Recover state

Read these inputs:

```bash
VAULT_TAG="<your-tag>"
cat ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/scaffold.md
cat ~/.kiro/crew/workspace/research/notes/final_report_$VAULT_TAG.md
```

---

## Step 16.1 — Spawn the readability recommender

Spawn ONE subagent via `spawn_run`. Single spawn, runs once.

```python
spawn_run(task="""
RESEARCH QUERY (verbatim, gospel):
> [paste research/runs/<vault_tag>/query.md body]

QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

PIPELINE POSITION: You are step 16 of the HyperResearch V8 pipeline —
the final analytical pass. The final report at
~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md has been
drafted (step 10), synthesized (step 11), critiqued (step 12), gap-filled
(step 13), patched (step 14), and polish-audited (step 15). Your job: write
JSON recommendations for paragraph rhythm, list/table conversions, and other
structural readability improvements. You CANNOT edit the report directly.
The orchestrator reads your recommendations and decides which to apply.

YOUR TASK:
1. Read the final report at ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
2. Analyze for readability improvements
3. Write recommendations to ~/.kiro/crew/workspace/research/runs/<vault_tag>/readability-recommendations.json

RECOMMENDATION SCHEMA:
Write a JSON array of objects, each with:
{
  "id": "rec-1",
  "category": "merge-paragraphs|break-paragraph|make-list|make-table|bold-keyterms|split-sentence|remove-hr|add-whitespace",
  "severity": "high|medium|low",
  "location": "<section name or line reference>",
  "rationale": "<why this change improves readability>",
  "current": "<exact text to replace — copy verbatim>",
  "recommended": "<replacement text>"
}

CATEGORY GUIDANCE:
- merge-paragraphs: Adjacent paragraphs on same sub-topic that should be one
- break-paragraph: Paragraphs > 800 CJK / 1500 EN chars needing a break
- make-list: Enumerative prose (3+ sequential items) → bullet list
- make-table: Comparison prose (3+ entities × 2+ dimensions) → table
- bold-keyterms: Load-bearing concepts and statistics to emphasize
- split-sentence: Overly long sentences (> 50 words) harming clarity
- remove-hr: Horizontal rules that don't belong in research reports
- add-whitespace: Missing blank lines between sections

Cap at 25 recommendations, prioritized by impact (high severity first).

Report back:
- Total count by category
- Highest-severity issue
- Expected net char delta if all applied
""")
```

**STOP after spawn_run.** Wait for the `[Subagent completion event]` before continuing.

---

## Step 16.2 — Read the recommendations

When the recommender returns:

1. Read `~/.kiro/crew/workspace/research/runs/<vault_tag>/readability-recommendations.json`
2. Note the recommender's summary: count by category, highest severity, expected delta

---

## Step 16.3 — Decide which to apply

You are NOT obligated to apply every recommendation. Use these heuristics:

**Apply confidently:**
- All `merge-paragraphs` where adjacent paragraphs are clearly same sub-topic
- All `break-paragraph` on paragraphs > 800 CJK / 1500 EN chars
- All `remove-hr` (horizontal rules don't belong in research reports)
- All `add-whitespace` (zero risk)
- `make-table` when prose-comparison cited 3+ entities × 2+ dimensions and table preserves all points

**Apply with judgment:**
- `make-list`: Confirm prose was actually enumerative (3+ items in sequence), NOT load-bearing argumentative prose. If rationale says "items appear sequentially in flowing prose," skip it.
- `bold-keyterms`: Confirm term is genuinely key, not just any noun. Bold concepts and statistics; don't over-bold.

**Apply skeptically (often skip):**
- `split-sentence` on argumentative prose where length serves emphasis
- Recommendations touching the opening thesis paragraph
- Recommendations changing existing tables

**Always skip:**
- Recommendations whose `current` field doesn't match actual draft (mis-anchored)
- Recommendations changing H2 heading text
- Recommendations deleting substantive content

---

## Step 16.4 — Apply chosen recommendations via Edit

For each recommendation you decide to apply, use the file write tool with `strReplace`:

```python
write(
    command="strReplace",
    path="~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md",
    oldStr=recommendation["current"],  # Exactly as recommender wrote it
    newStr=recommendation["recommended"]
)
```

**Order of application:**
1. `remove-hr` first (smallest changes, cleanest baseline)
2. `merge-paragraphs` and `break-paragraph` (paragraph-level)
3. `make-list` and `make-table` (structural conversions)
4. `bold-keyterms` (within finalized paragraphs)
5. `split-sentence` (within finalized paragraphs)
6. `add-whitespace` (final cleanup)

If an Edit fails because `oldStr` doesn't match, skip that recommendation and continue.

---

## Step 16.5 — Log decisions

Write `~/.kiro/crew/workspace/research/runs/<vault_tag>/readability-decisions.json`:

```json
{
  "vault_tag": "<vault_tag>",
  "timestamp": "<ISO-8601>",
  "total_recommendations": 15,
  "applied": ["rec-1", "rec-3", "rec-7"],
  "skipped": [
    {"id": "rec-2", "reason": "Prose was load-bearing argument, not enumerative list"},
    {"id": "rec-5", "reason": "Touches opening thesis paragraph"}
  ],
  "edit_failures": [
    {"id": "rec-4", "reason": "old_string did not match the draft"}
  ],
  "net_char_delta_actual": -127
}
```

This audit trail shows whether we considered and skipped a recommendation, or never saw it.

---

## Exit criterion

All must be true:
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/readability-recommendations.json` exists
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/readability-decisions.json` exists with at least one `applied` or all `skipped`
- `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` reflects applied recommendations
- Report structure (H2 list, executive summary, conclusion) unchanged from step 15

---

## Pipeline complete

Return to the router skill (`hyr-research`). Update `run.json`:

```json
{
  "status": "done",
  "steps_completed": [..., "step-16-readability"]
}
```

Tell the user the final report path:
`~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`

**You're done.**
