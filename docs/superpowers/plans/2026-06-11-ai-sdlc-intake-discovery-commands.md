# Intake + Discovery Slash Commands Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add 7 slash commands (`/intake` + 6 discovery step commands) that automate the intake + discovery run order — each orchestrating in the main context and delegating artifact production to the mapped subagent, tracked by a per-engagement `engagement.md` state file.

**Architecture:** Each command is a Markdown prompt in `.claude/commands/<name>.md` that runs in the **main context** (so it can interact with the user and manage state) and uses the **Task tool** to spawn the mapped subagent (`subagent_type: <agent>`), which fills a template and writes the artifact into `src/<eng>/delivery/`. No runtime app, so "tests" = the existing structural verifier extended with a commands check (written first, fails, then driven green) plus a documented manual smoke test. Spec: `docs/superpowers/specs/2026-06-11-ai-sdlc-intake-discovery-commands-design.md`.

**Tech Stack:** Claude Code custom slash commands (`.claude/commands/*.md`, YAML frontmatter, `$ARGUMENTS`, Task-tool delegation), Markdown, PowerShell 5.1 (verifier), git.

**Branch:** `intake-discovery-commands` (already created; spec already committed there).

---

## File map (what gets created / modified)

```
.claude/commands/intake.md                 Task 2   (front door)
.claude/commands/discovery-prep.md         Task 3   (GF step 2)
.claude/commands/discovery-summary.md      Task 3   (GF step 3)
.claude/commands/product-goal.md           Task 3   (GF step 4)
.claude/commands/access-checklist.md       Task 4   (INH step 2)
.claude/commands/system-assessment.md      Task 4   (INH step 3)
.claude/commands/stabilization-goal.md     Task 4   (INH step 4)
scripts/verify-scaffold.ps1                Task 1   (modify: add commands check)
CLAUDE.md                                  Task 5   (modify: Command column + Slash commands section)
README.md                                  Task 5   (modify: quick-start leads with /intake)
```

`engagement.md` is created at **runtime** by `/intake` under `src/<eng>/` (gitignored) — it is not a repo file.

---

## Authoring contracts (read once; referenced by Tasks 2–4)

### `engagement.md` state file (created by `/intake` at runtime)

Greenfield seed:
```markdown
---
engagement: <eng>
scenario: greenfield
phase: discovery
created: <YYYY-MM-DD>
---
## Completed steps
- [x] 1 Project Request Brief — delivery/project-request-brief.md
- [ ] 2 Discovery Workshop Plan
- [ ] 3 Discovery Meeting Summary
- [ ] 4 Product Goal Draft
```
Inherited seed (same frontmatter with `scenario: inherited`):
```markdown
## Completed steps
- [x] 1 Takeover Request Brief — delivery/takeover-request-brief.md
- [ ] 2 Access & Information Checklist
- [ ] 3 Initial System Assessment
- [ ] 4 Inherited Project Goal Draft
```
`<YYYY-MM-DD>` = today's date from the environment (do not hard-code).

### Step-command shared shape

All six step commands share this exact body structure; only the italicized `<…>` data differs per command (filled from the per-command data blocks in Tasks 3–4). Frontmatter is always:
```markdown
---
description: <one line>
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```
Body:
```markdown
You are running the **/<command>** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **<scenario>** engagements. If `engagement.md`'s `scenario` is not `<scenario>`, STOP and tell the user: "`<eng>` is a <other-scenario> engagement — use its discovery commands instead: <other-command-list>."
4. **Check prerequisite.** <prereq-check>. If unmet, STOP with: "<prereq-fail-message>". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **<agent>** subagent (`subagent_type: <agent>`). Instruct it to: read <inputs>; fill the template `templates/<folder>/<template>.md`; write the completed artifact to `src/<eng>/delivery/<template>.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step <N>'s line to `- [x] <N> <Pack name> — delivery/<template>.md`.
7. **Report next.** Tell the user what was produced and the next action: <next>.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

---

