# MarketingSkills Port for KiroCrew

**49 marketing skills consolidated into 9 specialist agents**

This port transforms [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills) — a comprehensive marketing skill library — into a cohesive KiroCrew multi-agent system.

## What's Different

The original project provides 49 individual skills for Claude Code. This port **consolidates** them into specialist agents organized by marketing function:

| Original | This Port |
|----------|-----------|
| 49 standalone skills | 9 specialist agents |
| No orchestration | 1 orchestrating agent (marketingcrew) |
| Flat structure | Hierarchical routing via select_crew |
| Individual skill invocation | Intelligent delegation |

---

## Architecture

```
                    ┌─────────────────────────┐
                    │     marketingcrew       │
                    │  ~/.kiro/agents/*.json  │
                    │  • Product context mgmt │
                    │  • Intelligent routing  │
                    └───────────┬─────────────┘
                                │ select_crew / spawn_run
    ┌───────┬───────┬───────┬───┴───┬───────┬───────┬───────┐
    ▼       ▼       ▼       ▼       ▼       ▼       ▼       ▼
┌───────┐┌───────┐┌───────┐┌───────┐┌───────┐┌───────┐┌───────┐┌───────┐
│mkt-seo││mkt-cro││mkt-   ││mkt-   ││mkt-   ││mkt-   ││mkt-   ││mkt-   │
│       ││       ││copy   ││paid   ││growth ││sales  ││strat  ││council│
│7 skill││5 skill││8 skill││5 skill││7 skill││10 skil││5 skill││12 advs│
└───────┘└───────┘└───────┘└───────┘└───────┘└───────┘└───────┘└───────┘
```

All agents are registered in `config.json` with triggers, making them available via `select_crew`.

---

## Components

### Agents

| Agent | Domain | Skills Consolidated |
|-------|--------|---------------------|
| `marketingcrew` | Orchestrator | product-marketing (context management) |
| `mkt-seo` | SEO & Content | seo-audit, ai-seo, site-architecture, programmatic-seo, schema, content-strategy, aso |
| `mkt-cro` | Conversion Optimization | cro, signup, onboarding, popups, paywalls |
| `mkt-copy` | Content & Copywriting | copywriting, copy-editing, cold-email, emails, social, video, image, sms |
| `mkt-paid` | Paid Ads & Measurement | ads, ad-creative, ab-testing, analytics, attribution |
| `mkt-growth` | Growth & Retention | referrals, free-tools, churn-prevention, community-marketing, lead-magnets, co-marketing, influencer-marketing |
| `mkt-sales` | Sales & GTM | revops, sales-enablement, launch, pricing, competitors, competitor-profiling, directory-submissions, prospecting, public-relations, offers |
| `mkt-strategy` | Strategy & Research | marketing-ideas, marketing-psychology, customer-research, marketing-plan, marketing-loops |
| `mkt-council` | Advisory Council | 12 legendary marketer personas for strategic debates |

### Advisory Council Personas

The `mkt-council` agent simulates debates between these marketing legends:

| Advisor | Lens |
|---------|------|
| Alex Hormozi | Offers, pricing, volume |
| Seth Godin | Permission, remarkable |
| April Dunford | Positioning |
| David Ogilvy | Brand + direct response |
| Byron Sharp | Brand science, reach |
| Eugene Schwartz | Awareness stages |
| Claude Hopkins | Scientific advertising |
| Gary Halbert | Starving crowd, lists |
| Russell Brunson | Funnels, value ladders |
| Rory Sutherland | Behavioral science |
| Ann Handley | Content, writing craft |
| Gary Vaynerchuk | Attention arbitrage |

---

## Installation

### Quick Install

```bash
cd kirocrew-ports/marketingskills
./install.sh
```

### Manual Install

1. **Copy agent definitions:**
```bash
cp agents/*.json ~/.kiro/agents/
```

2. **Copy prompts:**
```bash
mkdir -p ~/.kiro/crew/prompts
cp prompts/*.md ~/.kiro/crew/prompts/
```

3. **Update prompt paths in agent files** (replace `$HOME` with your actual home path):
```bash
sed -i "s|\$HOME|$HOME|g" ~/.kiro/agents/mkt-*.json ~/.kiro/agents/marketingcrew.json
```

4. **Merge agent bindings** into `~/.kiro/crew/config.json`:
```bash
# Use jq or manually merge the "agents" section from config-fragment.json
```

5. **Restart KiroCrew gateway** to pick up changes.

---

## Usage

### Switch to the Marketing Crew

In the dashboard, use the agent selector dropdown to choose `marketingcrew`.

Or in Slack:
```
!agent marketingcrew
```

### How Routing Works

1. **Default agent (kirocrew)** has conductor skill enabled
2. When you mention "marketing", `select_crew` shows `marketingcrew` in the roster
3. The default agent delegates via `spawn_run(agent="marketingcrew", task="...")`
4. `marketingcrew` then routes to specialists as needed

