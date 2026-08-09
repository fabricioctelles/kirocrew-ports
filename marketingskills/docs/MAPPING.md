# Component Mapping: MarketingSkills → KiroCrew

This document provides a complete mapping of all 49 original skills to their KiroCrew destinations.

## Upstream Reference

- **Original Repository:** https://github.com/coreyhaines31/marketingskills
- **Ported from commit:** `7868cb9251fad80a73d26e488a5ad5f6c4a9f335`
- **Commit date:** 2026-07-27
- **Total original skills:** 49
- **Total advisor dossiers:** 12

---

## KiroCrew Component Model

### What Gets Created

| Component | Location | Purpose |
|-----------|----------|---------|
| **Kiro Agents** | `~/.kiro/agents/*.json` | Agent definitions (model, tools, prompt path) |
| **System Prompts** | `~/.kiro/crew/prompts/*.md` | The actual agent instructions |
| **Agent Bindings** | `~/.kiro/crew/config.json` → `agents` | Triggers, workspace, memory store |

### What Does NOT Exist in KiroCrew

| Myth | Reality |
|------|---------|
| `crews/*.yaml` | Crews are agents with triggers, not separate YAML files |
| `~/.kiro/crew/agents/` | Agents live in `~/.kiro/agents/` (not under crew) |
| `knowledge://` protocol | Use Knowledge Library ingestion instead |
| Automatic YAML loading | KiroCrew only reads JSON agent definitions |

---

## Transformation Overview

```
Original (49 skills)              KiroCrew (9 agents)
─────────────────────             ──────────────────────

┌─────────────────────┐           ┌──────────────────────────────┐
│  product-marketing  │ ────────► │  marketingcrew               │
│  (foundation)       │           │  ~/.kiro/agents/marketingcrew.json
└─────────────────────┘           │  triggers: "marketing, cmo..." │
                                  └──────────────────────────────┘
                                              │
        ┌─────────────────────────────────────┼─────────────────────────────────────┐
        │         │         │         │       │       │         │         │         │
        ▼         ▼         ▼         ▼       ▼       ▼         ▼         ▼         ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ mkt-seo │ │ mkt-cro │ │mkt-copy │ │mkt-paid │ │mkt-grow │ │mkt-sale │ │mkt-strt │ │mkt-cncl │
│ 7 skills│ │ 5 skills│ │ 8 skills│ │ 5 skills│ │ 7 skills│ │10 skills│ │ 5 skills│ │12 advis │
└─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
     │           │           │           │           │           │           │           │
     └───────────┴───────────┴───────────┴───────────┴───────────┴───────────┴───────────┘
                                              │
                              All are ~/.kiro/agents/*.json
                              All have triggers in config.json
                              All appear in select_crew roster
```

---

## Complete Skill Mapping (All 49)

| # | Original Skill | → KiroCrew Agent | Category |
|---|----------------|------------------|----------|
| 1 | ab-testing | `mkt-paid` | Paid & Measurement |
| 2 | ad-creative | `mkt-paid` | Paid & Measurement |
| 3 | ads | `mkt-paid` | Paid & Measurement |
| 4 | ai-seo | `mkt-seo` | SEO & Content |
| 5 | analytics | `mkt-paid` | Paid & Measurement |
| 6 | aso | `mkt-seo` | SEO & Content |
| 7 | attribution | `mkt-paid` | Paid & Measurement |
| 8 | churn-prevention | `mkt-growth` | Growth & Retention |
| 9 | co-marketing | `mkt-growth` | Growth & Retention |
| 10 | cold-email | `mkt-copy` | Content & Copy |
| 11 | community-marketing | `mkt-growth` | Growth & Retention |
| 12 | competitor-profiling | `mkt-sales` | Sales & GTM |
| 13 | competitors | `mkt-sales` | Sales & GTM |
| 14 | content-strategy | `mkt-seo` | SEO & Content |
| 15 | copy-editing | `mkt-copy` | Content & Copy |
| 16 | copywriting | `mkt-copy` | Content & Copy |
| 17 | cro | `mkt-cro` | CRO |
| 18 | customer-research | `mkt-strategy` | Strategy |
| 19 | directory-submissions | `mkt-sales` | Sales & GTM |
| 20 | emails | `mkt-copy` | Content & Copy |
| 21 | free-tools | `mkt-growth` | Growth & Retention |
| 22 | image | `mkt-copy` | Content & Copy |
| 23 | influencer-marketing | `mkt-growth` | Growth & Retention |
| 24 | launch | `mkt-sales` | Sales & GTM |
| 25 | lead-magnets | `mkt-growth` | Growth & Retention |
| 26 | marketing-council | `mkt-council` | Council |
| 27 | marketing-ideas | `mkt-strategy` | Strategy |
| 28 | marketing-loops | `mkt-strategy` | Strategy |
| 29 | marketing-plan | `mkt-strategy` | Strategy |
| 30 | marketing-psychology | `mkt-strategy` | Strategy |
| 31 | offers | `mkt-sales` | Sales & GTM |
| 32 | onboarding | `mkt-cro` | CRO |
| 33 | paywalls | `mkt-cro` | CRO |
| 34 | popups | `mkt-cro` | CRO |
| 35 | pricing | `mkt-sales` | Sales & GTM |
| 36 | product-marketing | `marketingcrew` | Foundation |
| 37 | programmatic-seo | `mkt-seo` | SEO & Content |
| 38 | prospecting | `mkt-sales` | Sales & GTM |
| 39 | public-relations | `mkt-sales` | Sales & GTM |
| 40 | referrals | `mkt-growth` | Growth & Retention |
| 41 | revops | `mkt-sales` | Sales & GTM |
| 42 | sales-enablement | `mkt-sales` | Sales & GTM |
| 43 | schema | `mkt-seo` | SEO & Content |
| 44 | seo-audit | `mkt-seo` | SEO & Content |
| 45 | signup | `mkt-cro` | CRO |
| 46 | site-architecture | `mkt-seo` | SEO & Content |
| 47 | sms | `mkt-copy` | Content & Copy |
| 48 | social | `mkt-copy` | Content & Copy |
| 49 | video | `mkt-copy` | Content & Copy |

