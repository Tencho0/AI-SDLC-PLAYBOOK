# AI-SDLC Review, Retro, Release / Modernization Slash Commands — Design Spec

- **Date:** 2026-06-12
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** `2026-06-11-ai-sdlc-sprint-execution-qa-commands-design.md` (pass 4 — recurring sprint-execution + QA commands)

---

## 1. Goal & Context

Passes 2–4 built command coverage for run-order steps 1–12 (greenfield) and 1–11 (inherited):
the once-per-engagement linear chain (`/intake` → `/sprint-plan`) and the recurring per-sprint
loop (`/execution`, `/daily-scrum`, `/pr-review`, `/qa`). **Pass 5 is the final required pass** —
it covers the sprint/milestone wrap-up steps currently marked `— (manual)`:

- **Greenfield:** step 13 (Sprint Review) → 14 (Retrospective) → 15 (Release readiness).
- **Inherited:** step 12 (Sprint Review) → 13 (Retrospective) → 14 (Modernization).

When Pass 5 merges, **every step in both run-order tables has a command** — full coverage — so
the `docs/ROADMAP.md` build-tracker's own deletion trigger fires and Pass 5's capstone is to
delete it (§7).

**Success criterion:** after the sprint loop, an engagement can run `/sprint-review`, `/retro`,
and (greenfield) `/release-readiness` or (inherited) `/modernize` — each delegating to the
mapped subagent, writing an artifact under `src/<eng>/delivery/`, and appending to the
`## Activity log`. The verifier stays green at 22 commands. No `— (manual)` rows remain.

**Out of scope (optional, later):** the `security-review` command (Pass 6 candidate), reusable
skills (e.g. a `/status` / `/next` navigator), and plugin packaging. Also out of scope:
making `/sprint-plan` re-runnable per sprint — see §8 (known limitation).

## 2. Decisions (locked)

Five taken as recommended (consistent with Passes 3–4); three settled in the brainstorm.

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **The asymmetric third step becomes two separate single-scenario commands:** `/release-readiness` (greenfield, `devops`) and `/modernize` (inherited, `documentation`), each with a hard scenario guard cross-referencing the other. | Release readiness and modernization are genuinely different activities (different agent, template, meaning); one scenario-aware command would conflate them. Mirrors the existing single-scenario commands (`/initial-backlog` vs `/recover-rules`). |
| D2 | **`/sprint-review` and `/retro` are keyed by sprint number**, defaulting to `engagement.md`'s current `sprint:` marker (1 if unset), with an optional `[sprint]` arg to target a past sprint. Output: `delivery/sprint-review/sprint-<N>.md`, `delivery/retro/sprint-<N>.md`. | These recur per sprint; keying by the `sprint:` marker (the field added in Pass 4) is the natural granularity and finally exercises it. |
| D3 | **`/modernize` produces a single living document** `delivery/modernization-roadmap.md`, updated in place on re-run (the `documentation` agent already prefers `Edit`), with an activity-log line each run. No second argument. | A modernization roadmap is a strategic, milestone-level doc — usually one living roadmap per engagement, not a per-instance snapshot. |
| D4 | **`/sprint-review` and `/retro` are scenario-aware** (branch on `scenario` like `/execution`/`/qa`); `/release-readiness` and `/modernize` are single-scenario (hard guard). | Sprint review and retro have per-scenario templates; the third step's two activities are per-scenario by nature. |
| D5 | **Commands delegate to the mapped subagent via Task; they never reimplement agent logic.** | Agent definitions remain the single source of behavior (DRY) — same invariant as every prior pass. |
| D6 | **Soft prerequisite gate** = engagement exists (hard stop → "run `/intake`"); beyond that, if the engagement's sprint-planning pack is missing, **warn but proceed**. No hard repo gate. | Same warn-but-allow model as Pass 4's recurring commands — teams legitimately run a review/retro/roadmap before every upstream artifact exists. |
| D7 | **Capstone: delete `docs/ROADMAP.md`** in this pass. | The ROADMAP's own trigger says delete once Passes 3–5 are merged (Passes 6–7 don't block it). Pass 5 completes coverage; the permanent record lives in `docs/superpowers/`. Nothing references the file (not the verifier, README, or CLAUDE.md). |

