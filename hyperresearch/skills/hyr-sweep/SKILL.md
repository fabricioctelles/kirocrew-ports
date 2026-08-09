---
name: hyr-sweep
description: >
  Step 2 do HyperResearch para KiroCrew. Width sweep com 3 lentes
  (breadth/depth/adversarial) + fetchers paralelos via spawn_run.
  Gera cobertura ampla sobre todos os itens atômicos da decomposição.
triggers: hyr-sweep, width sweep, sweep, varredura, busca ampla, 3 lentes
---

# hyr-sweep — Width Sweep (Step 2)

**Goal:** Cobertura topical completa — todo item atômico da decomposição deve ter ≥3 fontes ao final. Target: 40-60 fontes curadas.

---

## Inputs (do Step 1)

Ler de `~/.kiro/crew/workspace/research/<vault_tag>/`:
- `scaffold.md` — vault_tag, modalidade
- `prompt-decomposition.json` — atomic items, sub_questions, entities
- `temp/coverage-matrix.md` — query phrases mapeadas para atomic items
- `query.md` — research query canônica (GOSPEL)

---

## Step 2.1 — Planejamento multi-perspectiva

Antes de qualquer busca, produzir um **search plan** mapeando a decomposição para buscas concretas de **3 perspectivas independentes**.

### 1. Ler a decomposição
Extrair cada `sub_question` e `entity` com seus `required_fields`.

### 2. Gerar buscas das 3 lentes

Para CADA item atômico, gerar buscas das 3 perspectivas:

**Lens A — Breadth (cobertura sistemática):**
- Uma busca para o conteúdo factual core do item
- Uma busca para desenvolvimentos recentes (últimos 2 anos)
- Uma busca para cada entidade/sub-conceito nomeado
- Goal: nenhum item sem cobertura. Rede ampla.

**Lens B — Depth (acadêmico/canônico):**
- Buscas por papers acadêmicos, relatórios autoritativos
- Buscas por trabalhos seminais/fundacionais
- Buscas por fontes upstream que comentários derivativos citam
- Goal: encontrar as fontes load-bearing.

**Lens C — Adversarial (dialético):**
- "criticism of X", "limitations of X", "problems with X"
- Buscas por frameworks alternativos, especialistas dissidentes
- Buscas por casos de falha, resultados negativos
- Pelo menos uma busca "X is wrong" por item major
- Goal: corpus inclui o caso mais forte CONTRA o consenso emergente.

### 3. Escrever search plan

Criar `~/.kiro/crew/workspace/research/<vault_tag>/temp/search-plan.md`:

```markdown
| Atomic item | Search query | Type | Lens | Target |
|---|---|---|---|---|
| Sub-Q1 | "topic X trends 2024" | web | breadth | factual |
| Sub-Q1 | "topic X structural risks" | web | adversarial | contrarian |
| Sub-Q1 | "topic X scholarly analysis" | web | depth | canonical |
```

**Target: 30-50 planned searches** para uma query completa.

### 4. Gap check

Cross-check contra `coverage-matrix.md`. Para cada linha na matrix, verificar se pelo menos uma busca no plano cobre aquele item.

**Mínimo adversarial: 8 buscas adversariais total.**

---

## Step 2.2 — Execução das buscas

### Wave 1 — Buscas paralelas via spawn_run

Usar `spawn_run` para executar buscas em paralelo (max 3 subagents simultâneos):

```
spawn_run com tasks array:
- Cada task = um batch de 8-12 buscas do search plan
- Subagent usa web_search para descobrir URLs
- Subagent usa web_fetch para extrair conteúdo
- Retorna lista de fontes encontradas com metadata
```

**Template de task para cada fetcher:**

```
RESEARCH QUERY: <conteúdo de query.md>

BATCH: <lista de search queries deste batch>

INSTRUÇÕES:
1. Para cada query no batch, executar web_search
2. Dos resultados, selecionar top 5-8 URLs mais relevantes
3. Para cada URL selecionada, executar web_fetch (mode: selective)
4. Extrair: título, URL, resumo do conteúdo relevante, stance (pro/contra/neutro)
5. Retornar JSON com todas as fontes encontradas

OUTPUT: JSON array com {url, title, summary, stance, atomic_items_covered, lens}
```

### Consolidação Wave 1

