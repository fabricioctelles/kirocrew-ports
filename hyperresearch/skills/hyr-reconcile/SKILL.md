---
name: hyr-reconcile
description: Reconcile committed positions from depth investigators into cross-locus tensions that give the draft argumentative density (Step 6).
---

# Step 6 — Cross-Locus Reconciliation

**Tier gate:** SKIP for `light` tier. Only `full` tier runs this step.

**Goal:** Reconcile the committed positions from all depth investigators. Output `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md` — 3–5 cross-locus tensions with engagement guidance for the draft.

**Why this step exists:** Depth investigators each committed to a position on their locus. Some disagree, some reinforce, some complicate each other. The draft must engage these cross-locus dynamics explicitly — not summarize loci in isolation.

---

## Inputs

Read these files:

```bash
VAULT_TAG="<your-tag>"
BASE=~/.kiro/crew/workspace/research/runs/$VAULT_TAG

cat $BASE/scaffold.md
cat $BASE/loci.json
```

Gather all interim notes (type: interim) from the sources directory:

```bash
ls ~/.kiro/crew/workspace/research/sources/*interim*.md 2>/dev/null
# or search for files with "type: interim" in frontmatter
```

Extract the `## Committed position` section from every interim note.

---

## Procedure

1. **Lay out all committed positions.** For each interim note, extract its `## Committed position` section. Write them side-by-side in scratch:
   ```
   $BASE/temp/orchestrator-notes.md
   ```

2. **Hunt for tensions.** For every pair of positions, ask:
   - Do they agree on facts but disagree on meaning?
   - Do they cite different evidence and reach opposite conclusions?
   - Does one locus's position assume something another's evidence complicates?
   - Is one position a special case of another's general claim?
   - Do they converge via different mechanisms? (Convergence from independent paths is itself a finding.)

3. **Select 3–5 strongest cross-locus dynamics.** Reject weak ones (orthogonal loci, restatements). Choose relationships the final draft should wrestle with.

4. **Write `comparisons.md`:**

   ```bash
   cat > $BASE/comparisons.md << 'EOF'
   # Cross-locus comparisons

   ## Tension 1: <short name>

   - **Locus A** ([[interim-A]]) commits: <one-line position>
   - **Locus B** ([[interim-B]]) commits: <one-line position>
   - **The cross-locus dynamic:** <2–3 sentences: conflict? convergence? complication? special case? Name the load-bearing disagreement or agreement.>
   - **How the draft should engage this:** <one sentence guidance>
   - **Calibration note:** <confidence levels, "what would change this" conditions>

   ## Tension 2: ...

   ## Tension 3: ...
   EOF
   ```

5. **Calibration synthesis.** For each tension:
   - Note investigators' confidence levels
   - Note "what would change this position" conditions
   - When one is high-confidence and another low-confidence, draft should weight accordingly
   - When both name the same "change my mind" condition, flag as genuine open question

6. **Single-locus runs.** Even with one locus, produce `comparisons.md` with that locus's committed position as the lone argumentative anchor.

---

## Output Format

`~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md`:

```markdown
# Cross-locus comparisons

## Tension 1: <short name for the dynamic>

- **Locus A** ([[interim-A]]) commits: <one-line committed position>
- **Locus B** ([[interim-B]]) commits: <one-line committed position>
- **The cross-locus dynamic:** <2–3 sentences naming exactly how they relate>
- **How the draft should engage this:** <one sentence engagement guidance>
- **Calibration note:** <confidence differential, shared uncertainty conditions>

## Tension 2: ...

## Tension 3: ...

## Tension 4: ...

## Tension 5: ...
```

---

## Quality Constraints

- Every tension named here must become a visible argumentative beat in the final report
- Not one-line gestures — paragraphs or sections that engage disagreement explicitly
- If `comparisons.md` has 4 tensions and draft only engages 1, insight score suffers
- This document is the **argumentative spine** of the draft

---

## Exit Criterion

- `~/.kiro/crew/workspace/research/runs/<vault_tag>/comparisons.md` exists
- Contains 3–5 named tensions (or 1 distilled position for single-locus runs)
- Each tension includes: locus references, dynamic description, engagement guidance, calibration note

---

## Next Step

Return to orchestrator. Invoke step 7:

```bash
cat ~/.kiro/crew/skills/hyr-source-tensions/SKILL.md
```
