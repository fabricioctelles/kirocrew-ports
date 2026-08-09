# Impeccable Port Mapping

How the original Impeccable components map to KiroCrew.

## Component Mapping

| Original | KiroCrew | Notes |
|----------|----------|-------|
| `.kiro/skills/impeccable/SKILL.md` | `~/.kiro/crew/skills/impeccable/SKILL.md` | Skill file unchanged |
| `.kiro/skills/impeccable/scripts/` | `~/.kiro/crew/skills/impeccable/scripts/` | All scripts preserved |
| `.kiro/skills/impeccable/reference/` | `~/.kiro/crew/skills/impeccable/reference/` | Reference docs preserved |
| N/A | `~/.kiro/agents/impeccable.json` | **New:** Dedicated agent |
| N/A | `~/.kiro/crew/prompts/impeccable.md` | **New:** System prompt |
| N/A | `~/.kiro/crew/config.json` (agents section) | **New:** Agent binding |

## What's New in This Port

### 1. Dedicated Agent

The original Impeccable has no agent — it's a skill you invoke with `/impeccable`. This port adds a KiroCrew agent that:

- Responds to design-related triggers automatically
- Has a specialized system prompt with design expertise
- Links to the impeccable skill

### 2. Automatic Routing

With KiroCrew's `select_crew` mechanism, requests like "review my design" automatically route to the impeccable agent without needing to specify `/impeccable`.

### 3. Global Installation

Original Impeccable installs per-project (`.kiro/skills/`). This port installs globally (`~/.kiro/crew/skills/`) so the skill is available across all projects.

## Path Translations

Scripts in the skill reference paths. These are the mappings:

| Original Path | KiroCrew Path |
|---------------|---------------|
| `.kiro/skills/impeccable/` | `~/.kiro/crew/skills/impeccable/` |
| `<skill-base-dir>/scripts/` | `~/.kiro/crew/skills/impeccable/scripts/` |

**Note:** The SKILL.md contains relative paths like `reference/new-work.md` which resolve correctly regardless of installation location.

## Scripts Compatibility

All JavaScript scripts (`.mjs`, `.js`) are preserved unchanged. They require:

- Node.js runtime
- Project context (PRODUCT.md, DESIGN.md)
- Browser for live mode features

The scripts should work identically in KiroCrew as they do in vanilla Kiro.

## Triggers Rationale

The agent triggers were chosen to cover common design request patterns:

| Trigger | Matches |
|---------|---------|
| "design review" | General design assessment |
| "ui audit" | Technical quality check |
| "ux critique" | User experience review |
| "polish the ui" | Final refinement pass |
| "improve the design" | General enhancement |
| "make it bolder" | Amplification request |
| "design system" | Token/component extraction |
| "typography fix" | Font/hierarchy issues |
| "layout issues" | Spacing/rhythm problems |
| "animate this" | Motion addition |
| "colorize" | Color strategy |
| "distill the ui" | Simplification request |

## Version Tracking

- **Impeccable version:** 4.0.4
- **Port version:** 1.0.0
- **Port date:** 2026-08-08
