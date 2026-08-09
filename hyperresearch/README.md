# HyperResearch for KiroCrew

Deep research pipeline with 16 adversarial steps, adapted from [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch) for native KiroCrew operation.

**Original:** Claude Code + Python CLI  
**This port:** KiroCrew Agent + 18 modular skills

---

## What is HyperResearch?

HyperResearch is a research harness that turns a question into a thoroughly-vetted report through a 16-step pipeline:

1. **Decompose** the prompt into atomic items
2. **Sweep** the web for multi-perspective sources
3. **Build a contradiction graph** across sources
4. **Identify loci** — the most argumentatively-dense focus points
5. **Depth-investigate** each locus with committed positions
6. **Reconcile** positions into cross-locus comparisons
7. **Extract tensions** — expert disagreements worth surfacing
8. **Corpus-critic** — identify "what source would overturn this?"
9. **Digest evidence** — top claims + verbatim quotes
10. **Triple-draft** — 3 parallel angle-specific drafts
11. **Synthesize** into one integrated report
12. **Adversarial critics** — 4 critics attack the draft in parallel
13. **Gap-fetch** — retrieve sources for critic-identified gaps
14. **Patch** — surgical edits only, no regeneration
14.5. **Cite-check** — verify citation↔sentence bindings
15. **Polish** — filler removal, hygiene pass
16. **Readability audit** — structural improvements

The pipeline is **tier-adaptive**:
- `light` tier (~30 min): steps 1→2→10→15→16
- `full` tier (~2-4 hours): all 16 steps
- `dissertation` tier: per-chapter loop (not yet implemented)

---

## Installation

### Prerequisites