**Audit:** 49/49 skills mapped ✓

---

## Mapping by Agent

### marketingcrew (Orchestrator)

**File:** `~/.kiro/agents/marketingcrew.json`  
**Prompt:** `~/.kiro/crew/prompts/marketingcrew.md`  
**Triggers:** `marketing, help with marketing, marketing crew, cmo, marketing help`

**Absorbs:**
| Skill | Purpose |
|-------|---------|
| product-marketing | Foundation context creation/management |

**Responsibilities:**
- Check/create `.agents/product-marketing.md` on start
- Route requests to appropriate specialist agent
- Coordinate multi-agent workflows
- Synthesize results from specialists

---

### mkt-seo (SEO & Content Specialist)

**File:** `~/.kiro/agents/mkt-seo.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-seo.md`  
**Triggers:** `seo, search optimization, rankings, organic traffic, keywords, schema markup, ai seo, aso`

**Absorbs 7 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | ai-seo | AI search optimization (AEO, GEO, LLMO) |
| 2 | aso | App Store Optimization |
| 3 | content-strategy | Content planning and topic strategy |
| 4 | programmatic-seo | Scaled page generation |
| 5 | schema | Structured data markup |
| 6 | seo-audit | Technical and on-page SEO |
| 7 | site-architecture | Page hierarchy, navigation, URLs |

---

### mkt-cro (CRO Specialist)

**File:** `~/.kiro/agents/mkt-cro.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-cro.md`  
**Triggers:** `conversion, cro, landing page, signup, onboarding, popup, paywall`

**Absorbs 5 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | cro | Page and form conversion optimization |
| 2 | onboarding | Post-signup activation |
| 3 | paywalls | In-app upgrade screens |
| 4 | popups | Modals and overlays |
| 5 | signup | Registration flow optimization |

---

### mkt-copy (Content & Copy Specialist)

**File:** `~/.kiro/agents/mkt-copy.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-copy.md`  
**Triggers:** `copywriting, copy, email, social media, video script, ad creative, content writing`

**Absorbs 8 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | cold-email | B2B cold outreach |
| 2 | copy-editing | Edit and improve existing copy |
| 3 | copywriting | Marketing page copy |
| 4 | emails | Automated email sequences |
| 5 | image | AI image generation |
| 6 | sms | SMS/MMS marketing |
| 7 | social | Social media content |
| 8 | video | Video production |

---

### mkt-paid (Paid & Measurement Specialist)

**File:** `~/.kiro/agents/mkt-paid.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-paid.md`  
**Triggers:** `paid ads, google ads, facebook ads, analytics, attribution, ppc, a/b testing`

**Absorbs 5 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | ab-testing | Experiment design |
| 2 | ad-creative | Bulk ad copy generation |
| 3 | ads | Campaign strategy and optimization |
| 4 | analytics | Event tracking setup |
| 5 | attribution | Marketing attribution models |

---

### mkt-growth (Growth & Retention Specialist)

**File:** `~/.kiro/agents/mkt-growth.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-growth.md`  
**Triggers:** `growth, referral, churn, retention, community, lead magnet, partnership`

**Absorbs 7 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | churn-prevention | Cancel flows, dunning, retention |
| 2 | co-marketing | Partner campaigns |
| 3 | community-marketing | Community building |
| 4 | free-tools | Engineering as marketing |
| 5 | influencer-marketing | Creator partnerships |
| 6 | lead-magnets | Content for email capture |
| 7 | referrals | Referral/affiliate programs |

---

### mkt-sales (Sales & GTM Specialist)

**File:** `~/.kiro/agents/mkt-sales.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-sales.md`  
**Triggers:** `sales, revops, pricing, launch, competitor, pr, prospecting, pitch deck`

