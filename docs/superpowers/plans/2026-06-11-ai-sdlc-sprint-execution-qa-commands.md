# Sprint Execution & QA Slash Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 4 *recurring* slash commands for the per-ticket/PR/story/day sprint loop (greenfield steps 9–12, inherited steps 10–11 + cross-cutting) — each orchestrating in the main context, delegating artifact production to the mapped subagent, writing an item-keyed artifact under `src/<eng>/delivery/<activity>/`, and appending to an `## Activity log` in `engagement.md`.

**Architecture:** Each command is a Markdown prompt in `.claude/commands/<name>.md` that runs in the **main context** and uses the **Task tool** to spawn the mapped subagent (`subagent_type: <agent>`), which fills a template and writes the artifact. This pass introduces a **new recurring-command shape** (distinct from Pass 1–3's once-per-engagement step commands): a second argument (the item id), path-safe item-id validation, item-keyed output folders, a *soft* prerequisite gate (warn-but-allow), and an append-only activity log plus `phase`/`sprint` frontmatter markers — instead of ticking the linear `## Completed steps` checklist. `/execution` and `/qa` are scenario-aware (branch on `engagement.md`'s `scenario` like `/refine`); `/daily-scrum` and `/pr-review` are shared (one template, read `scenario` only for the soft gate). No runtime app, so "tests" = the structural verifier extended with the new command names (run first to confirm they fail, then driven green) plus a documented manual smoke test. Spec: `docs/superpowers/specs/2026-06-11-ai-sdlc-sprint-execution-qa-commands-design.md`.

**Tech Stack:** Claude Code custom slash commands (`.claude/commands/*.md`, YAML frontmatter, `$ARGUMENTS`, Task-tool delegation), Markdown, PowerShell 5.1 (verifier), git.

**Branch:** `sprint-execution-qa-commands` (already created; spec already committed there).

---

## File map (what gets created / modified)

```
.claude/commands/execution.md      Task 2   (GF step 9 / INH step 10; scenario-aware)
.claude/commands/qa.md             Task 2   (GF step 12 / INH step 11; scenario-aware)
.claude/commands/daily-scrum.md    Task 3   (recurring, shared; date-keyed, defaults today)
.claude/commands/pr-review.md      Task 3   (recurring, shared; PR-keyed; code-review agent)
scripts/verify-scaffold.ps1        Task 1   (modify: add 4 names to $expectedCmds)
CLAUDE.md                          Task 4   (modify: Command column + cross-cutting note + Slash commands section)
README.md                          Task 5   (modify: Deferred note)
docs/ROADMAP.md                    Task 5   (modify: Pass 4 → Done, Pass 5 → Next, status log, open decisions)
```

`/intake.md` is **not** modified — the `phase`/`sprint` markers and `## Activity log` are created at **runtime** by the recurring commands on first use, not seeded by intake. `engagement.md` is created at runtime under `src/<eng>/` (gitignored) — not a repo file.

---

## Authoring contracts (read once; referenced by Tasks 2–3)

### Frontmatter (every command)
```markdown
---
description: <one line; no surrounding quotes, matching existing commands — a colon inside the value is fine>
argument-hint: <engagement-slug> <item-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```

### Recurring-command shared shape
Body (scenario-aware = 8 steps, shared = 7 steps): resolve args (slug + item; validate slug
`^[a-z0-9][a-z0-9-]*$`; validate item as a path-safe token) → load state (missing → "run
`/intake` first") → [scenario branch — aware only] → **soft** prerequisite (sprint-planning
pack present? else WARN + continue) → derive item-keyed output path + ensure folder → delegate
to the mapped subagent via Task (read repo only *if present*) → update state (ensure
`phase: execution` + `sprint:` marker; append one `## Activity log` line; never touch
`## Completed steps`) → report next recurring action. Footer: "You orchestrate only — the agent
produces the artifact and a human reviews it. Never paste secrets or production data."

### Item-id path-safety rule (verbatim, used in every command's step 1)
Validate the item id as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`,
whitespace, or `..`, or starts with `.` or `-`. (`/daily-scrum` instead requires `YYYY-MM-DD`;
`/pr-review` strips a single leading `#` before validating.)