- [KiroCrew](https://kirocrew.com) installed and running
- Skills directory at `~/.kiro/crew/skills/`

### Quick Install

```bash
cd kirocrew-ports/hyperresearch
./install.sh
```

### Manual Install

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/kirocrew-ports.git

# Copy skills to KiroCrew
cp -r kirocrew-ports/hyperresearch/skills/hyr-* ~/.kiro/crew/skills/

# Create workspace
mkdir -p ~/.kiro/crew/workspace/research/{runs,notes,sources}

# Copy agent (optional - for dedicated hyperresearch agent)
cp kirocrew-ports/hyperresearch/agents/hyperresearch.json ~/.kiro/agents/
cp kirocrew-ports/hyperresearch/prompts/hyperresearch.md ~/.kiro/crew/prompts/

# Verify
ls ~/.kiro/crew/skills/hyr-*
# Should show 18 directories
```

---

## Usage

### Quick Start

In KiroCrew dashboard, load the router skill:

```
cat ~/.kiro/crew/skills/hyr-research/SKILL.md
```

Then provide your research query:

```
Research: What are the most effective techniques for improving LLM reasoning capabilities?
```

The orchestrator will:
1. Bootstrap the run (create vault_tag, scaffold, query.md)
2. Classify the tier (light/full)
3. Execute each step in sequence
4. Produce the final report at `~/.kiro/crew/workspace/research/notes/final_report_<vault_tag>.md`

### Specifying Tier

By default, the pipeline auto-classifies. To force a tier:

```
Research (tier=light): What is quantum computing?
Research (tier=full): Analyze the geopolitical implications of China's AI strategy vs US approach
```

### Using a Prompt File

For complex queries, create a prompt file:

```bash
cat > ~/.kiro/crew/workspace/research/prompt.txt << 'EOF'
Your report should:
1) Analyze the current state of transformer alternatives (Mamba, RWKV, etc.)
2) Compare inference efficiency vs quality tradeoffs
3) Identify which architectures are most promising for edge deployment
4) Include a table comparing key metrics across architectures
EOF
```

Then run the router skill — it will detect and use `prompt.txt` as the canonical query.

---

## Skills Reference

| Skill | Step | Description |
|-------|------|-------------|
| `hyr-research` | — | Router/orchestrator |
| `hyr-decompose` | 1 | Prompt → atomic items + tier classification |
| `hyr-sweep` | 2 | Multi-perspective web search |
| `hyr-contradiction` | 3 | Build contradiction graph |
| `hyr-loci` | 4 | Identify argumentative loci |
| `hyr-depth` | 5 | Depth investigation per locus |
| `hyr-reconcile` | 6 | Cross-locus reconciliation |
| `hyr-tensions` | 7 | Expert disagreement extraction |
| `hyr-corpus-critic` | 8 | Pre-draft corpus critique |
| `hyr-evidence` | 9 | Evidence digest |
| `hyr-draft` | 10 | Triple-draft ensemble |
| `hyr-synthesize` | 11 | Draft synthesis |
| `hyr-critics` | 12 | 4 adversarial critics |
| `hyr-gap-fetch` | 13 | Gap-targeted fetching |
| `hyr-patcher` | 14 | Surgical patching |
| `hyr-cite-check` | 14.5 | Citation verification |
| `hyr-polish` | 15 | Final hygiene pass |
| `hyr-readability` | 16 | Readability improvements |

---

## Key Concepts

### Canonical Query (GOSPEL)

The user's original research question is saved to `query.md` and **never modified**. All steps reference it verbatim. This prevents drift.

### Levers & Shims

Three "levers" control how the pipeline behaves:
- **register** — report voice: teach/survey/analyze/advocate
- **domain_notes** — sourcing strategy for this topic
- **inference_depth** — surface/standard/deep

These are written to shim files (`runs/<tag>/shims/*.md`) and included in subagent prompts.

### Tool-Locking

Critical subagents (patcher, synthesizer) are "tool-locked" — they can only use Read + Edit, preventing accidental regeneration.

### Vault Tag

Each run gets a unique identifier: `<topical-slug>-<6-char-hex>`. Example: `llm-reasoning-a7f3b2`.

---

## Artifacts Produced

After a full-tier run:

```
~/.kiro/crew/workspace/research/
├── runs/llm-reasoning-a7f3b2/
│   ├── run.json                     # Run manifest
│   ├── scaffold.md                  # Bootstrap context
│   ├── query.md                     # Canonical query
│   ├── prompt-decomposition.json    # Atomic items
│   ├── loci.json                    # Identified loci
│   ├── comparisons.md               # Cross-locus analysis
│   ├── temp/
│   │   ├── contradiction-graph.json
│   │   ├── evidence-digest.md
│   │   ├── draft-a.md, draft-b.md, draft-c.md
│   │   └── coverage-matrix.md
│   ├── shims/
│   │   ├── research.md, drafting.md, critics.md, polish.md
│   ├── critic-findings-*.json       # 4 critic reports
│   ├── patch-log.json               # Applied patches
│   ├── polish-log.json              # Polish changes
│   └── readability-*.json           # Readability audit
├── notes/
│   └── final_report_llm-reasoning-a7f3b2.md  # ⭐ THE OUTPUT
└── sources/
    └── <fetched documents>
```

---

## Four Invariants

1. **PATCH, NEVER REGENERATE** — After step 11, only surgical edits
2. **ARGUE, DON'T JUST REPORT** — Loci must have dialectical tension
3. **RESPECT THE TIER GATE** — Don't add/skip steps arbitrarily
4. **Canonical query is GOSPEL** — Never modify after bootstrap

---

## Differences from Original

| Aspect | Original | This Port |
|--------|----------|-----------|
| Runtime | Claude Code + Python | KiroCrew native |
| Storage | SQLite vault | Filesystem |
| Search | `hyperresearch search` CLI | `local_knowledge_search` MCP |
| Fetching | `hyperresearch fetch` CLI | `web_fetch` native |
| Subagents | `Task()` primitive | `spawn_run` / `spawn_sub_agents` |
| Dependencies | 12+ Python packages | Zero |

See [MAPPING.md](docs/MAPPING.md) for detailed component mapping.

---

## Documentation

- [MAPPING.md](docs/MAPPING.md) — Detailed mapping from original to KiroCrew
- [DECISIONS.md](docs/DECISIONS.md) — Architectural decisions and problems solved
- [hyperresearch-reference.yaml](docs/hyperresearch-reference.yaml) — Original agent config (reference only)

---

## Upstream Tracking

| Field | Value |
|-------|-------|
| **Original repo** | [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch) |
| **Ported from commit** | [`15010c5`](https://github.com/jordan-gibbs/hyperresearch/commit/15010c5142244b88265f7abadf7b7aa1a8237fde) |
| **Commit date** | 2026-08-04 |
| **Port date** | 2026-08-05 |

### Updating this port

When the original HyperResearch releases significant changes:

1. Clone the latest original: `git clone https://github.com/jordan-gibbs/hyperresearch.git /tmp/hpr`
2. Compare skills and adapt affected `hyr-*/SKILL.md` files
3. Update this table with the new commit hash
4. Submit a PR

---

## Credits

- Original HyperResearch: [jordan-gibbs/hyperresearch](https://github.com/jordan-gibbs/hyperresearch)
- KiroCrew port: Adapted for native operation without Python dependencies

---

## License

MIT — same as original HyperResearch