## Task 1: Extend the verifier with a commands check (test-first)

**Files:** Modify `scripts/verify-scaffold.ps1`

- [ ] **Step 1: Insert the commands check**

In `scripts/verify-scaffold.ps1`, find the block that ends section 5:

```powershell
# 5. .docx removed
$docx = Get-ChildItem $root -Filter *.docx -Recurse -ErrorAction SilentlyContinue
Check (-not $docx) "no .docx files remain"
```

Immediately AFTER that block (before the `Write-Host ""` summary line), insert:

```powershell
# 6. Slash commands (7) — present with frontmatter (description + argument-hint)
$commands = 'intake','discovery-prep','discovery-summary','product-goal',
            'access-checklist','system-assessment','stabilization-goal'
foreach ($c in $commands) {
  $p = Join-Path $root ".claude/commands/$c.md"
  if (-not (Test-Path $p)) { Check $false "command: $c.md"; continue }
  $txt = Get-Content $p -Raw
  $m = [regex]::Match($txt, '(?s)^---\s*\r?\n(.*?)\r?\n---')
  Check ($m.Success) "command frontmatter: $c.md"
  if ($m.Success) {
    Check ([regex]::IsMatch($m.Groups[1].Value,'(?m)^description:\s*\S')) "command has description: $c.md"
    Check ([regex]::IsMatch($m.Groups[1].Value,'(?m)^argument-hint:\s*\S')) "command has argument-hint: $c.md"
  }
}
```

- [ ] **Step 2: Run the verifier — the new checks FAIL**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: previous checks still PASS; 7 new `command: <name>.md` lines FAIL; exit code 1. Confirms the harness sees the missing commands.

- [ ] **Step 3: Commit**

```powershell
git add scripts/verify-scaffold.ps1
git commit -q -m "Extend verifier with slash-command checks"
```

---

## Task 2: `/intake` — the front door

**Files:** Create `.claude/commands/intake.md`

- [ ] **Step 1: Create `.claude/commands/intake.md`**

```markdown
---
description: Start an engagement — bootstrap its folder, classify greenfield/inherited, and produce the first brief via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/intake** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

Work through these steps in order. Stop and ask the user wherever a step says to ask — you are in the main conversation, so interaction is expected.

1. **Resolve the engagement slug.** If `$ARGUMENTS` is empty, ask the user for a short slug (e.g. `acme-portal`). Call it `<eng>`.

2. **Bootstrap the workspace.** Create `src/<eng>/request/` and `src/<eng>/delivery/` if they do not exist. If `src/<eng>/engagement.md` already exists, show its `scenario` and completed steps and ask the user whether to re-run intake before continuing; stop if they decline.

3. **Classify (always ask).** Ask the user: "Is **<eng>** a **greenfield** (new build) or **inherited** (existing/takeover) project?" Wait for the answer. Do not guess.

4. **Resolve the request.** Look in `src/<eng>/request/`. If it contains files, use them as the client request. If it is empty, ask the user to paste the request text or give a file path, then save what they provide to `src/<eng>/request/request.md` (or copy the file into `request/`).

5. **Produce the first brief — delegate.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to read the request in `src/<eng>/request/`, fill the template — `templates/greenfield/project-request-brief.md` for greenfield or `templates/inherited/takeover-request-brief.md` for inherited — and write the completed artifact to `src/<eng>/delivery/project-request-brief.md` (greenfield) or `src/<eng>/delivery/takeover-request-brief.md` (inherited), following the template's governance footer.

6. **Write the state file.** Create `src/<eng>/engagement.md` with frontmatter `engagement: <eng>`, `scenario: <chosen>`, `phase: discovery`, `created: <today's date from the environment>`, then a `## Completed steps` checklist seeded for the chosen scenario with step 1 checked and pointing at the artifact from step 5:
   - greenfield: `1 Project Request Brief`, `2 Discovery Workshop Plan`, `3 Discovery Meeting Summary`, `4 Product Goal Draft`
   - inherited: `1 Takeover Request Brief`, `2 Access & Information Checklist`, `3 Initial System Assessment`, `4 Inherited Project Goal Draft`

