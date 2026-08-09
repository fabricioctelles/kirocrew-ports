---
name: hyr-evidence
description: >
  Step 9 of HyperResearch V8 -- extract top load-bearing claims and verbatim
  quotes into evidence-digest.md for the draft sub-orchestrators.
triggers: evidence digest, claims extraction, quote compilation, step 9
---

# Step 9 — Evidence Digest

**Tier gate:** Run for `full`. Skip for `light`.

**Goal:** Assemble the top load-bearing claims and verbatim quotes from claims JSONs into a single digest file the drafter reads as primary evidence — higher-fidelity than fetcher summaries.

---

## Inputs

Read these files from the run workspace:

```
~/.kiro/crew/workspace/research/runs/<vault_tag>/scaffold.md
~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json
~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/claims-*.json
~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/consensus-claims.json (if step 3 ran)
~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/contradiction-graph.json (if step 3 ran)
```

---

## Procedure

### 1. Read all claims files

Glob `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/claims-*.json` for every non-deprecated note tagged with the vault tag.

If no claim files exist (fetchers didn't produce them), **skip this step entirely** and proceed to step 10.

### 2. Filter and rank

Keep claims where:
- `confidence` is `"high"`, OR
- `evidence_type` is `"empirical"` or `"statistical"`

From the remainder, **prefer claims with**:
- Non-empty `numbers` arrays
- Non-empty `quoted_support`

**Cap at 50 claims total** for `full` tier.

### 3. Group by atomic item

Match each surviving claim to the atomic item it is most relevant to based on **topic overlap** — do NOT rely on exact field matching.

A claim about "United Health Group regulatory exposure" serves the atomic item "UNH risk factors" even if no field matches exactly.

Use the claim's `entities`, `stance_target`, `scope_conditions`, and `claim` text **holistically** to judge relevance. When uncertain, include the claim under the most relevant item rather than dropping it to Ungrouped.

Claims that genuinely don't map to any atomic item go into an **"Ungrouped"** section at the end.

### 4. Include consensus and contested claims

**Consensus claims:** If `temp/consensus-claims.json` exists, include its claims marked as `[consensus]`.

**Contested claims:** If `temp/contradiction-graph.json` exists, include the **top 3–5 contested claim pairs** with both sides' `quoted_support` passages.

### 5. Write evidence-digest.md

Write to: `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md`

**Format:** One H3 per atomic item, bullet list of claims. Each bullet includes:
- The `claim` text
- The `quoted_support` verbatim passage (block-quoted)
- The `source_note_id`

Keep it **scannable** — this is an evidence index, not a narrative.

**Example:**

```markdown
# Evidence Digest

> vault_tag: market-asia-a1b2c3
> generated: 2026-08-05T21:20:00Z
> total_claims: 42

---

### Atomic item: Market growth in Southeast Asia

- Annual growth rate of 12.4% in 2024 (empirical)
  > "Southeast Asian e-commerce GMV grew from $89B to $100B between 2023 and 2024, a 12.4% YoY expansion."
  [source-note-12]

- Vietnam led by penetration rate (statistical)
  > "Vietnam reached 64% e-commerce penetration in 2024, the highest in SEA, surpassing Singapore (61%)."
  [source-note-19]

### Atomic item: Competitive landscape

- Shopee maintains 48% market share [consensus]
  > "According to consolidated Q4 reports, Shopee held 48% GMV share across SEA markets."
  [source-note-07]

### Contested: Growth sustainability

**Position A:** Growth is sustainable due to demographic tailwinds
> "The under-30 population represents 65% of SEA consumers and shows 3x higher e-commerce adoption than older cohorts."
[source-note-22]

**Position B:** Growth will decelerate as penetration saturates
> "Vietnam and Singapore are approaching saturation at 60%+ penetration; further growth requires new verticals, not new users."
[source-note-31]

### Ungrouped

- Regional logistics costs dropped 18% YoY (statistical)
  > "Cross-border fulfillment costs in SEA fell from $4.20 to $3.44 per package in 2024."
  [source-note-44]
```

---

## Exit criterion

- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md` exists
- Contains at least **15 claims** for `full` tier
- Grouped by atomic item with verbatim `quoted_support` and `source_note_id`

If fewer claims exist in total, include all of them.

---

## Next step

Return to the orchestrator skill (`hyr-research`). Invoke step 10:

```bash
cat ~/.kiro/crew/skills/hyr-10-triple-draft/SKILL.md
```

Step 10 is the most important step in the pipeline — the triple-draft ensemble spawns 3 draft-orchestrators for `full` tier.