### Activity-log line format (verbatim, used in every command's update-state step)
`- <today> · sprint <N> · <activity> · <item> → delivery/<activity>/<item>.md`, where `<today>`
is today's date from the environment and `<N>` is the current `sprint` value. Append it to the
`## Activity log` section; if that section does not exist yet, add it after `## Completed steps`.

The exact rendered body for each command is given verbatim in its task step — copy it as-is.

---

## Task 1: Extend the verifier with the new command names (test-first)

**Files:** Modify `scripts/verify-scaffold.ps1`

- [ ] **Step 1: Add the 4 names to `$expectedCmds`**

In `scripts/verify-scaffold.ps1` section 4, replace this block:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan'
```

with:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan',
                'execution','daily-scrum','pr-review','qa'
```

- [ ] **Step 2: Run the verifier — the new checks FAIL**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: the 14 existing commands still PASS; 4 new `command present: <name>` lines FAIL (`execution`, `daily-scrum`, `pr-review`, `qa`); exit code 1. Confirms the harness sees the missing commands.

- [ ] **Step 3: Commit**

```powershell
git add scripts/verify-scaffold.ps1
git commit -q -m "Extend verifier with Pass 4 recurring sprint command names"
```

---

## Task 2: Scenario-aware recurring commands (`/execution`, `/qa`)

**Files:** Create `.claude/commands/execution.md`, `.claude/commands/qa.md`

These read `scenario` and branch (like `/refine`) — they do not reject either track.

- [ ] **Step 1: Create `.claude/commands/execution.md`**

```markdown
---
description: Sprint execution (greenfield step 9 / inherited step 10): capture a ticket's implementation as an Implementation Pack (greenfield) or Safe Change Pack (inherited), via the implementation agent.
argument-hint: <engagement-slug> <ticket-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/execution** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it once per ticket worked in the sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the ticket id (`<ticket>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<ticket>` is empty, ask the user which ticket. Validate `<ticket>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 9; `<template>` = `templates/shared/implementation-pack.md`; `<pack>` = `Implementation Pack`.
   - **inherited** → `<step>` = 10; `<template>` = `templates/inherited/safe-change-pack.md`; `<pack>` = `Safe Change Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — execution usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/execution/<ticket>.md`. Create the `src/<eng>/delivery/execution/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the relevant prior artifacts in `src/<eng>/delivery/` (the refined story pack and sprint planning pack; for inherited, also the codebase & architecture map and business rule recovery report) and, if a cloned project repo is present under `src/<eng>/`, the repo itself; focus on ticket **`<ticket>`**; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). Code and tests go INTO the project repo, never into `delivery/`.
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · execution · <ticket> → delivery/execution/<ticket>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where), the current sprint, and a sensible next action: open the PR and run `/pr-review <eng> <pr>`, run `/qa <eng> <ticket>` for tests, and `/daily-scrum <eng>` at standup. To start a new sprint, bump `sprint:` in `engagement.md`. Sprint review / retrospective / release commands aren't built yet — run their agents manually per `CLAUDE.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/qa.md`**

```markdown
---
description: QA & testing (greenfield step 12 / inherited step 11): turn a story's acceptance criteria into a QA Test Pack (greenfield) or Regression Test Pack (inherited), via the qa-test-design agent.
argument-hint: <engagement-slug> <story-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/qa** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it once per story/ticket tested in the sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the story id (`<story>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<story>` is empty, ask the user which story. Validate `<story>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 12; `<template>` = `templates/shared/qa-test-pack.md`; `<pack>` = `QA Test Pack`.
   - **inherited** → `<step>` = 11; `<template>` = `templates/inherited/regression-test-pack.md`; `<pack>` = `Regression Test Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — QA usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/qa/<story>.md`. Create the `src/<eng>/delivery/qa/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **qa-test-design** subagent (`subagent_type: qa-test-design`). Instruct it to: read the relevant prior artifacts in `src/<eng>/delivery/` (the refined story pack with acceptance criteria; for inherited, also the business rule recovery report and codebase & architecture map for regression risks) and, if a cloned project repo is present under `src/<eng>/`, the repo itself; focus on story **`<story>`**; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · qa · <story> → delivery/qa/<story>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where) and a sensible next action: have QA validate the pack, automate the cases (no `/automate-tests` command yet — run the `test-automation` agent manually), and continue the sprint loop (`/execution`, `/pr-review`, `/daily-scrum`). To start a new sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Run the verifier — scenario-aware command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `command present: execution` and `command present: qa` (plus their `description` + `argument-hint` frontmatter checks) PASS; their `templates/…` link-integrity checks (`implementation-pack`, `safe-change-pack`, `qa-test-pack`, `regression-test-pack`) and `subagent exists: implementation` / `qa-test-design` PASS. `daily-scrum`/`pr-review` still FAIL (created in Task 3).

