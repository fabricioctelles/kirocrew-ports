# Contributing to KiroCrew Ports

Thank you for your interest in contributing! This document provides guidelines for contributing to this repository.

## Ways to Contribute

### 1. Port a New Project

Want to port another AI agent framework to KiroCrew? Here's the process:

1. **Open an issue** describing the project you want to port
2. **Get approval** before starting significant work
3. **Follow the structure** established by existing ports
4. **Document thoroughly** — mapping and decisions are as important as code

### 2. Improve Existing Ports

- Fix bugs in skill logic
- Improve documentation
- Add missing features from upstream
- Sync with upstream updates

### 3. Documentation

- Fix typos and unclear explanations
- Add examples and use cases
- Improve installation instructions

## Development Process

### Before You Start

1. Check existing issues and PRs to avoid duplicate work
2. For significant changes, open an issue first to discuss
3. Fork the repository and create a feature branch

### Port Structure

Every port must follow this structure:

```
<port-name>/
├── README.md             # Port documentation (required)
├── install.sh            # Installation script (required)
├── config-fragment.json  # Agent bindings (required for agent-based ports)
├── docs/
│   ├── MAPPING.md        # Original → KiroCrew mapping (required)
│   └── DECISIONS.md      # Architectural decisions (required)
├── agents/               # Kiro agent JSON files (if agent-based)
├── prompts/              # System prompts (if agent-based)
└── skills/               # SKILL.md files (if skill-based)
```

### KiroCrew Architecture Rules

**DO:**
- Put agents in `~/.kiro/agents/*.json`
- Put prompts in `~/.kiro/crew/prompts/*.md`
- Put skills in `~/.kiro/crew/skills/<name>/SKILL.md`
- Use `config-fragment.json` for agent bindings

**DON'T:**
- Create `crews/*.yaml` files (crews = agents with triggers)
- Put agents in `~/.kiro/crew/agents/` (wrong path)
- Use `knowledge://` protocol (use Knowledge Library instead)

### Naming Conventions

- **Skill prefix:** 3-4 lowercase letters derived from project name (e.g., `hyr-` for HyperResearch)
- **Skill names:** `<prefix>-<function>` (e.g., `hyr-decompose`, `hyr-draft`)
- **Agent prefix:** `mkt-` for MarketingSkills, etc.
- **Branch names:** `port/<project-name>` or `fix/<port-name>-<issue>`

### Commit Messages

Follow conventional commits:

```
feat(hyperresearch): add step 14.5 cite-check skill
fix(marketingskills): correct prompt path expansion
docs(hyperresearch): update MAPPING.md with new commands
```

### Pull Request Process

1. **Update documentation** — README, MAPPING.md, DECISIONS.md
2. **Test locally** — Run `./install.sh` and verify in KiroCrew
3. **Keep PRs focused** — One port or one fix per PR
4. **Describe changes** — What and why, not just what

### PR Template

```markdown
## Summary
Brief description of changes

## Type
- [ ] New port
- [ ] Port update (sync with upstream)
- [ ] Bug fix
- [ ] Documentation

## Checklist
- [ ] README.md updated
- [ ] MAPPING.md updated (if applicable)
- [ ] DECISIONS.md updated (if applicable)
- [ ] install.sh works correctly
- [ ] Tested locally with KiroCrew
- [ ] No credentials or secrets in files
```

## Code of Conduct

- Be respectful and constructive
- Focus on the work, not the person
- Welcome newcomers
- Give credit where due, especially to original projects

## Questions?

Open an issue with the `question` label.

---

Thank you for contributing! 🚀
