# Review, Retro, Release / Modernization Slash Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the final 4 slash commands for the sprint/milestone wrap-up (greenfield steps 13–15, inherited steps 12–14) — `/sprint-review`, `/retro`, `/release-readiness` (GF), `/modernize` (INH) — completing command coverage of the whole run order, and delete the `docs/ROADMAP.md` build tracker (its deletion trigger is now met).

**Architecture:** Each command is a Markdown prompt in `.claude/commands/<name>.md` that runs in the **main context** and uses the **Task tool** to delegate artifact production to the mapped subagent. They reuse Pass 4's recurring-command shape (second arg, soft gate, `phase`/`sprint` markers, append-only `## Activity log`, linear checklist untouched). `/sprint-review` and `/retro` are scenario-aware (branch on `scenario`) and keyed by sprint number (default from the `sprint:` marker); `/release-readiness` (greenfield) and `/modernize` (inherited) are single-scenario with a hard guard that names the other; `/modernize` writes a single living `delivery/modernization-roadmap.md` (no key). No runtime app, so "tests" = the structural verifier extended with the new command names (run first to confirm they fail, then driven green) plus a documented manual smoke test. Spec: `docs/superpowers/specs/2026-06-12-ai-sdlc-review-retro-release-commands-design.md`.

**Tech Stack:** Claude Code custom slash commands (`.claude/commands/*.md`, YAML frontmatter, `$ARGUMENTS`, Task-tool delegation), Markdown, PowerShell 5.1 (verifier), git.

**Branch:** `review-retro-release-commands` (already created; spec already committed there).

---

## File map (what gets created / modified)

```
.claude/commands/sprint-review.md       Task 2   (GF step 13 / INH step 12; scenario-aware, sprint-keyed)
.claude/commands/retro.md               Task 2   (GF step 14 / INH step 13; scenario-aware, sprint-keyed)
.claude/commands/release-readiness.md   Task 3   (GF step 15; single-scenario; release-keyed)
.claude/commands/modernize.md           Task 3   (INH step 14; single-scenario; single living doc)
scripts/verify-scaffold.ps1             Task 1   (modify: add 4 names to $expectedCmds → 22)
CLAUDE.md                               Task 4   (modify: Command column + cross-cutting note + Slash commands section)
README.md                               Task 5   (modify: Deferred note)
docs/ROADMAP.md                         Task 5   (DELETE: trigger met — Passes 3–5 shipped)
```

`/intake.md` and `engagement.md`'s schema are **unchanged** — Pass 5 reuses Pass 4's `phase`/`sprint` markers and `## Activity log` (created at runtime under gitignored `src/`).

---

## Authoring contracts (read once; referenced by Tasks 2–3)

### Frontmatter (every command)
```markdown
---
description: <one line; no surrounding quotes, matching existing commands — a colon inside the value is fine>
argument-hint: <engagement-slug> [item]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```

### Activity-log line (verbatim convention, from Pass 4)
`- <today> · sprint <N> · <activity> · <item> → delivery/<activity>/<item>.md`, where `<today>`
is today's date from the environment and `<N>` is the **current `sprint:` marker value**.
For `/sprint-review` and `/retro` the item is `sprint-<sprint>` (usually `<N>` == `<sprint>`;
they differ only when the user reviews a past sprint via the optional arg). For `/modernize`
(a single living doc, not in an activity subfolder) the line omits the `· <item>` token and
points straight at `delivery/modernization-roadmap.md`.

