---
name: hyr-research
description: Deep research via HyperResearch V8 architecture — tier-adaptive pipeline (light/full/dissertation) that scales from 30-min answers to adversarially-audited reports. Router skill that sequences step skills.
triggers: hyperresearch, deep research, research pipeline, hyr research, full research, dissertation research, research query, academic research
---

# HyperResearch V8 — KiroCrew Orchestrator

You are the research orchestrator. Your job is:
1. Read this file once at the start.
2. Bootstrap canonical inputs (research_query, vault_tag, scaffold).
3. Invoke each step skill in sequence by reading them via `cat`.
4. Between steps, do nothing except update the run manifest.

You do NOT do the work of any step yourself. The step skills contain the procedures.

---

## How the chain works

Each pipeline step is its own skill file under `~/.kiro/crew/skills/`. To run a step:

```bash
cat ~/.kiro/crew/skills/hyr-<N>-<stepname>/SKILL.md
```

Read the step's full procedure into context, execute it, hit its exit criterion, then return here to invoke the next step.

**The 16 step skills** (all prefixed `hyr-`):

| # | Skill file | What it does | Tiers |
|---|---|---|---|
| 1 | `hyr-1-decompose` | Canonical query → scaffold + decomposition + coverage matrix + tier classification | all |
| 1.5 | `hyr-1-5-chapter-partition` | Partition atomic items into 4–10 chapters; steps 2–10 loop per chapter | dissertation |
| 2 | `hyr-2-width-sweep` | Multi-perspective search plan + parallel fetcher waves | all |
| 3 | `hyr-3-contradiction-graph` | Pair contradictions across corpus into ranked fight clusters | full |
| 4 | `hyr-4-loci-analysis` | 2 loci-analysts → scored loci.json with source budgets | full |
| 5 | `hyr-5-depth-investigation` | K depth-investigators in parallel → interim notes with committed positions | full |
| 6 | `hyr-6-cross-locus-reconcile` | Reconcile committed positions → comparisons.md | full |
| 7 | `hyr-7-source-tensions` | Extract expert disagreements → source-tensions.json | full |
| 8 | `hyr-8-corpus-critic` | "What source would overturn this?" + targeted gap-fill fetch | full |
| 9 | `hyr-9-evidence-digest` | Top claims + verbatim quotes → evidence-digest.md | full |
| 10 | `hyr-10-triple-draft` | Per-angle source curation + 3 parallel draft-orchestrators | all |
| 11 | `hyr-11-synthesize` | Synthesis plan + outline + synthesizer subagent → final_report.md | full |
| 12 | `hyr-12-critics` | 4 adversarial critics in parallel → findings JSONs | full |
| 13 | `hyr-13-gap-fetch` | Fetch sources for critic-identified vault gaps | full |
| 14 | `hyr-14-patcher` | Surgical edit hunks applied to draft | full |
| 14.5 | `hyr-14-5-cite-check` | Verify citation-sentence bindings; second small patcher pass | full |
| 15 | `hyr-15-polish` | Hygiene + filler pass | all |
| 16 | `hyr-16-readability-audit` | Readability recommender writes JSON suggestions; selectively applies | all |

---

## Tier routing

Step 1 classifies the query into a `pipeline_tier` (`light` / `full`). The tier is written to `~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json`. After step 1, read that file to learn the tier:

| Tier | Steps that run | Typical time |
|------|---|---|
| `light` | 1 → 2 → 10 (single draft) → 15 → 16 | ~30 min |
| `full` | 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 14.5 → 15 → 16 | ~2-4 hours |
| `dissertation` | 1 → 1.5 → [2–10 per chapter] → 6g/11 (global) → 12 → 13 → 14 → 14.5 → 15 → 16 | ~6-12 hours |

**RESPECT THE TIER GATE.** When step 1 classifies a query as `light`, do NOT run skipped steps "just to be thorough."

---

## Bootstrap (run BEFORE step 1)

**Workspace path:** `~/.kiro/crew/workspace/research/`

1. **Create workspace structure if missing:**
   ```bash
   mkdir -p ~/.kiro/crew/workspace/research/runs
   mkdir -p ~/.kiro/crew/workspace/research/notes
   mkdir -p ~/.kiro/crew/workspace/research/sources
   ```

2. **Resolve the canonical research query.** Order of precedence:
   - If `~/.kiro/crew/workspace/research/prompt.txt` exists, read it. GOSPEL.
   - Otherwise, use the user's verbatim prompt as the canonical research query.
   - Extract wrapper requirements separately: save path, citation format, terminal sections.

3. **Mint a unique vault tag.** Produce a short topical slug from the query (3–5 lowercase hyphen-separated words), then append a random 6-char hex suffix:
   ```bash
   VAULT_TAG="<slug>-$(openssl rand -hex 3)"
   ```

4. **Initialize the run workspace:**
   ```bash
   mkdir -p ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/temp
   mkdir -p ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/shims
   ```

5. **Write the run manifest** to `~/.kiro/crew/workspace/research/runs/$VAULT_TAG/run.json`:
   ```json
   {
     "vault_tag": "<vault_tag>",
     "created_at": "<ISO-8601>",
     "profile": "full|light|dissertation",
     "status": "running",
     "current_step": 0,
     "steps_completed": [],
     "budget_usd": null
   }
   ```