7. **Report next step.** Summarize what was produced (and where), then tell the user the next command: `/discovery-prep <eng>` for greenfield, or `/access-checklist <eng>` for inherited.

You orchestrate only — the agent produces the brief and a human reviews it. Never paste secrets or production data into prompts.
```

- [ ] **Step 2: Run the verifier — intake checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `command: intake.md`, `command frontmatter: intake.md`, `command has description: intake.md`, `command has argument-hint: intake.md` all PASS (other 6 commands still FAIL).

- [ ] **Step 3: Commit**

```powershell
git add .claude/commands/intake.md
git commit -q -m "Add /intake command (engagement front door)"
```

---

## Task 3: Greenfield discovery commands

**Files:** Create `.claude/commands/discovery-prep.md`, `.claude/commands/discovery-summary.md`, `.claude/commands/product-goal.md`

Each follows the **Step-command shared shape**. Fill the `<…>` slots from the data blocks below.

- [ ] **Step 1: Create `discovery-prep.md`**

- description: `Greenfield discovery (step 2): produce the Discovery Workshop Plan from the request, via the product-discovery agent.`
- `<command>` = discovery-prep · `<scenario>` = greenfield · `<other-scenario>` = inherited · `<other-command-list>` = `/access-checklist`, `/system-assessment`, `/stabilization-goal`
- `<prereq-check>` = Confirm step 1 is checked in `engagement.md` and `src/<eng>/delivery/project-request-brief.md` exists.
- `<prereq-fail-message>` = Intake isn't complete — run `/intake <eng>` first.
- `<agent>` = product-discovery
- `<inputs>` = the request in `src/<eng>/request/` and `src/<eng>/delivery/project-request-brief.md`
- `<folder>/<template>` = greenfield/discovery-workshop-plan · output `src/<eng>/delivery/discovery-workshop-plan.md`
- `<N>` = 2 · `<Pack name>` = Discovery Workshop Plan
- `<next>` = Run your discovery workshop, save the meeting notes into `src/<eng>/request/`, then run `/discovery-summary <eng>`.

- [ ] **Step 2: Create `discovery-summary.md`**

- description: `Greenfield discovery (step 3): summarize discovery-meeting notes into a Discovery Meeting Summary, via the product-discovery agent.`
- `<command>` = discovery-summary · `<scenario>` = greenfield · `<other-scenario>` = inherited · `<other-command-list>` = `/access-checklist`, `/system-assessment`, `/stabilization-goal`
- `<prereq-check>` = Confirm `src/<eng>/delivery/discovery-workshop-plan.md` exists (step 2 done) AND that discovery-meeting notes are present in `src/<eng>/request/` beyond the original request; if you cannot identify meeting notes, ask the user which file in `request/` holds them.
- `<prereq-fail-message>` = No discovery-meeting notes found — run `/discovery-prep <eng>`, hold the workshop, and add the notes to `src/<eng>/request/` first.
- `<agent>` = product-discovery
- `<inputs>` = the discovery-meeting notes in `src/<eng>/request/` plus prior artifacts in `src/<eng>/delivery/`
- `<folder>/<template>` = greenfield/discovery-meeting-summary · output `src/<eng>/delivery/discovery-meeting-summary.md`
- `<N>` = 3 · `<Pack name>` = Discovery Meeting Summary
- `<next>` = Run `/product-goal <eng>`.

- [ ] **Step 3: Create `product-goal.md`**

- description: `Greenfield discovery (step 4): synthesize discovery into a Product Goal Draft, via the product-discovery agent.`
- `<command>` = product-goal · `<scenario>` = greenfield · `<other-scenario>` = inherited · `<other-command-list>` = `/access-checklist`, `/system-assessment`, `/stabilization-goal`
- `<prereq-check>` = Confirm `src/<eng>/delivery/discovery-meeting-summary.md` exists (step 3 done).
- `<prereq-fail-message>` = Discovery summary missing — run `/discovery-summary <eng>` first.
- `<agent>` = product-discovery
- `<inputs>` = all discovery artifacts in `src/<eng>/delivery/` (brief, workshop plan, meeting summary)
- `<folder>/<template>` = greenfield/product-goal-draft · output `src/<eng>/delivery/product-goal-draft.md`
- `<N>` = 4 · `<Pack name>` = Product Goal Draft
- `<next>` = Discovery phase complete. The next step is the Initial Product Backlog (step 5); its command isn't built yet — run the `product-backlog` agent manually per `CLAUDE.md`'s run-order table.

- [ ] **Step 4: Run the verifier — greenfield command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `discovery-prep`, `discovery-summary`, `product-goal` command checks PASS.

- [ ] **Step 5: Commit**

```powershell
git add .claude/commands/discovery-prep.md .claude/commands/discovery-summary.md .claude/commands/product-goal.md
git commit -q -m "Add greenfield discovery commands (steps 2-4)"
```

---

## Task 4: Inherited discovery commands

**Files:** Create `.claude/commands/access-checklist.md`, `.claude/commands/system-assessment.md`, `.claude/commands/stabilization-goal.md`

Each follows the **Step-command shared shape**.

- [ ] **Step 1: Create `access-checklist.md`**

- description: `Inherited takeover (step 2): produce the Access & Information Checklist from the request, via the product-discovery agent.`
- `<command>` = access-checklist · `<scenario>` = inherited · `<other-scenario>` = greenfield · `<other-command-list>` = `/discovery-prep`, `/discovery-summary`, `/product-goal`
- `<prereq-check>` = Confirm step 1 is checked in `engagement.md` and `src/<eng>/delivery/takeover-request-brief.md` exists.
- `<prereq-fail-message>` = Intake isn't complete — run `/intake <eng>` first.
- `<agent>` = product-discovery
- `<inputs>` = the request in `src/<eng>/request/` and `src/<eng>/delivery/takeover-request-brief.md`
- `<folder>/<template>` = inherited/access-information-checklist · output `src/<eng>/delivery/access-information-checklist.md`
- `<N>` = 2 · `<Pack name>` = Access & Information Checklist
- `<next>` = Once the client grants access, clone the project repo into `src/<eng>/<project-repo>/`, then run `/system-assessment <eng>`.

- [ ] **Step 2: Create `system-assessment.md`**

- description: `Inherited takeover (step 3): assess the cloned project repo into an Initial System Assessment, via the implementation agent.`
- `<command>` = system-assessment · `<scenario>` = inherited · `<other-scenario>` = greenfield · `<other-command-list>` = `/discovery-prep`, `/discovery-summary`, `/product-goal`
- `<prereq-check>` = Confirm the project repo is cloned under `src/<eng>/` — i.e. there is a subdirectory of `src/<eng>/` other than `request/` and `delivery/` (ideally containing source or a `.git`). If none is found, ask the user for the cloned repo's folder name.
- `<prereq-fail-message>` = No cloned project repo found under `src/<eng>/` — clone it into `src/<eng>/<project-repo>/` (access required) first.
- `<agent>` = implementation
- `<inputs>` = the cloned project repo under `src/<eng>/` plus prior artifacts in `src/<eng>/delivery/`
- `<folder>/<template>` = inherited/initial-system-assessment · output `src/<eng>/delivery/initial-system-assessment.md`
- `<N>` = 3 · `<Pack name>` = Initial System Assessment
- `<next>` = Run `/stabilization-goal <eng>`.

- [ ] **Step 3: Create `stabilization-goal.md`**

- description: `Inherited takeover (step 4): define the Stabilization Goal, via the product-discovery agent.`
- `<command>` = stabilization-goal · `<scenario>` = inherited · `<other-scenario>` = greenfield · `<other-command-list>` = `/discovery-prep`, `/discovery-summary`, `/product-goal`
- `<prereq-check>` = Confirm `src/<eng>/delivery/initial-system-assessment.md` exists (step 3 done).
- `<prereq-fail-message>` = System assessment missing — run `/system-assessment <eng>` first.
- `<agent>` = product-discovery
- `<inputs>` = all inherited artifacts in `src/<eng>/delivery/` (takeover brief, access checklist, system assessment)
- `<folder>/<template>` = inherited/inherited-project-goal-draft · output `src/<eng>/delivery/inherited-project-goal-draft.md`
- `<N>` = 4 · `<Pack name>` = Inherited Project Goal Draft
- `<next>` = Discovery/assessment phase complete. The next step is Business Rule Recovery (step 5); its command isn't built yet — run the `documentation` agent manually per `CLAUDE.md`'s run-order table.

- [ ] **Step 4: Run the verifier — all 7 command checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 7 command checks PASS; `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 5: Commit**

