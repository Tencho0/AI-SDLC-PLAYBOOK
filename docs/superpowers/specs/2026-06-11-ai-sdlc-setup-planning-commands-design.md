# AI-SDLC Setup & Planning Slash Commands — Design Spec

- **Date:** 2026-06-11
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** `2026-06-11-ai-sdlc-intake-discovery-commands-design.md` (pass 2 — intake + discovery commands)

---

## 1. Goal & Context

Pass 2 added the orchestration layer for intake + discovery (run-order steps 1–4 in both
tracks): `/intake` plus the six per-scenario discovery step commands, backed by a
per-engagement `engagement.md` state file. **Pass 3 extends that same pattern to the
once-per-engagement Setup & Planning chain** — the linear, gated steps that run after
discovery and before the recurring per-sprint events.

**Scope:** the linear chain after discovery —
- **Greenfield:** step 5 → 6 → 7 → 8 (initial backlog → architecture → refinement → sprint planning).
- **Inherited:** step 5 → 6 → 7 → 8 → 9 (business-rule recovery → codebase mapping → stabilization backlog → refinement → sprint planning).

These are the steps currently marked `— (manual)` for 5–8 (GF) / 5–9 (INH) in the
`CLAUDE.md` run-order tables. Pass 3 gives each a command.

**Out of scope (still deferred to Pass 4–5):** the recurring per-sprint events — sprint
execution, daily scrum, code review, QA, sprint review, retrospective, release readiness /
modernization. Those run many times per engagement and need a different (recurring,
ticket/PR/sprint-keyed) command model, not a one-time `engagement.md` checklist tick.

**Success criterion:** after the discovery commands, a greenfield engagement can run
`/initial-backlog → /architecture → /refine → /sprint-plan`, and an inherited engagement can
run `/recover-rules → /map-codebase → /stabilization-backlog → /refine → /sprint-plan` — each
delegating to the mapped subagent, respecting human gates and prerequisites, and tracking
progress in `engagement.md`. The verifier stays green with the expanded command set.

## 2. Decisions (locked)

These three were settled in the brainstorm; the remaining decisions inherit Pass 2's pattern.

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **`/refine` and `/sprint-plan` are each a single scenario-aware command** (not two per-track names). They read `engagement.md`'s `scenario` and branch to the right template/output/step/next — like `/intake` branches. | One command per dual-track step matches the run-order tables; the user never has to pick a track-specific name. |
| D2 | **`/intake`'s seed is extended to the full linear chain** (GF steps 1–8, INH steps 1–9). Setup commands tick their line; if the line is absent (engagement seeded by the older 1–4 intake), they insert it in numeric order. | One authoritative step list; the full once-per-engagement roadmap is visible from day one; backward-compatible with existing engagements. |
| D3 | **`/architecture` delegates to `implementation` only** (the primary agent). `security-review` and `documentation` are noted as recommended follow-ups in the pack, not spawned by the command. | Keeps the invariant "one command → one named subagent"; consistent with every other command; the fan-out multi-agent model is Pass 4–5 territory. |
| D4 (inherited) | **Single-scenario commands keep the hard scenario guard**; scenario-aware commands (`/refine`, `/sprint-plan`) branch instead of rejecting. | Mirrors Pass 2: step commands guard, the front door branches. |
| D5 (inherited) | **Commands delegate to subagents** via the Task tool; they never re-implement agent logic. | Agent definitions remain the single source of behavior (DRY). |
| D6 (inherited) | **Prerequisite = the prior step's `delivery/` artifact exists (+ correct scenario)**; `/map-codebase` additionally requires a confirmed cloned repo (reusing `/system-assessment`'s repo detection). | Enforces the gated chain; produces nothing when a gate is unmet. |

## 3. Command set (7 new commands)

All live in `.claude/commands/<name>.md`. Each takes the engagement slug as `$ARGUMENTS`
(asks if omitted). Output filename = template basename, written to `src/<eng>/delivery/`.

