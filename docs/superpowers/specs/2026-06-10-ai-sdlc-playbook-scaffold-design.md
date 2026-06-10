# AI-SDLC Playbook Scaffold — Design Spec

- **Date:** 2026-06-10
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Source material:** `AI-Assisted Scrum Delivery Model` (Word doc, to be converted to Markdown and deleted)

---

## 1. Goal & Context

Turn the `AI-SDLC-PLAYBOOK` repo into a **pristine, reusable base** that an outsourcing team clones (or copies) at the start of every engagement to eliminate per-project AI setup. The repo ships the operating manual, specialized AI subagents, and the full library of output templates derived from the AI-Assisted Scrum Delivery Model. A team member clones it, drops a client request into `src/`, and immediately has working Claude Code agents + templates to run the model's steps for **both greenfield and inherited projects**.

**Primary success criterion:** opening Claude Code in a fresh clone gives you — with zero manual wiring — the governance rules, the 12 specialized agents, the output templates, and a documented engagement workflow.

**Hard constraint:** the playbook repo must never commit any project-specific data, so a single repo (or template) serves many projects. All project-specific data — the client request, generated artifacts, and the project's own git repo — lives under `src/`, which is gitignored.

This is **pass 1 = scaffold only**. Orchestration slash-commands, skills, and plugin packaging are explicitly deferred (see §3).

## 2. Decisions (locked)

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **Native Claude Code** form: subagents in `.claude/agents/`, reference docs, `CLAUDE.md` brain | Zero manual wiring per project; agents auto-discovered |
| D2 | **Scaffold-first** — structure + 12 agent stubs + ~30 templates + reference docs. No orchestration commands yet | Get the foundation right before automating flow |
| D3 | **Operating-manual-driven** organization (Approach 1): root `CLAUDE.md` is the brain | Maximizes the speed-up payoff |
| D4 | **Playbook repo stays pristine** — only reusable tooling is committed | One base serves many projects |
| D5 | **All project-specific data under `src/`** (request + delivery artifacts + project repo), fully gitignored | Keeps the base clean and reusable |
| D6 | **Gitignored clone** for the project's own repo inside `src/` | Clean separation, no git-in-git, project keeps its own history |
| D7 | **Convert `.docx` → clean Markdown**, then **delete the `.docx`** | Markdown is the version-controlled source of truth |
| D8 | **Durable project docs** (project `README.md`, `CLAUDE.md`, ADRs) are written **into the project repo**; throwaway analysis artifacts stay in `src/<engagement>/delivery/` | Client-owned docs travel with the code; analysis stays separate |

## 3. Non-goals / Deferred to later passes

- **Slash commands** (`/intake`, `/discovery`, …) that orchestrate agents. The structure leaves a clean slot (`.claude/commands/`) for them.
- **Skills** for multi-step procedures.
- **Plugin packaging** (`plugin.json` / marketplace) for portability into arbitrary repos — a future evolution once content is proven.
- Deep tuning of agent system prompts beyond usable-stub quality.
- Any actual client/project content.

## 4. Repo structure (the pristine playbook)

```
AI-SDLC-PLAYBOOK/                  ← PRISTINE & REUSABLE. Zero project data ever committed.
├── CLAUDE.md                      ← operating manual (auto-loaded every session)
├── README.md                      ← "how to start a new engagement"
├── .gitignore                     ← ignores all of src/ except its README
├── playbook/                      ← canonical reference (from the .docx, then .docx deleted)
│   ├── PLAYBOOK.md                ← full 14-section model in Markdown
│   ├── governance.md              ← the 7 governance rules
│   ├── definition-of-ready.md     ← AI-enhanced DoR checklist
│   ├── definition-of-done.md      ← AI-enhanced DoD checklist
│   └── greenfield-vs-inherited.md ← comparison table + both flow overviews
├── .claude/
│   └── agents/                    ← 12 usable subagent stubs
│       ├── product-discovery.md
│       ├── product-backlog.md
│       ├── scrum-planning.md
│       ├── implementation.md
│       ├── code-review.md
│       ├── qa-test-design.md
│       ├── test-automation.md
│       ├── devops.md
│       ├── security-review.md
│       ├── documentation.md
│       ├── support-incident.md
│       └── retrospective-insights.md
├── templates/                     ← ~30 output-pack templates
│   ├── shared/                    ← used in both scenarios (10)
│   ├── greenfield/                ← discovery → product goal → backlog → architecture (6)
│   └── inherited/                 ← takeover → assessment → stabilization → modernization (14)
└── src/                           ← GITIGNORED workspace — ALL project-specific data lives here
    └── README.md                  ← the ONLY committed file under src/; documents the layout
```