**Command-name note (stated, not gating):** `/sprint-review`, `/retro`, `/release-readiness`,
`/modernize`. `/release-readiness` (not `/release`) signals a readiness *assessment*, not a
deploy action — consistent with the `devops` agent's "never autonomous production deployment".

## 3. Command set (4 new commands)

All live in `.claude/commands/<name>.md`. `$ARGUMENTS` = `<slug> [item]` (see §5).

| Command | argument-hint | Scenario | Step | Delegates to | Template → output |
|---------|---------------|----------|------|--------------|-------------------|
| `/sprint-review <eng> [sprint]` | `<engagement-slug> [sprint-number]` | aware | GF 13 / INH 12 | `scrum-planning` | GF `templates/shared/sprint-review-pack.md` · INH `templates/inherited/inherited-sprint-review-pack.md` → `delivery/sprint-review/sprint-<N>.md` |
| `/retro <eng> [sprint]` | `<engagement-slug> [sprint-number]` | aware | GF 14 / INH 13 | `retrospective-insights` | GF `templates/shared/retrospective-insights-pack.md` · INH `templates/inherited/inherited-retrospective-insights-pack.md` → `delivery/retro/sprint-<N>.md` |
| `/release-readiness <eng> <release>` | `<engagement-slug> <release-label>` | greenfield (hard guard) | GF 15 | `devops` | `templates/shared/release-readiness-pack.md` → `delivery/release-readiness/<release>.md` |
| `/modernize <eng>` | `<engagement-slug>` | inherited (hard guard) | INH 14 | `documentation` | `templates/inherited/modernization-roadmap.md` → `delivery/modernization-roadmap.md` |

All four delegated agents (`scrum-planning`, `retrospective-insights`, `devops`,
`documentation`) already exist in `.claude/agents/`. All six template paths already exist.
Pass 5 adds **commands only**.

## 4. Engagement state file — no schema change

Pass 5 reuses the Pass-4 state model unchanged: the linear `## Completed steps` checklist is
left untouched; the recurring commands ensure the `phase: execution` and `sprint:` frontmatter
markers exist (set on first recurring run if absent — Pass 5 commands inherit this) and append
to the append-only `## Activity log`. No new frontmatter keys, no new sections.

Activity-log line format (from Pass 4) is
`- <today> · sprint <N> · <activity> · <item> → delivery/<activity>/<item>.md`. Pass 5 lines:

```markdown
- 2026-06-12 · sprint 3 · sprint-review · sprint-3 → delivery/sprint-review/sprint-3.md
- 2026-06-12 · sprint 3 · retro · sprint-3 → delivery/retro/sprint-3.md
- 2026-06-12 · sprint 3 · release-readiness · v1.2 → delivery/release-readiness/v1.2.md
- 2026-06-12 · sprint 3 · modernize → delivery/modernization-roadmap.md
```

`/modernize` is the one command whose artifact is **not** in an activity subfolder (it is a
single living doc), so its log line omits the `· <item>` token and points straight at
`delivery/modernization-roadmap.md`.

## 5. Command anatomy

Frontmatter is the standard contract:

```markdown
---
description: <one line; no surrounding quotes, matching existing commands>
argument-hint: <engagement-slug> [item]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```

Body steps (scenario-aware = 8; single-scenario = 8 with a guard instead of a branch;
`/modernize` = 7, no second arg):