- [ ] **Step 4: Commit**

```powershell
git add .claude/commands/execution.md .claude/commands/qa.md
git commit -q -m "Add scenario-aware recurring execution & qa commands"
```

---

## Task 3: Shared recurring commands (`/daily-scrum`, `/pr-review`)

**Files:** Create `.claude/commands/daily-scrum.md`, `.claude/commands/pr-review.md`

These use one template for both tracks (no scenario branch). They read `scenario` only to pick the pack the soft gate checks.

- [ ] **Step 1: Create `.claude/commands/daily-scrum.md`**

```markdown
---
description: Daily Scrum (recurring, both scenarios): produce a date-keyed Daily Scrum Support Summary, via the scrum-planning agent.
argument-hint: <engagement-slug> [date]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/daily-scrum** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring**, **shared** command — run it each standup, in either scenario. It uses one template for both tracks (no scenario branch).

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional date (`<date>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<date>` is empty, DEFAULT it to today's date (from the environment) in `YYYY-MM-DD` form — do not ask. If `<date>` is given, it MUST match `YYYY-MM-DD`; otherwise ask again.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Soft prerequisite check.** Read `scenario` from the frontmatter to pick the pack to check, then confirm it exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — the daily scrum usually runs during an active sprint; proceeding anyway." Then CONTINUE — do not block. (If `scenario` is missing or malformed, skip the pack check and continue.)
4. **Derive the output path.** `<output>` = `src/<eng>/delivery/daily-scrum/<date>.md`. Create the `src/<eng>/delivery/daily-scrum/` folder if it does not exist.
5. **Delegate to the agent.** Use the Task tool to spawn the **scrum-planning** subagent (`subagent_type: scrum-planning`). Instruct it to: read the sprint planning pack and the recent `delivery/execution/` artifacts in `src/<eng>/delivery/` to understand the Sprint Goal and in-flight work; summarise progress toward the Sprint Goal, impediments, and the focus for **`<date>`**; fill the template `templates/shared/daily-scrum-support-summary.md`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · daily-scrum · <date> → delivery/daily-scrum/<date>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
7. **Report.** Tell the user what was produced (and where) and that this is a focus aid the Developers own — not for micromanagement. Continue the sprint loop (`/execution`, `/pr-review`, `/qa`). To start a new sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/pr-review.md`**

