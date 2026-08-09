# Architectural Decisions and Problems Faced

A record of decisions made during the HyperResearch adaptation to KiroCrew, including trade-offs, alternatives considered, and problems solved.

---

## Architectural Decisions

### 1. Modular Skills vs Monolithic Skill

**Problem:** The original `hyperresearch.md` file is ~24,000 characters. Loading everything into context at once causes aggressive compaction and loss of detailed instructions in later steps.

**Decision:** Split into 18 independent skills with `hyr-*` prefix.

**Alternatives considered:**
- ❌ Keep single skill — would cause compaction
- ❌ Lazy loading via includes — KiroCrew doesn't support this
- ✅ Modular skills with on-demand `cat`

**Trade-offs:**
- (+) Each step fits comfortably in context
- (+) Easier maintenance and per-step debugging
- (+) Skills can be reused independently
- (-) Orchestrator needs to manually `cat` each skill
- (-) More files to manage

---

### 2. Naming Convention: `hyr-*` prefix

**Problem:** KiroCrew has dozens of skills. We need to group HyperResearch skills for easy discovery.

**Decision:** `hyr-` prefix for all skills (e.g., `hyr-decompose`, `hyr-sweep`).

**Alternatives considered:**
- ❌ `hyperresearch-*` — too long
- ❌ Separate namespace — KiroCrew doesn't support this
- ✅ `hyr-*` — short, groupable, grep-friendly

---

### 3. SQLite Vault → Filesystem

**Problem:** Original HyperResearch uses SQLite for the vault. KiroCrew doesn't have native SQLite and `local_knowledge_search` operates on files.

**Decision:** Use directory structure in `~/.kiro/crew/workspace/research/`.

**Adopted structure:**
```
research/
├── runs/<vault_tag>/    # Per-run artifacts
├── notes/               # Final reports
└── sources/             # Fetched documents
```

**Trade-offs:**
- (+) Compatible with `local_knowledge_search`
- (+) Files are directly readable
- (+) No external dependency
- (-) No optimized full-text search
- (-) No vector similarity (embeddings)

---

### 4. Subagent Orchestration Pattern

**Problem:** HyperResearch uses blocking `Task(prompt: "...")`. KiroCrew has `spawn_run` (async) and `spawn_sub_agents` (blocking).

**Decision:** Use `spawn_sub_agents` for critical parallel work (drafters, critics), and `spawn_run` for fire-and-forget.

**Implemented rule:**
```python
# For parallel work that needs results
spawn_sub_agents(tasks=[
    {"task": "...", "description": "Drafter A"},
    {"task": "...", "description": "Drafter B"},
])

# For async work
spawn_run(tasks=["Task 1", "Task 2"])
# Then STOP and wait for [Subagent completion event]
```

**Critical invariant:** "NEVER emit bare text while tasks are running"

---

### 5. Tool-Locking for Specific Subagents

**Problem:** The original patcher sometimes regenerated entire sections instead of applying surgical patches.

**Decision:** Critical subagents are "tool-locked" — they receive explicit instruction about which tools they can use.

**Implementation:**
- `hyr-patcher`: "YOU ARE TOOL-LOCKED TO READ + EDIT ONLY"
- `hyr-synthesize`: "YOU ARE TOOL-LOCKED TO READ + EDIT ONLY"
- `hyr-polish`: Similar constraint

**Trade-offs:**
- (+) Prevents accidental regeneration
- (+) Patches are auditable
- (-) Subagent cannot create new files if needed

---

### 6. Shim Files for Lever Propagation

**Problem:** Levers (register, domain_notes, inference_depth) need to reach all subagents without polluting each prompt.

**Decision:** Create shim files in `runs/<vault_tag>/shims/` that are included verbatim in subagent prompts.

**Created shims:**
- `research.md` — for search steps
- `drafting.md` — for drafters
- `critics.md` — for adversarial critics
- `polish.md` — for final steps

**Example shim:**
```markdown
## Research Posture
**Register:** analyze (evaluation-shaped)
**Inference depth:** standard
**Domain notes:** Sourcing: academic APIs first; recency matters within 24 months...
```