1. **Resolve args.** Split `$ARGUMENTS`: first token = `<eng>`, remainder = the item. If
   `<eng>` empty, ask. Validate `<eng>` with the slug rule `^[a-z0-9][a-z0-9-]*$` (reject slash,
   backslash, space, dot, `..`, reserved names).
   - `/sprint-review`, `/retro`: the item is `[sprint]`. If empty, default to `engagement.md`'s
     current `sprint:` value (or `1` if no marker). Validate the sprint as `^[0-9]+$`; the
     output key is `sprint-<N>`.
   - `/release-readiness`: the item is `<release>` (required; ask if empty). Validate as a
     path-safe token: reject `/`, `\`, whitespace, `..`, or a leading `.`/`-`.
   - `/modernize`: no second arg.
2. **Load state.** Read `src/<eng>/engagement.md`. Missing → STOP: "run `/intake <eng>` first."
3. **Scenario.**
   - *Scenario-aware (`/sprint-review`, `/retro`):* read `scenario`; fix `<step>`, `<template>`,
     `<pack>`. Unrecognised value → STOP (state file malformed; re-run `/intake`).
   - *Single-scenario (`/release-readiness` = greenfield, `/modernize` = inherited):* scenario
     guard. Mismatch → STOP and name the other track's command (`/release-readiness` ↔
     `/modernize`).
4. **Soft gate.** Check the engagement's sprint-planning pack exists (greenfield:
   `delivery/sprint-planning-support-pack.md`; inherited:
   `delivery/inherited-sprint-planning-support-pack.md`). Missing → WARN (".. these commands
   usually run after `/sprint-plan <eng>`; proceeding anyway.") and **continue**. Never block.
5. **Derive output + ensure folder.** Item-keyed commands:
   `delivery/<activity>/<item>.md` (create the subfolder). `/modernize`:
   `delivery/modernization-roadmap.md` (no subfolder).
6. **Delegate via Task.** Spawn the mapped subagent (`subagent_type: <agent>`). Instruct it to:
   read the relevant prior artifacts in `src/<eng>/delivery/` (and, *if a cloned repo is present
   under `src/<eng>/`*, the repo); fill `<template>`; write `<output>` (`/modernize`: update the
   existing roadmap in place if present); follow the governance footer (Observed facts /
   Assumptions / Risks / Recommendations / Open questions). The command orchestrates only —
   never touches project code.
7. **Update state.** Ensure `phase: execution` + a `sprint:` marker (add `sprint: 1` if absent;
   otherwise leave its value unchanged); append one activity-log line (§4), creating the
   `## Activity log` section if absent. Do not modify `## Completed steps`.
8. **Report.** State what was produced and a sensible next action (see §5.2).

Governance footer (identical to all commands): "You orchestrate only — the agent produces the
artifact and a human reviews it. Never paste secrets or production data."

### 5.1 Scenario branch tables

`/sprint-review`:

| scenario | step | template | output |
|----------|------|----------|--------|
| greenfield | 13 | `templates/shared/sprint-review-pack.md` | `delivery/sprint-review/sprint-<N>.md` |
| inherited | 12 | `templates/inherited/inherited-sprint-review-pack.md` | `delivery/sprint-review/sprint-<N>.md` |

`/retro`:

| scenario | step | template | output |
|----------|------|----------|--------|
| greenfield | 14 | `templates/shared/retrospective-insights-pack.md` | `delivery/retro/sprint-<N>.md` |
| inherited | 13 | `templates/inherited/inherited-retrospective-insights-pack.md` | `delivery/retro/sprint-<N>.md` |

`/release-readiness` (greenfield only): step 15 · `templates/shared/release-readiness-pack.md`
→ `delivery/release-readiness/<release>.md`. `/modernize` (inherited only): step 14 ·
`templates/inherited/modernization-roadmap.md` → `delivery/modernization-roadmap.md`.

### 5.2 Report-next text

- `/sprint-review` → "Run `/retro <eng> <N>` for the same sprint." (Greenfield: also
  "`/release-readiness <eng> <release>` when you cut a release.")
- `/retro` → "Start the next sprint: bump `sprint:` in `engagement.md` and continue the
  execution loop (re-run `/sprint-plan <eng>` if you re-plan the backlog — see the known
  limitation below)."
- `/release-readiness` → "A human (DevOps/PO) approves the deploy — the report is advisory; the
  `devops` agent never deploys autonomously."
