# AI-Assisted Scrum Delivery — Engagement Operating Manual

This repository is a **reusable base** for running AI-assisted Scrum delivery on client engagements. It stays pristine: it ships only reusable tooling (this manual, the playbook, specialized agents, and output templates). **All project-specific data lives under `src/` and is gitignored** — so one clone serves many projects.

> Full model: `playbook/PLAYBOOK.md`. This file is the quick operating manual.

## Engagement workflow

1. **Create the workspace:** `src/<engagement>/` with `request/` and `delivery/` subfolders.
2. **Add the request:** put the raw client request in `src/<engagement>/request/`.
3. **Classify:** **greenfield** (new build) vs **inherited** (existing/takeover) — see `playbook/greenfield-vs-inherited.md`.
4. **Run agents per step:** follow the **Step-by-step run order** below — it maps each numbered Greenfield/Inherited step to its agent and output template. Write each artifact to `src/<engagement>/delivery/`.
5. **Clone the project repo:** into `src/<engagement>/<project-repo>/`. Durable project docs (its own README, CLAUDE.md, ADRs) and code/tests go INSIDE that repo, not in `delivery/`. For **inherited** engagements the first agents (Inherited Steps 1–2) run from `request/` alone — the repo is cloned only once access is granted, so an empty `<project-repo>/` early on is expected, not a blocker.

Nothing project-specific is ever committed to this playbook repo.

## Agents

| Agent | Use it for | Produces | Human review owner |
|-------|-----------|----------|--------------------|
| `product-discovery` | Intake & discovery; product/stabilization goal | Request/Takeover Brief, Discovery Workshop Plan, Meeting Summary, Goal Draft, Access Checklist | PO / BA |
| `product-backlog` | Epics, stories, acceptance criteria, stabilization backlog | Initial/Stabilization Backlog, Refined Story Pack | Product Owner |
| `scrum-planning` | Sprint Planning, Daily Scrum, Sprint Review | Sprint Planning Support Pack, Daily Scrum Summary, Sprint Review Pack | Scrum Team |
| `implementation` | Build stories, fix bugs, refactor, codebase analysis | Implementation Pack, Safe Change Pack, Architecture/System/Codebase docs | Developer / Tech Lead |
| `code-review` | First-pass PR review before human review | AI PR Review Report | Human reviewer / Tech Lead |
| `qa-test-design` | Test cases, edge cases, regression packs | QA Test Pack, Regression Test Pack | QA |
| `test-automation` | Automated tests (written into the project repo) | Test code in project repo | QA Automation / Developers |
| `devops` | CI/CD, deployment, release readiness | Release Readiness Pack | DevOps |
| `security-review` | Security review of code/arch/config | Security Review Report | Security Owner / Tech Lead |
| `documentation` | Project docs, ADRs, business-rule recovery, modernization | Business Rule Recovery, Modernization Roadmap, project docs | Developers / BA / PM |
| `support-incident` | Triage support tickets & incidents | Triage notes in delivery/ | Support / Developers / PM |
| `retrospective-insights` | Analyze Sprint patterns & improvements | Retrospective Insights Pack | Scrum Master / Scrum Team |

Invoke an agent with the Task/Agent tool (`subagent_type` = agent name), or let Claude auto-route via the agent's `description`. Each agent file lists the exact template(s) it fills.

## Step-by-step run order

The authoritative step sequence lives in `playbook/PLAYBOOK.md` (§5 greenfield, §6 inherited). These tables map each step to the agent that drives it and the template it fills.

### Greenfield (new build)

| Step | Scrum activity | Agent | Output template | Command |
|------|----------------|-------|-----------------|---------|
| 1 | Client request | `product-discovery` | `templates/greenfield/project-request-brief.md` | `/intake` |
| 2 | Discovery prep | `product-discovery` | `templates/greenfield/discovery-workshop-plan.md` | `/discovery-prep` |
| 3 | Discovery meetings | `product-discovery` | `templates/greenfield/discovery-meeting-summary.md` | `/discovery-summary` |
| 4 | Product Goal | `product-discovery` | `templates/greenfield/product-goal-draft.md` | `/product-goal` |
| 5 | Initial backlog | `product-backlog` | `templates/greenfield/initial-product-backlog-pack.md` | `/initial-backlog` |
| 6 | Architecture foundation | `implementation` (+ `security-review`, `documentation`) | `templates/greenfield/architecture-technical-foundation-pack.md` | `/architecture` |
| 7 | Backlog refinement | `product-backlog` | `templates/shared/refined-story-pack.md` | `/refine` |
| 8 | Sprint Planning | `scrum-planning` | `templates/shared/sprint-planning-support-pack.md` | `/sprint-plan` |
| 9 | Sprint execution | `implementation` | `templates/shared/implementation-pack.md` | `/execution` |
| 10 | Daily Scrum | `scrum-planning` | `templates/shared/daily-scrum-support-summary.md` | `/daily-scrum` |
| 11 | Code review | `code-review` | `templates/shared/ai-pr-review-report.md` | `/pr-review` |
| 12 | QA & testing | `qa-test-design` (+ `test-automation`) | `templates/shared/qa-test-pack.md` | `/qa` |
| 13 | Sprint Review | `scrum-planning` | `templates/shared/sprint-review-pack.md` | — (manual) |
| 14 | Retrospective | `retrospective-insights` | `templates/shared/retrospective-insights-pack.md` | — (manual) |
| 15 | Release readiness | `devops` | `templates/shared/release-readiness-pack.md` | — (manual) |