```markdown
---
description: PR review (recurring, both scenarios): first-pass review of a PR as an AI PR Review Report, via the code-review agent. Distinct from the built-in code-review skill.
argument-hint: <engagement-slug> <pr-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/pr-review** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring**, **shared** command — run it once per PR, in either scenario. It uses one template for both tracks (no scenario branch) and delegates to the project's **code-review agent** (not the built-in code-review skill).

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the PR id (`<pr>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<pr>` is empty, ask the user which PR. Strip a single leading `#` from `<pr>` if present, then validate it as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Soft prerequisite check.** Read `scenario` from the frontmatter to pick the pack to check, then confirm it exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — PR review usually runs during an active sprint; proceeding anyway." Then CONTINUE — do not block. (If `scenario` is missing or malformed, skip the pack check and continue.)
4. **Derive the output path.** `<output>` = `src/<eng>/delivery/pr-review/<pr>.md`. Create the `src/<eng>/delivery/pr-review/` folder if it does not exist.
5. **Delegate to the agent.** Use the Task tool to spawn the **code-review** subagent (`subagent_type: code-review`). Instruct it to: review PR **`<pr>`** — its diff in the cloned project repo under `src/<eng>/` if one is present (otherwise from the diff or branch the user provides) — against the linked acceptance criteria in `src/<eng>/delivery/` (the refined story pack) and the test suite; fill the template `templates/shared/ai-pr-review-report.md`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). The agent produces a report only — it never modifies project code and cannot approve the PR.
6. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · pr-review · <pr> → delivery/pr-review/<pr>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
7. **Report.** Tell the user what was produced (and where), that a human reviewer owns the merge decision, and a sensible next action: address findings, then `/qa <eng> <story>` and `/daily-scrum <eng>`. To start a new sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Run the verifier — all 18 command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 18 `command present` checks PASS; the link-integrity section confirms every `templates/…` path (`daily-scrum-support-summary`, `ai-pr-review-report`) and `subagent_type:` (`scrum-planning`, `code-review`) in the new commands resolves; no `WARN unexpected command file`; `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 4: Commit**

```powershell
git add .claude/commands/daily-scrum.md .claude/commands/pr-review.md
git commit -q -m "Add shared recurring daily-scrum & pr-review commands"
```

---

## Task 4: Wire commands into CLAUDE.md

**Files:** Modify `CLAUDE.md`

- [ ] **Step 1: Fill the Command column in the Greenfield run-order table**

In `CLAUDE.md`'s `### Greenfield (new build)` table, replace each row's trailing `— (manual)` Command cell. Replace this exact block:

```
| 9 | Sprint execution | `implementation` | `templates/shared/implementation-pack.md` | — (manual) |
| 10 | Daily Scrum | `scrum-planning` | `templates/shared/daily-scrum-support-summary.md` | — (manual) |
| 11 | Code review | `code-review` | `templates/shared/ai-pr-review-report.md` | — (manual) |
| 12 | QA & testing | `qa-test-design` (+ `test-automation`) | `templates/shared/qa-test-pack.md` | — (manual) |
```

with:

```
| 9 | Sprint execution | `implementation` | `templates/shared/implementation-pack.md` | `/execution` |
| 10 | Daily Scrum | `scrum-planning` | `templates/shared/daily-scrum-support-summary.md` | `/daily-scrum` |
| 11 | Code review | `code-review` | `templates/shared/ai-pr-review-report.md` | `/pr-review` |
| 12 | QA & testing | `qa-test-design` (+ `test-automation`) | `templates/shared/qa-test-pack.md` | `/qa` |
```

- [ ] **Step 2: Fill the Command column in the Inherited run-order table**

In `CLAUDE.md`'s `### Inherited (existing / takeover)` table, replace this exact block:

```
| 10 | Safe execution | `implementation` | `templates/inherited/safe-change-pack.md` | — (manual) |
| 11 | Regression QA | `qa-test-design` (+ `test-automation`) | `templates/inherited/regression-test-pack.md` | — (manual) |
```

with:

```
| 10 | Safe execution | `implementation` | `templates/inherited/safe-change-pack.md` | `/execution` |
| 11 | Regression QA | `qa-test-design` (+ `test-automation`) | `templates/inherited/regression-test-pack.md` | `/qa` |
```

- [ ] **Step 3: Update the cross-cutting note under the tables**

Replace this line:

```
Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`.
```

with:

```
Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`. The recurring sprint commands `/execution`, `/daily-scrum`, `/pr-review`, and `/qa` drive these for both tracks (see Slash commands below).
```

- [ ] **Step 4: Update the "Slash commands" section**

In `CLAUDE.md`'s `## Slash commands` section, replace the intro paragraph and the trailing scenario-aware paragraph. Replace this block:

