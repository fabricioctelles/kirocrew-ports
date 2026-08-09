---
name: hyr-loci
description: >
  HyperResearch Step 4: Loci Analysis. Spawns 2 parallel loci-analyst
  subagents to identify 1-6 depth investigation questions from width corpus.
  Deduplicates, scores on importance/uncertainty/disagreement/decision_impact,
  and allocates source budgets dynamically.
triggers: hyr-loci, loci analysis, depth questions, research loci, identify loci
---

# hyr-loci — Loci Analysis (Step 4)

**Tier gate:** SKIP for `light` tier — proceed directly to step 9 (synthesis). Only `full` tier runs loci analysis.

**Goal:** identify 1–6 specific questions where depth investigation will pay off.

## When to use

- Called by hyr-orchestrator after width sweep completes (step 2/3)
- User says "identify loci", "find depth questions", "run loci analysis"
- Full-tier research needs focused depth investigation

## Inputs

Read from `~/.kiro/crew/workspace/research/runs/<vault_tag>/`:
- `scaffold.md` — vault_tag, tier
- `prompt-decomposition.json` — atomic items, sub-questions
- `temp/contradiction-graph.json` — ranked fight clusters (if step 3 ran)
- `temp/coverage-gaps.md` — weak coverage areas
- `query.md` — original research query (verbatim)

## Procedure

### 1. Spawn 2 parallel loci-analysts

Use `spawn_run` with tasks array to run both analysts in parallel:

```
spawn_run(tasks=[
  "LOCI ANALYST A: Read width corpus at ~/.kiro/crew/workspace/research/runs/<vault_tag>/. 
   Research query: [paste query.md content].
   Analyze contradiction-graph.json and coverage-gaps.md.
   Identify 1-6 loci (specific questions) where depth investigation pays off.
   For each locus: name, one_line summary, flavor (dialectical|synthesis|technical),
   corpus_evidence (note IDs supporting it), opposing_positions if any.
   Also list skip_loci with justification for questions you considered but rejected.
   Write JSON to ~/.kiro/crew/workspace/research/runs/<vault_tag>/loci-a.json",
   
  "LOCI ANALYST B: Read width corpus at ~/.kiro/crew/workspace/research/runs/<vault_tag>/.
   Research query: [paste query.md content].
   Analyze contradiction-graph.json and coverage-gaps.md.
   Identify 1-6 loci (specific questions) where depth investigation pays off.
   For each locus: name, one_line summary, flavor (dialectical|synthesis|technical),
   corpus_evidence (note IDs supporting it), opposing_positions if any.
   Also list skip_loci with justification for questions you considered but rejected.
   Write JSON to ~/.kiro/crew/workspace/research/runs/<vault_tag>/loci-b.json"
])
```

### 2. Handle results

- If one fails, proceed with successful output
- If both fail (empty loci), stop — width sweep too thin for depth

### 3. Deduplicate and clamp to 6 max

Read both `loci-a.json` and `loci-b.json`:
- Dedupe on `name` (exact or near-match on core question)
- Prefer entry with stronger `corpus_evidence` when merging
- Drop weakest if >6 loci (rank by load-bearing value to research query)
- **Union both analysts' `skip_loci` arrays** — justifications matter downstream

### 4. Score and budget each locus

For each surviving locus, compute four dimensions (0-10 each):

| Dimension | Low (1-3) | Moderate (4-6) | High (8-10) |
|-----------|-----------|----------------|-------------|
| **importance** | tangential enrichment | secondary sub-question | directly answers primary sub-question |
| **uncertainty** | corpus resolves it | one side clearly stronger | sharp fight, equal-quality evidence |
| **disagreement** | singleton source | few sources differ | multi-source fights (7+ in cluster) |
| **decision_impact** | adds nuance only | moderate thesis adjustment | changes recommendation/thesis |

**Composite score** = importance + uncertainty + disagreement + decision_impact (max 40)

**Source budget allocation** (total budget ~30 sources):

| Score Range | Budget | Investigation Level |
|-------------|--------|---------------------|
| 30-40 | 10-15 sources | deep dive |
| 20-29 | 5-8 sources | standard |
| 10-19 | 2-4 sources | shallow pass |
| <10 | 0-3 sources | skip or minimal |

### 5. Write scored loci

Output to `~/.kiro/crew/workspace/research/runs/<vault_tag>/loci.json`:

```json
{
  "loci": [
    {
      "name": "...",
      "one_line": "...",
      "flavor": "dialectical|synthesis|technical",
      "importance": 8,
      "uncertainty": 7,
      "disagreement": 6,
      "decision_impact": 9,
      "composite_score": 30,
      "source_budget": 12,
      "rationale": "...",
      "corpus_evidence": ["note-id-1", "note-id-2"]
    }
  ],
  "skip_loci": [
    {
      "name": "...",
      "reason": "..."
    }
  ],
  "total_budget_allocated": 30,
  "investigator_count": 3
}
```

### 6. Determine investigator count

- One depth-investigator per locus with `source_budget > 0`
- Cap at 4 investigators max
- If only 1 locus passes scoring, spawn 1

### 7. Review inference_depth

Check if step 1's provisional `inference_depth` still fits the actual corpus:

- **Upgrade to `deep`**: load-bearing questions underdetermined by published sources; missing evidence is gray literature, filings, unpublished figures
- **Downgrade to `surface`**: corpus turned out rich and univocal

Update `scaffold.md` if changed.

## Invariants

- **At least one `flavor: "dialectical"` locus required** unless an analyst's `skip_loci` justifies absence with specific evidence of univocal corpus
- No dialectical locus + no justification = re-run analysts with tighter prompt
- No placeholder breadcrumbs — use real source note IDs or omit

## Exit criteria

- `loci.json` exists with ≥1 locus (or both analysts justified skip)
- At least one dialectical locus OR documented justification
- All retained loci have `source_budget` allocated

## Next step

Return to hyr-orchestrator. Proceed to step 5:

```
cat ~/.kiro/crew/skills/hyr-depth/SKILL.md
```

Then spawn depth investigators for each locus with `source_budget > 0`.