### Direct Agent Access

You can also switch directly to specialists:

```
!agent mkt-seo      # SEO questions
!agent mkt-cro      # Conversion optimization
!agent mkt-council  # Get multiple expert perspectives
```

### Example Workflows

**Landing page optimization:**
```
User: "My landing page isn't converting"
→ marketingcrew checks product context
→ Routes to mkt-cro for analysis
→ mkt-cro may delegate headline work to mkt-copy
```

**Strategic decision:**
```
User: "Should we go freemium or free trial?"
→ marketingcrew routes to mkt-council
→ Council seats Hormozi, Godin, and Sharp for debate
→ Returns synthesis with recommendation
```

---

## File Structure

After installation:

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
├── config.json                    # Agent bindings with triggers
└── prompts/                       # System prompts (Markdown)
    ├── marketingcrew.md
    ├── mkt-seo.md
    ├── mkt-cro.md
    ├── mkt-copy.md
    ├── mkt-paid.md
    ├── mkt-growth.md
    ├── mkt-sales.md
    ├── mkt-strategy.md
    └── mkt-council.md
```

---

## Configuration

### Agent Bindings (config.json)

Each agent needs a binding in `~/.kiro/crew/config.json` under the `agents` key:

```json
{
  "agents": {
    "marketingcrew": {
      "kiro_agent": "marketingcrew",
      "workspace": "default",
      "memory_store": "default",
      "model": "",
      "description": "Marketing Crew orchestrator",
      "triggers": "marketing, help with marketing, marketing crew, cmo",
      "source": "kirocrew-ports"
    },
    "mkt-seo": {
      "kiro_agent": "mkt-seo",
      "workspace": "default",
      "memory_store": "default",
      "model": "",
      "description": "SEO & Content specialist",
      "triggers": "seo, search optimization, rankings, keywords",
      "source": "kirocrew-ports"
    }
  }
}
```

The `triggers` field determines when the agent appears in `select_crew` routing.

### Kiro Agent JSON Format

Each agent in `~/.kiro/agents/` follows this structure:

```json
{
  "name": "mkt-seo",
  "description": "SEO & Content specialist",
  "model": "claude-sonnet-4-20250514",
  "tools": [
    "execute_bash",
    "fs_read",
    "fs_write",
    "code",
    "grep",
    "glob",
    "web_fetch",
    "web_search",
    "tool_search",
    "@kirocrew-cron",
    "@kirocrew-core"
  ],
  "allowedTools": [
    "web_fetch",
    "web_search",
    "@kirocrew-core",
    "@kirocrew-cron/cron_list"
  ],
  "prompt": "file:///home/USER/.kiro/crew/prompts/mkt-seo.md",
  "resources": []
}
```

**Important:** The `prompt` field must use an absolute path with `file://` protocol.

---

## Enabling Conductor Skill

For the default agent to route to marketing specialists, enable the conductor skill:

```bash
kirocrew config set agent.conductor_skill true
```

This loads an always-on skill that teaches the default agent to use `select_crew`.

---

## Upstream Tracking

| | |
|---|---|
| **Original Repository** | https://github.com/coreyhaines31/marketingskills |
| **Ported from commit** | `7868cb9251fad80a73d26e488a5ad5f6c4a9f335` |
| **Commit date** | 2026-07-27 |
| **Original version** | v2.x |

### Checking for Updates

```bash
# Clone original and compare
git clone https://github.com/coreyhaines31/marketingskills.git /tmp/mkt
cd /tmp/mkt
git log --oneline -10  # Check recent commits
```

---

## Documentation

- **[MAPPING.md](./docs/MAPPING.md)** — Complete mapping of all 49 skills to agents
- **[DECISIONS.md](./docs/DECISIONS.md)** — Architectural decisions and rationale

---

## KiroCrew Architecture Notes

### What is a "Crew"?

In KiroCrew, **a crew is simply an agent with non-empty `triggers`**. There is no separate crew file format — the `select_crew` MCP tool routes to agents based on their `triggers` in the config binding.

### File Locations

| Component | Location |
|-----------|----------|
| Kiro Agent definitions | `~/.kiro/agents/*.json` |
| Agent bindings (triggers, workspace) | `~/.kiro/crew/config.json` → `agents` section |
| System prompts | `~/.kiro/crew/prompts/*.md` |
| Skills (optional) | `~/.kiro/crew/skills/<name>/SKILL.md` |

### What Does NOT Exist

| Myth | Reality |
|------|---------|
| `crews/*.yaml` | Crews are agents with triggers, not YAML files |
| `~/.kiro/crew/agents/` | Agents go in `~/.kiro/agents/` (not under crew) |
| `knowledge://` protocol | Use Knowledge Library ingestion instead |

---

## Credit

Original project by [Corey Haines](https://corey.co). This port transforms the skill library into a multi-agent system while preserving all the marketing expertise.

---

## License

MIT — Same as the original project.
