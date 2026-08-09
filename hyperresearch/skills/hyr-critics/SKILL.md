---
name: hyr-critics
description: Step 12 of HyperResearch V8 -- spawn 4 adversarial critics in parallel against the final report to produce findings JSONs for the patcher.
---

# Step 12 — Adversarial critique (parallel critics)

**Tier gate:** SKIP entirely for `light` tier — proceed directly to step 15 (polish). For `full` tier: spawn all 4 critics.

**Goal:** independent findings lists against the synthesized final report, each from a different adversarial angle. Critics complement rather than duplicate.

---

## Recover state

Read these inputs:
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/scaffold.md` — vault_tag
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json` — pipeline_tier, atomic items
- `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` — merged draft from step 11
- `~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md` — canonical research query

---

## Procedure

1. **Spawn all 4 critics in parallel using `spawn_run`.** In ONE call:

```python
spawn_run(tasks=[
    # Dialectic critic
    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste query.md body}

    QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

    PIPELINE POSITION: You are step 12 (dialectic critic) of the HyperResearch V8 pipeline.
    Step 11 (synthesizer) produced the final report. After you return, step 13 may run a
    gap-fetch wave, then step 14 (patcher) applies findings as edit hunks.

    YOUR TASK: Find counter-evidence the draft missed or straw-manned. Look for:
    - Arguments against the draft's positions that exist in the corpus but were omitted
    - Opposing viewpoints that were presented weakly or unfairly
    - Evidence that contradicts claims made in the draft

    YOUR INPUTS:
    - draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
    - output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-dialectic.json
    - vault_tag: <vault_tag>

    OUTPUT FORMAT: Write a JSON file with this structure:
    {
      "critic": "dialectic",
      "vault_tag": "<vault_tag>",
      "findings": [
        {
          "id": "d1",
          "severity": "high|medium|low",
          "location": "section or paragraph reference",
          "issue": "description of what was missed or straw-manned",
          "evidence": "quote or reference from corpus",
          "suggested_fix": "how to address this"
        }
      ]
    }
    """,

    # Depth critic
    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste query.md body}

    QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

    PIPELINE POSITION: You are step 12 (depth critic) of the HyperResearch V8 pipeline.
    Step 11 (synthesizer) produced the final report. After you return, step 13 may run a
    gap-fetch wave, then step 14 (patcher) applies findings as edit hunks.

    YOUR TASK: Find shallow spots where interim notes could fill substance. Look for:
    - Claims that lack supporting detail
    - Sections that are superficial compared to the depth of available sources
    - Places where the draft hand-waves instead of engaging with complexity

    YOUR INPUTS:
    - draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
    - output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-depth.json
    - vault_tag: <vault_tag>

    OUTPUT FORMAT: Write a JSON file with this structure:
    {
      "critic": "depth",
      "vault_tag": "<vault_tag>",
      "findings": [
        {
          "id": "dp1",
          "severity": "high|medium|low",
          "location": "section or paragraph reference",
          "issue": "description of shallow treatment",
          "available_depth": "what the sources actually contain",
          "suggested_fix": "specific content to add"
        }
      ]
    }
    """,

    # Width critic
    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste query.md body}

    QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

    PIPELINE POSITION: You are step 12 (width critic) of the HyperResearch V8 pipeline.
    Step 11 (synthesizer) produced the final report. After you return, step 13 may run a
    gap-fetch wave, then step 14 (patcher) applies findings as edit hunks.

    YOUR TASK: Find corpus clusters the draft ignores despite evidence. Look for:
    - Source clusters or perspectives that were fetched but not used
    - Topics mentioned in sources but absent from the draft
    - Entire angles of the question that the draft skips

    YOUR INPUTS:
    - draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
    - sources_dir: ~/.kiro/crew/workspace/research/sources/
    - output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-width.json
    - vault_tag: <vault_tag>

    OUTPUT FORMAT: Write a JSON file with this structure:
    {
      "critic": "width",
      "vault_tag": "<vault_tag>",
      "findings": [
        {
          "id": "w1",
          "severity": "high|medium|low",
          "ignored_cluster": "description of the ignored topic/perspective",
          "sources": ["list of source files with relevant content"],
          "suggested_fix": "where and how to integrate this"
        }
      ]
    }
    """,

    # Instruction critic
    """
    RESEARCH QUERY (verbatim, gospel):
    > {paste query.md body}

    QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

    PIPELINE POSITION: You are step 12 (instruction critic) of the HyperResearch V8 pipeline.
    Step 11 (synthesizer) produced the final report. After you return, step 13 may run a
    gap-fetch wave, then step 14 (patcher) applies findings as edit hunks.

    YOUR TASK: Check prompt adherence. Find atomic items from the decomposition that the draft:
    - Missed entirely
    - Under-covered relative to their importance
    - Reordered in a way that breaks the user's intent
    - Reformatted contrary to explicit instructions

    YOUR INPUTS:
    - draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
    - decomposition_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/prompt-decomposition.json
    - output_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-instruction.json
    - vault_tag: <vault_tag>

    OUTPUT FORMAT: Write a JSON file with this structure:
    {
      "critic": "instruction",
      "vault_tag": "<vault_tag>",
      "findings": [
        {
          "id": "i1",
          "severity": "high|medium|low",
          "atomic_item": "the specific requirement from decomposition",
          "issue": "missed|under-covered|reordered|reformatted",
          "details": "explanation of the gap",
          "suggested_fix": "how to address this"
        }
      ]
    }
    """
])
```

2. **Wait for all 4 `[Subagent completion event]` messages.** Do NOT proceed until all critics have reported.

3. **Validate outputs.** Check that all 4 files exist and contain valid JSON with a `findings` array:
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-dialectic.json`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-depth.json`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-width.json`
   - `~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-instruction.json`

4. **If a critic fails:** log the absence but proceed — the patch pass is less robust with missing coverage. **Do NOT skip the instruction-critic specifically** — it's the only critic measuring prompt adherence, the dimension with the widest variance.

5. **Do NOT read findings and apply them yourself.** The patcher (step 14) reads the findings. Your job is to hand them to the patcher — AFTER step 13 (gap-fetch) runs.

---

## Exit criterion

- All 4 critic findings JSONs exist
- Each is valid JSON with a `findings` array

---

## Next step

Return to the orchestrator (`hyr-research`). Invoke step 13:

```bash
cat ~/.kiro/crew/skills/hyr-gap-fetch/SKILL.md
```