```
The intake + discovery and setup + planning phases are automated by commands in `.claude/commands/`. Each takes the engagement slug as its argument, orchestrates in the main conversation (so it can ask you questions and track progress in `src/<eng>/engagement.md`), and delegates the actual artifact to the mapped agent.

- `/intake <eng>` — bootstrap the engagement, classify greenfield/inherited, produce the first brief.
- Greenfield discovery → setup/planning: `/discovery-prep` → `/discovery-summary` → `/product-goal` → `/initial-backlog` → `/architecture` → `/refine` → `/sprint-plan`.
- Inherited discovery → setup/planning: `/access-checklist` → `/system-assessment` → `/stabilization-goal` → `/recover-rules` → `/map-codebase` → `/stabilization-backlog` → `/refine` → `/sprint-plan`.

`/refine` and `/sprint-plan` are scenario-aware — they read `engagement.md` and pick the right template for the track. The recurring per-sprint steps beyond planning (greenfield steps 9+, inherited steps 10+) have no command yet — run their agents manually per the run-order tables above.
```

with:

```
The intake + discovery, setup + planning, and recurring sprint-execution + QA phases are automated by commands in `.claude/commands/`. Each takes the engagement slug as its argument (recurring commands also take an item id), orchestrates in the main conversation (so it can ask you questions and track progress in `src/<eng>/engagement.md`), and delegates the actual artifact to the mapped agent.

- `/intake <eng>` — bootstrap the engagement, classify greenfield/inherited, produce the first brief.
- Greenfield discovery → setup/planning: `/discovery-prep` → `/discovery-summary` → `/product-goal` → `/initial-backlog` → `/architecture` → `/refine` → `/sprint-plan`.
- Inherited discovery → setup/planning: `/access-checklist` → `/system-assessment` → `/stabilization-goal` → `/recover-rules` → `/map-codebase` → `/stabilization-backlog` → `/refine` → `/sprint-plan`.
- Recurring per-sprint (both scenarios): `/execution <eng> <ticket>`, `/daily-scrum <eng> [date]`, `/pr-review <eng> <pr>`, `/qa <eng> <story>` — run repeatedly, keyed by ticket / PR / story / date. They write item-keyed artifacts under `src/<eng>/delivery/<activity>/` and append to an `## Activity log` in `engagement.md` rather than ticking the linear checklist.

`/refine`, `/sprint-plan`, `/execution`, and `/qa` are scenario-aware — they read `engagement.md` and pick the right template for the track (`/daily-scrum` and `/pr-review` are shared). The recurring commands set `phase: execution` and a `sprint:` marker on first run; to start a new sprint, bump `sprint:` in `engagement.md`. The remaining per-sprint steps (greenfield steps 13+, inherited steps 12+ — sprint review, retrospective, release / modernization) have no command yet — run their agents manually per the run-order tables above.
```

- [ ] **Step 5: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 6: Commit**

```powershell
git add CLAUDE.md
git commit -q -m "Wire recurring sprint commands into CLAUDE.md run-order and slash-commands section"
```

---

## Task 5: Update README and ROADMAP

**Files:** Modify `README.md`, `docs/ROADMAP.md`

- [ ] **Step 1: Update the README "Deferred (future passes)" note**

Replace the `## Deferred (future passes)` paragraph in `README.md`:

```
The intake + discovery and setup + planning slash commands are built — the full once-per-engagement chain from `/intake` through `/sprint-plan` (greenfield and inherited). Still deferred: commands for the recurring per-sprint steps (sprint execution → daily scrum → code review → QA → sprint review → retrospective → release / modernization), reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

with:

```
The intake + discovery, setup + planning, and recurring sprint-execution + QA slash commands are built — the once-per-engagement chain from `/intake` through `/sprint-plan`, plus the recurring `/execution`, `/daily-scrum`, `/pr-review`, and `/qa` (greenfield and inherited). Still deferred: commands for the per-sprint/milestone wrap-up (sprint review → retrospective → release / modernization), an `/automate-tests` command, reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

- [ ] **Step 2: Mark Pass 4 done and Pass 5 next in `docs/ROADMAP.md`**

In the Build-order table, replace the Pass 4 row:

```
| **4 — Sprint Execution & QA** | Steps 9–12 (GF) / 10–11 (INH) — *recurring per ticket/PR* | execution, daily-scrum, code-review, QA commands. **Needs a new recurring-command shape first** (see Open decisions). | ⏭️ Next |
```

with:

