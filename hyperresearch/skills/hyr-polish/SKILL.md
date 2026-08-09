---
name: hyr-polish
description: Step 15 of HyperResearch V8 -- final hygiene + filler pass via tool-locked polish auditor. Strips pipeline leaks, YAML frontmatter, filler phrases, run-on sentences. Escalates structural mismatches.
triggers: polish, hygiene, filler, step 15, final pass
---

# Step 15 — Polish Audit

**Tier gate:** Runs for ALL tiers. Every report gets a polish pass regardless of tier.

**Goal:** Final hygiene + readability pass. Tool-locked to `Read + Edit` only.

---

## Recover state

Read these inputs:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

cat ~/.kiro/crew/workspace/research/notes/final_report_$VAULT_TAG.md  # patched draft from step 14 (or single-pass for light tier)
cat $BASE/query.md  # canonical research query
cat $BASE/run.json  # check pipeline_tier
```

---

## Step 15.1 — Pre-create the polish log stub

The polish auditor has `Read + Edit` only and cannot create new files. Stub it first:

```bash
echo '{"applied": [], "escalations": []}' > ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/polish-log.json
```

---

## Step 15.2 — Spawn the polish auditor

Spawn a SINGLE subagent with this prompt:

```
spawn_sub_agents(tasks=[{
    "task": """
RESEARCH QUERY (verbatim, gospel):
> <paste query.md body here>

QUERY FILE: ~/.kiro/crew/workspace/research/runs/<vault_tag>/query.md

PIPELINE POSITION: You are step 15 (polish auditor) of the HyperResearch V8
pipeline. Step 14 (patcher) applied critic findings as Edit hunks. After you
return, the orchestrator runs the final integrity gate and proceeds to step 16.
You are TOOL-LOCKED to Read + Edit ONLY.

YOUR INPUTS:
- draft_path: ~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md
- polish_log_path: ~/.kiro/crew/workspace/research/runs/<vault_tag>/polish-log.json (already stubbed)

YOUR TASK:
1. Read the draft at draft_path
2. Apply surgical Edits to strip:
   - Pipeline reference leaks: [I\\d+] references, [[interim-*]] wiki-links pointing at workspace artifacts
   - Hygiene leaks: YAML frontmatter, scaffold sections, prompt echoes
   - Filler phrases: "It is worth noting", "Importantly", "It should be noted", etc.
   - Redundant sentences/paragraphs that restate prior content
   - Run-on sentences and over-long paragraphs (break into smaller units)
3. PRESERVE citation wiki-links [[<source-note-id>]] when citation_style == "wikilink"
4. Log each edit to polish-log.json with:
   - "type": "filler" | "leak" | "hygiene" | "redundant" | "structure"
   - "before": original text
   - "after": replacement text
   - "reason": why stripped/changed
5. ESCALATE (do not fix) structural mismatches to escalations array:
   - Wrong format for the prompt (e.g., user asked for ranked list, draft is unranked prose)
   - Missing required sections
   - Content gaps that need new material (you cannot fabricate)

OUTPUT FORMAT for polish-log.json:
{
  "applied": [
    {"type": "filler", "before": "...", "after": "...", "reason": "..."},
    ...
  ],
  "escalations": [
    {"type": "structural", "issue": "...", "location": "..."},
    ...
  ],
  "stats": {
    "chars_removed": <int>,
    "chars_added": <int>,
    "net_delta": <int>,
    "edits_count": <int>
  }
}

CONSTRAINT: Polish should have NEGATIVE net char delta. You are cutting, not expanding.
""",
    "description": "Polish auditor (tool-locked)"
}])
```

**CRITICAL:** After spawning, END YOUR TURN. Wait for the `[Subagent completion event]`.

---

## Step 15.3 — Handle escalations

Read the polish log:

```bash
cat ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/polish-log.json
```

Check for escalations. If present:

1. **Structural issues** (wrong format, missing sections): You have ONE shot to fix it — craft the restructure yourself with hand-written Edits, then proceed.

2. **Sanity-check net length:** Polish should have NEGATIVE net char delta. If `stats.net_delta > 0`, something went wrong — polish is for cutting, not expanding. Investigate before proceeding.

**Do not apply polish edits yourself in step 15.2.** The auditor's tool lock is the mechanism. If the auditor returned empty `applied` array, re-spawn it with more specific instructions; don't do the work yourself unless escalations require it.

---

## Step 15.4 — Final integrity gate

Verify expected pipeline artifacts exist. **The required set depends on the tier:**

**Light tier:**

```bash
test -f ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/polish-log.json || echo "MISSING: polish-log.json"
```

**Full tier:**

```bash
for f in ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/critic-findings-dialectic.json \
         ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/critic-findings-depth.json \
         ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/critic-findings-width.json \
         ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/critic-findings-instruction.json \
         ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/patch-log.json \
         ~/.kiro/crew/workspace/research/runs/$VAULT_TAG/polish-log.json; do
  test -f "$f" || echo "MISSING: $f"
done
```

If any artifact is missing:
1. Re-spawn the responsible agent ONCE with the missing output path as explicit required output
2. If it fails a second time, write a minimal stub (`{"findings":[]}` or `{"applied":[],"escalations":[]}`) and log the failure in run.json before proceeding

---

## Step 15.5 — Record the run

Update `~/.kiro/crew/workspace/research/runs/$VAULT_TAG/run.json`:

```json
{
  "steps_completed": [..., "polish"],
  "polish_stats": {
    "edits_applied": <int>,
    "escalations": <int>,
    "net_char_delta": <int>
  }
}
```

---

## Exit criterion

- `~/.kiro/crew/workspace/research/runs/$VAULT_TAG/polish-log.json` populated
- Final integrity gate passed (or stub-filled with documented failure)
- `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md` is polished

---

## Next step

Return to the orchestrator (`hyr-research`). Invoke step 16:

```bash
cat ~/.kiro/crew/skills/hyr-readability-audit/SKILL.md
```

Step 16 is the final step — readability audit + selective apply. Runs for ALL tiers.

---

## Filler phrases to strip (reference list)

- "It is worth noting"
- "Importantly"
- "It should be noted"
- "It is important to note"
- "Interestingly"
- "Notably"
- "As mentioned earlier"
- "As previously discussed"
- "In fact"
- "Actually"
- "Basically"
- "Essentially"
- "Obviously"
- "Clearly"
- "Of course"
- "Needless to say"
- "It goes without saying"
- "In other words" (unless genuinely rephrasing for clarity)
- "That being said"
- "With that being said"
- "At the end of the day"
- "All things considered"
- "When all is said and done"
