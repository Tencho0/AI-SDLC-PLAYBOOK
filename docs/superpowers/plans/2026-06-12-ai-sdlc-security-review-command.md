# Security Review Slash Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the cross-cutting `/security-review <eng> [target]` command — delegating to the existing `security-review` agent to produce a `Security Review Report` — closing the last cross-cutting gap (security review was the only run-order event without a command).

**Architecture:** One Markdown prompt in `.claude/commands/security-review.md` that runs in the **main context** and uses the **Task tool** to delegate to the `security-review` subagent (which fills `templates/shared/security-review-report.md` and writes the report). It is shared (both scenarios, no branch) and **cross-phase**: it has no sprint-planning soft gate and does NOT mutate the `phase`/`sprint` markers — it only reads state, appends an `## Activity log` line (including the `· sprint <N> ·` token only if a `sprint:` marker already exists), and leaves the linear checklist untouched. No runtime app, so "tests" = the structural verifier extended with the new command name (run first to confirm it fails, then driven green) plus a documented manual smoke test. Spec: `docs/superpowers/specs/2026-06-12-ai-sdlc-security-review-command-design.md`.

**Tech Stack:** Claude Code custom slash commands (`.claude/commands/*.md`, YAML frontmatter, `$ARGUMENTS`, Task-tool delegation), Markdown, PowerShell 5.1 (verifier), git.

**Branch:** `security-review-command` (already created; spec already committed there).

---

## File map (what gets created / modified)

```
.claude/commands/security-review.md   Task 2   (cross-cutting, shared, target-keyed)
scripts/verify-scaffold.ps1           Task 1   (modify: add 'security-review' to $expectedCmds → 23)
CLAUDE.md                             Task 3   (modify: cross-cutting note + Slash commands section)
README.md                             Task 3   (modify: Deferred note)
```

`/intake.md` and `engagement.md`'s schema are unchanged — `/security-review` reads state and appends a log line but creates no markers.

---

## Task 1: Extend the verifier with the new command name (test-first)

**Files:** Modify `scripts/verify-scaffold.ps1`

- [ ] **Step 1: Add `'security-review'` to `$expectedCmds`**

In `scripts/verify-scaffold.ps1` section 4, replace this block:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan',
                'execution','daily-scrum','pr-review','qa',
                'sprint-review','retro','release-readiness','modernize'
```

with:

```powershell
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan',
                'execution','daily-scrum','pr-review','qa',
                'sprint-review','retro','release-readiness','modernize',
                'security-review'
```

- [ ] **Step 2: Run the verifier — the new check FAILS**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: the 22 existing commands still PASS; 1 new `command present: security-review` line FAILS; exit code 1.

- [ ] **Step 3: Commit**

```powershell
git add scripts/verify-scaffold.ps1
git commit -q -m "Extend verifier with the security-review command name"
```

---

## Task 2: Create the `/security-review` command

**Files:** Create `.claude/commands/security-review.md`

- [ ] **Step 1: Create `.claude/commands/security-review.md`**

```markdown
---
description: Security review (cross-cutting, both scenarios, any phase): assess security posture for a target into a Security Review Report, via the security-review agent.
argument-hint: <engagement-slug> [target]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/security-review** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **cross-cutting** command — run it any time (architecture/security baseline, per PR, per release, or ad-hoc) in **either** scenario. It uses one shared template (no scenario branch) and, because security review is cross-phase, it does **not** require sprint planning and does **not** change the engagement's `phase`/`sprint` markers.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional target (`<target>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<target>` is empty, DEFAULT it to `baseline`. Validate `<target>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. Typical targets: `baseline`, `pr-42`, `v1.2`, `codebase`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed. (This is the only gate — security review is cross-phase, so there is no sprint-planning prerequisite.)
3. **Derive the output path.** `<output>` = `src/<eng>/delivery/security-review/<target>.md`. Create the `src/<eng>/delivery/security-review/` folder if it does not exist.
4. **Delegate to the agent.** Use the Task tool to spawn the **security-review** subagent (`subagent_type: security-review`). Instruct it to: review the security posture for **`<target>`** — read the cloned project repo under `src/<eng>/` if one is present (its code, architecture/config, and dependency manifests), the relevant prior artifacts in `src/<eng>/delivery/` (architecture & technical foundation pack, codebase & architecture map, PR review reports), and, when `<target>` names a PR, that PR's diff; cover authentication/authorization, injection, secrets handling, dependencies, and data protection; fill the template `templates/shared/security-review-report.md`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). The agent produces a **report only** — it never modifies project code and never decides security outcomes.
5. **Record the run.** In `src/<eng>/engagement.md`, append one line to the `## Activity log` section. If `engagement.md`'s frontmatter has a `sprint:` marker, use `- <today> · sprint <N> · security-review · <target> → delivery/security-review/<target>.md` (with `<N>` = the current `sprint` value); if there is no `sprint:` marker, omit the sprint token: `- <today> · security-review · <target> → delivery/security-review/<target>.md`. Here `<today>` is today's date from the environment. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT set or change the `phase`/`sprint` frontmatter markers, and do NOT modify the `## Completed steps` checklist.
6. **Report.** Tell the user what was produced (and where) and that a human (Security Owner / Tech Lead) owns remediation and the security decision — the report is advisory. Suggest re-running `/security-review <eng> <target>` per PR or release as the codebase evolves.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
```

- [ ] **Step 2: Run the verifier — the command check passes**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `command present: security-review` plus its `description` + `argument-hint` frontmatter checks PASS; the link-integrity section shows `link resolves: templates/shared/security-review-report.md (in security-review.md)` and `subagent exists: security-review (in security-review.md)`; no `WARN unexpected command file`; `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 3: Commit**