---

### 7. Coverage Matrix Self-Audit

**Problem:** The original pipeline sometimes "forgot" prompt elements, especially in complex queries with multiple entities.

**Decision:** Add a mandatory self-audit in step 1 that maps each query phrase to atomic items.

**Implementation in `hyr-decompose`:**
```markdown
| Query phrase (verbatim) | Mapped atomic item(s) | Scope check | Gap? |
```

**Rule:** "If any row has `Gap? = YES`: go back and fix the decomposition. Do NOT proceed with known gaps."

---

### 8. Cite-Check as Separate Step (14.5)

**Problem:** The original V8 pipeline had cite-check, but it was a sub-step of patcher. Citation verification deserves dedicated attention.

**Decision:** Create step 14.5 (`hyr-cite-check`) between patcher and polish.

**Flow:**
1. Step 14 (patcher) applies critic findings
2. Step 14.5 (cite-check) verifies citation↔sentence bindings
3. If problems found, runs second patcher pass
4. Step 15 (polish) cleans filler/formatting

---

## Problems Faced and Solutions

### P1: Aggressive Compaction in Long Runs

**Symptom:** In full-tier runs (~2h), context compacted and lost instructions for later steps.

**Solution:** Modular skills + on-demand loading. Each step loads only its skill when needed.

---

### P2: Subagents Not Receiving Complete Context

**Symptom:** Subagents (drafters, critics) produced output that ignored the research_query or levers.

**Solution:** Mandatory spawn contract:
1. `research_query` verbatim block-quoted
2. Pipeline position statement
3. Shim file included
4. Specific inputs (vault_tag, output_path)

---

### P3: Race Condition in Parallel Spawns

**Symptom:** Orchestrator continued working after `spawn_run`, duplicating effort.

**Solution:** Explicit rule: "After spawn_run, END YOUR TURN immediately. Wait for completion events."

---

### P4: Patcher Regenerating Instead of Patching

**Symptom:** Patcher sometimes rewrote entire sections, losing nuances from original drafter.

**Solution:** Tool-locking + instruction "Each Edit hunk must be minimal. Never regenerate sections."

---

### P5: Tier Misclassification

**Symptom:** Simple queries received full-tier, wasting time. Complex queries received light-tier, producing shallow reports.

**Solution:** Explicit classification table in `hyr-decompose`:
- `light`: "What is...", "How do I...", "List the...", single clear question
- `full`: "Analyze the impact of...", multi-paragraph prompts, contested topics

---

### P6: Vault Tag Collisions

**Symptom:** Runs with similar queries overwrote artifacts.

**Solution:** Vault tag = topical slug + random 6-char hex:
```bash
VAULT_TAG="quantum-computing-$(openssl rand -hex 3)"
# Result: quantum-computing-a7f3b2
```

---

### P7: Shim Files Didn't Exist

**Symptom:** Subagents failed trying to read shims that step 1 didn't create.

**Solution:** Step 1 now creates all 4 shims mandatorily, even if empty:
```bash
mkdir -p runs/$VAULT_TAG/shims
# research.md, drafting.md, critics.md, polish.md
```

---

## Adaptation Metrics

| Metric | Original | Adapted |
|--------|----------|---------|
| Skill files | 20 | 18 |
| Lines of Python code | ~15,000 | 0 (pure skills) |
| Total skills size | ~180KB | ~95KB |
| External dependencies | 12+ packages | 0 |
| Setup time | 5-10min (pip install) | 0 (copy skills) |

---

## Lessons Learned

1. **Modular skills > Monolithic skills** — Compaction is real in long runs
2. **Tool-locking works** — Subagents respect explicit constraints
3. **Shims are elegant** — Context propagation without polluting prompts
4. **Self-audit prevents drift** — Coverage matrix in step 1 is high-leverage
5. **Spawn discipline is critical** — The "stop after spawn" rule prevents races
6. **Filesystem > SQLite for LLMs** — Files are inspectable and grep-friendly