### Item-id / sprint validation (verbatim, used in step 1)
- Slug: `^[a-z0-9][a-z0-9-]*$` (reject `/`, `\`, space, `.`, `..`, reserved names).
- Sprint number (`/sprint-review`, `/retro`): `^[0-9]+$`; default to the `sprint:` marker (or `1`).
- Release label (`/release-readiness`): path-safe token — reject `/`, `\`, whitespace, `..`, leading `.`/`-`.

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
                'stabilization-backlog','refine','sprint-plan',
                'execution','daily-scrum','pr-review','qa'
```

with:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan',
                'execution','daily-scrum','pr-review','qa',
                'sprint-review','retro','release-readiness','modernize'
```

- [ ] **Step 2: Run the verifier — the new checks FAIL**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: the 18 existing commands still PASS; 4 new `command present: <name>` lines FAIL (`sprint-review`, `retro`, `release-readiness`, `modernize`); exit code 1.

- [ ] **Step 3: Commit**

```powershell
git add scripts/verify-scaffold.ps1
git commit -q -m "Extend verifier with Pass 5 wrap-up command names"
```

---

## Task 2: Scenario-aware wrap-up commands (`/sprint-review`, `/retro`)

**Files:** Create `.claude/commands/sprint-review.md`, `.claude/commands/retro.md`

Sprint-keyed; read `scenario` and branch (like `/execution`).

- [ ] **Step 1: Create `.claude/commands/sprint-review.md`**

```markdown
---
description: Sprint Review (greenfield step 13 / inherited step 12): produce a sprint-keyed Sprint Review Pack, via the scrum-planning agent.
argument-hint: <engagement-slug> [sprint-number]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/sprint-review** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it at the end of each sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional sprint number (`<sprint>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<sprint>` is empty, DEFAULT it to the current `sprint:` value in `engagement.md`'s frontmatter — or `1` if there is no `sprint:` marker yet. Validate `<sprint>` as a positive integer `^[0-9]+$`; otherwise ask again. The output key is `sprint-<sprint>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 13; `<template>` = `templates/shared/sprint-review-pack.md`; `<pack>` = `Sprint Review Pack`.
   - **inherited** → `<step>` = 12; `<template>` = `templates/inherited/inherited-sprint-review-pack.md`; `<pack>` = `Inherited Sprint Review Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — the sprint review usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/sprint-review/sprint-<sprint>.md`. Create the `src/<eng>/delivery/sprint-review/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **scrum-planning** subagent (`subagent_type: scrum-planning`). Instruct it to: read the sprint planning pack and the sprint's `delivery/execution/`, `delivery/qa/`, and `delivery/pr-review/` artifacts in `src/<eng>/delivery/` to see what was committed vs delivered; summarise the increment, demo notes, and stakeholder feedback for **sprint <sprint>**; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · sprint-review · sprint-<sprint> → delivery/sprint-review/sprint-<sprint>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where) and a sensible next action: run `/retro <eng> <sprint>` for the same sprint; greenfield teams also run `/release-readiness <eng> <release>` when cutting a release. To start the next sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/retro.md`**

```markdown
---
description: Retrospective (greenfield step 14 / inherited step 13): produce a sprint-keyed Retrospective Insights Pack, via the retrospective-insights agent.
argument-hint: <engagement-slug> [sprint-number]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/retro** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it after each sprint review. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional sprint number (`<sprint>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<sprint>` is empty, DEFAULT it to the current `sprint:` value in `engagement.md`'s frontmatter — or `1` if there is no `sprint:` marker yet. Validate `<sprint>` as a positive integer `^[0-9]+$`; otherwise ask again. The output key is `sprint-<sprint>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 14; `<template>` = `templates/shared/retrospective-insights-pack.md`; `<pack>` = `Retrospective Insights Pack`.
   - **inherited** → `<step>` = 13; `<template>` = `templates/inherited/inherited-retrospective-insights-pack.md`; `<pack>` = `Inherited Retrospective Insights Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — the retrospective usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/retro/sprint-<sprint>.md`. Create the `src/<eng>/delivery/retro/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **retrospective-insights** subagent (`subagent_type: retrospective-insights`). Instruct it to: read the sprint review pack for this sprint (`delivery/sprint-review/sprint-<sprint>.md` if present) plus the sprint's `delivery/execution/`, `delivery/qa/`, and `delivery/pr-review/` artifacts and any prior `delivery/retro/` packs (to track recurring patterns and prior action items); surface blockers, estimation misses, and quality/communication patterns for **sprint <sprint>** and propose improvement experiments; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · retro · sprint-<sprint> → delivery/retro/sprint-<sprint>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where), that the team owns the improvements (AI only surfaces patterns), and the next action: start the next sprint — bump `sprint:` in `engagement.md` and continue the execution loop (re-run `/sprint-plan <eng>` if you re-plan the backlog).

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Run the verifier — scenario-aware command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `command present: sprint-review` and `command present: retro` (plus frontmatter checks) PASS; their `templates/…` link-integrity (`sprint-review-pack`, `inherited-sprint-review-pack`, `retrospective-insights-pack`, `inherited-retrospective-insights-pack`) and `subagent exists: scrum-planning` / `retrospective-insights` PASS. `release-readiness`/`modernize` still FAIL.

- [ ] **Step 4: Commit**

```powershell
git add .claude/commands/sprint-review.md .claude/commands/retro.md
git commit -q -m "Add scenario-aware sprint-review & retro commands"
```

---

## Task 3: Single-scenario wrap-up commands (`/release-readiness`, `/modernize`)

**Files:** Create `.claude/commands/release-readiness.md`, `.claude/commands/modernize.md`

These keep a hard scenario guard (mirroring `/initial-backlog` / `/recover-rules`) and cross-reference each other.

- [ ] **Step 1: Create `.claude/commands/release-readiness.md`**

```markdown
---
description: Release readiness (greenfield step 15): assess a release into a release-keyed Release Readiness Pack, via the devops agent.
argument-hint: <engagement-slug> <release-label>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/release-readiness** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it per release candidate. It is for **greenfield** engagements; inherited engagements run `/modernize` instead.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the release label (`<release>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<release>` is empty, ask the user which release (e.g. `v1.2` or `sprint-3`). Validate `<release>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — its milestone wrap-up is `/modernize <eng>` (Modernization Roadmap), not release readiness."
4. **Soft prerequisite check.** Confirm `src/<eng>/delivery/sprint-planning-support-pack.md` exists. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — release readiness usually runs late in an active sprint; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/release-readiness/<release>.md`. Create the `src/<eng>/delivery/release-readiness/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **devops** subagent (`subagent_type: devops`). Instruct it to: read the prior artifacts in `src/<eng>/delivery/` (sprint planning pack, the release's `delivery/qa/` and `delivery/pr-review/` artifacts) and, if a cloned project repo is present under `src/<eng>/`, its CI/CD config and environment info; assess deployment readiness, rollback plan, and go/no-go for release **`<release>`**; fill the template `templates/shared/release-readiness-pack.md`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). The agent never deploys autonomously — a human approves the deploy.
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · release-readiness · <release> → delivery/release-readiness/<release>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where) and that a human (DevOps / PO) owns the go/no-go and the deploy — the pack is advisory and the `devops` agent never deploys autonomously. Continue the sprint loop or close out the milestone.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/modernize.md`**

```markdown
---
description: Modernization (inherited step 14): produce or update the engagement's living Modernization Roadmap, via the documentation agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/modernize** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This produces a single **living** Modernization Roadmap for the engagement (re-running updates it in place). It is for **inherited** engagements; greenfield engagements run `/release-readiness` instead.

1. **Resolve arguments.** `$ARGUMENTS` is just the engagement slug (`<eng>`); there is no second argument. If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name).
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — its release wrap-up is `/release-readiness <eng> <release>`, not modernization."
4. **Soft prerequisite check.** Confirm `src/<eng>/delivery/inherited-sprint-planning-support-pack.md` exists. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — modernization usually follows stabilization; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/modernization-roadmap.md` (a single living document — no per-instance subfolder).
6. **Delegate to the agent.** Use the Task tool to spawn the **documentation** subagent (`subagent_type: documentation`). Instruct it to: read the inherited analysis artifacts in `src/<eng>/delivery/` (initial system assessment, business rule recovery report, codebase & architecture map, stabilization backlog) and, if a cloned project repo is present under `src/<eng>/`, the repo; propose a prioritized, risk-aware modernization roadmap (incremental steps, sequencing, risks); fill the template `templates/inherited/modernization-roadmap.md`; write the completed artifact to `<output>` — if `<output>` already exists, UPDATE it in place (use Edit for surgical changes rather than regenerating wholesale); and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · modernize → delivery/modernization-roadmap.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value (this line omits an item token because the roadmap is a single living doc). If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced or updated (and where) and the next action: PO / Architect / Client review the roadmap; feed prioritized items back into the backlog via `/stabilization-backlog <eng>` or `/refine <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Run the verifier — all 22 command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 22 `command present` checks PASS; link-integrity confirms every `templates/…` path (`release-readiness-pack`, `modernization-roadmap`) and `subagent_type:` (`devops`, `documentation`) resolves; no `WARN unexpected command file`; `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 4: Commit**

```powershell
git add .claude/commands/release-readiness.md .claude/commands/modernize.md
git commit -q -m "Add single-scenario release-readiness & modernize commands"
```

---

## Task 4: Wire commands into CLAUDE.md

**Files:** Modify `CLAUDE.md`

- [ ] **Step 1: Fill the Command column in the Greenfield run-order table**

In `CLAUDE.md`'s `### Greenfield (new build)` table, replace this exact block:

```
| 13 | Sprint Review | `scrum-planning` | `templates/shared/sprint-review-pack.md` | — (manual) |
| 14 | Retrospective | `retrospective-insights` | `templates/shared/retrospective-insights-pack.md` | — (manual) |
| 15 | Release readiness | `devops` | `templates/shared/release-readiness-pack.md` | — (manual) |
```

with:

```
| 13 | Sprint Review | `scrum-planning` | `templates/shared/sprint-review-pack.md` | `/sprint-review` |
| 14 | Retrospective | `retrospective-insights` | `templates/shared/retrospective-insights-pack.md` | `/retro` |
| 15 | Release readiness | `devops` | `templates/shared/release-readiness-pack.md` | `/release-readiness` |
```

- [ ] **Step 2: Fill the Command column in the Inherited run-order table**

In `CLAUDE.md`'s `### Inherited (existing / takeover)` table, replace this exact block:

```
| 12 | Sprint Review | `scrum-planning` | `templates/inherited/inherited-sprint-review-pack.md` | — (manual) |
| 13 | Retrospective | `retrospective-insights` | `templates/inherited/inherited-retrospective-insights-pack.md` | — (manual) |
| 14 | Modernization | `documentation` (+ Architect) | `templates/inherited/modernization-roadmap.md` | — (manual) |
```

with:

```
| 12 | Sprint Review | `scrum-planning` | `templates/inherited/inherited-sprint-review-pack.md` | `/sprint-review` |
| 13 | Retrospective | `retrospective-insights` | `templates/inherited/inherited-retrospective-insights-pack.md` | `/retro` |
| 14 | Modernization | `documentation` (+ Architect) | `templates/inherited/modernization-roadmap.md` | `/modernize` |
```

- [ ] **Step 3: Update the cross-cutting note under the tables**

Replace this paragraph:

```
Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`. Of these, code review, QA, and the Daily Scrum now have recurring commands (`/pr-review`, `/qa`, `/daily-scrum`), alongside sprint execution (`/execution`), for both tracks; security review and release readiness remain manual (see Slash commands below).
```

with:

```
Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`. Of these, code review, QA, the Daily Scrum, and release readiness now have commands (`/pr-review`, `/qa`, `/daily-scrum`, `/release-readiness`), alongside sprint execution (`/execution`); only security review remains without a command (see Slash commands below).
```

- [ ] **Step 4: Update the "Slash commands" section**

In `CLAUDE.md`'s `## Slash commands` section, (a) add a wrap-up bullet after the "Recurring per-sprint" bullet, and (b) replace the trailing scenario-aware paragraph. First, insert this bullet immediately after the line that begins "- Recurring per-sprint (both scenarios):":

```
- Sprint wrap-up: `/sprint-review <eng> [sprint]` → `/retro <eng> [sprint]` (both scenarios, keyed by sprint number), then `/release-readiness <eng> <release>` (greenfield) or `/modernize <eng>` (inherited).
```

Then replace this paragraph:

```
`/refine`, `/sprint-plan`, `/execution`, and `/qa` are scenario-aware — they read `engagement.md` and pick the right template for the track (`/daily-scrum` and `/pr-review` are shared). The recurring commands set `phase: execution` and a `sprint:` marker on first run; to start a new sprint, bump `sprint:` in `engagement.md`. The remaining per-sprint steps (greenfield steps 13+, inherited steps 12+ — sprint review, retrospective, release / modernization) have no command yet — run their agents manually per the run-order tables above.
```

with:

```
`/refine`, `/sprint-plan`, `/execution`, `/qa`, `/sprint-review`, and `/retro` are scenario-aware — they read `engagement.md` and pick the right template for the track; `/daily-scrum` and `/pr-review` are shared; `/release-readiness` (greenfield) and `/modernize` (inherited) are single-scenario with a guard that points to the other. The recurring commands set `phase: execution` and a `sprint:` marker on first run; to start a new sprint, bump `sprint:` in `engagement.md`. Every step in the run-order tables now has a command — only the optional `security-review` command, reusable skills, and plugin packaging remain unbuilt.
```

- [ ] **Step 5: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 6: Commit**

```powershell
git add CLAUDE.md
git commit -q -m "Wire wrap-up commands into CLAUDE.md; full run-order coverage"
```

---

## Task 5: Update README and delete the ROADMAP

**Files:** Modify `README.md`; delete `docs/ROADMAP.md`

- [ ] **Step 1: Update the README "Deferred (future passes)" note**

Replace the `## Deferred (future passes)` paragraph in `README.md`:

```
The intake + discovery, setup + planning, and recurring sprint-execution + QA slash commands are built — the once-per-engagement chain from `/intake` through `/sprint-plan`, plus the recurring `/execution`, `/daily-scrum`, `/pr-review`, and `/qa` (greenfield and inherited). Still deferred: commands for the per-sprint/milestone wrap-up (sprint review → retrospective → release / modernization), an `/automate-tests` command, reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

with:

```
Every run-order step now has a slash command — the full once-per-engagement chain (`/intake` → `/sprint-plan`), the recurring sprint loop (`/execution`, `/daily-scrum`, `/pr-review`, `/qa`), and the wrap-up (`/sprint-review`, `/retro`, and `/release-readiness` (greenfield) / `/modernize` (inherited)), for both greenfield and inherited. Still optional / deferred: a `security-review` command, an `/automate-tests` command, reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

- [ ] **Step 2: Confirm nothing references `docs/ROADMAP.md`, then delete it**

First confirm there are no dangling references (expected: only matches inside `docs/` self-references / the file itself):

```powershell
Select-String -Path CLAUDE.md,README.md,scripts/verify-scaffold.ps1 -Pattern 'ROADMAP' -SimpleMatch
```
Expected: no output (none of these reference it).

Then delete the build tracker — its deletion trigger (Passes 3–5 merged) is now met:

```powershell
git rm docs/ROADMAP.md
```

- [ ] **Step 3: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (the verifier never referenced `docs/ROADMAP.md`).

- [ ] **Step 4: Commit**

```powershell
git add README.md
git commit -q -m "Update README for full command coverage; remove completed ROADMAP build tracker"
```

---

## Task 6: Final verification, smoke test, wrap-up

- [ ] **Step 1: Full verifier run**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`, exit 0. No `WARN unexpected command file` lines.

- [ ] **Step 2: Link integrity + no remaining "— (manual)" rows**

Run:
```powershell
$broken = 0
Get-ChildItem .claude/commands/*.md | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  [regex]::Matches($c,'templates/[A-Za-z0-9_./-]+\.md') | ForEach-Object {
    if (-not (Test-Path $_.Value)) { Write-Host "BROKEN: $($_.Value) in $($_.Name)" -ForegroundColor Red; $broken++ }
  }
}
$agentNames = (Get-ChildItem .claude/agents/*.md | ForEach-Object { $_.BaseName })
Get-ChildItem .claude/commands/*.md | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  [regex]::Matches($c,'subagent_type:\s*`?([a-z][a-z-]*)`?') | ForEach-Object {
    $n = $_.Groups[1].Value
    if ($agentNames -notcontains $n) { Write-Host "UNKNOWN AGENT '$n'" -ForegroundColor Red; $broken++ }
  }
}
if ($broken -eq 0) { Write-Host "OK - command template + agent references resolve" -ForegroundColor Green }
$manual = Select-String -Path CLAUDE.md -Pattern '— \(manual\)'
if (-not $manual) { Write-Host "OK - no '— (manual)' rows remain in CLAUDE.md (full coverage)" -ForegroundColor Green } else { Write-Host "STILL MANUAL: $($manual.Count) rows" -ForegroundColor Red }
```
Expected: `OK - command template + agent references resolve` and `OK - no '— (manual)' rows remain`.

- [ ] **Step 3: Manual smoke test (document the result)**

Use a slug that passes the slug rule — `smoke5`, NOT `_smoke5`. Set up a throwaway greenfield engagement mid-sprint (frontmatter `sprint: 2`):
```powershell
New-Item -ItemType Directory -Force src/smoke5/delivery | Out-Null
Set-Content src/smoke5/delivery/sprint-planning-support-pack.md "# Sprint Planning Support Pack`n`nSprint Goal: ship MVP." -Encoding utf8
@"
---
engagement: smoke5
scenario: greenfield
phase: execution
sprint: 2
created: 2026-06-12
---

## Completed steps
- [x] 1 Project Request Brief — delivery/project-request-brief.md
"@ | Set-Content src/smoke5/engagement.md -Encoding utf8
```
In Claude Code:
- Run `/sprint-review smoke5` (no sprint arg) → confirm it writes `src/smoke5/delivery/sprint-review/sprint-2.md` (defaulted from the `sprint: 2` marker) and appends an `## Activity log` line `… · sprint-review · sprint-2 → delivery/sprint-review/sprint-2.md`.
- Run `/modernize smoke5` → confirm the greenfield scenario guard STOPS it and points to `/release-readiness` (no artifact written).
- Confirm `## Completed steps` is unchanged and `git status` shows nothing under `src/smoke5/` (gitignored).
Clean up:
```powershell
Remove-Item -Recurse -Force src/smoke5
```

- [ ] **Step 4: Report completion**

Summarize files created/modified/deleted, verifier result, and the smoke-test outcome. Note `main` can fast-forward from `review-retro-release-commands`. Merge/push per the build process (fast-forward merge to main, push, delete branch). Pass 5 completes the build: the ROADMAP is gone, command coverage is total.

---

## Self-review (completed by plan author)

**Spec coverage:** §2 D1 two single-scenario third-step commands → Task 3 (`/release-readiness` greenfield guard, `/modernize` inherited guard, cross-referencing). D2 sprint-number keying w/ marker default → Task 2 step 1 of both bodies + derive-output (`sprint-<sprint>.md`). D3 modernize single living doc → Task 3 Step 2 (no second arg, `delivery/modernization-roadmap.md`, update-in-place). D4 scenario-aware vs single-scenario split → Task 2 branches, Task 3 guards. D5 delegate via Task → step 6 of every body. D6 soft gate → step 4 of every body (warn + continue). D7 delete ROADMAP → Task 5 Step 2. §3 command set (4) → Tasks 2–3. §4 no schema change / activity-log format incl. modernize's item-less line → update-state steps. §5 anatomy + §5.1 branch tables → rendered bodies. §5.2 report-next → step 8 (step 8/8/8 and modernize step 8). §6 docs → Tasks 4–5. §7 verification → Task 1 + Task 6.

**Placeholder scan:** No "TBD/handle appropriately". The `<eng>`, `<sprint>`, `<release>`, `<N>`, `<step>`, `<template>`, `<pack>`, `<output>`, `<today>` tokens are documented runtime variables, each given concrete values (scenario branches in step 3 for aware commands; literal template/agent paths for single-scenario) and concrete derivation rules (sprint from marker; release from `$ARGUMENTS`; `<today>`/`<N>` from environment + frontmatter). Command bodies are fully rendered.

**Type/name consistency:** Command names match across the verifier `$expectedCmds` (Task 1), the file map, Tasks 2–3 bodies, the CLAUDE.md tables + cross-cutting note + Slash-commands section (Task 4), and README (Task 5): `sprint-review`, `retro`, `release-readiness`, `modernize`. Agent names in `subagent_type` (`scrum-planning`, `retrospective-insights`, `devops`, `documentation`) all exist in `.claude/agents/`. Template paths match existing `templates/` files (sprint-review-pack, inherited-sprint-review-pack, retrospective-insights-pack, inherited-retrospective-insights-pack, release-readiness-pack, modernization-roadmap). Output folders (`sprint-review`, `retro`, `release-readiness`) match the activity token in each activity-log line; `/modernize` correctly uses no subfolder and an item-less log line. Step numbers (GF 13/14/15, INH 12/13/14) match the run-order tables and branch tables.