```powershell
git add .claude/commands/access-checklist.md .claude/commands/system-assessment.md .claude/commands/stabilization-goal.md
git commit -q -m "Add inherited discovery commands (steps 2-4)"
```

---

## Task 5: Wire commands into the docs

**Files:** Modify `CLAUDE.md`, `README.md`

- [ ] **Step 1: Add a Command column to CLAUDE.md's Greenfield run-order table**

Replace the existing Greenfield table (the one under `### Greenfield (new build)`) with this version (adds a **Command** column):

```markdown
| Step | Scrum activity | Agent | Output template | Command |
|------|----------------|-------|-----------------|---------|
| 1 | Client request | `product-discovery` | `templates/greenfield/project-request-brief.md` | `/intake` |
| 2 | Discovery prep | `product-discovery` | `templates/greenfield/discovery-workshop-plan.md` | `/discovery-prep` |
| 3 | Discovery meetings | `product-discovery` | `templates/greenfield/discovery-meeting-summary.md` | `/discovery-summary` |
| 4 | Product Goal | `product-discovery` | `templates/greenfield/product-goal-draft.md` | `/product-goal` |
| 5 | Initial backlog | `product-backlog` | `templates/greenfield/initial-product-backlog-pack.md` | — (manual) |
| 6 | Architecture foundation | `implementation` (+ `security-review`, `documentation`) | `templates/greenfield/architecture-technical-foundation-pack.md` | — (manual) |
| 7 | Backlog refinement | `product-backlog` | `templates/shared/refined-story-pack.md` | — (manual) |
| 8 | Sprint Planning | `scrum-planning` | `templates/shared/sprint-planning-support-pack.md` | — (manual) |
| 9 | Sprint execution | `implementation` | `templates/shared/implementation-pack.md` | — (manual) |
| 10 | Daily Scrum | `scrum-planning` | `templates/shared/daily-scrum-support-summary.md` | — (manual) |
| 11 | Code review | `code-review` | `templates/shared/ai-pr-review-report.md` | — (manual) |
| 12 | QA & testing | `qa-test-design` (+ `test-automation`) | `templates/shared/qa-test-pack.md` | — (manual) |
| 13 | Sprint Review | `scrum-planning` | `templates/shared/sprint-review-pack.md` | — (manual) |
| 14 | Retrospective | `retrospective-insights` | `templates/shared/retrospective-insights-pack.md` | — (manual) |
| 15 | Release readiness | `devops` | `templates/shared/release-readiness-pack.md` | — (manual) |
```

