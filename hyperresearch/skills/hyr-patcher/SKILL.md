---
name: hyr-patcher
description: Apply critic findings as surgical Edit hunks against the synthesized final report. Zero regeneration. Tool-locked to Read+Edit only.
triggers: patcher, patch findings, apply critic fixes, surgical edit, step 14
---

# Step 14 — Patcher

**Tier gate:** SKIP for `light` tier (no critics = no findings). Run only for `full` tier.

**Goal:** Apply critic findings to the draft as surgical Edit hunks. Zero regeneration.

---

## Recover state

Read these inputs:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

cat "$BASE/scaffold.md"                              # vault_tag
cat ~/.kiro/crew/workspace/research/notes/final_report_$VAULT_TAG.md  # synthesized report from step 11
cat "$BASE/critic-findings-dialectic.json"           # (full tier)
cat "$BASE/critic-findings-depth.json"               # (full tier)
cat "$BASE/critic-findings-width.json"
cat "$BASE/critic-findings-instruction.json"
cat "$BASE/temp/evidence-digest.md"                  # citation source
cat "$BASE/query.md"                                 # canonical query
```

---

## Step 14.0 — Skip gate

Check if `~/.kiro/crew/workspace/research/runs/<vault_tag>/skip-patcher.txt` exists. If yes, record minimal log and proceed to step 15:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

cat > "$BASE/patch-log.json" << 'EOF'
{"total_findings": 0, "applied": [], "skipped": [{"reason": "patcher-skipped-by-invoker"}], "conflicts": [], "orchestrator_escalated": []}
EOF
```

Then invoke step 15.

---

## Step 14.1 — Pre-create patch log stub

The patcher subagent is **TOOL-LOCKED to Read + Edit** — it cannot Write. You MUST create the stub first:

```bash
VAULT_TAG="<your-tag>"
echo '{"total_findings": 0, "applied": [], "skipped": [], "conflicts": [], "orchestrator_escalated": []}' > ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/patch-log.json
```

Canonical schema:
```json
{
  "total_findings": 0,
  "applied": [],
  "skipped": [],
  "conflicts": [],
  "orchestrator_escalated": []
}
```

The patcher MUST NOT invent alternate schemas — downstream tooling assumes this shape.

---

## Step 14.2 — Spawn the patcher subagent

Spawn ONCE using `spawn_sub_agents` (blocking) or `spawn_run` (async):

```python
spawn_sub_agents(tasks=[{
    "task": """
RESEARCH QUERY (verbatim, gospel):
> <paste ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md body>

PIPELINE POSITION: You are step 14 (patcher) of the HyperResearch V8 pipeline.
Step 12 produced critic findings; step 13 filled vault gaps.
After you return, step 15 (polish auditor) does the final hygiene pass.

**YOU ARE TOOL-LOCKED TO READ + EDIT ONLY.**
- You CANNOT use Write to create files
- You can ONLY Edit files that already exist
- All patches must be surgical — change as little as possible

YOUR INPUTS:
- draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
- findings_paths:
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-dialectic.json
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-depth.json
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-width.json
  - ~/.kiro/crew/workspace/research/runs/<vault_tag>/critic-findings-instruction.json
- patch_log_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/patch-log.json (already stubbed)
- evidence_digest_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/temp/evidence-digest.md

YOUR JOB:
1. Read all critic-findings-*.json files
2. For each finding, apply a surgical Edit to the draft
3. Update the patch-log.json via Edit (populate the arrays)
4. Reject findings that don't serve the research_query
5. Escalate findings requiring structural restructure to orchestrator_escalated

RULES:
- Each Edit hunk must be minimal — change only what's needed
- Never regenerate sections — only patch
- Check every finding against the canonical query before applying
- Log all actions to patch-log.json via Edit

<paste shims/critics.md if exists>
""",
    "description": "patcher-subagent"
}])
```

---

## Step 14.3 — Validate patch log

After patcher returns, check `~/.kiro/crew/workspace/research/runs/<vault_tag>/patch-log.json`:

**Validation checklist:**

1. **All `critical` findings applied?** If any critical was SKIPPED:
   - (a) Reject as invalid after re-reading draft
   - (b) Escalate to user
   - (c) Hand-craft an Edit yourself (you have Write/Edit access; lock only applies to patcher)

2. **Any conflicts?** Review the conflicts array. If two critics disagreed and patcher picked one, verify the discarded wasn't more important.

3. **"Patch too large" skips?** Means critic proposed regeneration in patch clothing. If critical, re-spawn critic with tighter suggestion or address with multiple small hunks.

4. **Patch log still empty stub?** Patcher failed to log — parse the result inline and write to patch-log.json yourself:
   ```bash
   cat > ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/patch-log.json << 'EOF'
   <parsed JSON from patcher response>
   EOF
   ```

---

## Step 14.4 — Handle orchestrator-escalated findings

The `orchestrator_escalated` array contains findings where `requires_orchestrator_restructure: true` — typically structural issues (wrong H2 order, missing heading, extra H2).

For each entry:

1. **Read** the `issue` field to understand what needs to move/add/rename
2. **Apply** via Edit on `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`
3. **Preserve** body content — move/rename/insert headings, don't regenerate prose
4. **Log** changes to `~/.kiro/crew/workspace/research/runs/<vault_tag>/orchestrator-restructure-log.md`:
   ```markdown
   ## Orchestrator Restructures
   - Moved "Methodology" section from position 4 to position 2
   - Renamed "Results" to "Findings" per instruction critic
   - Added missing "Limitations" heading with brief evidence-grounded paragraph
   ```
5. **Never regenerate** whole sections — the "patch not regenerate" invariant still binds

---

## Constraints

- **Do NOT apply revisions yourself in step 14.2** — MUST spawn the patcher subagent. The patcher has tool-lock invariants (surgical-edit discipline, conflict resolution) baked in. Bypassing defeats the adversarial-review architecture.

- **Do NOT re-spawn patcher on same findings** — waste of resources. Only re-spawn if you've modified the findings.

- **NEVER regenerate** — only surgical edits. This is a hard invariant.

---

## Exit criterion

All must be true:

- [ ] `~/.kiro/crew/workspace/research/runs/<vault_tag>/patch-log.json` exists with `total_findings` set
- [ ] At least one of `applied`/`skipped`/`conflicts` is populated
- [ ] All critical findings either applied or resolved by orchestrator
- [ ] All `orchestrator_escalated` findings handled
- [ ] `orchestrator-restructure-log.md` exists if any structural restructures were applied
- [ ] `final_report_<vault_tag>.md` has been edited (or no edits needed)

---

## Next step

Return to entry skill (`hyr-research`). Invoke step 14.5 (cite-check):

```bash
cat ~/.kiro/crew/skills/hyr-cite-check/SKILL.md
```