## 5. `src/` runtime layout & `.gitignore`

At runtime (all gitignored, supports multiple engagements side-by-side):

```
src/
├── README.md                      ← committed (explains this convention)
└── <engagement-name>/             ← one folder per client/project  (gitignored)
    ├── request/                   ← drop the raw client request here (intake input)
    ├── delivery/                  ← generated artifacts: briefs, backlogs, assessments, reports
    └── <project-repo>/            ← the project's OWN git repo, cloned here (keeps its history)
```

`.gitignore`:
```
# Keep the playbook pristine — no project-specific data is ever committed.
src/*
!src/README.md
```

Effect: project code, requests, and delivery artifacts are never tracked by the playbook. Only reusable tooling + `src/README.md` are committed.

## 6. `CLAUDE.md` — the brain (auto-loaded every session)

A concise operating manual (not a copy of the playbook). Sections:

1. **What this repo is** — one paragraph: a reusable AI-assisted Scrum delivery base; pristine; project data lives in `src/`.
2. **Engagement workflow** — numbered:
   1. Create `src/<engagement>/` (with `request/` and `delivery/` subfolders).
   2. Put the raw client request in `src/<engagement>/request/`.
   3. Classify the engagement: **greenfield** vs **inherited** (link to `playbook/greenfield-vs-inherited.md`).
   4. Run the relevant agents for each step; write artifacts to `src/<engagement>/delivery/`.
   5. Clone the project's repo into `src/<engagement>/<project-repo>/`; durable project docs go inside that repo.
3. **Agent index** — table: agent name · when to use · primary output pack(s) · human review owner.
4. **Template index** — where each pack lives (`templates/shared|greenfield|inherited/`).
5. **Governance guardrails** (condensed from the 7 rules) — AI cannot approve its own work; AI code/requirements/tests/client-comms require human validation; never paste secrets or production data; every AI output must separate **Observed facts / Assumptions / Risks / Recommendations / Open questions**. Links to `playbook/governance.md`.
6. **Definition of Ready / Done** — condensed checklists with links to the full versions.
7. **Path convention** — uses an `{engagement}` placeholder so nothing is hard-coded.

## 7. `playbook/` — canonical reference

Convert the `.docx` to clean Markdown, then **delete the `.docx`**. Split into:

- **`PLAYBOOK.md`** — the full 14-section model (executive summary, vision, principles, agents, shared flow, greenfield 15 steps, inherited 14 steps, event/artifact mapping, rollout, governance, operating model).
- **`governance.md`** — the 7 governance rules (extracted for precise linking).
- **`definition-of-ready.md`** — the 10-point AI-enhanced DoR.
- **`definition-of-done.md`** — the 10-point AI-enhanced DoD.
- **`greenfield-vs-inherited.md`** — the §11 comparison table + the two flow overviews (§5.2, §6.2).

Conversion must preserve all numbered lists, the role/owner tables, and the step structure. Tables that don't render as clean source tables in the raw `.docx` extraction (the doc stores some as line-by-line cells) must be reconstructed as proper Markdown tables.

## 8. `.claude/agents/` — 12 usable subagent stubs

