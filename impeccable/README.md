# Impeccable Port for KiroCrew

Design guidance for AI coding agents. 1 skill, 23 commands, live browser iteration, and 59 deterministic detector rules for AI-generated frontend design.

This port adapts [pbakaus/impeccable](https://github.com/pbakaus/impeccable) for native KiroCrew operation, adding a dedicated design agent with automatic routing.

## What's Included

### Agent: impeccable

A dedicated KiroCrew agent that automatically handles design-related requests:

**Triggers:**
- "design review", "ui audit", "ux critique"
- "polish the ui", "improve the design"
- "make it bolder", "distill the ui"
- "typography fix", "layout issues"
- "animate this", "colorize"

### Skill: impeccable

The complete Impeccable skill with 23 commands:

| Command | What it does |
|---------|--------------|
| `init` | Capture product context in PRODUCT.md |
| `document` | Generate DESIGN.md from existing code |
| `shape` | Plan UX/UI before writing code |
| `critique` | UX design review with heuristic scoring |
| `audit` | Technical quality checks (a11y, perf, responsive) |
| `polish` | Final quality pass before shipping |
| `bolder` | Amplify safe or bland designs |
| `quieter` | Tone down aggressive designs |
| `distill` | Strip to essence |
| `harden` | Production-ready: errors, i18n, edge cases |
| `onboard` | First-run flows, empty states |
| `animate` | Add purposeful motion |
| `colorize` | Add strategic color |
| `typeset` | Improve typography |
| `layout` | Fix spacing and rhythm |
| `delight` | Add personality |
| `overdrive` | Push past limits |
| `clarify` | Improve UX copy |
| `adapt` | Responsive design |
| `optimize` | Fix UI performance |
| `live` | Visual iteration in browser |

## Installation

### Let KiroCrew Do It

```
Install the Impeccable port from fabricioctelles/kirocrew-ports
```

### Manual Installation

```bash
git clone https://github.com/fabricioctelles/kirocrew-ports.git
cd kirocrew-ports/impeccable
./install.sh
```

## Post Install

### Review Model Configuration

The default model is `claude-sonnet-4-20250514`. Adjust based on your needs:

```bash
# Check current model
cat ~/.kiro/agents/impeccable.json | grep model

# Or edit in KiroCrew dashboard:
# Settings → Agents → impeccable → Model
```

### Initialize in Your Project

After installing, run in any frontend project:

```
impeccable init
```

This creates `PRODUCT.md` and `DESIGN.md` files that guide all future design work.

## Usage Examples

### Automatic Routing

Just describe what you need — KiroCrew routes to the impeccable agent:

```
Review the design of my landing page
```

```
The settings page feels cluttered, can you distill it?
```

```
Make the hero section bolder
```

### Direct Commands

Use the skill directly for specific operations:

```
$impeccable audit the checkout form
```

```
$impeccable polish the dashboard
```

```
$impeccable animate the navigation
```

## Anti-Patterns Detected

The skill includes guidance to avoid common AI design tells:

- ❌ Overused fonts (Inter, Arial without intention)
- ❌ Gray text on colored backgrounds
- ❌ Pure black/gray (should tint with brand)
- ❌ Cards nested inside cards
- ❌ Bounce/elastic easing
- ❌ Purple-to-blue gradients
- ❌ Rounded-square icon tiles above headings

## Architecture

```
~/.kiro/
├── agents/
│   └── impeccable.json          # Agent definition
└── crew/
    ├── prompts/
    │   └── impeccable.md        # System prompt
    ├── skills/
    │   └── impeccable/          # Full skill
    │       ├── SKILL.md
    │       ├── reference/       # Command docs
    │       └── scripts/         # JS tooling
    └── config.json              # Agent binding
```

## Scripts and Tooling

This port includes the full Impeccable scripts for:

- **Detector:** 59 deterministic rules for design anti-patterns
- **Live mode:** Browser-based visual iteration
- **Hooks:** Auto-run detector after UI file edits
- **Context:** Loads PRODUCT.md, DESIGN.md, and surface briefs

Scripts require Node.js and run via the skill's embedded tooling.

## Upstream Tracking

| Item | Value |
|------|-------|
| **Original repo** | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) |
| **Version ported** | 4.0.4 |
| **License** | Apache 2.0 |

## Differences from Original

| Aspect | Original | This Port |
|--------|----------|-----------|
| Installation | `npx impeccable install` | `./install.sh` |
| Skill location | `.kiro/skills/` (project) | `~/.kiro/crew/skills/` (global) |
| Agent | None | Dedicated agent with triggers |
| Routing | Manual `/impeccable` | Auto-routes on design requests |

## Credits

- Original project by [Paul Bakaus](https://github.com/pbakaus)
- Port maintains full attribution and Apache 2.0 license
