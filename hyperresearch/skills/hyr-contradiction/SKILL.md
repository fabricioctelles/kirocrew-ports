---
name: hyr-contradiction
description: Build contradiction graph from extracted claims — identifies opposing positions across sources and consensus claims for confident assertions.
---

# Step 3 — Contradiction Graph

**Tier gate:** SKIP for `light`. Run for `full`.

**Goal:** Build an explicit graph of opposing claims before loci analysis. Loci should emerge from where evidence actually forks, not from agent intuition.

---

## Paths

- Run directory: `~/.kiro/crew/workspace/research/runs/<vault_tag>/`
- Scaffold: `scaffold.md`
- Decomposition: `prompt-decomposition.json`
- Claims input: `temp/claims-*.json`
- Output graph: `temp/contradiction-graph.json`
- Output consensus: `temp/consensus-claims.json`

---

## Recover state

Read these inputs:
- `research/runs/<vault_tag>/scaffold.md` — vault_tag
- `research/runs/<vault_tag>/prompt-decomposition.json` — atomic items, pipeline_tier
- All `research/runs/<vault_tag>/temp/claims-*.json` files (one per fetched note)

If no claims files exist (fetchers didn't produce them), skip this step — loci analysis falls back to corpus prose-scanning.

---

## Procedure

### 1. Load all claims

Glob `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/claims-*.json` and parse each file.

### 2. Pair contradictions (spawn_run for parallel analysis)

For large claim sets (>50 claims), use spawn_run to parallelize:

```
spawn_run(tasks=[
  "Analyze claims batch 1-25 for contradictions: same stance_target with opposing stance, same entities with opposite conclusions",
  "Analyze claims batch 26-50 for contradictions: same scope but different numbers, overlapping scope_conditions with different evidence"
])
```

Match contradictions on:
- Same `stance_target` with opposing `stance` (supports vs. refutes)
- Same `entities` with opposite conclusions
- Same scope but different `numbers` (e.g., "market grew 15%" vs. "market shrank 3%")
- Overlapping `scope_conditions` but different `evidence_type` pointing different directions

### 3. Cluster contradiction pairs into fights

Group related pairs into clusters — each cluster is one contested question:

```json
{
  "cluster_id": "short-slug",
  "fight": "one-sentence description of what's contested",
  "side_a": {
    "position": "...",
    "claims": ["claim-text-1"],
    "sources": ["note-id-1"]
  },
  "side_b": {
    "position": "...",
    "claims": ["claim-text-1"],
    "sources": ["note-id-1"]
  },
  "evidence_quality_delta": "which side has stronger evidence types (empirical > theoretical > anecdotal)",
  "scope_overlap": "genuine disagreement, or scoped differently and both right?",
  "decision_relevance": "high|medium|low — does resolving this matter for the research_query"
}
```

### 4. Rank clusters

Order by:
1. `decision_relevance` (high first)
2. `evidence_quality_delta` (tighter fights rank higher — closer evidence quality = more contested)

### 5. Write contradiction graph

Output to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/contradiction-graph.json`:

```json
[
  {
    "cluster_id": "ai-job-displacement",
    "fight": "Whether AI will create net job losses or gains",
    "side_a": {...},
    "side_b": {...},
    "evidence_quality_delta": "side_a: empirical studies, side_b: theoretical projections",
    "scope_overlap": "genuine disagreement on same timeframe",
    "decision_relevance": "high"
  }
]
```

### 6. Identify consensus claims

Claims where 3+ INDEPENDENT sources agree. Independence is computed:

**Independence scoring:**
- Cluster syndicated copies (same canonical URL, near-duplicate bodies, shared wire-service boilerplate)
- Score each member as `1/cluster_size`
- Count cluster as ONE voice — sum of independence scores ≥ 3.0, not raw source count ≥ 3

Write to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/consensus-claims.json`:

```json
[
  {
    "claim": "Global AI market expected to exceed $1T by 2030",
    "independence_score": 4.2,
    "sources": ["note-a", "note-b", "note-c", "note-d"],
    "source_clusters": 5,
    "evidence_type": "market_analysis"
  }
]
```

These are "settled ground" — the draft can assert confidently without hedging.

---

## Exit criterion

Both files must exist (may be empty arrays if corpus is univocal):
- `temp/contradiction-graph.json`
- `temp/consensus-claims.json`

---

## Next step

Return to entry skill. Tier-based routing:
- **full tier:** Proceed to `hyr-loci` (loci analysis)