### Anatomy of every agent file

```
---
name: <kebab-case, matches filename>
description: <what it does + trigger cues so Claude auto-routes to it>
tools: <scoped per agent — see below>
---

# <Agent Title>

## Purpose
<one paragraph from the doc>

## When to use / primary users
<which Scrum step(s) and which roles>

## Inputs
<request file, codebase in src/, meeting notes, prior delivery artifacts, …>

## Outputs
<links to the exact template(s) in templates/… that it fills, written into src/<engagement>/delivery/ (or into the project repo for durable docs)>

## Governance reminders
- Human review owner: <role>
- Separate Observed facts / Assumptions / Risks / Recommendations / Open questions
- <any agent-specific rule, e.g. "AI cannot approve its own PR" for code-review>
```

**Tool scoping defaults:** analysis/authoring agents (discovery, backlog, scrum-planning, qa-test-design, security-review, documentation, retrospective-insights, support-incident) → `Read, Grep, Glob, Write, WebSearch, WebFetch`. Code-touching agents (implementation, test-automation, devops) → add `Edit, Bash`. `code-review` → `Read, Grep, Glob, Bash` (no Edit — it reviews, it doesn't fix). Final tool lists confirmed during implementation.

### The 12 agents (from §3.1) and their primary output packs

| Agent | Purpose (from doc) | Primary output pack(s) | Human review owner |
|-------|--------------------|------------------------|--------------------|
| `product-discovery` | Understands client goals, problems, initial scope | Project Request Brief, Discovery Workshop Plan, Discovery Meeting Summary, Product Goal Draft / Takeover Request Brief, Access & Information Checklist, Inherited Project Goal Draft | PO / BA (Sales, Delivery Mgr, Architect contribute) |
| `product-backlog` | Creates/refines epics, stories, acceptance criteria | Initial Product Backlog Pack, Refined Story Pack / Stabilization Product Backlog, Inherited Refined Story Pack | Product Owner |
| `scrum-planning` | Sprint Planning, Sprint Goal drafting, risk analysis | Sprint Planning Support Pack, Daily Scrum Support Summary, Sprint Review Pack / Inherited Sprint Planning Support Pack, Inherited Sprint Review Pack | Scrum Team / Scrum Master |
| `implementation` | Helps Developers implement stories, fix bugs, refactor | Implementation Pack / Safe Change Pack; Architecture & Technical Foundation Pack, Initial System Assessment, Codebase & Architecture Map | Developer / Tech Lead |
| `code-review` | First-pass PR review | AI PR Review Report | Human reviewer / Tech Lead |
| `qa-test-design` | Manual test cases, edge cases, regression checks | QA Test Pack / Regression Test Pack | QA |
| `test-automation` | Helps create automated tests | Automated test code **into the project repo** (no standalone pack) | QA Automation / Developers |
| `devops` | CI/CD, deployments, environments, logs | Release Readiness Pack (deployment checklist, rollback) | DevOps |
| `security-review` | Reviews code/architecture/config for security risks | Security Review Report | Security Owner / Tech Lead |
| `documentation` | Creates/updates project documentation | Business Rule Recovery Report, Modernization Roadmap; durable project docs (README, CLAUDE.md, ADRs) **into the project repo** | Developers / BA / PM |
| `support-incident` | Triages support tickets and incidents | Incident triage notes into `delivery/` (lightweight; no standalone pack) | Support / Developers / PM |
| `retrospective-insights` | Analyzes Sprint patterns and improvement opportunities | Retrospective Insights Pack / Inherited Retrospective Insights Pack | Scrum Master / Scrum Team |

Notes: `test-automation` and `support-incident` primarily produce code/notes rather than a numbered doc pack, so they get richer in-agent guidance instead of a dedicated template. Architecture/recovery packs are cross-role; the table lists the **primary** producing agent — other agents contribute and the listed human owner approves.

## 9. `templates/` — the ~30 output packs

### Anatomy of every template file

```
---
pack: <Pack Name>
scenario: shared | greenfield | inherited
produced-by: <agent name>
review-owner: <role>
source: <doc section, e.g. "Greenfield Step 5">
---

# <Pack Name>

> What this is / when to produce it (1–2 lines).

## 1. <Section from doc's numbered list>
<one-line "what goes here" guidance>

## 2. <…>
...
```

Headings come verbatim from the doc's numbered list for each pack. Every template ends with a **Governance footer**: "Observed facts / Assumptions / Risks / Recommendations / Open questions" and the human review owner.

### Full enumeration (30 templates)

**`templates/shared/` (10)** — used in both scenarios:

| File | Pack | Produced by | Review owner | Source |
|------|------|-------------|--------------|--------|
| `refined-story-pack.md` | Refined Story Pack | product-backlog | PO / BA | GF Step 7 / §7.1 |
| `sprint-planning-support-pack.md` | Sprint Planning Support Pack | scrum-planning | Scrum Team | GF Step 8 / §7.2 |
| `daily-scrum-support-summary.md` | Daily Scrum Support Summary | scrum-planning | Developers | GF Step 10 / §7.3 |
| `implementation-pack.md` | Implementation Pack | implementation | Developer / Tech Lead | GF Step 9 / §7.4 |
| `ai-pr-review-report.md` | AI PR Review Report | code-review | Human reviewer / Tech Lead | GF Step 11 |
| `qa-test-pack.md` | QA Test Pack | qa-test-design | QA | GF Step 12 |
| `sprint-review-pack.md` | Sprint Review Pack | scrum-planning | PO / Scrum Team | GF Step 13 / §7.5 |
| `retrospective-insights-pack.md` | Retrospective Insights Pack | retrospective-insights | Scrum Team | GF Step 14 / §7.6 |
| `release-readiness-pack.md` | Release Readiness Pack | devops | PO / QA / DevOps / PM | GF Step 15 |
| `security-review-report.md` | Security Review Report | security-review | Security Owner / Tech Lead | §3.1 + DoD security checks |

**`templates/greenfield/` (6):**

| File | Pack | Produced by | Review owner | Source |
|------|------|-------------|--------------|--------|
| `project-request-brief.md` | Project Request Brief | product-discovery | Sales / Delivery Mgr / Architect / PO-BA | GF Step 1 |
| `discovery-workshop-plan.md` | Discovery Workshop Plan | product-discovery | BA / Architect / PM / QA | GF Step 2 |
| `discovery-meeting-summary.md` | Discovery Meeting Summary | product-discovery | BA / PM / Architect / Client | GF Step 3 |
| `product-goal-draft.md` | Product Goal Draft | product-discovery | PO / Client / Delivery Mgr / Architect | GF Step 4 |
| `initial-product-backlog-pack.md` | Initial Product Backlog Pack | product-backlog | PO / BA / QA / Devs / Architect | GF Step 5 |
| `architecture-technical-foundation-pack.md` | Architecture & Technical Foundation Pack | implementation (+ security-review, documentation) | Architect / Tech Lead / DevOps / Security / QA | GF Step 6 |

**`templates/inherited/` (14):**

| File | Pack | Produced by | Review owner | Source |
|------|------|-------------|--------------|--------|
| `takeover-request-brief.md` | Takeover Request Brief | product-discovery | Sales / Delivery Mgr / Architect / PM | INH Step 1 |
| `access-information-checklist.md` | Access & Information Checklist | product-discovery (+ devops) | PM / Tech Lead / DevOps / Security | INH Step 2 |
| `initial-system-assessment.md` | Initial System Assessment | implementation | Tech Lead / Architect / Devs / PM | INH Step 3 |
| `inherited-project-goal-draft.md` | Inherited Project Goal Draft | product-discovery | PO / Client / Tech Lead / QA | INH Step 4 |
| `business-rule-recovery-report.md` | Business Rule Recovery Report | documentation | BA / Devs / QA / Client | INH Step 5 |
| `codebase-architecture-map.md` | Codebase & Architecture Map | implementation | Architect / Tech Lead / DevOps / QA | INH Step 6 |
| `stabilization-product-backlog.md` | Stabilization Product Backlog | product-backlog | PO / Tech Lead / QA / DevOps / Client | INH Step 7 |
| `inherited-refined-story-pack.md` | Inherited Refined Story Pack | product-backlog | PO / BA / Devs / QA | INH Step 8 |
| `inherited-sprint-planning-support-pack.md` | Inherited Sprint Planning Support Pack | scrum-planning | PO / Devs / QA / Scrum Master / Tech Lead | INH Step 9 |
| `safe-change-pack.md` | Safe Change Pack | implementation | Developer / Tech Lead / QA / BA | INH Step 10 |
| `regression-test-pack.md` | Regression Test Pack | qa-test-design | QA / Devs / BA / Support | INH Step 11 |
| `inherited-sprint-review-pack.md` | Inherited Sprint Review Pack | scrum-planning | PO / Client / Scrum Team | INH Step 12 |
| `inherited-retrospective-insights-pack.md` | Inherited Retrospective Insights Pack | retrospective-insights | Scrum Team / Tech Lead | INH Step 13 |
| `modernization-roadmap.md` | Modernization Roadmap | documentation (+ architect) | PO / Architect / Client | INH Step 14 |

## 10. Artifact location rules

- **Working analysis artifacts** (briefs, backlogs, assessments, review reports, retro insights) → `src/<engagement>/delivery/`.
- **Durable project docs** (the project's own `README.md`, `CLAUDE.md`, ADRs, architecture docs) → written **into the project repo** at `src/<engagement>/<project-repo>/`, so they travel with the code and are owned by the client/team.
- **Automated tests / code** (`test-automation`, `implementation`) → into the project repo.
- Nothing project-specific is ever written outside `src/`.

## 11. Verification (structural — it's a scaffold, no app to run)

1. Every `.claude/agents/*.md` has valid YAML frontmatter and `name` matches its filename.
2. Every template referenced by an agent or by `CLAUDE.md` exists (no broken relative links).
3. All 30 templates exist with the agreed frontmatter + the doc-derived headings + governance footer.
4. `.gitignore` excludes everything under `src/` except `src/README.md` (verify: `git status` after creating a dummy `src/<x>/request/foo.txt` shows nothing).
5. The `.docx` is deleted and `playbook/PLAYBOOK.md` (+ split docs) exist and preserve all numbered lists/tables.
6. A short verification checklist is included; optionally a tiny frontmatter/link validation script.

## 12. Implementation phases (suggested build order)

1. **Convert & split** the `.docx` → `playbook/*.md`; delete the `.docx`.
2. **Scaffold structure** — folders, `.gitignore`, `src/README.md`, root `README.md`.
3. **Templates** — generate all 30 from the doc's numbered packs (parallelizable).
4. **Agents** — write the 12 subagent stubs, linking to their templates.
5. **`CLAUDE.md`** — author the brain (indexes reference the now-existing agents + templates).
6. **Verify** — run the structural checks in §11.

## 13. Assumptions & open questions

- **A1:** One playbook clone may host multiple engagements simultaneously under `src/<engagement>/`. The structure supports this; teams may also just re-clone per engagement.
- **A2:** `delivery/` artifacts are not version-controlled by the playbook. If a team wants them versioned, they commit them into the project repo or init a separate git in the engagement folder. (Out of scope for the scaffold.)
- **A3:** Agent system prompts are usable stubs, not deeply tuned; tuning happens as the team uses them.
- **Q1 (resolved):** Durable docs into the project repo, analysis into `delivery/` — confirmed by user.
- **Q2 (resolved):** Delete the `.docx` after conversion — confirmed by user.
