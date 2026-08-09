# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| latest  | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly:

1. **Do NOT** open a public GitHub issue
2. **Email** the maintainer directly at the contact on [ft.ia.br](https://ft.ia.br)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to expect

- **Acknowledgment** within 48 hours
- **Status update** within 7 days
- **Resolution timeline** depends on severity

### Scope

This repository contains **skill files** (markdown) and **agent configurations** (JSON). Security concerns may include:

- Prompt injection vectors in skill instructions
- Unsafe command patterns in skill procedures
- Credential exposure risks in documented workflows

### Out of Scope

- Vulnerabilities in KiroCrew itself (report to KiroCrew maintainers)
- Vulnerabilities in original upstream projects (report to their maintainers)
- General coding best practices that don't pose security risks

## Security Best Practices

When using these ports:

1. **Review skills before installing** — These are markdown files that instruct AI agents. Read them.
2. **Don't store credentials in skill files** — Use environment variables or secure vaults
3. **Audit agent actions** — Monitor what agents do with these skills, especially in production
4. **Keep KiroCrew updated** — Security patches come from the runtime, not the skills

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who report valid vulnerabilities (unless they prefer to remain anonymous).
