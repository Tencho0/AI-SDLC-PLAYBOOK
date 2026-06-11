# AI-SDLC Playbook — Development Roadmap

> ⚠️ **TEMPORARY — DELETE THIS FILE WHEN THE BUILD IS COMPLETE.**
> This is build-process scaffolding, not part of the delivered playbook. It tracks the
> multi-pass build so we know what to build and in which order. **Delete it once command
> coverage for the full run order is shipped (Passes 3–5 merged).** Passes 6–7 (skills,
> plugin) are optional and do not block deletion. The permanent record of *what* was built
> and *why* lives in the per-pass specs and plans under `docs/superpowers/`.

**Goal:** a reusable, pristine base repo that automates AI-assisted Scrum delivery across the full model, for greenfield **and** inherited projects.

**Per-pass workflow (the rhythm):** brainstorm → spec (`docs/superpowers/specs/`) → plan (`docs/superpowers/plans/`) → build (parallel Workflow) → audit + code-review → fix → merge + push. Invariants: playbook stays pristine (all project data under gitignored `src/`); commits carry no Claude co-author; each pass ends with the verifier green.

## Build order

| Pass | Scope | Delivers | Status |
|------|-------|----------|--------|
| **1 — Scaffold** | Foundation | `.docx`→`playbook/` Markdown, 12 agents, 30 templates, `CLAUDE.md` brain, `.gitignore`, `scripts/verify-scaffold.ps1` | ✅ Done |
| **2 — Intake + Discovery** | Run-order steps 1–4, both tracks | `/intake` + `/discovery-prep` / `/discovery-summary` / `/product-goal` (GF) and `/access-checklist` / `/system-assessment` / `/stabilization-goal` (INH); `engagement.md` state file | ✅ Done |
| **3 — Setup & Planning** | Steps 5–8 (GF) / 5–9 (INH) — *linear, once per engagement* | GF: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`. INH: `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, `/refine`, `/sprint-plan` | ✅ Done |
| **4 — Sprint Execution & QA** | Steps 9–12 (GF) / 10–11 (INH) — *recurring per ticket/PR* | execution, daily-scrum, code-review, QA commands. **Needs a new recurring-command shape first** (see Open decisions). | ⏭️ Next |
| **5 — Review, Retro, Release / Modernization** | Steps 13–15 (GF) / 12–14 (INH) — *per sprint / milestone* | GF: sprint-review, retrospective, release-readiness. INH: sprint-review, retrospective, modernization-roadmap | 📋 Planned |
| **6 — Skills** *(optional)* | Cross-cutting | Reusable multi-step skills (e.g. a `/status` / `/next` engagement navigator) | 💡 Backlog |
| **7 — Plugin packaging** *(optional)* | Portability | Package agents + commands as an installable Claude Code plugin so they drop into any repo without cloning the base | 💡 Backlog |

**Ordering rationale:** passes follow the delivery model's own sequence (discover → plan → build → review → release). Pass 3 finishes the *linear* gated chain using the proven Pass-2 pattern. Passes 4–5 cover the *recurring* per-sprint events. Skills and plugin packaging repackage proven content, so they come last.

## Definition of "complete" (deletion trigger)

Delete this file once **Passes 3, 4, and 5 are merged** — i.e. every step in both run-order tables (`CLAUDE.md`) has a command instead of "— (manual)". At that point the playbook is fully built out and this build-tracker has served its purpose.

## Open decisions (resolve before the pass that needs them)

- **Recurring-command model (Pass 4):** code-review / QA / execution run many times per engagement; they should be parameterized by ticket / PR / sprint rather than ticking a one-time `engagement.md` checklist. Short brainstorm before building Pass 4.
- **`engagement.md` evolution:** as later phases land, the state file likely needs a "current sprint / phase" notion beyond the linear step list.

## Status log

- Pass 1 merged + pushed; repo marked as a GitHub template.
- Pass 2 merged + pushed; built, audited (fidelity/consistency/usability), and code-reviewed (15 findings fixed) at the code level.
- Pass 3 built on branch `setup-planning-commands`: 7 setup & planning commands added (`/initial-backlog`, `/architecture`, `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, scenario-aware `/refine` + `/sprint-plan`); `/intake` seed extended to the full linear chain (GF 1–8 / INH 1–9); verifier extended to 14 commands and green; audited and code-reviewed. Roadmap kept (deletion waits for Passes 4–5).