| Command | Scenario | Step | Delegates to | Fills template → `delivery/<output>` | Prerequisite |
|---------|----------|------|--------------|--------------------------------------|--------------|
| `/initial-backlog <eng>` | greenfield | 5 | `product-backlog` | `greenfield/initial-product-backlog-pack.md` → `initial-product-backlog-pack.md` | step 4 done: `product-goal-draft.md` exists |
| `/architecture <eng>` | greenfield | 6 | `implementation` | `greenfield/architecture-technical-foundation-pack.md` → `architecture-technical-foundation-pack.md` | step 5 done: `initial-product-backlog-pack.md` exists |
| `/recover-rules <eng>` | inherited | 5 | `documentation` | `inherited/business-rule-recovery-report.md` → `business-rule-recovery-report.md` | step 4 done: `inherited-project-goal-draft.md` exists |
| `/map-codebase <eng>` | inherited | 6 | `implementation` | `inherited/codebase-architecture-map.md` → `codebase-architecture-map.md` | step 5 done: `business-rule-recovery-report.md` exists **AND** a cloned repo is present under `src/<eng>/` |
| `/stabilization-backlog <eng>` | inherited | 7 | `product-backlog` | `inherited/stabilization-product-backlog.md` → `stabilization-product-backlog.md` | step 6 done: `codebase-architecture-map.md` exists |
| `/refine <eng>` | both (scenario-aware) | GF 7 / INH 8 | `product-backlog` | GF: `shared/refined-story-pack.md` → `refined-story-pack.md` · INH: `inherited/inherited-refined-story-pack.md` → `inherited-refined-story-pack.md` | GF: step 6 `architecture-technical-foundation-pack.md` · INH: step 7 `stabilization-product-backlog.md` |
| `/sprint-plan <eng>` | both (scenario-aware) | GF 8 / INH 9 | `scrum-planning` | GF: `shared/sprint-planning-support-pack.md` → `sprint-planning-support-pack.md` · INH: `inherited/inherited-sprint-planning-support-pack.md` → `inherited-sprint-planning-support-pack.md` | GF: step 7 `refined-story-pack.md` · INH: step 8 `inherited-refined-story-pack.md` |

All four delegated agents (`product-backlog`, `implementation`, `documentation`,
`scrum-planning`) already exist in `.claude/agents/`. All seven template paths already exist
in `templates/`.

## 4. Engagement state file — extended seed

`/intake` already creates `src/<engagement>/engagement.md`. Pass 3 extends the seeded
`## Completed steps` checklist from steps 1–4 to the full linear chain. Frontmatter is
unchanged. The seeds become:

Greenfield:
```markdown
## Completed steps
- [x] 1 Project Request Brief — delivery/project-request-brief.md
- [ ] 2 Discovery Workshop Plan
- [ ] 3 Discovery Meeting Summary
- [ ] 4 Product Goal Draft
- [ ] 5 Initial Product Backlog Pack
- [ ] 6 Architecture & Technical Foundation Pack
- [ ] 7 Refined Story Pack
- [ ] 8 Sprint Planning Support Pack
```

Inherited:
```markdown
## Completed steps
- [x] 1 Takeover Request Brief — delivery/takeover-request-brief.md
- [ ] 2 Access & Information Checklist
- [ ] 3 Initial System Assessment
- [ ] 4 Inherited Project Goal Draft
- [ ] 5 Business Rule Recovery Report
- [ ] 6 Codebase & Architecture Map
- [ ] 7 Stabilization Product Backlog
- [ ] 8 Inherited Refined Story Pack
- [ ] 9 Inherited Sprint Planning Support Pack
```

Pack labels are the template `pack:` titles, so the checklist label matches the artifact's
own heading. Each setup command, on success, replaces its step's line with
`- [x] N <Pack name> — delivery/<output>.md`. **Backward-compat fallback:** if the step's
line is absent (an `engagement.md` created by the pre-Pass-3 `/intake`, which seeded only
1–4), the command inserts the line in numeric order rather than failing.

`/intake`'s re-run behavior (preserve already-checked steps, never reset progress) is
unchanged and now spans the longer list.

## 5. Command anatomy

### 5.1 Single-scenario commands (5 of them)

Identical to the Pass-2 step-command shared shape (7 numbered steps): resolve engagement →
load state (missing → "run `/intake` first") → **scenario guard** (mismatch → stop and name
the other track's commands) → check prerequisite (prior `delivery/` artifact; missing → "do
X first", produce nothing) → delegate to the mapped subagent via Task → update state (tick
step N, with the append-in-order fallback) → report next command. Governance footer:
"You orchestrate only — the agent produces the artifact and a human reviews it. Never paste
secrets or production data."

`/map-codebase` is a single-scenario (inherited) command with an **extended prerequisite**:
after confirming step 5's artifact (`business-rule-recovery-report.md`) exists, it locates
the cloned project repo using `/system-assessment`'s hardened detection — a subdirectory of
`src/<eng>/` other than `request/` and `delivery/` that actually contains code (a `.git`
dir or real source). None → stop with a "clone it first" message; several candidates or an
empty/non-code candidate → ask the user to confirm which folder is the repo. The confirmed
folder is passed to the `implementation` agent as the codebase to map.

### 5.2 Scenario-aware commands (`/refine`, `/sprint-plan`)

Same skeleton, but instead of a reject-on-mismatch scenario guard they **branch on
`scenario`** (like `/intake`). After loading state, the command reads `scenario` and selects,
for that track: the prerequisite artifact, the template, the output filename, the step number
N, the `<Pack name>`, and the "report next" message. Everything else (delegate to
`product-backlog` / `scrum-planning`, update state, governance footer) is shared. If
`scenario` is neither `greenfield` nor `inherited`, stop and tell the user the state file is
malformed.

Branch tables:

`/refine`:

| scenario | step N | prereq artifact | template | output |
|----------|--------|-----------------|----------|--------|
| greenfield | 7 | `delivery/architecture-technical-foundation-pack.md` | `templates/shared/refined-story-pack.md` | `delivery/refined-story-pack.md` |
| inherited | 8 | `delivery/stabilization-product-backlog.md` | `templates/inherited/inherited-refined-story-pack.md` | `delivery/inherited-refined-story-pack.md` |

`/sprint-plan`:

| scenario | step N | prereq artifact | template | output |
|----------|--------|-----------------|----------|--------|
| greenfield | 8 | `delivery/refined-story-pack.md` | `templates/shared/sprint-planning-support-pack.md` | `delivery/sprint-planning-support-pack.md` |
| inherited | 9 | `delivery/inherited-refined-story-pack.md` | `templates/inherited/inherited-sprint-planning-support-pack.md` | `delivery/inherited-sprint-planning-support-pack.md` |

### 5.3 End-of-chain "report next"

The end of each track points beyond Pass 3 without inventing commands that do not exist yet:

- `/refine` → "Run `/sprint-plan <eng>`."
- `/sprint-plan` → "Setup & planning is complete. The next steps are the recurring per-sprint
  events (greenfield: sprint execution, daily scrum, code review, QA…; inherited: safe
  execution, regression QA…) — their commands aren't built yet, so run their agents manually
  per `CLAUDE.md`'s run-order table."

## 6. Slash-command technical format

Unchanged from Pass 2. Each `.claude/commands/<name>.md` is a Markdown prompt with YAML
frontmatter:

```markdown
---
description: <one line shown in the / menu>
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
<prompt body that orchestrates the numbered steps; uses $ARGUMENTS for the slug>
```

## 7. Docs updates

- **`CLAUDE.md`** — in the Greenfield run-order table, replace `— (manual)` in the Command
  column for steps 5–8 with `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`. In
  the Inherited table, replace `— (manual)` for steps 5–9 with `/recover-rules`,
  `/map-codebase`, `/stabilization-backlog`, `/refine`, `/sprint-plan`. Update the "Slash
  commands" section to list the new Setup & Planning chain and adjust the "Steps 5+ have no
  command yet" line so it points at the now-uncovered steps (GF 9+, INH 10+).
- **`README.md`** — extend the quick-start so the post-discovery chain is shown, and update the
  "Deferred (future passes)" note to say the setup & planning commands now exist; what remains
  deferred is the recurring per-sprint commands (execution → review → retro → release /
  modernization), skills, and plugin packaging.
- **`docs/ROADMAP.md`** — mark Pass 3 ✅ Done and add a status-log line. Do **not** delete the
  roadmap; deletion waits until Passes 3–5 all ship (per the file's own deletion trigger).

## 8. Verification

- **Extend `scripts/verify-scaffold.ps1`**: add the seven new command basenames to the
  `$expectedCmds` list (total 14). No other change is required — the verifier already
  discovers command files, validates each one's `description` + `argument-hint` frontmatter,
  warns on unexpected files, and (in its link-integrity section) checks that every
  `templates/…` path and `subagent_type:` named in any command resolves. The new commands'
  template paths and agent names all exist, so those checks pass automatically. The verifier
  must end with `ALL CHECKS PASSED`, exit 0.
- **Manual smoke test** (documented in the plan): on a throwaway greenfield engagement that
  has been carried through `/product-goal`, run `/initial-backlog` and confirm it writes
  `delivery/initial-product-backlog-pack.md` and ticks step 5; then run `/architecture` and
  confirm step 6. Confirm `git status` shows nothing under the throwaway `src/` engagement
  (gitignored). Clean up afterward.
- The pristine-repo invariant still holds: everything the commands create lives under `src/`
  (gitignored). Commits carry no Claude co-author.

## 9. Out of scope (still deferred)

- The recurring per-sprint commands: GF steps 9–15 (sprint execution, daily scrum, code
  review, QA, sprint review, retrospective, release readiness) and INH steps 10–14 (safe
  execution, regression QA, sprint review, retrospective, modernization). These need the
  recurring-command model flagged in `docs/ROADMAP.md`'s open decisions (Pass 4–5).
- Reusable skills, a `/status` / `/next` navigator, and plugin packaging (Pass 6–7).

## 10. Assumptions & open questions

- **A1:** The four delegated agents and seven templates already exist (verified against
  `.claude/agents/` and `templates/`); Pass 3 adds no agents or templates.
- **A2:** Extending `/intake`'s seed does not break existing engagements — setup commands'
  append-in-order fallback covers `engagement.md` files seeded by the older 1–4 intake.
- **A3:** `/map-codebase` can safely reuse `/system-assessment`'s repo-detection prose
  verbatim (same need: locate a cloned repo subdir of `src/<eng>/`).
- **Q1 (resolved):** Scenario-aware single commands for `/refine` + `/sprint-plan` — confirmed (D1).
- **Q2 (resolved):** Extend the `/intake` seed to the full linear chain — confirmed (D2).
- **Q3 (resolved):** `/architecture` delegates to `implementation` only — confirmed (D3).
