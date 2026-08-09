---
name: hyr-draft
description: Step 10 — Triple-draft ensemble with per-angle source curation and 3 parallel draft-orchestrators (full tier) or single direct draft (light tier).
triggers: hyr-draft, triple draft, step 10, draft ensemble, draft orchestrators
---

# Step 10 — Triple-draft ensemble (curated lists, parallel writers)

**⚠ CRITICAL ANTI-PATTERN: Writing a single draft for `full` tier is a PIPELINE VIOLATION.** If you find yourself about to write `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` directly without spawning 3 draft-orchestrator subagents, STOP. Re-read this skill. Spawn the sub-orchestrators. (Light tier is the ONE exception — see "Light tier" section below.)

**Tier gate:** Runs for ALL tiers.
- `light` tier: write a single draft directly to `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` and skip ahead to step 15 (polish).
- `full` tier: run the triple-draft ensemble below — step 11 (synthesizer) will turn the 3 drafts into the final report.

**Goal:** produce THREE independent angle-specific drafts (`draft-{a,b,c}.md`). Step 11 (synthesizer subagent) consumes all three and writes the final report.

---

## Recover state

Read these inputs:
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/scaffold.md` — vault_tag, modality, wrapper requirements
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json` — atomic items, required_section_headings, response_format, citation_style, pipeline_tier
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md` — top claims + verbatim quotes (full only; absent for light)
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md` (full tier) — cross-locus tensions
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/source-tensions.json` (full tier) — expert disagreements
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/coverage-gaps.md` (if exists) — items with weak source coverage
- Survey vault via `local_knowledge_search` for the evidence landscape
- Modality calibration (from the scaffold's `modality` field):
  - **collect** — enumerative coverage, per-entity sections with named fields
  - **synthesize** — defended thesis with evidence chains, interpretive density
  - **compare** — proportionate per-entity depth + a committed recommendation
  - **forecast** — predictive claims grounded in past + present, explicit time horizon

---

## Step 10.0 — Read response_format and citation_style

Read `response_format` and `citation_style` from `~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json`. These control the draft shape:

| Format | Target length | Character |
|--------|-------------|-----------|
| `"short"` | 500–1500 words / 1500–6000 chars (CJK) | Direct answer, compact |
| `"structured"` | 1500–3000 words / 6000–15000 chars (CJK) | Scannable, breadth-first |
| `"argumentative"` | 4000–6000 words / 20000–25000 chars (CJK) | Dense thesis-driven |

**Length discipline:** Target the MIDDLE of the range. Under-length loses on comprehensiveness; over-length dilutes good content.

---

## Light tier ONLY: single-draft path

If `pipeline_tier == "light"`: SKIP steps 10.1 — 10.3 below and follow this section instead.

**Light tier writes a single draft directly to `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`.** No subagents, no triple-draft ensemble, no synthesizer.

1. **Read the vault directly.** Light tier has no `evidence-digest.md` (step 9 was skipped). Use `local_knowledge_search(query="<vault_tag>")` and pick the 10–20 most relevant non-deprecated notes. Read each one before writing.

2. **Honor the structural contract.**
   - Use the literal H2 headings from `required_section_headings` in `~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json`, in order.
   - Hit the length target from step 10.0's table for the chosen `response_format` (light typically pairs with `short` or `structured`).
   - Apply the modality calibration from the recover-state list above.

3. **Citations.** Three styles:
   - `"wikilink"` (default for non-wrapped runs): every citation is a `[[<source-note-id>]]` marker pointing at the source note in the vault. No separate `## Sources` section.
   - `"inline"` (benchmark + public deliverables): numbered `[N]` citations + a `## Sources` section listing each cited note as `[N] Title. URL`.
   - `"none"`: no citation markers anywhere, no Sources section.

4. **Hygiene.** No YAML frontmatter on the final report. No pipeline vocabulary in prose ("hyperresearch", "evidence digest", "comparisons.md", "committed reading", etc.).

5. **Exit and route.** Once `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` is written, return to the entry skill and invoke step 15 (polish). Light tier skips steps 11–14 entirely.

---

## Step 10.1 — Define 3 analytical angles (full tier)

Based on the evidence, tensions, and query, assign each sub-orchestrator a distinct angle. The angles should produce genuinely different drafts — not three versions of the same argument.

**For topics with clear tensions/disagreements:**
- **Draft A — Strongest-thesis:** take the position best supported by evidence and argue it forcefully.
- **Draft B — Steelman-contrarian:** take the strongest counter-position seriously. Defend the MINORITY view.
- **Draft C — Synthesis-reconciler:** argue that both sides capture part of the truth. Focus on BOUNDARY CONDITIONS — when does each side's argument hold?

**For topics without clear tensions (surveys, comparisons, collections):**
- **Draft A — Breadth-optimized:** widest possible coverage of all atomic items.
- **Draft B — Depth-optimized:** deeper treatment of the 3-4 most important atomic items.
- **Draft C — Practitioner-optimized:** organized around actionable recommendations.

Write the 3 angle assignments to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-angles.md` (for the run log). Each angle: 2-3 sentences describing the analytical direction.

---

## Step 10.2 — Curate per-angle source lists

**Critical step.** Each draft sub-orchestrator does NOT decide what to read. YOU pick the 20-50 most relevant vault notes for each angle and pass them as `must_read_note_ids`. This eliminates wasted vault-survey loops in the sub-orchestrators and forces real differentiation by giving each draft a different evidence base.

1. **List all substantive vault notes:**
   - Read `~/.kiro/crew/workspace/research/runs/<vault_tag>/sources/` directory
   - Use `local_knowledge_search` to surface notes tagged with vault_tag
   - Filter to non-deprecated notes. You should have 50-100 candidates.

2. **For each draft (A, B, C), pick 20-50 angle-specific notes.** Use these signals:
   - **Source-analysis notes** (`type: source-analysis`): high-value, full digests of long sources. Include relevant ones in EVERY draft's list — these are gold.
   - **Interim notes** (`type: interim`, full tier only): include all of them in EVERY draft's list — these have the committed positions.
   - **For Draft A (strongest-thesis or breadth):** prefer sources that support the dominant evidence direction.
   - **For Draft B (steelman-contrarian or depth):** prefer minority-view or methodological-critique sources. Pull from `source-tensions.json` proponents on the contested side.
   - **For Draft C (synthesis or practitioner):** prefer sources with boundary conditions, comparative analyses, or applied case studies.

3. **Source overlap is fine.** Drafts can share source IDs — interim notes and key source-analyses should appear in all three lists. Differentiation comes from the angle-specific extras.

4. **Cap each list at 50, minimum 20.** For `argumentative` format, lean toward 40-50. For `structured`, lean toward 25-35. For `short`, lean toward 20-25.

5. **Write each list to disk:**
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-a-source-list.md`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-b-source-list.md`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-c-source-list.md`

   Format:
   ```markdown
   # Draft A — must_read_note_ids (n=37)
   Angle: <2-3 sentence angle assignment>

   - <note-id-1>: <one-line summary or title>
   - <note-id-2>: <one-line summary or title>
   ...
   ```

---

## Step 10.3 — Spawn 3 draft sub-orchestrators in parallel

**Spawn 3 draft-orchestrator subagents in ONE `spawn_run` call.** This is true parallel execution. Each gets a different `draft_id`, `analytical_angle`, and (CRUCIALLY) a different `must_read_note_ids` array.

```python
spawn_run(tasks=[
    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste research query from query.md}

    PIPELINE POSITION: You are Draft A sub-orchestrator in the hyr-research V8 pipeline.
    After you and the other two return, the main orchestrator runs step 11 (synthesizer)
    which reads all 3 drafts and writes the final report.

    YOUR INPUTS:
    - vault_tag: <vault_tag>
    - draft_id: "a"
    - output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-a.md
    - analytical_angle: "<Draft A angle assignment>"
    - must_read_note_ids: [<IDs from draft-a-source-list.md>]
    - decomposition_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json
    - evidence_digest_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md
    - comparisons_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md
    - source_tensions_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/source-tensions.json
    - response_format: "<short|structured|argumentative>"
    - citation_style: "<wikilink|inline|none>"
    - modality: "<collect|synthesize|compare|forecast>"

    Read every note on must_read_note_ids before writing. Do NOT survey the vault — your
    reading list is curated. Do NOT fetch new sources. Write your draft from your assigned
    angle, citing your curated sources.

    Output: Write draft to output_path. Report back: path, core thesis, notes read count,
    strongest argumentative beat, word count.
    """,

    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste research query from query.md}

    PIPELINE POSITION: You are Draft B sub-orchestrator...
    [same structure, draft_id: "b", Draft B angle, draft-b-source-list.md IDs]
    """,

    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste research query from query.md}

    PIPELINE POSITION: You are Draft C sub-orchestrator...
    [same structure, draft_id: "c", Draft C angle, draft-c-source-list.md IDs]
    """
])
```

**CRITICAL: After calling `spawn_run`, END YOUR TURN IMMEDIATELY.** Do not emit bare text, do not do other work. Wait for `[Subagent completion event]` messages to arrive.

---

## Step 10.4 — Validate that all 3 drafts came back

When all 3 sub-orchestrators return:

1. **Confirm all 3 draft files exist:**
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-a.md`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-b.md`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-c.md`

2. **Read each sub-orchestrator's report-back.** Each should report:
   - Path to the draft
   - Core thesis
   - How many notes from `must_read_note_ids` it actually read
   - Strongest argumentative beat
   - Word/character count

3. **If a draft is missing or trivially short** (under 1000 chars for argumentative, 500 for structured), re-spawn that single sub-orchestrator with the same inputs. Do not proceed to step 11 with fewer than 3 drafts.

4. **Do NOT synthesize the drafts in this step.** Step 11 (the synthesizer subagent) does that. Your only job here is to ensure 3 valid drafts exist.

---

## Exit criterion

**Light tier:**
- `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` exists
- Hits the length target from step 10.0
- Follows `required_section_headings`
- Respects `citation_style`

**Full tier:**
- All three drafts exist at `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/draft-{a,b,c}.md`
- Each draft has non-trivial length (1000+ chars argumentative, 500+ structured)
- Sub-orchestrator report-backs are captured

---

## Next step

Return to the entry skill (`hyr-research`). Tier-based routing:

- **light tier:** You already wrote the final report directly. Skip steps 11-14 and invoke step 15 (polish): `cat ~/.kiro/crew/skills/hyr-polish/SKILL.md` (or the appropriate polish skill path).
- **full tier:** Invoke step 11 (synthesize): `cat ~/.kiro/crew/skills/hyr-synthesize/SKILL.md` (or the appropriate path).

---

## Invariants

1. **NEVER write final_report directly for full tier** — that's step 11's job
2. **3 drafts required for full tier** — no synthesis with fewer
3. **Light tier skips steps 11-14** — goes straight to polish
4. **Each draft gets a DIFFERENT curated source list** — this forces angle differentiation
5. **After `spawn_run`, END YOUR TURN** — wait for completion events
