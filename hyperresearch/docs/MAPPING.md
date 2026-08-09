# HyperResearch → KiroCrew: Complete Mapping

This document describes how each component of the original [HyperResearch](https://github.com/jordan-gibbs/hyperresearch) was adapted to the KiroCrew ecosystem.

---

## Architecture Overview

| Aspect | Original HyperResearch | KiroCrew Adaptation |
|--------|------------------------|---------------------|
| **Runtime** | Claude Code + Python CLI | KiroCrew Agent + Modular Skills |
| **Orchestration** | Monolithic `hyperresearch.md` (~24K chars) | `hyr-research` skill + 17 step skills |
| **Subagents** | Inline `Task(prompt: "...")` | `spawn_run()` / `spawn_sub_agents()` MCP |
| **Vault/Storage** | SQLite + markdown in `~/hyperresearch/` | Filesystem in `~/.kiro/crew/workspace/research/` |
| **Vault search** | `hyperresearch search <query>` CLI | `local_knowledge_search(query="...")` MCP |
| **Web fetch** | `hyperresearch fetch <url>` CLI | Native `web_fetch(url="...")` |
| **Skills loading** | `Skill(skill: "hyperresearch-N-...")` | `cat ~/.kiro/crew/skills/hyr-<name>/SKILL.md` |

---

## Skills Mapping (V8 Pipeline)

### Original Skills → KiroCrew Skills

| # | Original | KiroCrew | Notable Changes |
|---|----------|----------|-----------------|
| — | `hyperresearch.md` | `hyr-research/SKILL.md` | Split: bootstrap + tier routing separated from orchestration |
| 1 | `hyperresearch-1-decompose.md` | `hyr-decompose/SKILL.md` | Added coverage matrix self-audit |
| 1.5 | `hyperresearch-1-5-chapter-partition.md` | — | Not implemented (dissertation tier future) |
| 2 | `hyperresearch-2-width-sweep.md` | `hyr-sweep/SKILL.md` | Adapted to `web_search` + `web_fetch` |
| 3 | `hyperresearch-3-contradiction-graph.md` | `hyr-contradiction/SKILL.md` | Kept — pure logic |
| 4 | `hyperresearch-4-loci-analysis.md` | `hyr-loci/SKILL.md` | Kept — pure logic |
| 5 | `hyperresearch-5-depth-investigation.md` | `hyr-depth/SKILL.md` | Adapted spawn pattern |
| 6 | `hyperresearch-6-cross-locus-reconcile.md` | `hyr-reconcile/SKILL.md` | Kept — pure logic |
| 7 | `hyperresearch-7-source-tensions.md` | `hyr-tensions/SKILL.md` | Kept — pure logic |
| 8 | `hyperresearch-8-corpus-critic.md` | `hyr-corpus-critic/SKILL.md` | Adapted spawn + fetch patterns |
| 9 | `hyperresearch-9-evidence-digest.md` | `hyr-evidence/SKILL.md` | Kept — pure logic |
| 10 | `hyperresearch-10-triple-draft.md` | `hyr-draft/SKILL.md` | Adapted to spawn 3 parallel drafters |
| 11 | `hyperresearch-11-synthesize.md` | `hyr-synthesize/SKILL.md` | Tool-locked synthesizer pattern |
| 12 | `hyperresearch-12-critics.md` | `hyr-critics/SKILL.md` | Spawn 4 parallel critics |
| 13 | `hyperresearch-13-gap-fetch.md` | `hyr-gap-fetch/SKILL.md` | Adapted to `web_fetch` |
| 14 | `hyperresearch-14-patcher.md` | `hyr-patcher/SKILL.md` | Tool-locked Read+Edit only |
| 14.5 | `hyperresearch-14-5-cite-check.md` | `hyr-cite-check/SKILL.md` | New step for citation verification |
| 15 | `hyperresearch-15-polish.md` | `hyr-polish/SKILL.md` | Lint rules internalized |
| 16 | `hyperresearch-16-readability-audit.md` | `hyr-readability/SKILL.md` | Recommender + orchestrator-applied |

---

## CLI Commands Mapping

| Original Command | KiroCrew Equivalent | Notes |
|------------------|---------------------|-------|
| `hyperresearch init` | Bootstrap in `hyr-research` | Creates workspace + run manifest |
| `hyperresearch run` | Invoke `hyr-research` skill | Executes full pipeline |
| `hyperresearch fetch <url>` | `web_fetch(url="...")` | Native KiroCrew tool |
| `hyperresearch search <query>` | `local_knowledge_search(query="...")` | MCP tool |
| `hyperresearch note create` | `write(path="...")` | Native file tool |
| `hyperresearch lint` | Integrated in `hyr-polish` | Lint rules inline in skill |
| `hyperresearch status` | `cat run.json` | JSON manifest |
| `hyperresearch profile list/set` | `pipeline_tier` in decomposition | light/full/dissertation |

---

## Core Modules Mapping

| Original Module | KiroCrew Implementation |
|-----------------|-------------------------|
| `core/vault.py` | `~/.kiro/crew/workspace/research/` filesystem |
| `core/db.py` (SQLite) | JSON/MD files in run workspace |
| `core/hooks.py` (195KB!) | Distributed across 18 skills |
| `core/levers.py` | Shim files in `runs/<tag>/shims/` |
| `core/runs.py` | `run.json` manifest |
| `core/fetcher.py` | `web_fetch` + `web_search` |
| `core/embed.py` | Not implemented (no vector search) |
| `core/claims.py` | Inline in `hyr-evidence` |
| `core/citecheck.py` | `hyr-cite-check` skill |

---

## File Structure

### Original (HyperResearch)
```
~/hyperresearch/
├── .hyperresearch/
│   ├── config.toml
│   ├── vault.db (SQLite)
│   └── runs/<run_id>/
├── notes/
│   ├── sources/
│   └── reports/
└── prompts/
```

### Adapted (KiroCrew)
```
~/.kiro/crew/
├── skills/hyr-*/SKILL.md          # 18 skills
├── crews/hyperresearch.yaml       # Agent config
└── workspace/research/
    ├── runs/<vault_tag>/
    │   ├── run.json               # Manifest
    │   ├── scaffold.md            # Bootstrap context
    │   ├── query.md               # Canonical query (GOSPEL)
    │   ├── prompt-decomposition.json
    │   ├── loci.json
    │   ├── comparisons.md
    │   ├── temp/                  # Intermediate artifacts
    │   └── shims/                 # Lever propagation files
    ├── notes/
    │   └── final_report_<tag>.md
    └── sources/                   # Fetched documents
```

---

## Tier Routing

| Tier | Steps Executed | Estimated Time |
|------|----------------|----------------|
| `light` | 1 → 2 → 10 (single draft) → 15 → 16 | ~30 min |
| `full` | 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 14.5 → 15 → 16 | ~2-4h |
| `dissertation` | (not implemented) | ~6-12h |

---

## Preserved Invariants

1. **PATCH, NEVER REGENERATE** — After step 11, only surgical edits
2. **ARGUE, DON'T JUST REPORT** — Loci with mandatory dialectical tension
3. **RESPECT THE TIER GATE** — Don't add/remove steps arbitrarily
4. **Canonical query is GOSPEL** — Query never modified after bootstrap
5. **Step 10 triple-draft MANDATORY** for full tier
6. **Tool-locking** — Patcher/synthesizer can only Read+Edit

---

## Not Implemented (Future)

| Original Feature | Status | Reason |
|------------------|--------|--------|
| Dissertation tier | Planned | Requires chapter partitioning |
| Vector embeddings | Not planned | KiroCrew uses `local_knowledge_search` |
| Chrome lane | Not applicable | KiroCrew has Playwright MCP |
| MCP server mode | Not needed | KiroCrew is already MCP-native |
| Source ranking | Partial | Implemented inline in skills |