```
| **4 — Sprint Execution & QA** | Steps 9–12 (GF) / 10–11 (INH) — *recurring per ticket/PR* | `/execution`, `/daily-scrum`, `/pr-review`, `/qa` — new recurring-command shape (item-keyed artifacts under `delivery/<activity>/`, append-only `## Activity log`, `phase`/`sprint` markers) | ✅ Done |
```

And replace the Pass 5 row's Status cell `📋 Planned` with `⏭️ Next`:

```
| **5 — Review, Retro, Release / Modernization** | Steps 13–15 (GF) / 12–14 (INH) — *per sprint / milestone* | GF: sprint-review, retrospective, release-readiness. INH: sprint-review, retrospective, modernization-roadmap | 📋 Planned |
```

with:

```
| **5 — Review, Retro, Release / Modernization** | Steps 13–15 (GF) / 12–14 (INH) — *per sprint / milestone* | GF: sprint-review, retrospective, release-readiness. INH: sprint-review, retrospective, modernization-roadmap | ⏭️ Next |
```

- [ ] **Step 3: Mark the open decisions resolved in `docs/ROADMAP.md`**

Replace the two bullets under `## Open decisions (resolve before the pass that needs them)`:

```
- **Recurring-command model (Pass 4):** code-review / QA / execution run many times per engagement; they should be parameterized by ticket / PR / sprint rather than ticking a one-time `engagement.md` checklist. Short brainstorm before building Pass 4.
- **`engagement.md` evolution:** as later phases land, the state file likely needs a "current sprint / phase" notion beyond the linear step list.
```

with:

```
- **Recurring-command model (Pass 4) — RESOLVED:** recurring commands are item-keyed (ticket / PR / story / date) and append to an `## Activity log` rather than ticking the linear checklist. See the Pass-4 spec.
- **`engagement.md` evolution — RESOLVED:** the state file gained `phase: execution` and a `sprint:` frontmatter marker (set on first recurring run; sprint bumped manually) plus the append-only `## Activity log`, leaving the linear `## Completed steps` checklist intact.
```

- [ ] **Step 4: Add a status-log line in `docs/ROADMAP.md`**

Append to the `## Status log` list:

```
- Pass 4 built on branch `sprint-execution-qa-commands`: 4 recurring sprint commands added (scenario-aware `/execution` + `/qa`, shared `/daily-scrum` + `/pr-review`); new recurring-command shape (item-keyed artifacts under `delivery/<activity>/`, append-only `## Activity log`, `phase`/`sprint` frontmatter markers); verifier extended to 18 commands and green; audited and code-reviewed. Roadmap kept (deletion waits for Pass 5).
```

- [ ] **Step 5: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 6: Commit**

```powershell
git add README.md docs/ROADMAP.md
git commit -q -m "Update README deferred note and ROADMAP status for Pass 4"
```

---

## Task 6: Final verification, smoke test, wrap-up

- [ ] **Step 1: Full verifier run**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`, exit 0. No `WARN unexpected command file` lines (every command on disk is in `$expectedCmds`).

- [ ] **Step 2: Link integrity across commands**

Run:
```powershell
$broken = 0
Get-ChildItem .claude/commands/*.md | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  [regex]::Matches($c,'templates/[A-Za-z0-9_./-]+\.md') | ForEach-Object {
    if (-not (Test-Path $_.Value)) { Write-Host "BROKEN: $($_.Value) in $($_.PSPath)" -ForegroundColor Red; $broken++ }
  }
}
$agentNames = (Get-ChildItem .claude/agents/*.md | ForEach-Object { $_.BaseName })
Get-ChildItem .claude/commands/*.md | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  [regex]::Matches($c,'subagent_type:\s*`?([a-z][a-z-]*)`?') | ForEach-Object {
    $n = $_.Groups[1].Value
    if ($agentNames -notcontains $n) { Write-Host "UNKNOWN AGENT '$n' in $($_.PSPath)" -ForegroundColor Red; $broken++ }
  }
}
if ($broken -eq 0) { Write-Host "OK - command template + agent references resolve" -ForegroundColor Green }
```
Expected: `OK - command template + agent references resolve`.

- [ ] **Step 3: Manual smoke test (document the result)**

