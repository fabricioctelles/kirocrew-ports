---
name: hyr-corpus-critic
description: "Step 8: Pre-draft corpus critic -- identify 'what source would overturn this?' gaps and run targeted fetch wave to fill them before drafting."
---

# Step 8 — Pre-draft corpus critic (targeted gap-fill)

**Tier gate:** `full` tier ONLY. Skip for `light`.

**Goal:** before drafting, ask "what source, if found, would overturn the current direction?" and run a targeted fetch wave to fill the most dangerous gaps. This is the highest-leverage intervention point in the pipeline — corrections applied before drafting cost nothing; corrections applied after drafting require patches and risk structural drift.

---

## Recover state

Read these inputs from `~/.kiro/crew/workspace/research/runs/<vault_tag>/`:
- `scaffold.md` — vault_tag
- `comparisons.md` — cross-locus tensions
- `loci.json` — scored loci
- `temp/source-tensions.json` — expert disagreements
- `prompt-decomposition.json` — specifically the `time_periods` array

---

## Pre-flight: period-pinned primary-source coverage check

**Run this BEFORE spawning the corpus-critic subagent.** If `prompt-decomposition.json -> time_periods` is non-empty, walk every entry and verify the vault contains a primary source filed *for that exact period* — not "most recent", not narrative commentary, not earnings-call transcripts standing in for tabular filings.

For each `time_period` entry:

1. Search the vault for a primary source matching the `primary_source` description and the `issuer`:
   ```python
   local_knowledge_search(query="<period> <issuer> <primary_source>")
   ```

2. Verify the document's actual reporting period — the filing must cover the SPECIFIC period named in the prompt, not an adjacent one. A Q1 2025 10-Q does NOT satisfy "Q3 2024" — different period, different tabular data.

3. **If the period-pinned filing is missing, add it to `~/.kiro/crew/workspace/research/runs/<vault_tag>/corpus-critic-gaps.json` as a `priority: critical` gap of type `period-pinned-primary` BEFORE spawning the corpus-critic subagent.** Schema:
   ```json
   {
     "type": "period-pinned-primary",
     "target_position": "<period> exact figures for <issuer>",
     "search_queries": [
       "site:sec.gov 10-Q \"period ended September 30, 2024\" <issuer>",
       "<issuer> Q3 2024 10-Q filing PDF"
     ],
     "source_type": "primary-filing",
     "priority": "critical",
     "rationale": "Prompt names <period>; vault has no filing covering that exact period. Tabular line items only exist in the period-pinned filing. Without it, the draft will paraphrase rounded numbers from earnings calls and miss the rubric's exact figures."
   }
   ```

The targeted fetch wave will pull these filings BEFORE the corpus-critic finishes its broader gap analysis. This ordering matters: numerical-precision misses are the largest single category of avoidable factual-accuracy failures.

---

## Procedure

### 1. Spawn the corpus-critic subagent

Spawn ONE subagent to identify gaps:

```python
spawn_run(task="""
RESEARCH QUERY (verbatim, gospel):
> {paste ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md body}

QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

PIPELINE POSITION: You are step 8 (corpus-critic) of the HyperResearch V8 pipeline.
Step 6 produced comparisons.md. After you return, the orchestrator runs a targeted
fetch wave, then step 10 drafts.

YOUR TASK:
1. Read comparisons.md and loci.json
2. For each committed position, ask: "What source, if found, would OVERTURN this?"
3. Also ask: "What source would STRENGTHEN this beyond the current evidence?"
4. Output gaps to corpus-critic-gaps.json

YOUR INPUTS:
- vault_tag: <vault_tag>
- comparisons_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md
- loci_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/loci.json
- output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/corpus-critic-gaps.json

OUTPUT FORMAT (corpus-critic-gaps.json):
{
  "gaps": [
    {
      "id": "gap-1",
      "type": "overturning|strengthening|independent-verification",
      "target_position": "<the committed position this gap relates to>",
      "search_queries": ["query1", "query2"],
      "source_type": "academic|primary-filing|expert-opinion|data-series",
      "priority": "critical|high",
      "rationale": "<why this gap matters>"
    }
  ]
}

Focus on:
- Overturning gaps: sources that could disprove key claims
- Period-pinned data: specific time periods mentioned in the query
- Expert disagreements: opposing voices not yet in the corpus
- Independent verification: second sources for single-sourced claims
""")
```

**STOP after spawning. Wait for the completion event.**

### 2. Read the gaps output

After the subagent completes, read `~/.kiro/crew/workspace/research/runs/<vault_tag>/corpus-critic-gaps.json`. Each gap has:
- `priority`: critical / high
- `type`: overturning / strengthening / independent-verification / period-pinned-primary

### 3. Targeted fetch wave

Spawn **2–4 fetcher subagents** to search for and fetch the sources identified in the gaps. Group gaps by priority — critical first.

```python
spawn_run(tasks=[
    """
    RESEARCH QUERY (verbatim, gospel):
    > {query}

    PIPELINE POSITION: Step 8 fetcher (corpus-critic gap-fill).
    The corpus critic identified specific gaps; you fetch sources targeting those gaps.

    YOUR TASK:
    1. Run web_search for each query in search_queries
    2. For promising results, run web_fetch to get content
    3. Write findings to ~/.kiro/crew/workspace/research/runs/<vault_tag>/sources/gap-<gap_id>.md

    YOUR INPUTS:
    - vault_tag: <vault_tag>
    - gap_id: <gap.id>
    - search_queries: {gap.search_queries}
    - source_type: {gap.source_type}
    - target_position: {gap.target_position}

    OUTPUT: Note file with fetched sources, or explicit "NOT_FOUND" if no relevant sources exist.
    """,
    # ... one task per critical/high gap, up to 4 parallel
])
```

**STOP after spawning. Wait for all completion events.**

### 4. Assess results

After fetchers complete, assess each gap:

- **Overturning source found:** Re-read the relevant committed position from the interim note. If the new source genuinely undercuts it, update `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md` to note the weakened position — the draft will handle it with appropriate calibration. Do NOT re-run the full depth investigation; adjust the position's confidence level.

- **Overturning source NOT found:** The committed position gains confidence. Note this in `comparisons.md` — "adversarial search for counter-evidence to [position] returned no substantive challenges."

- **Strengthening/verification source found:** Note the additional support in `comparisons.md`. The draft can assert more confidently.

### 5. Log results

Write to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/corpus-critic-results.md`:

```markdown
# Corpus Critic Results

## Gaps Identified
- Total: N
- Critical: N
- High: N

## Fetch Results

### Gap: <gap_id> (<type>)
- Target position: <target_position>
- Search queries: <queries>
- Result: FOUND / NOT_FOUND
- Impact: <how this affects the committed position>
- Confidence adjustment: <original> -> <new>

## Updated Positions
- Position X: confidence HIGH -> VERY HIGH (independent verification found)
- Position Y: confidence HIGH -> MEDIUM (partial counter-evidence found)

## Unfillable Gaps
- <gap_id>: <reason why unfindable>
```

---

## Exit criterion

All four conditions must be met:

1. `~/.kiro/crew/workspace/research/runs/<vault_tag>/corpus-critic-gaps.json` exists
2. All critical gaps attempted (fetched or documented as unfindable)
3. `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/corpus-critic-results.md` exists
4. `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md` updated with confidence/strengthening/overturning notes

---

## Next step

Return to the orchestrator (`hyr-research`). Invoke step 9:

```bash
cat ~/.kiro/crew/skills/hyr-evidence-digest/SKILL.md
```