### Inherited (existing / takeover)

| Step | Focus | Agent | Output template | Command |
|------|-------|-------|-----------------|---------|
| 1 | Takeover request | `product-discovery` | `templates/inherited/takeover-request-brief.md` | `/intake` |
| 2 | Access & information | `product-discovery` | `templates/inherited/access-information-checklist.md` | `/access-checklist` |
| 3 | System assessment | `implementation` | `templates/inherited/initial-system-assessment.md` | `/system-assessment` |
| 4 | Stabilization Goal | `product-discovery` | `templates/inherited/inherited-project-goal-draft.md` | `/stabilization-goal` |
| 5 | Business-rule recovery | `documentation` | `templates/inherited/business-rule-recovery-report.md` | `/recover-rules` |
| 6 | Codebase mapping | `implementation` | `templates/inherited/codebase-architecture-map.md` | `/map-codebase` |
| 7 | Stabilization backlog | `product-backlog` | `templates/inherited/stabilization-product-backlog.md` | `/stabilization-backlog` |
| 8 | Backlog refinement | `product-backlog` | `templates/inherited/inherited-refined-story-pack.md` | `/refine` |
| 9 | Sprint Planning | `scrum-planning` | `templates/inherited/inherited-sprint-planning-support-pack.md` | `/sprint-plan` |
| 10 | Safe execution | `implementation` | `templates/inherited/safe-change-pack.md` | `/execution` |
| 11 | Regression QA | `qa-test-design` (+ `test-automation`) | `templates/inherited/regression-test-pack.md` | `/qa` |
| 12 | Sprint Review | `scrum-planning` | `templates/inherited/inherited-sprint-review-pack.md` | — (manual) |
| 13 | Retrospective | `retrospective-insights` | `templates/inherited/inherited-retrospective-insights-pack.md` | — (manual) |
| 14 | Modernization | `documentation` (+ Architect) | `templates/inherited/modernization-roadmap.md` | — (manual) |

Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`. The recurring sprint commands `/execution`, `/daily-scrum`, `/pr-review`, and `/qa` drive these for both tracks (see Slash commands below).

## Slash commands

The intake + discovery, setup + planning, and recurring sprint-execution + QA phases are automated by commands in `.claude/commands/`. Each takes the engagement slug as its argument (recurring commands also take an item id), orchestrates in the main conversation (so it can ask you questions and track progress in `src/<eng>/engagement.md`), and delegates the actual artifact to the mapped agent.

- `/intake <eng>` — bootstrap the engagement, classify greenfield/inherited, produce the first brief.
- Greenfield discovery → setup/planning: `/discovery-prep` → `/discovery-summary` → `/product-goal` → `/initial-backlog` → `/architecture` → `/refine` → `/sprint-plan`.
- Inherited discovery → setup/planning: `/access-checklist` → `/system-assessment` → `/stabilization-goal` → `/recover-rules` → `/map-codebase` → `/stabilization-backlog` → `/refine` → `/sprint-plan`.
- Recurring per-sprint (both scenarios): `/execution <eng> <ticket>`, `/daily-scrum <eng> [date]`, `/pr-review <eng> <pr>`, `/qa <eng> <story>` — run repeatedly, keyed by ticket / PR / story / date. They write item-keyed artifacts under `src/<eng>/delivery/<activity>/` and append to an `## Activity log` in `engagement.md` rather than ticking the linear checklist.

`/refine`, `/sprint-plan`, `/execution`, and `/qa` are scenario-aware — they read `engagement.md` and pick the right template for the track (`/daily-scrum` and `/pr-review` are shared). The recurring commands set `phase: execution` and a `sprint:` marker on first run; to start a new sprint, bump `sprint:` in `engagement.md`. The remaining per-sprint steps (greenfield steps 13+, inherited steps 12+ — sprint review, retrospective, release / modernization) have no command yet — run their agents manually per the run-order tables above.

## Templates (output packs)

- **Shared** (both scenarios): `templates/shared/`
- **Greenfield**: `templates/greenfield/`
- **Inherited**: `templates/inherited/`

Copy the relevant template into `src/<engagement>/delivery/` (or the project repo for durable docs) and fill it.

## Governance guardrails (always apply)

1. AI cannot approve its own work — humans approve.
2. AI-generated code requires human review before merge.
3. AI-generated requirements require PO/BA validation.
4. AI-generated tests require QA/developer validation.
5. AI-generated client communication requires PM/PO review.
6. Never paste secrets, credentials, or production data into AI tools.
7. Every AI output separates: **Observed facts · Assumptions · Risks · Recommendations · Open questions.**

Full rules: `playbook/governance.md`.

## Definition of Ready / Done

- **Ready:** business goal, user role, expected behavior, acceptance criteria, dependencies, edge cases, risks, test scenarios, and open questions are clear. Full list: `playbook/definition-of-ready.md`.
- **Done:** acceptance criteria pass, code implemented, tests added/updated, AI self-review + human review done, QA/security checked where needed, docs updated, no critical regression risk, increment usable. Full list: `playbook/definition-of-done.md`.

## Path convention

`<engagement>` = a short slug for the client/project (e.g. `acme-portal`). Everything for that engagement lives in `src/<engagement>/`.
