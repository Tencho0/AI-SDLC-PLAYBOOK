# Setup & Planning Slash Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 7 slash commands for the once-per-engagement Setup & Planning chain (greenfield steps 5–8, inherited steps 5–9) — each orchestrating in the main context and delegating artifact production to the mapped subagent, tracked by `engagement.md`.

**Architecture:** Each command is a Markdown prompt in `.claude/commands/<name>.md` that runs in the **main context** and uses the **Task tool** to spawn the mapped subagent (`subagent_type: <agent>`), which fills a template and writes the artifact into `src/<eng>/delivery/`. Five commands are single-scenario (hard scenario guard, mirroring Pass 2's step commands); two (`/refine`, `/sprint-plan`) are scenario-aware and branch on `engagement.md`'s `scenario` like `/intake`. `/intake`'s seeded checklist is extended to the full linear chain. No runtime app, so "tests" = the existing structural verifier extended with the new command names (run first to confirm they fail, then driven green) plus a documented manual smoke test. Spec: `docs/superpowers/specs/2026-06-11-ai-sdlc-setup-planning-commands-design.md`.

**Tech Stack:** Claude Code custom slash commands (`.claude/commands/*.md`, YAML frontmatter, `$ARGUMENTS`, Task-tool delegation), Markdown, PowerShell 5.1 (verifier), git.

**Branch:** `setup-planning-commands` (already created; spec already committed there).

---

## File map (what gets created / modified)

```
.claude/commands/initial-backlog.md         Task 3   (GF step 5)
.claude/commands/architecture.md            Task 3   (GF step 6)
.claude/commands/recover-rules.md           Task 4   (INH step 5)
.claude/commands/map-codebase.md            Task 4   (INH step 6; needs cloned repo)
.claude/commands/stabilization-backlog.md   Task 4   (INH step 7)
.claude/commands/refine.md                  Task 5   (GF step 7 / INH step 8; scenario-aware)
.claude/commands/sprint-plan.md             Task 5   (GF step 8 / INH step 9; scenario-aware)
scripts/verify-scaffold.ps1                 Task 1   (modify: add 7 names to $expectedCmds)
.claude/commands/intake.md                  Task 2   (modify: extend seed to full linear chain)
CLAUDE.md                                    Task 6   (modify: Command column + Slash commands section)
README.md                                   Task 7   (modify: quick-start chain + deferred note)
docs/ROADMAP.md                             Task 7   (modify: Pass 3 status + log)
```

`engagement.md` is created at **runtime** by `/intake` under `src/<eng>/` (gitignored) — not a repo file.

---

## Authoring contracts (read once; referenced by Tasks 2–5)

### Output-path convention
Output filename = template basename, written to `src/<eng>/delivery/`. The `engagement.md`
step line records it as `delivery/<basename>.md`.

### Single-scenario step-command shared shape (Tasks 3 & 4)
Frontmatter is always:
```markdown
---
description: <one line>
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```
Body (7 numbered steps): resolve engagement → load state (missing → "run `/intake` first")
→ scenario guard (mismatch → stop, name the other track's commands) → check prerequisite
(prior `delivery/` artifact; missing → "do X first", produce nothing) → delegate to the
mapped subagent via Task → update state (tick step N; if the line is absent, insert it in
numeric order) → report next. Footer: "You orchestrate only — the agent produces the artifact
and a human reviews it. Never paste secrets or production data."

The exact rendered body for each command is given verbatim in its task step — copy it as-is.

---

## Task 1: Extend the verifier with the new command names (test-first)

**Files:** Modify `scripts/verify-scaffold.ps1`

- [ ] **Step 1: Add the 7 names to `$expectedCmds`**

In `scripts/verify-scaffold.ps1` section 4, replace this block:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal'
```

with:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan'
```

- [ ] **Step 2: Run the verifier — the new checks FAIL**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: the 7 previously-passing commands still PASS; 7 new `command present: <name>` lines FAIL; exit code 1. Confirms the harness sees the missing commands.

- [ ] **Step 3: Commit**

```powershell
git add scripts/verify-scaffold.ps1
git commit -q -m "Extend verifier with Pass 3 setup & planning command names"
```

---

## Task 2: Extend `/intake`'s seed to the full linear chain

**Files:** Modify `.claude/commands/intake.md`

- [ ] **Step 1: Extend the greenfield seed block**

In `.claude/commands/intake.md` step 6, replace the greenfield seed block:

```
     ## Completed steps
     - [x] 1 Project Request Brief — delivery/project-request-brief.md
     - [ ] 2 Discovery Workshop Plan
     - [ ] 3 Discovery Meeting Summary
     - [ ] 4 Product Goal Draft
```

with:

```
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

- [ ] **Step 2: Extend the inherited seed block**

In the same step 6, replace the inherited seed block:

```
     ## Completed steps
     - [x] 1 Takeover Request Brief — delivery/takeover-request-brief.md
     - [ ] 2 Access & Information Checklist
     - [ ] 3 Initial System Assessment
     - [ ] 4 Inherited Project Goal Draft
```

with:

```
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

- [ ] **Step 3: Commit**

```powershell
git add .claude/commands/intake.md
git commit -q -m "Extend /intake seed to the full once-per-engagement chain"
```

---

## Task 3: Greenfield setup commands

**Files:** Create `.claude/commands/initial-backlog.md`, `.claude/commands/architecture.md`

- [ ] **Step 1: Create `.claude/commands/initial-backlog.md`**

```markdown
---
description: "Greenfield setup (step 5): turn the Product Goal into an Initial Product Backlog Pack, via the product-backlog agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/initial-backlog** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its setup commands instead: `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/product-goal-draft.md` exists (step 4 done). If unmet, STOP with: "Product Goal missing — run `/product-goal <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-backlog** subagent (`subagent_type: product-backlog`). Instruct it to: read all discovery artifacts in `src/<eng>/delivery/` (request brief, workshop plan, meeting summary, product goal draft); fill the template `templates/greenfield/initial-product-backlog-pack.md`; write the completed artifact to `src/<eng>/delivery/initial-product-backlog-pack.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 5's line to `- [x] 5 Initial Product Backlog Pack — delivery/initial-product-backlog-pack.md`. If no step-5 line exists (an engagement created before setup steps were tracked), insert it in numeric order after step 4.
7. **Report next.** Tell the user what was produced and the next action: Run `/architecture <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/architecture.md`**

```markdown
---
description: "Greenfield setup (step 6): set the technical foundation as an Architecture & Technical Foundation Pack, via the implementation agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/architecture** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its setup commands instead: `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/initial-product-backlog-pack.md` exists (step 5 done). If unmet, STOP with: "Initial Product Backlog missing — run `/initial-backlog <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the discovery + backlog artifacts in `src/<eng>/delivery/` (product goal draft, initial product backlog pack); fill the template `templates/greenfield/architecture-technical-foundation-pack.md`; write the completed artifact to `src/<eng>/delivery/architecture-technical-foundation-pack.md`; record where `security-review` and `documentation` should follow up in the pack's Recommendations / Open questions; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 6's line to `- [x] 6 Architecture & Technical Foundation Pack — delivery/architecture-technical-foundation-pack.md`. If no step-6 line exists, insert it in numeric order after step 5.
7. **Report next.** Tell the user what was produced and the next action: Run `/refine <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Run the verifier — greenfield command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `command present: initial-backlog` and `command present: architecture` (plus their frontmatter checks) PASS.

- [ ] **Step 4: Commit**

```powershell
git add .claude/commands/initial-backlog.md .claude/commands/architecture.md
git commit -q -m "Add greenfield setup commands (steps 5-6)"
```

---

## Task 4: Inherited setup commands

**Files:** Create `.claude/commands/recover-rules.md`, `.claude/commands/map-codebase.md`, `.claude/commands/stabilization-backlog.md`

- [ ] **Step 1: Create `.claude/commands/recover-rules.md`**

```markdown
---
description: "Inherited stabilization (step 5): reconstruct how the system behaves as a Business Rule Recovery Report, via the documentation agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/recover-rules** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its setup commands instead: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/inherited-project-goal-draft.md` exists (step 4 done). If unmet, STOP with: "Stabilization Goal missing — run `/stabilization-goal <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **documentation** subagent (`subagent_type: documentation`). Instruct it to: read the prior inherited artifacts in `src/<eng>/delivery/` (takeover brief, access checklist, system assessment, project goal draft) and, if a project repo is cloned under `src/<eng>/`, the codebase itself; fill the template `templates/inherited/business-rule-recovery-report.md`; write the completed artifact to `src/<eng>/delivery/business-rule-recovery-report.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 5's line to `- [x] 5 Business Rule Recovery Report — delivery/business-rule-recovery-report.md`. If no step-5 line exists, insert it in numeric order after step 4.
7. **Report next.** Tell the user what was produced and the next action: Run `/map-codebase <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/map-codebase.md`**

Note the extended prerequisite (step 4) — it reuses `/system-assessment`'s hardened repo detection because mapping the codebase needs the cloned repo present.

```markdown
---
description: "Inherited stabilization (step 6): map the cloned codebase into a Codebase & Architecture Map, via the implementation agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/map-codebase** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its setup commands instead: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`."
4. **Check prerequisites & locate the repo.** First, confirm step 5 is done: `src/<eng>/delivery/business-rule-recovery-report.md` exists. If not, STOP with: "Business Rule Recovery Report missing — run `/recover-rules <eng>` first." Then locate the cloned project repo: a subdirectory of `src/<eng>/` other than `request/` and `delivery/` that actually contains the codebase (look for a `.git` directory or real source files). If there are none, STOP with: "No cloned project repo found under `src/<eng>/` — clone it into `src/<eng>/<project-repo>/` (access required) first." If there are several candidates, or the only candidate looks empty / non-code (e.g. a scratch or notes folder), ASK the user to confirm which folder is the project repo rather than guessing. Call the confirmed folder `<repo>`; produce nothing until a real repo is confirmed.
5. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the confirmed project repo at `src/<eng>/<repo>/` plus prior artifacts in `src/<eng>/delivery/` (system assessment, business rule recovery report); fill the template `templates/inherited/codebase-architecture-map.md`; write the completed artifact to `src/<eng>/delivery/codebase-architecture-map.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 6's line to `- [x] 6 Codebase & Architecture Map — delivery/codebase-architecture-map.md`. If no step-6 line exists, insert it in numeric order after step 5.
7. **Report next.** Tell the user what was produced and the next action: Run `/stabilization-backlog <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Create `.claude/commands/stabilization-backlog.md`**

```markdown
---
description: "Inherited stabilization (step 7): turn assessment findings into a Stabilization Product Backlog, via the product-backlog agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/stabilization-backlog** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its setup commands instead: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/codebase-architecture-map.md` exists (step 6 done). If unmet, STOP with: "Codebase & Architecture Map missing — run `/map-codebase <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-backlog** subagent (`subagent_type: product-backlog`). Instruct it to: read all inherited artifacts in `src/<eng>/delivery/` (system assessment, business rule recovery report, codebase & architecture map, project goal draft); fill the template `templates/inherited/stabilization-product-backlog.md`; write the completed artifact to `src/<eng>/delivery/stabilization-product-backlog.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 7's line to `- [x] 7 Stabilization Product Backlog — delivery/stabilization-product-backlog.md`. If no step-7 line exists, insert it in numeric order after step 6.
7. **Report next.** Tell the user what was produced and the next action: Run `/refine <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 4: Run the verifier — inherited command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `command present: recover-rules`, `map-codebase`, `stabilization-backlog` (plus frontmatter checks) PASS.

- [ ] **Step 5: Commit**

```powershell
git add .claude/commands/recover-rules.md .claude/commands/map-codebase.md .claude/commands/stabilization-backlog.md
git commit -q -m "Add inherited setup commands (steps 5-7)"
```

---

## Task 5: Scenario-aware refinement & planning commands

**Files:** Create `.claude/commands/refine.md`, `.claude/commands/sprint-plan.md`

These two do **not** reject either track — they read `scenario` and branch (like `/intake`).

- [ ] **Step 1: Create `.claude/commands/refine.md`**

```markdown
---
description: "Backlog refinement (greenfield step 7 / inherited step 8): refine a backlog item to Ready as a Refined Story Pack, via the product-backlog agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/refine** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

This command works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template and step — it does not reject either track.

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and select the track, fixing `<step>`, `<prereq>`, `<template>`, `<output>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 7; `<prereq>` = `src/<eng>/delivery/architecture-technical-foundation-pack.md`; `<template>` = `templates/shared/refined-story-pack.md`; `<output>` = `src/<eng>/delivery/refined-story-pack.md`; `<pack>` = `Refined Story Pack`.
   - **inherited** → `<step>` = 8; `<prereq>` = `src/<eng>/delivery/stabilization-product-backlog.md`; `<template>` = `templates/inherited/inherited-refined-story-pack.md`; `<output>` = `src/<eng>/delivery/inherited-refined-story-pack.md`; `<pack>` = `Inherited Refined Story Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Check prerequisite.** Confirm `<prereq>` exists. If unmet, STOP with — greenfield: "Architecture & Technical Foundation Pack missing — run `/architecture <eng>` first." · inherited: "Stabilization Product Backlog missing — run `/stabilization-backlog <eng>` first." Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-backlog** subagent (`subagent_type: product-backlog`). Instruct it to: read the relevant prior artifacts in `src/<eng>/delivery/` (greenfield: backlog pack + architecture pack; inherited: stabilization backlog + codebase map); fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). If the user named a specific backlog item to refine, refine that one; otherwise refine the top-priority item from the backlog and state which item you refined.
6. **Update state.** In `src/<eng>/engagement.md`, change step `<step>`'s line to `- [x] <step> <pack> — delivery/<basename of `<output>`>`. If no line for that step exists, insert it in numeric order.
7. **Report next.** Tell the user what was produced and the next action: Run `/sprint-plan <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Create `.claude/commands/sprint-plan.md`**

```markdown
---
description: "Sprint Planning (greenfield step 8 / inherited step 9): produce the Sprint Planning Support Pack, via the scrum-planning agent."
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/sprint-plan** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

This command works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template and step — it does not reject either track.

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and select the track, fixing `<step>`, `<prereq>`, `<template>`, `<output>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 8; `<prereq>` = `src/<eng>/delivery/refined-story-pack.md`; `<template>` = `templates/shared/sprint-planning-support-pack.md`; `<output>` = `src/<eng>/delivery/sprint-planning-support-pack.md`; `<pack>` = `Sprint Planning Support Pack`.
   - **inherited** → `<step>` = 9; `<prereq>` = `src/<eng>/delivery/inherited-refined-story-pack.md`; `<template>` = `templates/inherited/inherited-sprint-planning-support-pack.md`; `<output>` = `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`; `<pack>` = `Inherited Sprint Planning Support Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Check prerequisite.** Confirm `<prereq>` exists. If unmet, STOP with — greenfield: "Refined Story Pack missing — run `/refine <eng>` first." · inherited: "Inherited Refined Story Pack missing — run `/refine <eng>` first." Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **scrum-planning** subagent (`subagent_type: scrum-planning`). Instruct it to: read the refined story pack and prior backlog artifacts in `src/<eng>/delivery/`; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step `<step>`'s line to `- [x] <step> <pack> — delivery/<basename of `<output>`>`. If no line for that step exists, insert it in numeric order.
7. **Report next.** Tell the user what was produced and the next action: Setup & planning is complete. The next steps are the recurring per-sprint events (greenfield: sprint execution, daily scrum, code review, QA…; inherited: safe execution, regression QA…) — their commands aren't built yet, so run their agents manually per `CLAUDE.md`'s run-order table.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 3: Run the verifier — all 14 command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 14 `command present` checks PASS; the link-integrity section confirms every `templates/…` path and `subagent_type:` in the new commands resolves; `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 4: Commit**

```powershell
git add .claude/commands/refine.md .claude/commands/sprint-plan.md
git commit -q -m "Add scenario-aware refine & sprint-plan commands"
```

---

## Task 6: Wire commands into CLAUDE.md

**Files:** Modify `CLAUDE.md`

- [ ] **Step 1: Fill the Command column in the Greenfield run-order table**

In `CLAUDE.md`'s `### Greenfield (new build)` table, replace `— (manual)` in the Command column for these rows (leave the others unchanged):

- Row `| 5 | Initial backlog | ... |` → Command `/initial-backlog`
- Row `| 6 | Architecture foundation | ... |` → Command `/architecture`
- Row `| 7 | Backlog refinement | ... |` → Command `/refine`
- Row `| 8 | Sprint Planning | ... |` → Command `/sprint-plan`

- [ ] **Step 2: Fill the Command column in the Inherited run-order table**

In `CLAUDE.md`'s `### Inherited (existing / takeover)` table, replace `— (manual)` in the Command column for these rows:

- Row `| 5 | Business-rule recovery | ... |` → Command `/recover-rules`
- Row `| 6 | Codebase mapping | ... |` → Command `/map-codebase`
- Row `| 7 | Stabilization backlog | ... |` → Command `/stabilization-backlog`
- Row `| 8 | Backlog refinement | ... |` → Command `/refine`
- Row `| 9 | Sprint Planning | ... |` → Command `/sprint-plan`

- [ ] **Step 3: Update the "Slash commands" section**

In `CLAUDE.md`'s `## Slash commands` section, replace the existing bullet list and the trailing "Steps 5+ have no command yet" line with:

```markdown
The intake + discovery and setup + planning phases are automated by commands in `.claude/commands/`. Each takes the engagement slug as its argument, orchestrates in the main conversation (so it can ask you questions and track progress in `src/<eng>/engagement.md`), and delegates the actual artifact to the mapped agent.

- `/intake <eng>` — bootstrap the engagement, classify greenfield/inherited, produce the first brief.
- Greenfield discovery → setup/planning: `/discovery-prep` → `/discovery-summary` → `/product-goal` → `/initial-backlog` → `/architecture` → `/refine` → `/sprint-plan`.
- Inherited discovery → setup/planning: `/access-checklist` → `/system-assessment` → `/stabilization-goal` → `/recover-rules` → `/map-codebase` → `/stabilization-backlog` → `/refine` → `/sprint-plan`.

`/refine` and `/sprint-plan` are scenario-aware — they read `engagement.md` and pick the right template for the track. The recurring per-sprint steps beyond planning (greenfield steps 9+, inherited steps 10+) have no command yet — run their agents manually per the run-order tables above.
```

- [ ] **Step 4: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 5: Commit**

```powershell
git add CLAUDE.md
git commit -q -m "Wire setup & planning commands into CLAUDE.md run-order and slash-commands section"
```

---

## Task 7: Update README and ROADMAP

**Files:** Modify `README.md`, `docs/ROADMAP.md`

- [ ] **Step 1: Extend the README quick-start chain**

In `README.md`'s "Start a new engagement" list, replace step 3:

```markdown
3. Follow the command it points you to next — greenfield: `/discovery-prep` → `/discovery-summary` → `/product-goal`; inherited: `/access-checklist` → `/system-assessment` → `/stabilization-goal`.
```

with:

```markdown
3. Follow the command it points you to next, through discovery into setup & planning — greenfield: `/discovery-prep` → `/discovery-summary` → `/product-goal` → `/initial-backlog` → `/architecture` → `/refine` → `/sprint-plan`; inherited: `/access-checklist` → `/system-assessment` → `/stabilization-goal` → `/recover-rules` → `/map-codebase` → `/stabilization-backlog` → `/refine` → `/sprint-plan`.
```

- [ ] **Step 2: Update the README "Deferred (future passes)" note**

Replace the `## Deferred (future passes)` paragraph in `README.md` with:

```markdown
## Deferred (future passes)

The intake + discovery and setup + planning slash commands are built — the full once-per-engagement chain from `/intake` through `/sprint-plan` (greenfield and inherited). Still deferred: commands for the recurring per-sprint steps (sprint execution → daily scrum → code review → QA → sprint review → retrospective → release / modernization), reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

- [ ] **Step 3: Mark Pass 3 done in `docs/ROADMAP.md`**

In the Build-order table, change the Pass 3 row's Status cell from `⏭️ Next` to `✅ Done`, and change Pass 4's Status from `📋 Planned` to `⏭️ Next`.

- [ ] **Step 4: Add a status-log line in `docs/ROADMAP.md`**

Append to the `## Status log` list:

```markdown
- Pass 3 merged + pushed; 7 setup & planning commands added (`/initial-backlog`, `/architecture`, `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, scenario-aware `/refine` + `/sprint-plan`); `/intake` seed extended to the full linear chain; built, audited, and code-reviewed. Roadmap kept (deletion waits for Passes 4–5).
```

- [ ] **Step 5: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 6: Commit**

```powershell
git add README.md docs/ROADMAP.md
git commit -q -m "Update README quick-start and ROADMAP status for Pass 3"
```

---

## Task 8: Final verification, smoke test, wrap-up

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

Confirm the new chain ticks state correctly on a throwaway greenfield engagement:
```powershell
New-Item -ItemType Directory -Force src/_smoke3/request | Out-Null
Set-Content src/_smoke3/request/req.md "Client wants a new internal tool to track field-service jobs." -Encoding utf8
```
In Claude Code: run `/intake _smoke3` (choose greenfield) and confirm `engagement.md` now seeds steps 1–8. Run `/product-goal _smoke3` is blocked until 2–3 are done (expected). To exercise Pass-3 ticking directly, hand-create the step-4 artifact then run `/initial-backlog _smoke3` and confirm it writes `delivery/initial-product-backlog-pack.md` and ticks step 5; then `/architecture _smoke3` ticks step 6. Confirm `git status` shows nothing under `src/_smoke3/` (gitignored). Clean up:
```powershell
Remove-Item -Recurse -Force src/_smoke3
```

- [ ] **Step 4: Report completion**

Summarize files created/modified, verifier result, and the smoke-test outcome. Note `main` can fast-forward from `setup-planning-commands`. Merge/push per the build process.

---

## Self-review (completed by plan author)

**Spec coverage:** §2 D1 scenario-aware `/refine`+`/sprint-plan` → Task 5 (branch tables in both bodies). D2 extend seed → Task 2 + every setup command's append-in-order fallback in its update-state step. D3 `/architecture` → implementation only → Task 3 Step 2 (single Task delegation; security-review/documentation only noted in pack). D4 single-scenario guard vs branch → Tasks 3–4 keep the guard, Task 5 branches. D5 delegate via Task → step 5 of every body. D6 prereq = prior artifact (+repo for map-codebase) → step 4 of every body; map-codebase repo detection in Task 4 Step 2. §3 command set (7) → Tasks 3–5. §4 extended seed → Task 2. §5.1/5.2 anatomy → rendered bodies. §5.3 end-of-chain next → `/sprint-plan` step 7. §7 docs → Tasks 6–7. §8 verification → Task 1 (verifier) + Task 8 (links + smoke). §9 out-of-scope → only 7 commands built; tables keep `— (manual)` for GF 9+/INH 10+.

**Placeholder scan:** No "TBD/handle appropriately". The `<eng>`, `<step>`, `<prereq>`, `<template>`, `<output>`, `<pack>` tokens in `/refine` and `/sprint-plan` are documented runtime branch variables, each given concrete values for both tracks in step 3 of those bodies. Single-scenario command bodies are fully rendered with literal paths.

**Type/name consistency:** Command names match across the verifier `$expectedCmds` (Task 1), the file map, Tasks 3–5, the CLAUDE.md tables (Task 6), the Slash-commands section, and the README chain (Task 7). Agent names in `subagent_type` (`product-backlog`, `implementation`, `documentation`, `scrum-planning`) all exist in `.claude/agents/`. Template paths match existing `templates/` files. Output basenames mirror template basenames. Step numbers and `<Pack name>` labels match the extended `engagement.md` seeds (Task 2) and the `pack:` titles in each template.
