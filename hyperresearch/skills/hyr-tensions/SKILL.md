---
name: hyr-tensions
description: Extract explicit expert disagreements from corpus into source-tensions.json -- orphan tensions that didn't surface as loci, plus cross-locus tensions from comparisons.md. Highest-leverage move for insight scores.
triggers: source tensions, expert disagreements, tension extraction, step 7, hyr-7
---

# Step 7 — Source Tension Extraction

**Tier gate:** SKIP for `light` tier. Only `full` tier runs this step.

**Goal:** Extract explicit expert disagreements from the corpus and comparisons into a structured artifact that step 10 MUST include as a dedicated section. This is the single highest-leverage move for the insight dimension.

**Why this step exists:** Step 6's `comparisons.md` captures cross-locus tensions — places where depth investigators disagree. But the richest disagreements often live in the width corpus itself: Source A says X, Source B says Y, and neither the loci analysts nor the depth investigators elevated this as a locus because it cut across multiple topics. These "orphan tensions" are invisible to locus-driven analysis but are exactly what distinguishes an expert synthesis from a competent survey.

---

## Recover State

Read these inputs from `~/.kiro/crew/workspace/research/runs/<vault_tag>/`:

1. **`scaffold.md`** — vault_tag and research query
2. **`comparisons.md`** — cross-locus tensions from step 6
3. **`temp/contradiction-graph.json`** (if step 3 ran) — fight clusters
4. **Source notes** — use `local_knowledge_search(query="...")` to find the 15–20 highest-quality non-deprecated sources tagged with the vault_tag

---

## Procedure

### 1. Extract tensions from comparisons.md

Read `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md`. Each tension there is already a candidate source tension. Extract:
- The two positions
- The strongest evidence for each
- Your preliminary reading of which side has the better case

### 2. Scan width corpus for orphan tensions

For the 15–20 highest-quality sources, **read the full body** of the top 8–12 sources most likely to contain disagreements.

**Tensions hide in nuance that summaries flatten:** a source's "however" clause, a footnote caveat, a methodological critique buried in a discussion section. You cannot extract tensions you haven't read.

Look for:
- Sources that explicitly disagree with each other (different conclusions from similar evidence)
- Sources that use competing theoretical frameworks to explain the same phenomenon
- Sources where one side cites data the other side ignores
- Government/institutional positions that conflict with academic findings
- Industry claims that contradict independent research
- Historical consensus that recent evidence challenges

### 3. Mine the contradiction graph (if exists)

If `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/contradiction-graph.json` exists, read it.

Any high-relevance fight cluster that was NOT promoted to a locus is a prime orphan-tension candidate. It was important enough for the contradiction graph but wasn't investigated in depth — these deserve standalone treatment in the draft.

### 4. Select 3–7 source tensions

Combine comparisons.md tensions with orphan tensions. Rank by:

| Criterion | Question |
|-----------|----------|
| **Decision relevance** | Does resolving this tension change the report's recommendation? |
| **Evidence quality** | Are both sides grounded in real evidence (not just opinion)? |
| **Reader value** | Would an expert reader find this tension illuminating? |

**Drop tensions that are:**
- Trivially resolved (one side is clearly wrong)
- Definitional (disagreement about word meaning, not substance)
- Orthogonal to the research query

### 5. Pre-commit to a resolution for each tension

Do NOT leave tensions open. For each:

1. **Name it** in 5–10 words (e.g., "NHTSA's 'no defect' vs. NTSB's 'design failure'")
2. **State Side A's strongest case** with evidence (quote or cite specific sources)
3. **State Side B's strongest case** with evidence
4. **Commit to a reading:** which side has the better evidence, or is there a synthesis? Name the load-bearing reason.

### 6. Write source-tensions.json

Write to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/source-tensions.json`:

```json
{
  "tensions": [
    {
      "name": "short descriptive name",
      "side_a": {
        "position": "one-sentence claim",
        "evidence": "strongest evidence with source note ids",
        "proponents": ["source-note-id-1", "source-note-id-2"]
      },
      "side_b": {
        "position": "one-sentence claim",
        "evidence": "strongest evidence with source note ids",
        "proponents": ["source-note-id-3"]
      },
      "resolution": "one-paragraph committed reading with load-bearing reason",
      "origin": "comparisons|contradiction-graph|orphan-scan",
      "decision_relevance": "high|medium"
    }
  ]
}
```

This artifact feeds directly into step 10's mandatory Source Tensions section. Every tension named here becomes a subsection in the final report.

---

## Exit Criterion

- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/source-tensions.json` exists
- Contains 3–7 tensions
- Each tension has:
  - Both sides with proponents
  - A committed resolution
  - decision_relevance rating

---

## Next Step

Return to the orchestrator (`hyr-research`). Invoke step 8:

```bash
cat ~/.kiro/crew/skills/hyr-corpus-critic/SKILL.md
```
