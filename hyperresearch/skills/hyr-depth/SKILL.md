---
name: hyr-depth
description: >
  Step 5 of HyperResearch V8 pipeline. Spawns K depth-investigator subagents
  in parallel (one per scored locus), each producing one interim note with
  a Committed Position section. Full tier only.
triggers: depth investigation, depth investigators, interim notes, committed positions, locus investigation
---

# Step 5 — Depth Investigation (parallel, K = len(loci))

**Tier gate:** SKIP entirely for `light` tier. Only `full` tier runs depth investigation.

**Goal:** Produce ONE `interim-<locus>.md` note per locus with dense synthesis that the draft sub-orchestrators (step 10) will draft from.

---

## Inputs

Read these files from the run workspace:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

cat "$BASE/scaffold.md"                      # vault_tag confirmation
cat "$BASE/loci.json"                        # scored loci with source_budget per locus
cat "$BASE/temp/contradiction-graph.json"    # if step 3 ran
cat "$BASE/query.md"                         # canonical research query (GOSPEL)
```

---

## Procedure

### 1. Parse loci and filter by source_budget

Read `loci.json` and extract loci with `source_budget > 0`. Cap at 6 investigators max (KiroCrew subagent limit).

```python
import json

with open(f"{BASE}/loci.json") as f:
    loci = json.load(f)

# Filter loci with budget, cap at 6
active_loci = [l for l in loci if l.get("source_budget", 0) > 0][:6]
```

### 2. Spawn K depth-investigators in parallel

Use `spawn_run` with one task per locus. **All tasks in ONE spawn_run call.**

```python
spawn_run(tasks=[
    f"""
RESEARCH QUERY (verbatim, gospel):
> {query_text}

QUERY FILE: ~/.kiro/crew/workspace/research/runs/{vault_tag}/query.md

PIPELINE POSITION: You are step 5 (depth-investigator) of the HyperResearch V8
pipeline. Step 4's loci analysts produced loci.json; after you return, step 6
will reconcile your committed position against the other investigators'
positions in comparisons.md.

YOUR LOCUS (from loci.json):
- name: "{locus['name']}"
- one_line: "{locus['one_line']}"
- flavor: "{locus['flavor']}"  # dialectical / synthesis / technical
- source_budget: {locus['source_budget']}
- rationale: "{locus['rationale']}"

YOUR INPUTS:
- vault_tag: {vault_tag}
- locus_name: {locus['name']}
- source_budget: {locus['source_budget']} (hard cap on additional fetches)
- output_path: ~/.kiro/crew/workspace/research/runs/{vault_tag}/interim-{locus_slug}.md

DIRECTIVES:

1. **Read existing sources first.** Use `local_knowledge_search` to find vault
   notes tagged with {vault_tag}. Read FULL source bodies — drafting from
   summaries alone produces paraphrase; drafting from full text produces synthesis.

2. **Fetch additional sources if needed.** You have a budget of {locus['source_budget']}
   additional web fetches. Use `web_search` + `web_fetch` for sources that would
   strengthen your analysis. Save new sources to the vault.

3. **Write your interim note.** Create the file at:
   `~/.kiro/crew/workspace/research/runs/{vault_tag}/interim-{locus_slug}.md`

   Structure:
   ```markdown
   ---
   type: interim
   vault_tag: {vault_tag}
   locus: {locus['name']}
   flavor: {locus['flavor']}
   created: <ISO-8601>
   sources_used: <count>
   sources_fetched: <count of new fetches>
   ---

   # Interim Note: {locus['name']}

   ## Summary
   <dense synthesis of findings for this locus>

   ## Key Evidence
   <bullet points with source citations>

   ## Tensions and Tradeoffs
   <dialectical tensions within this locus>

   ## Committed Position

   **Position:** <your clear stance — take a SIDE>

   **Confidence:** <low/medium/high with percentage>

   **Reasoning:** <why you hold this position>

   **What would change my mind:** <specific evidence that would flip your position>
   ```

4. **CRITICAL: The `## Committed Position` section is MANDATORY.**
   - For dialectical loci: take a side in the debate
   - For synthesis loci: deliver a synthesis verdict
   - For technical loci: state the recommended approach
   - Include calibration: confidence level + falsifiability condition

OUTPUT: Confirm the interim note was written and report the file path.
"""
    for locus in active_loci
    for locus_slug in [locus['name'].lower().replace(' ', '-').replace('/', '-')]
])
```

### 3. Wait for completion events

After `spawn_run`, **END YOUR TURN IMMEDIATELY**. Wait for `[Subagent completion event]` messages.

- Each investigator returns confirmation of their interim note
- Investigators can fail independently — proceed with successes
- **If >50% failed:** Stop and reassess loci quality with the user

### 4. Validate interim notes

After all events arrive, verify each note exists and has the required structure:

```bash
# List all interim notes
ls ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/interim-*.md

# Check each has ## Committed Position
for f in ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/interim-*.md; do
  grep -q "## Committed Position" "$f" || echo "DEFECTIVE: $f missing committed position"
done
```

### 5. Handle defective notes

If an interim note is missing `## Committed Position`:

1. Flag it as defective
2. Re-spawn that single investigator with emphasis on the committed-position requirement:

```python
spawn_run(task=f"""
RETRY: Your previous interim note for locus "{locus_name}" was DEFECTIVE —
it did not include a ## Committed Position section.

Read your existing draft at:
~/.kiro/crew/workspace/research/runs/{vault_tag}/interim-{locus_slug}.md

APPEND a ## Committed Position section that:
- Takes a clear SIDE (not "it depends")
- States confidence level (low/medium/high with %)
- Explains your reasoning
- Lists what evidence would change your mind

This is MANDATORY. An interim note without a committed position is unusable.
""")
```

---

## Exit Criterion

✅ One `interim-<locus>.md` file per locus with `source_budget > 0`
✅ Every interim note ends with `## Committed Position`
✅ All notes tagged with vault_tag and locus name in frontmatter

**If >50% of investigators failed:** STOP and escalate to user.

---

## Outputs

Files created in `~/.kiro/crew/workspace/research/runs/<vault_tag>/`:

```
interim-<locus-1-slug>.md
interim-<locus-2-slug>.md
...
interim-<locus-K-slug>.md
```

Each contains:
- Frontmatter with type, vault_tag, locus, flavor
- Dense synthesis of locus findings
- Key evidence with citations
- Tensions and tradeoffs
- **Committed position with calibration**

---

## Invariants

1. **Every interim note MUST have `## Committed Position`** — no exceptions
2. **Position must take a SIDE** — "it depends" is not a position
3. **Include calibration** — confidence + what would change your mind
4. **One note per locus** — no splitting, no combining
5. **Read full source text** — not summaries — before writing

---

## Next Step

Return to the orchestrator (`hyr-research`). Invoke step 6:

```bash
cat ~/.kiro/crew/skills/hyr-reconcile/SKILL.md
```

(Step 6: Cross-Locus Reconciliation — compares committed positions across loci)
