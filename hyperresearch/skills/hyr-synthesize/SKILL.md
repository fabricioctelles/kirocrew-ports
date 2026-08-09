---
name: hyr-synthesize
description: Step 11 of HyperResearch V8 -- synthesize 3 angle-specific drafts into one integrated final report via a tool-locked synthesizer subagent.
triggers: hyperresearch step 11, synthesize drafts, final report synthesis, combine drafts, merge drafts into report
---

# Step 11 — Synthesize the Final Report

**Tier gate:** SKIP entirely for `light` tier — light tier wrote `final_report_<vault_tag>.md` directly in step 10 and proceeds straight to step 15 (polish). For `full`: run as documented below.

**Goal:** Turn the 3 angle-specific drafts from step 10 into ONE integrated final report at `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`. The orchestrator preps the strategic brief; the synthesizer subagent writes the report in two passes (rough integrated draft, then voice/redundancy/length cleanup).

**Tool-lock:** The synthesizer subagent is restricted to **Read + Write only** — no shell, no web, no spawning. This keeps the synthesis focused on writing.

---

## Recover State

Read these inputs:
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/scaffold.md` — vault_tag
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json` — atomic items, required_section_headings, response_format, citation_style
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-a.md`, `draft-b.md`, `draft-c.md` — the 3 angle-specific drafts from step 10
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md` — cross-locus tensions
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/source-tensions.json` — expert disagreements
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md` — load-bearing claims with verbatim quotes
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md` — canonical research query (GOSPEL)

---

## Step 11.1 — Read All 3 Drafts in Full

1. **Read each draft in full** from `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-{a,b,c}.md`. Don't skim — actually read. Hold them in context.

2. **Note each draft's:**
   - Core thesis
   - How many notes from `must_read_note_ids` it actually read
   - Strongest argumentative beat
   - Word/character count

---

## Step 11.2 — Spot-Check Factual Conflicts (Orchestrator Only)

The synthesizer is tool-locked — it cannot query sources. Resolve factual conflicts HERE, before spawning it.

For each substantive contradiction between drafts:
1. Identify the cited source IDs on both sides
2. Use `local_knowledge_search` to verify the actual source content
3. Write the verdict to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-conflicts.md`:

```markdown
## Conflict 1: <one-line description>
- Draft A says: <claim with citation>
- Draft B says: <opposing claim with citation>
- Source check: <what the source actually says, verbatim where possible>
- **Verdict:** <which side, with reason>
```

If no substantive conflicts, write: "No factual conflicts found across drafts."

---

## Step 11.3 — Write the Synthesis Plan

Write `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-plan.md`:

```markdown
# Synthesis plan

## Core thesis (1-2 sentences)
<the final report's central argument>

## The 3-7 strongest argumentative beats
1. **<short name>** — sourced from Draft <A/B/C>. <one sentence on the beat and why it's load-bearing>
2. ...

## Section structure
<list required_section_headings if present, OR the inferred H2 structure>

## Per-section commitments
### Section 1: <heading>
- Evidence to pull from: Draft A's <topic>, Draft C's <topic>
- Argumentative beat: <which committed position to argue here>
- Cross-locus tension to engage (if any): <name from comparisons.md>

### Section 2: ...

## Where drafts disagreed
- **<Disagreement 1>:** Draft A says X; Draft B says Y. **Commit to <side>** because <reason>.
- ...

## Length target
- response_format: <short|structured|argumentative>
- Pass 1 target: <middle of pass-1 range>
- Pass 2 final target: <middle of pass-2 range>
```

---

## Step 11.4 — Write the Synthesis Outline

Write `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-outline.md`:

```markdown
# Synthesis outline

## Executive summary
<1-2 sentences: the direct answer to the research_query, with top-line numbers if applicable>

## I. <First H2 from required_section_headings or plan>
<1-2 sentences: what this section establishes, which evidence anchors it>

## II. <Second H2>
<1-2 sentences>

...

## Conclusion / Opinionated synthesis
<1-2 sentences: the committed reading, the strongest forward-looking implication>

## Sources
<only for citation_style == "inline" — N numbered entries, deduplicated>
```