Confirm the new recurring shape works on a throwaway greenfield engagement carried through `/sprint-plan`:
```powershell
New-Item -ItemType Directory -Force src/_smoke4/request | Out-Null
Set-Content src/_smoke4/request/req.md "Client wants a new internal tool to track field-service jobs." -Encoding utf8
```
In Claude Code: run `/intake _smoke4` (choose greenfield), then (to reach the soft-gate's prerequisite quickly) hand-create `src/_smoke4/delivery/sprint-planning-support-pack.md` with any placeholder content. Then:
- Run `/execution _smoke4 PROJ-1` → confirm it writes `src/_smoke4/delivery/execution/PROJ-1.md`, sets `phase: execution` + `sprint: 1` in `engagement.md` frontmatter, and appends an `## Activity log` line `… · execution · PROJ-1 → delivery/execution/PROJ-1.md`.
- Run `/daily-scrum _smoke4` (no date) → confirm it writes `src/_smoke4/delivery/daily-scrum/<today>.md` and appends a log line.
- Confirm the linear `## Completed steps` checklist is unchanged, and `git status` shows nothing under `src/_smoke4/` (gitignored).
Also confirm the soft gate: on a fresh engagement with no sprint-planning pack, `/execution` WARNS but still produces the artifact. Clean up:
```powershell
Remove-Item -Recurse -Force src/_smoke4
```

- [ ] **Step 4: Report completion**

Summarize files created/modified, verifier result, and the smoke-test outcome. Note `main` can fast-forward from `sprint-execution-qa-commands`. Merge/push per the build process (fast-forward merge to main, push, delete branch).

---

## Self-review (completed by plan author)

**Spec coverage:** §2 D1 state model (untouched checklist + activity log + markers) → Task 2/3 update-state steps (step 7/6). D2 lightweight sprint marker, manual bump → every update-state step ("add `sprint: 1` if none exists; otherwise leave unchanged") + report steps ("bump `sprint:` to start a new sprint") + CLAUDE.md Task 4 Step 4. D3 flat namespaced paths → derive-output steps (`delivery/<activity>/<item>.md`). D4 arg shape + daily-scrum default → step 1 of every body (daily-scrum defaults date; others ask). D5 `/pr-review` → `subagent_type: code-review` → Task 3 Step 2. D6 scenario split → Task 2 branches, Task 3 reads scenario only for the gate. D7 soft gate + no hard repo gate → step "Soft prerequisite check" (WARN + continue) and delegate steps ("if a cloned repo is present"). D8 defer `/automate-tests` → only 4 commands built; `/qa` report notes running `test-automation` manually. §3 command set (4) → Tasks 2–3. §4 schema delta → update-state steps. §5 anatomy + §5.1 branch tables → rendered bodies. §6 docs → Tasks 4–5. §7 verification → Task 1 (verifier) + Task 6 (links + smoke).

**Placeholder scan:** No "TBD/TODO/handle appropriately". The `<eng>`, `<ticket>`, `<story>`, `<pr>`, `<date>`, `<step>`, `<template>`, `<pack>`, `<output>`, `<today>`, `<N>` tokens are documented runtime variables — each is given concrete values (scenario branches in step 3 for aware commands; literal template/agent paths for shared) and concrete derivation rules (item from `$ARGUMENTS`; `<today>`/`<N>` from environment + frontmatter). Command bodies are fully rendered.

**Type/name consistency:** Command names match across the verifier `$expectedCmds` (Task 1), the file map, Tasks 2–3 bodies, the CLAUDE.md tables + cross-cutting note + Slash-commands section (Task 4), and README/ROADMAP (Task 5): `execution`, `daily-scrum`, `pr-review`, `qa`. Agent names in `subagent_type` (`implementation`, `qa-test-design`, `scrum-planning`, `code-review`) all exist in `.claude/agents/`. Template paths match existing `templates/` files (implementation-pack, safe-change-pack, qa-test-pack, regression-test-pack, daily-scrum-support-summary, ai-pr-review-report). Output folders (`execution`, `daily-scrum`, `pr-review`, `qa`) match the activity token used in the activity-log line and the report text. Step numbers (GF 9/10/11/12, INH 10/11) match the run-order tables and the branch tables.