- [ ] **Step 2: Add a Command column to CLAUDE.md's Inherited run-order table**

Replace the existing Inherited table (under `### Inherited (existing / takeover)`) with:

```markdown
| Step | Focus | Agent | Output template | Command |
|------|-------|-------|-----------------|---------|
| 1 | Takeover request | `product-discovery` | `templates/inherited/takeover-request-brief.md` | `/intake` |
| 2 | Access & information | `product-discovery` | `templates/inherited/access-information-checklist.md` | `/access-checklist` |
| 3 | System assessment | `implementation` | `templates/inherited/initial-system-assessment.md` | `/system-assessment` |
| 4 | Stabilization Goal | `product-discovery` | `templates/inherited/inherited-project-goal-draft.md` | `/stabilization-goal` |
| 5 | Business-rule recovery | `documentation` | `templates/inherited/business-rule-recovery-report.md` | — (manual) |
| 6 | Codebase mapping | `implementation` | `templates/inherited/codebase-architecture-map.md` | — (manual) |
| 7 | Stabilization backlog | `product-backlog` | `templates/inherited/stabilization-product-backlog.md` | — (manual) |
| 8 | Backlog refinement | `product-backlog` | `templates/inherited/inherited-refined-story-pack.md` | — (manual) |
| 9 | Sprint Planning | `scrum-planning` | `templates/inherited/inherited-sprint-planning-support-pack.md` | — (manual) |
| 10 | Safe execution | `implementation` | `templates/inherited/safe-change-pack.md` | — (manual) |
| 11 | Regression QA | `qa-test-design` (+ `test-automation`) | `templates/inherited/regression-test-pack.md` | — (manual) |
| 12 | Sprint Review | `scrum-planning` | `templates/inherited/inherited-sprint-review-pack.md` | — (manual) |
| 13 | Retrospective | `retrospective-insights` | `templates/inherited/inherited-retrospective-insights-pack.md` | — (manual) |
| 14 | Modernization | `documentation` (+ Architect) | `templates/inherited/modernization-roadmap.md` | — (manual) |
```