```powershell
git add .claude/commands/security-review.md
git commit -q -m "Add cross-cutting security-review command"
```

---

## Task 3: Wire into CLAUDE.md and README

**Files:** Modify `CLAUDE.md`, `README.md`

- [ ] **Step 1: Update the CLAUDE.md cross-cutting note**

Replace this paragraph:

```
Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`. Of these, code review, QA, the Daily Scrum, and release readiness now have commands (`/pr-review`, `/qa`, `/daily-scrum`, `/release-readiness`), alongside sprint execution (`/execution`); only security review remains without a command (see Slash commands below).
```

with:

```
Cross-cutting events that recur every sprint in both scenarios — code review, QA, Daily Scrum, security review, release readiness — draw from `templates/shared/`. All of them now have commands — `/pr-review`, `/qa`, `/daily-scrum`, `/security-review`, `/release-readiness` — alongside sprint execution (`/execution`), for both tracks (see Slash commands below).
```

- [ ] **Step 2: Add the `/security-review` bullet in the CLAUDE.md "Slash commands" section**

Immediately after the "Sprint wrap-up:" bullet (the line beginning "- Sprint wrap-up:"), insert:

```
- Cross-cutting (both scenarios, any phase): `/security-review <eng> [target]` — security-posture review for a target (`baseline`, a PR, a release); keyed by target, defaults to `baseline`. It does not require sprint planning and does not change the `phase`/`sprint` markers.
```

- [ ] **Step 3: Update the CLAUDE.md "Slash commands" closing paragraph**

Replace this paragraph:

```
`/refine`, `/sprint-plan`, `/execution`, `/qa`, `/sprint-review`, and `/retro` are scenario-aware — they read `engagement.md` and pick the right template for the track; `/daily-scrum` and `/pr-review` are shared; `/release-readiness` (greenfield) and `/modernize` (inherited) are single-scenario with a guard that points to the other. The recurring commands set `phase: execution` and a `sprint:` marker on first run; to start a new sprint, bump `sprint:` in `engagement.md`. Every step in the run-order tables now has a command — only the optional `security-review` command, reusable skills, and plugin packaging remain unbuilt.
```

with:

```
`/refine`, `/sprint-plan`, `/execution`, `/qa`, `/sprint-review`, and `/retro` are scenario-aware — they read `engagement.md` and pick the right template for the track; `/daily-scrum`, `/pr-review`, and `/security-review` are shared; `/release-readiness` (greenfield) and `/modernize` (inherited) are single-scenario with a guard that points to the other. The recurring sprint-loop commands set `phase: execution` and a `sprint:` marker on first run (except `/security-review`, which is cross-phase and leaves them untouched); to start a new sprint, bump `sprint:` in `engagement.md`. Every run-order step and cross-cutting event now has a command — only reusable skills (e.g. a `/status`–`/next` navigator) and plugin packaging remain unbuilt.
```

- [ ] **Step 4: Update the README "Deferred (future passes)" note**

Replace this paragraph in `README.md`:

```
Every run-order step now has a slash command — the full once-per-engagement chain (`/intake` → `/sprint-plan`), the recurring sprint loop (`/execution`, `/daily-scrum`, `/pr-review`, `/qa`), and the wrap-up (`/sprint-review`, `/retro`, and `/release-readiness` (greenfield) / `/modernize` (inherited)), for both greenfield and inherited. Still optional / deferred: a `security-review` command, an `/automate-tests` command, reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
```

with:

```
Every run-order step and cross-cutting event now has a slash command — the full once-per-engagement chain (`/intake` → `/sprint-plan`), the recurring sprint loop (`/execution`, `/daily-scrum`, `/pr-review`, `/qa`), the wrap-up (`/sprint-review`, `/retro`, and `/release-readiness` (greenfield) / `/modernize` (inherited)), and the cross-cutting `/security-review`, for both greenfield and inherited. Still optional / deferred: an `/automate-tests` command, reusable skills (e.g. a `/status`–`/next` navigator), and plugin packaging — see `docs/superpowers/specs/`.
```

- [ ] **Step 5: Run the verifier — still green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 6: Commit**

```powershell
git add CLAUDE.md README.md
git commit -q -m "Wire /security-review into CLAUDE.md cross-cutting note, slash-commands, and README"
```

---

## Task 4: Final verification, smoke test, wrap-up

- [ ] **Step 1: Full verifier run**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`, exit 0. No `WARN unexpected command file` lines. Command count is 23.