- `/modernize` → "PO / Architect / Client review the roadmap; feed prioritized items back into
  the backlog via `/stabilization-backlog` or `/refine`."

## 6. Docs updates

- **`CLAUDE.md`** — fill the Command column for the remaining `— (manual)` rows:
  - Greenfield: step 13 → `/sprint-review`, 14 → `/retro`, 15 → `/release-readiness`.
  - Inherited: step 12 → `/sprint-review`, 13 → `/retro`, 14 → `/modernize`.
  - **After this, no `— (manual)` rows remain** in either table.
  - Update the cross-cutting note: release readiness now has `/release-readiness`; only security
    review remains without a command.
  - In the **Slash commands** section, add a wrap-up bullet (`/sprint-review`, `/retro`,
    `/release-readiness` (GF) / `/modernize` (INH)) and remove the "remaining per-sprint steps …
    have no command yet" caveat (coverage is now complete; note only the optional
    security-review command, skills, and plugin packaging remain).
- **`README.md`** — update the "Deferred (future passes)" note: the full run order is now
  command-driven; what remains optional is a `security-review` command, reusable skills, and
  plugin packaging.
- **`docs/ROADMAP.md`** — **delete this file** (D7). Its deletion trigger ("Passes 3–5 merged")
  is satisfied by this pass; the per-pass specs/plans under `docs/superpowers/` are the
  permanent record.

## 7. Verification

- **Extend `scripts/verify-scaffold.ps1`:** add the four new command basenames to
  `$expectedCmds` (total 22):
  ```powershell
  $expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                  'access-checklist','system-assessment','stabilization-goal',
                  'initial-backlog','architecture','recover-rules','map-codebase',
                  'stabilization-backlog','refine','sprint-plan',
                  'execution','daily-scrum','pr-review','qa',
                  'sprint-review','retro','release-readiness','modernize'
  ```
  No other verifier change is needed: it discovers command files, validates `description` +
  `argument-hint` frontmatter, warns on unexpected files, and checks that every `templates/…`
  path and `subagent_type:` resolves. The new commands' templates and agents all exist, so those
  checks pass automatically. The verifier does not reference `docs/ROADMAP.md`, so deleting it is
  safe. Verifier must end `ALL CHECKS PASSED`, exit 0.
- **Manual smoke test** (documented in the plan): on a throwaway greenfield engagement with a
  `sprint: 2` marker, run `/sprint-review smoke5` (no sprint arg) → confirm it writes
  `delivery/sprint-review/sprint-2.md` (defaulted from the marker) and appends a log line; run
  `/modernize smoke5` → confirm the greenfield guard rejects it and points to
  `/release-readiness`. Confirm `git status` shows nothing under `src/smoke5/`. Clean up. (Use a
  slug that passes the slug rule — `smoke5`, not `_smoke5`.)
- Pristine-repo invariant holds: everything lives under gitignored `src/`; item-id validation
  keeps paths in-bounds. Commits carry no Claude co-author.

## 8. Assumptions & open questions

- **A1:** The four delegated agents and six templates already exist (verified against
  `.claude/agents/` and `templates/`); Pass 5 adds no agents or templates.
- **A2:** Pass 5 needs no `engagement.md` schema change — it reuses Pass 4's `phase`/`sprint`
  markers and `## Activity log`.
- **A3:** Deleting `docs/ROADMAP.md` breaks nothing — no file references it (verified: verifier
  `refFiles` list, README, CLAUDE.md).
- **Known limitation (not solved here):** `/sprint-plan` was built once-per-engagement (Pass 3,
  ticking step 8/9). A true multi-sprint flow needs sprint planning to recur each sprint;
  `/retro`'s report-next advises bumping `sprint:` and re-planning manually. A recurring
  `/sprint-plan` (or a `/next-sprint` helper) is a candidate for a future pass.
- **Q1 (resolved):** Asymmetric third step → two single-scenario commands (D1).
- **Q2 (resolved):** Per-sprint keying for review/retro → sprint number, default from marker (D2).
- **Q3 (resolved):** Modernization → single living doc (D3).