The outline is short (50-200 words). It's the structural anchor that prevents pass-1 sections from rambling.

---

## Step 11.5 — Verification Gate

Before spawning the synthesizer, verify these files exist with non-trivial content:
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-plan.md` — must include core thesis and per-section commitments
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-outline.md` — must include one outline entry per H2
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-conflicts.md` — exists (may say "no conflicts found")
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-{a,b,c}.md` — all three exist

If any are missing or trivial, fix them before proceeding.

---

## Step 11.6 — Spawn the Synthesizer

Spawn ONE synthesizer subagent using `spawn_sub_agents` (blocking) or `spawn_run`:

```python
spawn_sub_agents(tasks=[{
    "task": """
RESEARCH QUERY (verbatim, gospel):
> {paste query.md body}

PIPELINE POSITION: You are step 11 of the HyperResearch V8 pipeline.
Step 10 produced 3 angle-specific drafts. The orchestrator wrote a
synthesis plan and outline. You read everything and write the final
report in TWO passes (pass 1 = rough integrated draft, pass 2 = voice/
redundancy/length cleanup). You are tool-locked to Read + Write only —
you cannot use shell commands, cannot spawn subagents, cannot search the web.

YOUR INPUTS:
- query_file_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md
- draft_paths:
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-a.md
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-b.md
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-c.md
- synthesis_plan_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-plan.md
- synthesis_outline_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-outline.md
- synthesis_conflicts_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-conflicts.md
- decomposition_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json
- comparisons_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md
- source_tensions_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/source-tensions.json
- evidence_digest_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md
- pass1_output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-pass1.md
- final_output_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
- response_format: "<short|structured|argumentative>"
- citation_style: "<wikilink|inline|none>"

PROCEDURE:
1. Read ALL input files fully
2. Write pass 1 (rough integrated draft) to pass1_output_path
3. Audit pass 1 for redundancy, voice consistency, weak sections, length
4. Write cleaned pass 2 to final_output_path

Do not paste paragraphs from input drafts — synthesize in your own voice.

CITATION RENDERING:
- wikilink (default): `[[note-id]]` markers, NO separate Sources section
- inline: `[N]` markers, grouped as `[7, 12]` never `[7][12]`, plus `## Sources` section
- none: no citation markers anywhere

REPORT BACK: Word count for pass 1 and pass 2, delta, top redundancies cut, sections flagged as weak.
""",
    "description": "Synthesizer - final report writer"
}])
```

**CRITICAL: After spawning, END YOUR TURN.** Wait for the `[Subagent completion event]` message.

---

## Step 11.7 — Validate the Synthesizer Output

When the synthesizer returns:

1. **Confirm both files exist:**
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-pass1.md`
   - `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`

2. **Read the synthesizer's report-back** for word counts and flags.

3. **Sanity checks on the final report:**
   - **LENGTH GATE:** Count words. Must be within target range for response_format.
   - Has all H2s from `required_section_headings`
   - Citations match `citation_style`
   - No adjacent citation stacks (`][` patterns)
   - Major sections open with plain-language primer before analysis
   - No YAML frontmatter, no scaffold leaks, no pipeline vocabulary

4. **If pass 2 is longer than pass 1** — something went wrong. Pass 2 should CUT.

5. **If length gate fails:** Re-spawn synthesizer ONCE for compression pass with directive to cut to target range. This is the ONE permitted regeneration.

6. **For other issues:** Hand-craft edits yourself. Do NOT re-spawn for non-length issues.

---

## Write-Once After Synthesis

After this step, the final report is only modified by Edit hunks from the patcher (step 14) and polish auditor (step 15). Do NOT re-write or re-synthesize.

---

## Exit Criterion

- `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` exists
- Word count verified ≤ target high
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/synthesis-pass1.md` exists
- All H2s from `required_section_headings` present
- Citations match `citation_style`, no adjacent stacks
- No YAML frontmatter, no pipeline vocabulary, no scaffold leaks

---

## Next Step

Return to the orchestrator. Invoke step 12:

```bash
cat ~/.kiro/crew/skills/hyr-critics/SKILL.md
```
