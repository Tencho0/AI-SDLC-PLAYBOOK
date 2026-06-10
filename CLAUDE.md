# AI-Assisted Scrum Delivery — Engagement Operating Manual

This repository is a **reusable base** for running AI-assisted Scrum delivery on client engagements. It stays pristine: it ships only reusable tooling (this manual, the playbook, specialized agents, and output templates). **All project-specific data lives under `src/` and is gitignored** — so one clone serves many projects.

> Full model: `playbook/PLAYBOOK.md`. This file is the quick operating manual.

## Engagement workflow

1. **Create the workspace:** `src/<engagement>/` with `request/` and `delivery/` subfolders.
2. **Add the request:** put the raw client request in `src/<engagement>/request/`.
3. **Classify:** **greenfield** (new build) vs **inherited** (existing/takeover) — see `playbook/greenfield-vs-inherited.md`.
4. **Run agents per step:** invoke the relevant agent (below); write each artifact to `src/<engagement>/delivery/`.
5. **Clone the project repo:** into `src/<engagement>/<project-repo>/`. Durable project docs (its own README, CLAUDE.md, ADRs) and code/tests go INSIDE that repo, not in `delivery/`.

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