- [ ] **Step 3: Add a "Slash commands" subsection to CLAUDE.md**

Immediately AFTER the line `Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`.` and BEFORE `## Templates (output packs)`, insert:

```markdown
## Slash commands

The intake + discovery phase is automated by commands in `.claude/commands/`. Each takes the engagement slug as its argument, orchestrates in the main conversation (so it can ask you questions and track progress in `src/<eng>/engagement.md`), and delegates the actual artifact to the mapped agent.

- `/intake <eng>` — bootstrap the engagement, classify greenfield/inherited, produce the first brief.
- Greenfield: `/discovery-prep` → `/discovery-summary` → `/product-goal`.
- Inherited: `/access-checklist` → `/system-assessment` → `/stabilization-goal`.

Steps 5+ have no command yet — run their agent manually per the run-order tables above.
```

- [ ] **Step 4: Update README quick-start**

In `README.md`, replace step 2 of "Start a new engagement" (the `New-Item ... mkdir` block) and the surrounding numbered steps so the flow leads with `/intake`. Replace:

```markdown
2. Create the workspace:
   ```powershell
   New-Item -ItemType Directory -Force src/<engagement>/request, src/<engagement>/delivery
   ```
3. Drop the client request into `src/<engagement>/request/`.
4. Open Claude Code here and follow the workflow in `CLAUDE.md`.
5. Clone the project's own repo into `src/<engagement>/<project-repo>/`.
```

with:

```markdown
2. Open Claude Code here and run `/intake <engagement>` (e.g. `/intake acme-portal`). It creates the workspace, asks greenfield vs inherited, takes the request (from `src/<engagement>/request/` or by prompt), and produces the first brief.
3. Follow the command it points you to next — greenfield: `/discovery-prep` → `/discovery-summary` → `/product-goal`; inherited: `/access-checklist` → `/system-assessment` → `/stabilization-goal`.
4. For inherited projects, clone the project's own repo into `src/<engagement>/<project-repo>/` when access is granted (before `/system-assessment`).
```

- [ ] **Step 5: Update README "Deferred" note**

Replace the "Deferred (future passes)" paragraph in `README.md` with:

