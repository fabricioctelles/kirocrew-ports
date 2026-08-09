---
name: hyr-gap-fetch
description: Fetch sources for critic-identified vault gaps before patching (Step 13)
---

# Step 13 — Post-critic gap fetch (conditional)

**Tier gate:** Run for `full`. Skip for `light` (no critics = no findings).

**Goal:** Critics identify gaps the draft missed, but the patcher can only work with evidence already in the vault. If a critic says "the draft ignored topic X" and the vault has zero sources on X, the patcher has nothing to cite. This step fills those gaps BEFORE patching.

---

## Recover state

Read these inputs:
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/scaffold.md` — vault_tag
- All `~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-*.json` files

---

## Procedure

1. **Read whichever critic findings files exist.** Scan for findings where:
   - `failure_mode` is `"missing"`, `"under-covered"`, or `"missing-forward-analysis"`
   - `failure_mode` is any width-critic finding (coverage gaps by definition)
   - `severity` is `major` or `critical`

2. **For each qualifying finding, check whether the vault has evidence.** Run a targeted knowledge search:
   ```python
   local_knowledge_search(query="<finding topic keywords>")
   ```
   If 2+ relevant notes exist, the patcher can handle it — move on. If 0-1 relevant notes exist, this is a **fetch-worthy gap**.

3. **Collect fetch-worthy gaps.** Cap at **5 gaps maximum** — this is a surgical fill, not a second width sweep. Prioritize by severity (critical first) then by how many critic findings the gap would resolve.

   If 0 fetch-worthy gaps: log "no gaps to fill" and proceed directly to step 14.

4. **Run targeted fetch wave.** For each gap:
   - Generate 2-3 search queries using `web_search`
   - Collect promising URLs from results
   - Spawn fetchers with `spawn_run`

   **Spawn template:**
   ```python
   spawn_run(tasks=[
       """
       RESEARCH QUERY (verbatim, gospel):
       > {{paste ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md body}}

       QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

       PIPELINE POSITION: You are a step 13 (post-critic gap-fill) fetcher
       of the HyperResearch V8 pipeline. Critics identified gaps in vault
       coverage; you fetch sources targeting those gaps. After you return,
       the patcher (step 14) cites your sources to address findings.

       YOUR INPUTS:
       - vault_tag: <vault_tag>
       - urls: [<gap-targeted URLs>]
       - extra_tags: ["post-critic-fill"]
       - output_dir: ~/.kiro/crew/workspace/research/runs/<vault_tag>/sources/

       TASK:
       1. For each URL, use web_fetch to retrieve content
       2. Quality-check: skip paywalled, 404, or irrelevant pages
       3. Summarize key claims with source attribution
       4. Extract claims to ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/claims-<note-id>.json
       5. Write source note to output_dir with tags: [vault_tag, "post-critic-fill"]

       RUN DIRECTIVES: {{paste ~/.kiro/crew/workspace/research/runs/<vault_tag>/shims/research.md}}
       """,
       # ... additional fetcher tasks for other URLs
   ])
   ```

   **After spawn_run, STOP and wait for [Subagent completion event] messages.**

5. **Update evidence digest.** After fetchers complete, if new claims were extracted, append them to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md` under a new `### Post-critic gap fill` section. The patcher reads this when looking for citation sources.

6. **Log results** to `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/post-critic-fetch-log.md`:
   ```markdown
   # Post-critic Gap Fetch Log

   ## Summary
   - Gaps identified: N
   - Gaps with new sources: M
   - Total new sources fetched: X

   ## Gap Details

   ### Gap 1: <topic>
   - Source finding: critic-findings-<type>.json
   - Severity: critical|major
   - Search queries used: [...]
   - New sources found: N
   - Note IDs: [...]

   ### Gap 2: <topic>
   ...

   ## Unfilled Gaps
   - <topic>: No quality sources found (patcher will acknowledge limitation)
   ```

---

## Exit criterion

- `~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/post-critic-fetch-log.md` exists (even if it says "no gaps found")
- All fetch-worthy gaps attempted (proceed to step 14 whether or not all gaps were filled — unfilled gaps are noted in the log)

**Overhead:** Small — at most 5 fetchers. Most runs with good step 2 coverage will find 0-2 gaps, making this a near-no-op.

---

## Next step

Return to the orchestrator (`hyr-research`). Invoke step 14:

```bash
cat ~/.kiro/crew/skills/hyr-patcher/SKILL.md
```