Após todos os fetchers retornarem:
1. Coletar todos os resultados dos `[Subagent completion event]`
2. Deduplicar URLs
3. Escrever fontes para `~/.kiro/crew/workspace/research/<vault_tag>/sources/`
4. Atualizar `temp/sources-collected.json`

---

## Step 2.3 — Coverage check (MANDATORY)

Após Wave 1:

1. **Mapear fontes → atomic items**
   Para cada item na decomposição, contar fontes:
   - **Well-covered** (4+ fontes)
   - **Adequate** (2-3 fontes)  
   - **Thin** (1 fonte)
   - **Uncovered** (0 fontes)

2. **Wave 2 para gaps**
   Para cada item `thin` ou `uncovered`:
   - Gerar 2-3 buscas targeted
   - Spawn 1-2 fetchers com foco cirúrgico

3. **Escrever coverage report**
   `~/.kiro/crew/workspace/research/<vault_tag>/temp/coverage-gaps.md`:
   ```markdown
   ## Coverage Report
   
   | Atomic Item | Status | Source Count | Sources |
   |---|---|---|---|
   | Sub-Q1 | well-covered | 5 | [s1, s2, s3, s4, s5] |
   | Sub-Q2 | thin | 1 | [s6] |
   | Entity: X | uncovered | 0 | - |
   
   ### Gaps flagged
   - Entity X: ZERO sources after Wave 2
   ```

---

## Step 2.4 — Utility scoring

Antes de finalizar, score cada fonte (0-3 por dimensão, max 18):

1. **Authority:** Primary data/gov/academic (3) > report (2) > journalism (1) > blog (0)
2. **Novelty:** Perspectiva única (3) > overlap parcial (1) > redundante (0)
3. **Stance diversity:** Adversarial (3) > mixed (2) > neutro (1) > same-stance (0)
4. **Coverage:** Item uncovered (3) > thin (2) > adequate (1) > well-covered (0)
5. **Redundancy:** Conteúdo novel (3) > possibly overlap (1) > rewrite certo (0)
6. **Freshness:** Últimos 12mo (3) > 1-3y (2) > 3-5y (1) > older (0)

Escrever `~/.kiro/crew/workspace/research/<vault_tag>/temp/scored-sources.md`.

---

## Step 2.5 — Evidence redundancy audit

**Goal:** detectar quando N fontes são realmente 1 fonte em N roupagens.

1. Agrupar fontes por overlap de conteúdo (>60% citações compartilhadas = derivativas)
2. Identificar fonte canônica upstream de cada cluster
3. Marcar fontes derivativas (não remover, apenas descontar na cobertura)
4. Se algum item cair abaixo de 2 fontes independentes → Wave 3

Escrever `~/.kiro/crew/workspace/research/<vault_tag>/temp/redundancy-audit.md`.

---

## Source targets

| Tier | Min sources | Target | Fetchers/wave | Waves |
|------|-------------|--------|---------------|-------|
| light | 15 | 25 | 2 | 1 |
| full | 30 | 50 | 3 | 2-3 |

---

## Output artifacts

Ao final do step, devem existir:
- `temp/search-plan.md` — plano de buscas das 3 lentes
- `temp/coverage-gaps.md` — report de cobertura
- `temp/scored-sources.md` — fontes com utility scores
- `temp/redundancy-audit.md` — análise de redundância
- `sources/*.md` — notas individuais por fonte (ou `sources.json` consolidado)

---

## Exit criteria

- Mínimo de fontes atingido (per tier)
- Coverage check sem items `uncovered` (thin é aceitável)
- Todos os artifacts de output escritos

Se faltar após 2 waves, prosseguir mas garantir que `coverage-gaps.md` lista o que falta.

---

## Spawn pattern reference

```python
# Wave 1 - 3 fetcher batches paralelos
spawn_run(tasks=[
    "Fetch batch 1: [queries 1-12]. Query file: <path>. Output JSON.",
    "Fetch batch 2: [queries 13-24]. Query file: <path>. Output JSON.",
    "Fetch batch 3: [queries 25-36]. Query file: <path>. Output JSON."
])

# STOP após spawn_run - aguardar [Subagent completion event]

# Após receber todos os events:
# 1. Consolidar resultados
# 2. Run coverage check
# 3. Se gaps, spawn Wave 2
```

---

## Next step

Após completar:
- **light tier:** Pular para drafting final
- **full tier:** Invocar `hyr-contra` (contradiction graph analysis)