6. **Persist the query file** to `~/.kiro/crew/workspace/research/runs/$VAULT_TAG/query.md`:
   ```markdown
   ---
   vault_tag: <slug>
   created: <ISO-8601 timestamp>
   source: prompt.txt | user-prompt
   ---

   <verbatim query text>
   ```

7. **Classify modality** (collect / synthesize / compare / forecast) — record in scaffold.

8. **Write the scaffold** to `~/.kiro/crew/workspace/research/runs/$VAULT_TAG/scaffold.md`:
   - User Prompt (VERBATIM)
   - Run config (vault_tag, query_file_path, modality)
   - Modality classification rationale
   - Tier rationale (filled after step 1)

9. **Invoke step 1:** `cat ~/.kiro/crew/skills/hyr-1-decompose/SKILL.md`

---

## Subagent spawn contract

When a step skill instructs you to spawn subagents, use `spawn_run` or `spawn_sub_agents`:

```python
# For parallel independent work (non-blocking, results arrive as events)
spawn_run(tasks=[
    "Task 1 prompt with full context...",
    "Task 2 prompt with full context...",
])

# For blocking parallel work (waits for all results)
spawn_sub_agents(tasks=[
    {"task": "Task 1...", "description": "Analyst A"},
    {"task": "Task 2...", "description": "Analyst B"},
])
```

Every subagent prompt MUST include:

1. **`research_query`** — verbatim, block-quoted from `query.md`
2. **Pipeline position statement** — one sentence naming the step
3. **The subagent's specific inputs** (vault_tag, output_path, locus, etc.)
4. **The run's shim file** — paste verbatim from `runs/<vault_tag>/shims/`

---

## KiroCrew tool mappings

| Original | KiroCrew equivalent |
|----------|---------------------|
| `hyperresearch fetch <url>` | `web_fetch(url="...")` |
| `hyperresearch search <query>` | `web_search(query="...")` |
| `hyperresearch vault search` | `local_knowledge_search(query="...")` |
| `Skill(skill: "...")` | `cat ~/.kiro/crew/skills/hyr-<name>/SKILL.md` |
| `Task(prompt: "...")` | `spawn_run(task="...")` or `spawn_sub_agents(tasks=[...])` |
| Artifact writes | Write to `~/.kiro/crew/workspace/research/runs/<vault_tag>/` |

---

## Four canonical rules (ALWAYS in force)

1. **NEVER EMIT BARE TEXT WHILE TASKS ARE RUNNING.** After `spawn_run`, end your turn immediately. Wait for `[Subagent completion event]` messages.

2. **PATCH, NEVER REGENERATE.** After step 11 produces the final report (or step 10 for light tier), modifications are surgical edits only.

3. **ARGUE, DON'T JUST REPORT.** The pipeline pushes toward argumentative density. Loci must include dialectical tension. Depth investigators commit to positions.

4. **RESPECT THE TIER GATE.** Don't add steps "for thoroughness." Don't drop steps "for budget."

---

## Recovery: if you wake up uncertain

1. **Read the run manifest:** `cat ~/.kiro/crew/workspace/research/runs/<vault_tag>/run.json`
2. **Check disk artifacts.** Each step writes a canonical artifact:
   - Step 1: `scaffold.md`, `prompt-decomposition.json`
   - Step 2: notes in `sources/`
   - Step 3: `temp/contradiction-graph.json`
   - Step 4: `loci.json`
   - Step 5: interim notes with `type: interim`
   - Step 6: `comparisons.md`
   - Step 10: `temp/draft-{a,b,c}.md`
   - Step 11: `notes/final_report_<vault_tag>.md`
   - Step 12: `critic-findings-*.json`
3. **Find highest-numbered step whose artifact exists.** Resume from next step.
4. **Re-read this skill** if lost: `cat ~/.kiro/crew/skills/hyr-research/SKILL.md`

---

## Final integrity gate (after step 16)

Check all required artifacts exist:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

for f in "$BASE/scaffold.md" \
         "$BASE/prompt-decomposition.json" \
         "$BASE/polish-log.json"; do
  test -f "$f" || echo "MISSING: $f"
done

# For full tier only:
for f in "$BASE/critic-findings-dialectic.json" \
         "$BASE/critic-findings-depth.json" \
         "$BASE/critic-findings-width.json" \
         "$BASE/critic-findings-instruction.json" \
         "$BASE/patch-log.json"; do
  test -f "$f" || echo "MISSING: $f"
done
```

Update the run manifest to `"status": "done"` when all checks pass.

The final report lives at `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`.

---

## Invariants you cannot break

1. **PATCHING not REGENERATION after step 11**
2. **One final report** — step 11 writes it ONCE (step 10 for light tier)
3. **At least one dialectical locus** for full tier
4. **Every interim note commits to a position**
5. **Steps are sequential at outermost level, parallel within**
6. **Canonical research query is gospel everywhere**
7. **NEVER skip a step that the tier gate says to run**
8. **Step 10 triple-draft is MANDATORY for full tier**
9. **Step 11 synthesis is MANDATORY for full tier**
10. **NEVER emit bare text while subagent tasks are in flight**

---

## Now begin

If bootstrap is done, invoke step 1:

```bash
cat ~/.kiro/crew/skills/hyr-1-decompose/SKILL.md
```

If bootstrap is NOT done, do the bootstrap first, then invoke step 1.
