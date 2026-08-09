---
name: hyr-cite-check
description: >
  Step 14.5 of HyperResearch V8 -- verify citation-sentence bindings in the
  patched report, run a second small patcher pass for fixes. Runs AFTER step
  14 (patcher) and BEFORE step 15 (polish).
triggers: cite-check, citation verification, citation audit, hyperresearch 14.5
---

# Step 14.5 — Cite-check (citation-sentence binding verification)

**Tier gate:** Runs for `full` and `dissertation`. SKIP for `light` — a light report's citation volume doesn't justify the pass; the `quote-integrity` and `numeric-consistency` lint rules still cover it mechanically at the step-15 gate.

**Goal:** Every citation that ships either supports its sentence or gets fixed. This is the difference between "has citations" and "citations are true bindings" — the single thing external fact-checkers actually measure.

---

## Recover state

Read these inputs:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

cat "$BASE/scaffold.md"                              # vault_tag
cat ~/.kiro/crew/workspace/research/notes/final_report_$VAULT_TAG.md  # PATCHED report from step 14
cat "$BASE/temp/evidence-digest.md"                  # source of truth for claims
```

---

## Step 14.5.0 — Skip gate

Check tier from `prompt-decomposition.json`:

```bash
VAULT_TAG="<your-tag>"
tier=$(grep -o '"pipeline_tier"[[:space:]]*:[[:space:]]*"[^"]*"' ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/prompt-decomposition.json | cut -d'"' -f4)
```

If `tier == "light"`, skip this step entirely — record minimal log and proceed to step 15:

```bash
echo '{"skipped": true, "reason": "light-tier"}' > ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/cite-check-pairs.json
echo '[]' > ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/cite-check-findings.json
```

Then invoke step 15.

---

## Step 14.5.1 — Extract + mechanical triage

Parse the patched report to extract every (sentence, citation) pair:

1. **Read the final report** and identify all citation patterns:
   - `[N]` markers (single numbers)
   - `[N, M]` grouped citations (one pair per source number)
   - `[[note-id]]` wikilink styles

2. **For each pair**, check if the cited source's claims (from `evidence-digest.md` or vault notes) already confirm the sentence content.

3. **Write the pairs file** to `~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-pairs.json`:

```json
{
  "summary": {
    "total_pairs": 0,
    "auto_passed": 0,
    "dangling": 0,
    "needs_llm": 0
  },
  "sampled_for_llm": [
    {
      "index": 0,
      "sentence": "The sentence containing the citation.",
      "citation_ref": "[1]",
      "source_note": "path/to/source/note.md",
      "claim_excerpt": "Relevant excerpt from source"
    }
  ],
  "dangling": [
    {
      "sentence": "Sentence with broken citation.",
      "citation_ref": "[99]",
      "reason": "No vault note found for citation 99"
    }
  ],
  "auto_passed": []
}
```

**Dangling citations are findings immediately** — no agent needed. Each one becomes a `critical` finding (fabricated or mangled citation).

**If `sampled_for_llm` is empty and there are no dangling citations:** write `[]` to `cite-check-findings.json` and proceed to step 15.

---

## Step 14.5.2 — Spawn the cite-checker

**Note:** The cite-checker does NOT receive shims — verification is register-independent.

Spawn ONE cite-checker subagent (two in parallel with split index ranges when `sampled_for_llm` exceeds ~40 pairs):

```python
spawn_sub_agents(tasks=[{
    "task": """
RESEARCH QUERY (verbatim, gospel):
> <paste ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md body>

PIPELINE POSITION: You are step 14.5 (cite-checker) of the HyperResearch
V8 pipeline. Step 14's patcher already applied critic findings; you
verify citation-sentence bindings on the text that will ship. Your
findings feed a second, small patcher pass. You do not edit the report.

**NO SHIMS:** Citation verification is register-independent — you judge
whether the source supports the claim, not whether it matches a style.

YOUR INPUTS:
- pairs_file: ~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-pairs.json
- your_range: sampled_for_llm[<start>..<end>]
- findings_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-findings.json
- evidence_digest: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md
- vault_tag: <vault_tag>

YOUR JOB:
1. Read pairs_file and your assigned range from sampled_for_llm
2. For each pair, read the source note and judge: does this source actually support this sentence?
3. Output findings to findings_path as JSON array

JUDGMENT CRITERIA:
- PASS: Source directly supports the claim in the sentence
- FAIL_OVERCLAIM: Sentence claims more than source supports
- FAIL_MISATTRIBUTION: Citation points to wrong source for this claim
- FAIL_FABRICATION: No evidence this source says anything like this

FINDING SCHEMA:
{
  "index": 0,
  "severity": "critical|high|medium",
  "issue_type": "overclaim|misattribution|fabrication|dangling",
  "sentence": "The problematic sentence",
  "citation_ref": "[1]",
  "problem": "Description of the binding failure",
  "suggested_fix": "Swap to [3] which supports this claim" | "Soften to 'may indicate'" | "Delete sentence"
}

Write findings as a JSON array to findings_path.
""",
    "description": "cite-checker-subagent"
}])
```

When splitting across two checkers, give each its own findings path (`cite-check-findings-a.json` / `-b.json`) and merge the arrays into `cite-check-findings.json` yourself afterward.

---

## Step 14.5.3 — Merge dangling citations into findings

Append the dangling-citation findings (from 14.5.1) to the findings file:

```python
# For each dangling citation from pairs file
dangling_finding = {
    "index": -1,  # or next available
    "severity": "critical",
    "issue_type": "dangling",
    "sentence": dangling["sentence"],
    "citation_ref": dangling["citation_ref"],
    "problem": f"Citation {dangling['citation_ref']} resolves to no vault note",
    "suggested_fix": "Delete citation or find correct source"
}
```

---

## Step 14.5.4 — Second patcher pass

**Skip this pass entirely** when the merged findings file is `[]`.

Otherwise, pre-create the patch log stub (patcher is TOOL-LOCKED to Read + Edit):

```bash
VAULT_TAG="<your-tag>"
echo '{"total_findings": 0, "applied": [], "skipped": [], "conflicts": [], "orchestrator_escalated": []}' > ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/cite-check-patch-log.json
```

Spawn ONE patcher subagent:

```python
spawn_sub_agents(tasks=[{
    "task": """
RESEARCH QUERY (verbatim, gospel):
> <paste ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md body>

PIPELINE POSITION: You are the cite-check patcher (step 14.5) of the
HyperResearch V8 pipeline. You apply citation-binding fixes identified
by the cite-checker.

**YOU ARE TOOL-LOCKED TO READ + EDIT ONLY.**
- You CANNOT use Write to create files
- You can ONLY Edit files that already exist
- All patches must be surgical — change as little as possible

YOUR INPUTS:
- draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
- findings_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-findings.json
- patch_log_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-patch-log.json (already stubbed)

FIX REPERTOIRE (use suggested_fix from findings):
- Swap to correct_note_id — change [wrong] to [correct]
- Soften the claim — "X causes Y" → "X may contribute to Y"
- Delete the sentence — when nothing supports the claim

RULES:
- Each Edit hunk must be minimal
- Never regenerate sections — only patch
- Critical findings MUST be applied or escalated
- Log all actions to patch-log.json via Edit
""",
    "description": "cite-check-patcher-subagent"
}])
```

---

## Step 14.5.5 — Validate patch log

After patcher returns, check `~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-patch-log.json`:

1. **All `critical` findings applied?** Dangling citations and fabrications are always critical.
2. **Any conflicts?** Review and resolve.
3. **Patch log still empty stub?** Patcher failed to log — parse result and write yourself.

---

## Constraints

- **NO SHIMS** — cite-check is register-independent verification
- **NEVER REGENERATE** — only surgical edits, same as step 14
- **Critical findings cannot be silently skipped** — they must be applied or escalated

---

## Exit criterion

All must be true:

- [ ] `~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-pairs.json` exists
- [ ] `~/.kiro/crew/workspace/research/runs/<vault_tag>/cite-check-findings.json` exists (possibly `[]`)
- [ ] If findings were non-empty: `cite-check-patch-log.json` shows every `critical` finding applied or escalated
- [ ] `final_report_<vault_tag>.md` has been edited (or no edits needed)

---

## Next step

Return to entry skill (`hyr-research`). Invoke step 15 (polish):

```bash
cat ~/.kiro/crew/skills/hyr-polish/SKILL.md
```