- [ ] **Step 2: Link integrity across commands**

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
```
Expected: `OK - command template + agent references resolve`.

- [ ] **Step 3: Manual smoke test (document the result)**

The point of this test is to prove the two cross-phase deviations (no sprint-planning gate; no `phase`/`sprint` mutation). Use a slug that passes the slug rule — `smoke6`, NOT `_smoke6`. Set up a throwaway greenfield engagement in the **discovery** phase with **no `sprint:` marker** (the state right after `/intake`):
```powershell
New-Item -ItemType Directory -Force src/smoke6/delivery | Out-Null
@"
---
engagement: smoke6
scenario: greenfield
phase: discovery
created: 2026-06-12
---

## Completed steps
- [x] 1 Project Request Brief — delivery/project-request-brief.md
- [ ] 2 Discovery Workshop Plan
"@ | Set-Content src/smoke6/engagement.md -Encoding utf8
```
In Claude Code: run `/security-review smoke6` (no target) and confirm:
- it writes `src/smoke6/delivery/security-review/baseline.md` (default target `baseline`), with no sprint-planning warning;
- it appends an `## Activity log` line WITHOUT a `· sprint N ·` token (since there is no `sprint:` marker): `- 2026-06-12 · security-review · baseline → delivery/security-review/baseline.md`;
- the frontmatter still reads `phase: discovery` with NO `sprint:` key, and `## Completed steps` is unchanged.
Confirm `git status` shows nothing under `src/smoke6/` (gitignored). Clean up:
```powershell
Remove-Item -Recurse -Force src/smoke6
```

- [ ] **Step 4: Report completion**

Summarize files created/modified, verifier result, and the smoke-test outcome. Note `main` can fast-forward from `security-review-command`. Merge/push per the build process (fast-forward merge to main, push, delete branch). With this, every run-order step and cross-cutting event has a command; only optional skills and plugin packaging (Pass 7) remain.

---

## Self-review (completed by plan author)

**Spec coverage:** §2 D1 shared/cross-cutting, one template, no branch → Task 2 body (no scenario read/branch; single template path). D2 `[target]` defaulting to `baseline`, path-safe → Task 2 step 1; output `delivery/security-review/<target>.md` → step 3. D3 no sprint-planning gate, engagement-exists hard stop only → step 2 (explicit "only gate" note). D4 no `phase`/`sprint` mutation; conditional activity-log line; checklist untouched → step 5. D5 delegate to security-review agent, report-only → step 4. §3 command → Task 2. §4 read/log/no-mutate + conditional sprint token → step 5. §5 6-step anatomy → rendered body. §6 docs (cross-cutting note + slash-commands bullet + closing paragraph + README) → Task 3. §7 verification → Task 1 (verifier) + Task 4 (links + smoke proving the deviations).

**Placeholder scan:** No "TBD/handle appropriately". `<eng>`, `<target>`, `<N>`, `<today>`, `<output>` are documented runtime variables with concrete derivation rules (target from `$ARGUMENTS` defaulting to `baseline`; `<N>` from the `sprint:` marker only when present; `<today>` from the environment). The command body is fully rendered.

**Type/name consistency:** Command name `security-review` matches across the verifier `$expectedCmds` (Task 1), the file map, Task 2 body, the CLAUDE.md cross-cutting note + slash-commands bullet + closing paragraph (Task 3), and README (Task 3). Agent `subagent_type: security-review` exists in `.claude/agents/`. Template path `templates/shared/security-review-report.md` exists. Output folder `security-review` matches the activity-log line's activity token. The conditional activity-log format (sprint token only if a marker exists) is identical in §4/§5 of the spec and Task 2 step 5.