**Absorbs 10 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | competitor-profiling | Competitive intelligence |
| 2 | competitors | Comparison/alternative pages |
| 3 | directory-submissions | Directory listings |
| 4 | launch | Product launch strategy |
| 5 | offers | Offer construction |
| 6 | pricing | Pricing strategy |
| 7 | prospecting | Lead list building |
| 8 | public-relations | Earned media, PR |
| 9 | revops | Revenue operations |
| 10 | sales-enablement | Sales collateral |

---

### mkt-strategy (Strategy Specialist)

**File:** `~/.kiro/agents/mkt-strategy.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-strategy.md`  
**Triggers:** `marketing strategy, marketing plan, customer research, marketing ideas, marketing psychology`

**Absorbs 5 skills:**
| # | Skill | Original Purpose |
|---|-------|------------------|
| 1 | customer-research | VOC, interviews, surveys |
| 2 | marketing-ideas | 139 marketing tactics |
| 3 | marketing-loops | Recurring automation workflows |
| 4 | marketing-plan | 12-month fCMO planning |
| 5 | marketing-psychology | Mental models, behavioral science |

---

### mkt-council (Advisory Council)

**File:** `~/.kiro/agents/mkt-council.json`  
**Prompt:** `~/.kiro/crew/prompts/mkt-council.md`  
**Triggers:** `council, advisory board, what would hormozi say, multiple perspectives, debate this`

**Absorbs 1 skill + 12 advisor personas (inline in prompt):**

| # | Advisor | Lens |
|---|---------|------|
| 1 | Alex Hormozi | Offers, pricing, volume |
| 2 | Ann Handley | Content, writing craft |
| 3 | April Dunford | Positioning |
| 4 | Byron Sharp | Brand science, reach |
| 5 | Claude Hopkins | Scientific advertising |
| 6 | David Ogilvy | Brand + DR discipline |
| 7 | Eugene Schwartz | Awareness stages |
| 8 | Gary Halbert | Starving crowd, lists |
| 9 | Gary Vaynerchuk | Attention arbitrage |
| 10 | Rory Sutherland | Behavioral science |
| 11 | Russell Brunson | Funnels, value ladders |
| 12 | Seth Godin | Permission, remarkable |

---

## File Manifest

### Created by This Port

| File | Type | Description |
|------|------|-------------|
| `~/.kiro/agents/marketingcrew.json` | Kiro Agent | Orchestrator definition |
| `~/.kiro/agents/mkt-seo.json` | Kiro Agent | SEO specialist |
| `~/.kiro/agents/mkt-cro.json` | Kiro Agent | CRO specialist |
| `~/.kiro/agents/mkt-copy.json` | Kiro Agent | Copy specialist |
| `~/.kiro/agents/mkt-paid.json` | Kiro Agent | Paid specialist |
| `~/.kiro/agents/mkt-growth.json` | Kiro Agent | Growth specialist |
| `~/.kiro/agents/mkt-sales.json` | Kiro Agent | Sales specialist |
| `~/.kiro/agents/mkt-strategy.json` | Kiro Agent | Strategy specialist |
| `~/.kiro/agents/mkt-council.json` | Kiro Agent | Advisory council |
| `~/.kiro/crew/prompts/marketingcrew.md` | Prompt | Orchestrator instructions |
| `~/.kiro/crew/prompts/mkt-seo.md` | Prompt | SEO instructions |
| `~/.kiro/crew/prompts/mkt-cro.md` | Prompt | CRO instructions |
| `~/.kiro/crew/prompts/mkt-copy.md` | Prompt | Copy instructions |
| `~/.kiro/crew/prompts/mkt-paid.md` | Prompt | Paid instructions |
| `~/.kiro/crew/prompts/mkt-growth.md` | Prompt | Growth instructions |
| `~/.kiro/crew/prompts/mkt-sales.md` | Prompt | Sales instructions |
| `~/.kiro/crew/prompts/mkt-strategy.md` | Prompt | Strategy instructions |
| `~/.kiro/crew/prompts/mkt-council.md` | Prompt | Council instructions |

### Updated by This Port

| File | Section | Changes |
|------|---------|---------|
| `~/.kiro/crew/config.json` | `agents` | Add 9 agent bindings with triggers |

---

## Files NOT Created (Intentionally)

| Type | Reason |
|------|--------|
| `crews/*.yaml` | Not a KiroCrew format — crews are agents with triggers |
| `~/.kiro/crew/agents/*.json` | Wrong path — agents go in `~/.kiro/agents/` |
| `skills/*.md` | Optional; agent prompts are primary |
| `knowledge/*.md` | Use Knowledge Library ingestion instead |

---

## Summary

| Component | Count |
|-----------|-------|
| Original skills | 49 |
| Kiro Agent JSONs | 9 |
| Prompt files | 9 |
| Config.json bindings | 9 |
| Skills (optional) | 0 |
| Separate crew files | 0 |

**Verification:**
- Skills mapped: 49/49 ✓
- Advisors incorporated: 12/12 ✓
- File format compliance: JSON + MD ✓
- Native KiroCrew locations: ✓
