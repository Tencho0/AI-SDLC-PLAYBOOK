# AI-SDLC Sprint Execution & QA Slash Commands — Design Spec

- **Date:** 2026-06-11
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** `2026-06-11-ai-sdlc-setup-planning-commands-design.md` (pass 3 — setup + planning commands)

---

## 1. Goal & Context

Passes 2–3 added the orchestration layer for the **once-per-engagement linear chain** —
`/intake` through `/sprint-plan` (greenfield steps 1–8, inherited steps 1–9), backed by a
per-engagement `engagement.md` state file with a linear `## Completed steps` checklist.

**Pass 4 is the first pass of *recurring* commands** — the per-ticket / per-PR / per-story /
per-day events of the sprint loop, which run many times per engagement. It covers the steps
currently marked `— (manual)`:

- **Greenfield:** step 9 (sprint execution) → 10 (daily scrum) → 11 (code review) → 12 (QA).
- **Inherited:** step 10 (safe execution) → 11 (regression QA), plus the cross-cutting daily
  scrum and code review that recur in both tracks.

Because these run repeatedly, the Pass-3 "tick one fixed line in `engagement.md`" model does
not fit. **Pass 4 needs a new command shape:** item-keyed artifacts, a second argument, an
append-only activity record, and a lightweight current-sprint marker — adapted from, not
copied wholesale from, the Pass-3 step-command pattern.

**Success criterion:** after `/sprint-plan`, an engagement can run, repeatedly and in any
order, `/execution <eng> <ticket>`, `/daily-scrum <eng> [date]`, `/pr-review <eng> <pr>`, and
`/qa <eng> <story>` — each delegating to the mapped subagent, writing an item-keyed artifact
under `src/<eng>/delivery/<activity>/`, and appending one line to `engagement.md`'s activity
log. The verifier stays green with the expanded command set.

**Out of scope (Pass 5+):** sprint review, retrospective, release readiness / modernization
(GF 13–15, INH 12–14); an `/automate-tests` command (writes test *code* into the repo, not a
delivery pack); the optional security-review command; reusable skills; plugin packaging.

## 2. Decisions (locked)

