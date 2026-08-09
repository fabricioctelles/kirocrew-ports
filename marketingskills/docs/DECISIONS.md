# Architectural Decisions

This document records the key decisions made while porting MarketingSkills to KiroCrew.

## Upstream Reference

- **Original Repository:** https://github.com/coreyhaines31/marketingskills
- **Ported from commit:** `7868cb9251fad80a73d26e488a5ad5f6c4a9f335`
- **Commit date:** 2026-07-27

---

## KiroCrew Architecture Primer

Before diving into decisions, here's how KiroCrew's component model actually works:

### Agents in KiroCrew

KiroCrew has TWO layers of agent configuration:

1. **Kiro Agents** (`~/.kiro/agents/*.json`) — The native agent files that kiro-cli reads. These define:
   - `name`, `description`, `model`
   - `tools`, `allowedTools`
   - `prompt` (file:// path to system prompt — must be absolute)
   - `resources` (skill:// or file:// paths)
   - `mcpServers` (optional MCP server definitions)

2. **KiroCrew Agent Bindings** (`~/.kiro/crew/config.json` → `agents` section) — Metadata that binds a Kiro agent to KiroCrew features:
   - `kiro_agent`: name of the agent in `~/.kiro/agents/`
   - `workspace`: named workspace for isolation
   - `memory_store`: named memory store
   - `model`: model override (empty = inherit)
   - `triggers`: routing phrases for `select_crew`
   - `description`: human-readable summary
   - `source`: where this binding came from

### What is a "Crew"?

**A crew is simply an agent with non-empty `triggers`.** When an agent has triggers, it appears in the `select_crew` MCP tool's roster, allowing the default agent (kirocrew) to delegate tasks to it.

There is NO separate "crew" file format. No YAML. No dedicated directory. The conductor skill + `select_crew` tool handle routing.

### Skills

Skills are markdown files at `~/.kiro/crew/skills/<name>/SKILL.md` with optional frontmatter:

```yaml
---
name: my-skill
description: One-line summary
always: false  # true = inject into every session
triggers: keyword1, keyword2  # auto-load when matched
---
# Skill Content
```

Skills can be referenced from Kiro agents via `skill://~/.kiro/crew/skills/<name>/SKILL.md`.

### Knowledge

The Knowledge Library is a separate system for searchable documents. Files are **ingested** (not referenced as resources) and become searchable via `local_knowledge_search`. Knowledge is NOT loaded into agent context automatically — it's retrieved on demand.

---

## Decision 1: Consolidate 49 Skills into 8 Specialist Agents + 1 Orchestrator

### Context

The original repo contains 49 individual skills organized into 7 categories plus cross-references.

### Decision

Consolidate them into **9 agents total**:
- 1 orchestrator (`marketingcrew`)
- 8 specialists (one per domain)

### Rationale

1. **Reduced cognitive load:** Users interact with 9 agents instead of 49 skills
2. **Natural routing:** "I need help with SEO" routes to `mkt-seo` agent
3. **Better orchestration:** The orchestrator can route between specialists
4. **Aligned with KiroCrew:** Agents with triggers = selectable crews

### Implementation

Each specialist becomes:
1. A **Kiro agent** (`~/.kiro/agents/mkt-<domain>.json`) with consolidated prompt
2. A **KiroCrew binding** (`config.json` → `agents.mkt-<domain>`) with triggers
3. A **system prompt** (`~/.kiro/crew/prompts/mkt-<domain>.md`) with the actual instructions

---

## Decision 2: Orchestrator as Agent with Triggers (Not Separate Crew File)

### Context

The original system needs an entry point that manages product context and routes to specialists.

### Decision

Create `marketingcrew` as a standard agent with triggers. NO separate crew file format.

### Rationale

1. **This is how KiroCrew works** — crews are agents with triggers
2. **select_crew handles routing** — the conductor skill enables delegation
3. **Simpler architecture** — one component type, not two

### Implementation

```json
// ~/.kiro/agents/marketingcrew.json
{
  "name": "marketingcrew",
  "description": "Marketing Crew orchestrator...",
  "model": "claude-sonnet-4-20250514",
  "prompt": "file:///home/USER/.kiro/crew/prompts/marketingcrew.md",
  "tools": [...],
  "resources": []
}

// config.json → agents.marketingcrew
{
  "kiro_agent": "marketingcrew",
  "triggers": "marketing, help with marketing, marketing crew, cmo",
  ...
}
```

---

## Decision 3: Product Marketing Context Managed by Orchestrator

### Context

The original `product-marketing` skill creates a context document that ALL other skills read.

### Decision

The `marketingcrew` orchestrator manages product context as its first action, storing it at `.agents/product-marketing.md` in the project directory.

### Rationale

1. Product context is a prerequisite, not a skill to invoke
2. Orchestrator ensures context exists before routing
3. Context is passed to specialists via task description

### Implementation

The orchestrator's system prompt includes:
- Check for `.agents/product-marketing.md` on session start
- Guide user through creation if missing
- Read and summarize context before routing

---

## Decision 4: Marketing Council as Single Agent (Not 12 Agents)

### Context

The original `marketing-council` skill simulates 12 legendary marketers debating.

### Options Considered

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| A | 12 separate agents | True multi-agent | Expensive, complex |
| B | **1 agent with inline personas** | Simpler | Long prompt |
| C | 1 agent + knowledge files | Balanced | Requires knowledge ingestion |

### Decision

**Option B** — One `mkt-council` agent with advisor personas built into its system prompt.

### Rationale

1. Advisors are simulation, not autonomous agents
2. KiroCrew's Knowledge Library is for search, not context injection
3. Keeps the system simple and token-efficient
4. The 12 advisor "dossiers" become reference sections in the prompt

### Implementation

The `mkt-council` agent's prompt includes condensed frameworks for each advisor, with the "seat 3-5 advisors per session" model preserved in the instructions.

---

## Decision 5: Agent Naming Convention

### Decision

All agents use `mkt-` prefix. The orchestrator is `marketingcrew`.

### Agent Names

| Agent | Domain |
|-------|--------|
| `marketingcrew` | Orchestrator |
| `mkt-seo` | SEO & Content |
| `mkt-cro` | Conversion Rate Optimization |
| `mkt-copy` | Content & Copywriting |
| `mkt-paid` | Paid Ads & Measurement |
| `mkt-growth` | Growth & Retention |
| `mkt-sales` | Sales & GTM |
| `mkt-strategy` | Strategy & Research |
| `mkt-council` | Advisory Council |

---

## Decision 6: File Structure

### Decision

Follow KiroCrew's **native file locations** exactly:

```
~/.kiro/agents/                    # Kiro agent definitions (JSON)
├── marketingcrew.json
├── mkt-seo.json
├── mkt-cro.json
├── mkt-copy.json
├── mkt-paid.json
├── mkt-growth.json
├── mkt-sales.json
├── mkt-strategy.json
└── mkt-council.json

~/.kiro/crew/
├── config.json                    # Agent bindings (triggers, workspace, etc.)
└── prompts/                       # System prompts
    ├── marketingcrew.md
    ├── mkt-seo.md
    └── ...
```

### Rationale

1. **Native locations** — KiroCrew expects agents in `~/.kiro/agents/`
2. **Prompts separate** — Easier to maintain than inline JSON
3. **No YAML files** — KiroCrew doesn't load YAML agent/crew definitions
4. **No `~/.kiro/crew/agents/`** — This path does not exist in KiroCrew

---

## Decision 7: Skills Optional (Agents Are Primary)

### Decision

Skills (`SKILL.md`) are optional companions to agents, not the primary delivery mechanism.

### Rationale

1. **Agents are the routing unit** — `select_crew` routes to agents
2. **Skills are knowledge injection** — Useful for reference material
3. **Avoid duplication** — Don't put the same content in both

### Implementation

- Core logic lives in agent prompts (`~/.kiro/crew/prompts/*.md`)
- Skills may be created for supplementary reference (optional)
- Skills can be mapped to agents via the dashboard

---

## Decision 8: Installation via Script

### Decision

Provide an `install.sh` that:
1. Copies agent JSONs to `~/.kiro/agents/`
2. Copies prompts to `~/.kiro/crew/prompts/`
3. Updates `config.json` to register agent bindings
4. Expands `$HOME` in file paths

### Rationale

1. **Reduces user error** — Paths must be exact
2. **Handles config.json merge** — Can't just overwrite
3. **Idempotent** — Safe to run multiple times

---

## Decision 9: Prompt Path Format

### Decision

Use `file://$HOME/.kiro/crew/prompts/<name>.md` in agent JSON files, with `$HOME` expanded at install time.

### Rationale

1. The `prompt` field requires an absolute path with `file://` protocol
2. Relative paths don't work
3. `$HOME` variable allows portability across users

### Implementation

The install script uses `sed` to replace `$HOME` with the actual home directory:
```bash
sed "s|\$HOME|$HOME|g" "$agent" > "$AGENTS_DIR/$filename"
```

---

## Summary

| Metric | Original | KiroCrew Port |
|--------|----------|---------------|
| Skills | 49 | 0 (optional) |
| Kiro Agents | 0 | 9 (JSON files in `~/.kiro/agents/`) |
| KiroCrew Bindings | 0 | 9 (config.json entries) |
| Prompts | 0 | 9 (markdown files in `~/.kiro/crew/prompts/`) |
| Separate Crew Files | N/A | 0 (doesn't exist in KiroCrew) |
| YAML Files | N/A | 0 (not a KiroCrew format) |

The port transforms a flat skill library into a properly integrated KiroCrew multi-agent system using native file formats and locations.
