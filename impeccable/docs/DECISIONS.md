# Impeccable Port Decisions

Architectural decisions made during the port from pbakaus/impeccable to KiroCrew.

## Decision 1: Full Skill Preservation

**Choice:** Copy the entire `.kiro/skills/impeccable/` directory unchanged.

**Rationale:**
- Impeccable is hybrid: SKILL.md (prompts) + scripts/ (JavaScript tooling)
- Scripts provide critical functionality: detector rules, live mode, hooks
- Modifying scripts would require deep understanding and ongoing maintenance
- Keeping unchanged maximizes compatibility with upstream updates

**Trade-off:** Larger install size (~3.3MB), but full feature parity.

## Decision 2: Add Dedicated Agent

**Choice:** Create a new `impeccable` agent that doesn't exist in original.

**Rationale:**
- KiroCrew's strength is automatic routing via triggers
- Users shouldn't need to remember `/impeccable` command
- Design requests are common and benefit from specialist handling
- Agent can have optimized model choice for design tasks

**Implementation:**
- Agent JSON with triggers for design-related requests
- System prompt summarizing Impeccable's design philosophy
- Skill binding so agent has access to all 23 commands

## Decision 3: Global vs Project Installation

**Choice:** Install to `~/.kiro/crew/skills/` (global) instead of `.kiro/skills/` (project-local).

**Rationale:**
- KiroCrew architecture uses global skills
- Design skill is useful across all projects
- Avoids duplicating ~3.3MB in every project
- Consistent with other KiroCrew ports

**Trade-off:** Can't have per-project customizations of the skill itself.

## Decision 4: Model Selection

**Choice:** Use `claude-sonnet-4-20250514` as default model.

**Rationale:**
- Design tasks benefit from strong reasoning but don't always need Opus
- Sonnet balances quality and cost for iterative design work
- Users can upgrade to Opus for complex projects via dashboard
- Haiku would be too limited for nuanced design decisions

## Decision 5: Trigger Selection

**Choice:** 13 specific triggers covering common design request patterns.

**Rationale:**
- Broad enough to catch most design requests
- Specific enough to not overlap with general coding tasks
- Includes both action words ("polish", "audit") and concepts ("typography", "layout")
- Avoids overly generic triggers that would route non-design work

**Excluded triggers:**
- "improve" (too generic, could be code improvement)
- "fix" (too generic)
- "change" (too generic)

## Decision 6: No Path Modifications

**Choice:** Don't modify paths in SKILL.md or scripts.

**Rationale:**
- Skill uses relative paths (`reference/new-work.md`) which work anywhere
- Scripts use runtime path detection
- Modifying would create maintenance burden
- Original paths work as-is in KiroCrew context

## Decision 7: Include All Reference Docs

**Choice:** Copy entire `reference/` directory unchanged.

**Rationale:**
- Reference docs are loaded dynamically by skill
- Missing docs would break commands
- Docs provide valuable context for design decisions
- No adaptation needed

## Update Strategy

When Impeccable releases updates:

1. Clone latest: `git clone https://github.com/pbakaus/impeccable.git`
2. Copy skill: `cp -r .kiro/skills/impeccable kirocrew-ports/impeccable/skills/`
3. Update version in README.md
4. Test installation
5. Commit and push

Agent and prompt typically don't need updates unless new commands are added.