Five were taken as recommended in the prompt; three (D2/D3/D4 mechanics) were settled in the
brainstorm.

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **State model = leave the linear `## Completed steps` checklist untouched; add an append-only `## Activity log` section plus `phase`/`sprint` frontmatter markers.** | The linear checklist tracks the once-per-engagement chain (Pass 1–3); recurring events need a different, append-only record keyed by item — not a fixed line to tick. |
| D2 | **Sprint marker is lightweight.** On its first recurring run a command sets `phase: execution` and `sprint: 1` in frontmatter *if absent* (idempotent thereafter); it reads `sprint` for activity-log lines. Advancing to sprint N is a documented manual bump of `sprint:`. **No sprint-advancement command in Pass 4.** | Gives a current-sprint notion without inventing a sprint lifecycle that belongs to Pass 5 (sprint review). `/sprint-plan` is a Pass-3 command and re-running it is out of scope here. |
| D3 | **Flat namespaced output paths**, keyed by item: `delivery/execution/<ticket>.md`, `delivery/pr-review/<pr>.md`, `delivery/qa/<story>.md`, `delivery/daily-scrum/<YYYY-MM-DD>.md`. Sprint lives in frontmatter + the log, **not** in the path. | Matches the prompt's path examples; avoids coupling file paths to the sprint mechanism; one artifact per item, overwritten on re-run. |
| D4 | **Argument shape:** first whitespace-delimited token of `$ARGUMENTS` = engagement slug, the remainder = the item id. Ask if the item is missing — **except** `/daily-scrum`, whose date defaults to today. | A standup naturally defaults to today; tickets/PRs/stories have no sensible default, so prompt for them. |
| D5 | **The code-review command is named `/pr-review`** (not `code-review`, which collides with the built-in `code-review` *skill*). It delegates to the project **`code-review` agent** via `subagent_type: code-review`. | Avoids shadowing the environment's built-in review skill while still using the project agent. |
| D6 | **Scenario split:** `/execution` and `/qa` are **scenario-aware** (branch on `engagement.md`'s `scenario`, like `/refine`/`/sprint-plan`); `/daily-scrum` and `/pr-review` are **shared** (one template both tracks). Shared commands still read `scenario` — only to pick the right pack for the soft gate. | Execution and QA have per-scenario templates; daily-scrum and PR review have a single shared template each. |
| D7 | **Soft prerequisite gate.** Engagement must exist (hard stop → "run `/intake` first"). Beyond that, the gate is *soft*: if the engagement's sprint-planning pack is missing (planning not finished), **warn but proceed**. There is **no hard repo gate** — agents read the cloned repo *if one is present* under `src/<eng>/`. | Recurring commands shouldn't enforce a strict linear prior-artifact gate; teams legitimately run a standup or review before every pack upstream exists. |
| D8 | **Defer `/automate-tests`.** Pass 4 ships only the four pack-producing commands. | Keeps the pass focused; test-code generation targets the repo, not `delivery/`, and needs repo-detection + a different output target — a later pass. |

**Command-name note (stated, not a gating decision):** `/execution` and `/qa` are chosen as
scenario-neutral names that fit both run-order labels ("Sprint execution" / "Safe execution"
and "QA & testing" / "Regression QA"). If a future preference is `/implement` or `/qa-tests`,
that is a rename only.

## 3. Command set (4 new commands)

All live in `.claude/commands/<name>.md`. `$ARGUMENTS` = `<slug> <item>` (see D4). Output is an
item-keyed file under `src/<eng>/delivery/<activity>/`.

| Command | argument-hint | Scenario | Step | Delegates to | Template → output |
|---------|---------------|----------|------|--------------|-------------------|
| `/execution <eng> <ticket-id>` | `<engagement-slug> <ticket-id>` | aware | GF 9 / INH 10 | `implementation` | GF `templates/shared/implementation-pack.md` · INH `templates/inherited/safe-change-pack.md` → `delivery/execution/<ticket>.md` |
| `/daily-scrum <eng> [date]` | `<engagement-slug> [date]` | shared | GF 10 (cross-cutting) | `scrum-planning` | `templates/shared/daily-scrum-support-summary.md` → `delivery/daily-scrum/<YYYY-MM-DD>.md` |
| `/pr-review <eng> <pr-id>` | `<engagement-slug> <pr-id>` | shared | GF 11 (cross-cutting) | `code-review` | `templates/shared/ai-pr-review-report.md` → `delivery/pr-review/<pr>.md` |
| `/qa <eng> <story-id>` | `<engagement-slug> <story-id>` | aware | GF 12 / INH 11 | `qa-test-design` | GF `templates/shared/qa-test-pack.md` · INH `templates/inherited/regression-test-pack.md` → `delivery/qa/<story>.md` |

All four delegated agents (`implementation`, `scrum-planning`, `code-review`,
`qa-test-design`) already exist in `.claude/agents/`. All six template paths already exist in
`templates/`. Pass 4 adds **commands only** — no new agents or templates.

## 4. Engagement state file — schema delta

`/intake` creates `src/<eng>/engagement.md` with frontmatter (`engagement`, `scenario`,
`phase: discovery`, `created`) and the `## Completed steps` checklist. Pass 4 adds two things;
the Pass 1–3 structure is otherwise untouched.

### 4.1 Frontmatter markers

On its **first recurring run** for an engagement, a command ensures these exist (idempotent —
set only if absent or, for `phase`, not already `execution`):

- `phase: execution` (updates the `phase: discovery` value `/intake` seeded).
- `sprint: 1`.

`sprint` is read (never auto-incremented) for activity-log lines. To start sprint 2, a human
bumps `sprint:` in `engagement.md`. This is documented in the command's report and in
`CLAUDE.md`.

### 4.2 Append-only activity log

A new section, created after `## Completed steps` on the first recurring run if absent, then
appended to (never rewritten):

```markdown
## Activity log
- 2026-06-11 · sprint 1 · execution · PROJ-123 → delivery/execution/PROJ-123.md
- 2026-06-11 · sprint 1 · daily-scrum · 2026-06-11 → delivery/daily-scrum/2026-06-11.md
- 2026-06-11 · sprint 1 · pr-review · 42 → delivery/pr-review/42.md
- 2026-06-11 · sprint 1 · qa · PROJ-123 → delivery/qa/PROJ-123.md
```

Line format: `- <today> · sprint <N> · <activity> · <item> → delivery/<activity>/<item>.md`.
`<today>` is the run date from the environment. Re-running on the same item appends a new
dated line (an honest chronological record) rather than editing the prior one; the artifact
file itself is overwritten.

## 5. Recurring command anatomy (the new shape)

Frontmatter is the same contract as every prior command:

```markdown
---
description: <one line shown in the / menu>
argument-hint: <engagement-slug> <item-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```

Body = 8 numbered steps:

1. **Resolve args.** Split `$ARGUMENTS` on whitespace: first token = `<eng>`, remainder = the
   item id (`<item>`). If `<eng>` is empty, ask. Validate `<eng>` with the intake slug rule
   `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, reserved names). If the
   item id is empty: ask for it — **except `/daily-scrum`**, which defaults `<item>` to today's
   date. Validate the item id as a **path-safe token**: reject if it contains `/`, `\`,
   whitespace, or `..`, or starts with `.` or `-`; for `/daily-scrum` require `YYYY-MM-DD`. (A
   `/pr-review` id may be given as `#42`; strip a single leading `#` before validating.) This
   keeps every artifact safely under `src/<eng>/delivery/` and preserves the pristine-repo
   invariant.
2. **Load state.** Read `src/<eng>/engagement.md`. Missing → STOP: "No engagement found — run
   `/intake <eng>` first." Do not proceed.
3. **Scenario.**
   - *Scenario-aware (`/execution`, `/qa`):* read `scenario` and fix `<template>`, `<pack>`,
     `<step>` for the track; an unrecognised value → STOP (state file malformed; re-run
     `/intake`).
   - *Shared (`/daily-scrum`, `/pr-review`):* read `scenario` only to choose which
     sprint-planning pack the soft gate checks; no template branch.
4. **Soft gate.** Check the engagement's sprint-planning pack exists
   (greenfield: `delivery/sprint-planning-support-pack.md`; inherited:
   `delivery/inherited-sprint-planning-support-pack.md`). If missing, WARN ("setup & planning
   isn't complete — these recurring commands usually run after `/sprint-plan`; proceeding
   anyway.") and **continue**. Never block.
5. **Derive output + ensure folder.** `<output>` = `src/<eng>/delivery/<activity>/<item>.md`
   (`<activity>` ∈ `execution` | `daily-scrum` | `pr-review` | `qa`). Create the
   `delivery/<activity>/` subfolder if it does not exist.
6. **Delegate via Task.** Spawn the mapped subagent (`subagent_type: <agent>`). Instruct it to:
   read the relevant prior artifacts in `src/<eng>/delivery/` and, *if a cloned project repo is
   present under `src/<eng>/`*, the repo; focus on the specific `<item>` (the ticket / PR /
   story; for daily-scrum, the day's sprint progress); fill `<template>`; write `<output>`; and
   follow the template's governance footer (separate Observed facts / Assumptions / Risks /
   Recommendations / Open questions). The command **orchestrates only** — it never reimplements
   agent logic and never touches project code itself.
7. **Update state.** In `engagement.md`: ensure `phase: execution` and a `sprint:` marker exist
   (§4.1); append one activity-log line (§4.2), creating the `## Activity log` section if
   absent. Do not modify the `## Completed steps` checklist.
8. **Report.** State what was produced (and where) and a sensible next recurring action — e.g.
   `/execution` → "open the PR, then `/pr-review <eng> <pr>`, and `/qa <eng> <ticket>` for
   tests; `/daily-scrum <eng>` at standup." Note that sprint review / retrospective / release
   commands aren't built yet (Pass 5) — run their agents manually per `CLAUDE.md`.

Governance footer (identical to all commands): "You orchestrate only — the agent produces the
artifact and a human reviews it. Never paste secrets or production data."

### 5.1 Scenario branch tables

`/execution`:

| scenario | step N | template | output |
|----------|--------|----------|--------|
| greenfield | 9 | `templates/shared/implementation-pack.md` | `delivery/execution/<ticket>.md` |
| inherited | 10 | `templates/inherited/safe-change-pack.md` | `delivery/execution/<ticket>.md` |

`/qa`:

| scenario | step N | template | output |
|----------|--------|----------|--------|
| greenfield | 12 | `templates/shared/qa-test-pack.md` | `delivery/qa/<story>.md` |
| inherited | 11 | `templates/inherited/regression-test-pack.md` | `delivery/qa/<story>.md` |

`<step>` is recorded only in the activity-log context (the recurring commands do not tick the
linear checklist); it anchors the command to its run-order row.

## 6. Docs updates

- **`CLAUDE.md`** — fill the Command column in the run-order tables:
  - Greenfield: step 9 → `/execution`, 10 → `/daily-scrum`, 11 → `/pr-review`, 12 → `/qa`.
  - Inherited: step 10 → `/execution`, 11 → `/qa`.
  - Leave GF 13–15 and INH 12–14 as `— (manual)` (Pass 5).
  - Update the cross-cutting note under the tables to mention `/daily-scrum` and `/pr-review`
    as the recurring shared commands for both tracks.
  - In the **Slash commands** section, add the recurring sprint commands (note they take a
    second item argument, are item-keyed, scenario-aware where applicable, and that `sprint:`
    is bumped manually to start a new sprint). Adjust the "recurring per-sprint steps … have no
    command yet" line so it points at what's still uncovered (GF 13+, INH 12+).
- **`README.md`** — update the "Deferred (future passes)" note: the recurring per-sprint
  execution / daily-scrum / PR-review / QA commands now exist; what remains deferred is sprint
  review → retrospective → release / modernization, an `/automate-tests` command, skills, and
  plugin packaging.
- **`docs/ROADMAP.md`** — mark Pass 4 ✅ Done and Pass 5 ⏭️ Next; add a status-log line. Do
  **not** delete the roadmap; deletion waits until Pass 5 ships (per the file's own trigger).

## 7. Verification

- **Extend `scripts/verify-scaffold.ps1`:** add the four new command basenames to
  `$expectedCmds` (total 18):
  ```powershell
  $expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                  'access-checklist','system-assessment','stabilization-goal',
                  'initial-backlog','architecture','recover-rules','map-codebase',
                  'stabilization-backlog','refine','sprint-plan',
                  'execution','daily-scrum','pr-review','qa'
  ```
  No other verifier change is required. The verifier already discovers command files, validates
  each one's `description` + `argument-hint` frontmatter, warns on unexpected files, and (in its
  link-integrity section) checks that every `templates/…` path and `subagent_type:` named in a
  command resolves. The new commands' template paths and agent names all exist, so those checks
  pass automatically. Verifier must end with `ALL CHECKS PASSED`, exit 0.
- **Manual smoke test** (documented in the plan): on a throwaway greenfield engagement carried
  through `/sprint-plan`, run `/execution _smoke4 PROJ-1` and confirm it writes
  `delivery/execution/PROJ-1.md`, sets `phase: execution` + `sprint: 1`, and appends an
  activity-log line; run `/daily-scrum _smoke4` (no date) and confirm it writes
  `delivery/daily-scrum/<today>.md`. Confirm `git status` shows nothing under the throwaway
  `src/` engagement (gitignored). Clean up afterward.
- The pristine-repo invariant holds: everything the commands create lives under `src/`
  (gitignored), and the item-id validation keeps paths from escaping it. Commits carry no
  Claude co-author.

## 8. Assumptions & open questions

- **A1:** The four delegated agents and six templates already exist (verified against
  `.claude/agents/` and `templates/`); Pass 4 adds no agents or templates.
- **A2:** Adding `phase: execution`/`sprint:` and an `## Activity log` section to
  `engagement.md` is backward-compatible — the markers are set on first recurring run if
  absent, and the new section is created on first use; the linear `## Completed steps`
  checklist is never touched.
- **A3:** A single artifact per item (overwritten on re-run) with an append-only log line is
  the right granularity; the log preserves history even though the artifact is overwritten.
- **A4:** No hard repo gate is needed for recurring commands; agents degrade gracefully when no
  cloned repo is present (they work from the `delivery/` artifacts and the item id).
- **Q1 (resolved):** Sprint tracking → lightweight frontmatter marker, manual bump (D2).
- **Q2 (resolved):** Output layout → flat namespaced by item (D3).
- **Q3 (resolved):** `/daily-scrum` with no date → defaults to today (D4).