```markdown
## Deferred (future passes)

The intake + discovery slash commands (`/intake` and the six discovery step commands) are built. Still deferred: commands for the remaining steps (backlog → planning → execution → review → retro → release / modernization), reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

- [ ] **Step 6: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 7: Commit**

```powershell
git add CLAUDE.md README.md
git commit -q -m "Wire intake+discovery commands into CLAUDE.md run-order and README"
```

---

## Task 6: Final verification, smoke test, wrap-up

- [ ] **Step 1: Full verifier run**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 2: Link integrity across commands**

Run:
```powershell
$broken = 0
Get-ChildItem .claude/commands/*.md | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  [regex]::Matches($c,'templates/[^\s`)]+\.md') | ForEach-Object {
    if (-not (Test-Path $_.Value)) { Write-Host "BROKEN: $($_.Value) in $($_.PSPath)" -ForegroundColor Red; $broken++ }
  }
}
# every command must name a real subagent
$agentNames = (Get-ChildItem .claude/agents/*.md | ForEach-Object { $_.BaseName })
Get-ChildItem .claude/commands/*.md | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  [regex]::Matches($c,'subagent_type:\s*`?([a-z-]+)`?') | ForEach-Object {
    $n = $_.Groups[1].Value
    if ($agentNames -notcontains $n) { Write-Host "UNKNOWN AGENT '$n' in $($_.PSPath)" -ForegroundColor Red; $broken++ }
  }
}
if ($broken -eq 0) { Write-Host "OK - command template + agent references resolve" -ForegroundColor Green }
```
Expected: `OK - command template + agent references resolve`.

- [ ] **Step 3: Manual smoke test (document the result)**

Perform once to confirm runtime behavior end-to-end:
```powershell
New-Item -ItemType Directory -Force src/_smoke/request | Out-Null
Set-Content src/_smoke/request/req.md "Client wants a new internal tool to track field-service jobs." -Encoding utf8
```
Then in Claude Code run `/intake _smoke`, choose **greenfield**. Confirm it creates `src/_smoke/delivery/project-request-brief.md` and `src/_smoke/engagement.md` (scenario greenfield, step 1 checked). Then run `/discovery-prep _smoke` and confirm `src/_smoke/delivery/discovery-workshop-plan.md` appears and step 2 gets checked. Confirm `git status` shows nothing under `src/_smoke/` (gitignored). Clean up:
```powershell
Remove-Item -Recurse -Force src/_smoke
```

- [ ] **Step 4: Report completion**

Summarize files created, verifier result, and the smoke-test outcome. Note `main` can fast-forward from `intake-discovery-commands`. Do NOT merge or push unless the user asks.

---

## Self-review (completed by plan author)

**Spec coverage:** D1 front-door+step commands → Tasks 2,3,4 (7 commands). D2 delegate via Task → step-5 of every command body. D3 always-ask classification → intake step 3. D4 flexible request input → intake step 4. D5 engagement.md state file → contract + intake step 6 + every command's load/update steps. D6 bootstrap → intake step 2. Command set table (§3) → Tasks 2–4. engagement.md schema (§4) → contract. Command anatomy (§5) → step-command shared shape. Slash-command format (§7) → confirmed: `description`/`argument-hint`/`allowed-tools` frontmatter, `$ARGUMENTS`, Task delegation. Docs updates (§8) → Task 5. Verification (§9) → Task 1 (verifier) + Task 6 (links + smoke). Out-of-scope (§10) → only 7 commands built; tables mark steps 5+ "— (manual)".

**Placeholder scan:** No "TBD/handle appropriately". The `<…>` tokens are the documented per-command data slots, each given a concrete value in Tasks 3–4; `<eng>` is a runtime path variable. The intake body and the step-command shared shape are fully rendered.

**Type/name consistency:** Command names match across the verifier `$commands` list (Task 1), the file map, Tasks 2–4, the CLAUDE.md tables (Task 5), and the README. Agent names used in `subagent_type` (`product-discovery`, `implementation`) match existing `.claude/agents/` files. Template paths match existing `templates/` files. Output filenames in `delivery/` mirror the template basenames. Step numbers in `engagement.md` match the run-order tables.
