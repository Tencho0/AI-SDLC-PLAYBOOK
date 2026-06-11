# AI-SDLC Intake + Discovery Slash Commands — Design Spec

- **Date:** 2026-06-11
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** `2026-06-10-ai-sdlc-playbook-scaffold-design.md` (pass 1 — the scaffold)

---

## 1. Goal & Context

Pass 1 delivered the scaffold: 12 agents, 30 templates, the playbook, and CLAUDE.md run-order tables. Running a step today is manual — you read the run-order table, figure out the right agent, gather inputs, invoke it, and save the output. **Pass 2 adds the orchestration layer for the intake + discovery phase**: thin slash commands that automate the run order so you type `/intake acme-portal` instead of wiring it up by hand.

**Scope:** intake (step 1) + the discovery/understanding phase (steps 2–4) for both greenfield and inherited. The remaining 23 step-commands, skills, and plugin packaging stay deferred.

**Success criterion:** in a fresh clone, `/intake <eng>` bootstraps the engagement, classifies it, and produces the first brief; the per-scenario discovery commands then carry you through step 4 — each spawning the right agent, respecting human gates, and tracking progress.

## 2. Decisions (locked)

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **Front door + thin step commands** (7 total), mapping 1:1 to the run-order tables | Explicit, predictable, respects human gates |
| D2 | **Commands delegate to subagents** (Task tool); they never re-implement agent logic | Agent definitions stay the single source of behavior (DRY) |
| D3 | **`/intake` always asks** greenfield vs inherited (no auto-guess) | Simple, fully human-controlled; recorded in state file |
| D4 | **Request input is flexible**: use `src/<eng>/request/` if non-empty, else prompt to paste/point and save it there | Works whether or not you pre-dropped a file |
| D5 | **Per-engagement `engagement.md` state file** records scenario + step progress; every command reads/updates it | Commands stay quiet (no re-asking), can enforce prerequisites, show progress |
| D6 | `/intake` **bootstraps** `src/<eng>/{request,delivery}` if missing | Removes the manual mkdir ritual |

## 3. Command set (7 commands)

All live in `.claude/commands/<name>.md`. Each takes the engagement slug as `$1` (asks if omitted).

| Command | Scenario | Step | Delegates to | Fills template (→ `src/<eng>/delivery/`) | Prerequisite |
|---------|----------|------|--------------|-------------------------------------------|--------------|
| `/intake <eng>` | both | 1 | `product-discovery` | greenfield: `project-request-brief.md` · inherited: `takeover-request-brief.md` | request present, or prompts |
| `/discovery-prep <eng>` | greenfield | 2 | `product-discovery` | `discovery-workshop-plan.md` | intake done (scenario=greenfield) |
| `/discovery-summary <eng>` | greenfield | 3 | `product-discovery` | `discovery-meeting-summary.md` | meeting notes present in `request/` |
| `/product-goal <eng>` | greenfield | 4 | `product-discovery` | `product-goal-draft.md` | step 3 done |
| `/access-checklist <eng>` | inherited | 2 | `product-discovery` | `access-information-checklist.md` | intake done (scenario=inherited) |
| `/system-assessment <eng>` | inherited | 3 | `implementation` | `initial-system-assessment.md` | project repo cloned into `src/<eng>/` |
| `/stabilization-goal <eng>` | inherited | 4 | `product-discovery` | `inherited-project-goal-draft.md` | step 3 done |

## 4. Engagement state file

`/intake` creates `src/<engagement>/engagement.md` (gitignored, human-readable). Schema:

```markdown
---
engagement: <slug>
scenario: greenfield | inherited
phase: discovery
created: <YYYY-MM-DD>
---
## Completed steps
- [x] 1 <Pack name> — delivery/<file>.md
- [ ] 2 <Pack name>
- [ ] 3 <Pack name>
- [ ] 4 <Pack name>
```

The "Completed steps" checklist is seeded by `/intake` with the **scenario-appropriate** step list (greenfield steps 1–4 vs inherited steps 1–4). Each step command ticks its line on success and records the output path. `created` date is supplied by the user/runtime when `/intake` runs (commands are prompts; the date is read from the environment at run time, not hard-coded).

## 5. Command anatomy (every command performs these 6 steps)

1. **Resolve engagement** — read `$1`; if absent, ask for the slug.
2. **Load state** — read `src/<eng>/engagement.md`. Step commands that find it missing stop with: "run `/intake <eng>` first."
3. **Check scenario + prerequisites** — confirm the command's scenario matches `engagement.md`'s `scenario` (mismatch → stop and name the correct command, e.g. running `/discovery-prep` on an inherited engagement points to `/access-checklist`). Confirm the prerequisite artifact/input exists (prior `delivery/` file, meeting notes in `request/`, or cloned repo). Missing → clear "do X first" message; produce nothing.
4. **Gather inputs** — the request in `request/`, prior `delivery/` artifacts, and (for `system-assessment`) the cloned repo.
5. **Delegate to the agent** — spawn the mapped subagent via the Task tool (`subagent_type` = agent name) with a prompt naming the engagement paths, the template to fill, and the output destination. The agent fills the template and writes the artifact to `src/<eng>/delivery/`.
6. **Update state & report** — tick the step in `engagement.md` with the output path, then print the **next command** to run.

## 6. `/intake` specifics

1. Resolve slug (`$1` or ask).
2. Bootstrap `src/<eng>/request/` and `src/<eng>/delivery/` if missing.
3. **Ask** greenfield vs inherited.
4. Resolve the request: if `request/` is non-empty, use it; else prompt the user to paste it or give a path, and save it into `request/`.
5. Delegate to `product-discovery` to produce the brief (`project-request-brief.md` for greenfield, `takeover-request-brief.md` for inherited) into `delivery/`.
6. Write `engagement.md` with the chosen scenario and the seeded step checklist (step 1 ticked).
7. Report the next command: `/discovery-prep` (greenfield) or `/access-checklist` (inherited).

## 7. Slash command technical format

Each `.claude/commands/<name>.md` is a Markdown prompt file with YAML frontmatter:

```markdown
---
description: <one line shown in the / menu>
argument-hint: <eng>
---
<prompt body that orchestrates the 6 steps in §5; uses $1 for the engagement slug>
```

- `$1` (or `$ARGUMENTS`) carries the engagement slug.
- The body instructs Claude to perform §5's steps, including spawning the subagent via the Task tool.
- **Exact frontmatter keys (`description`, `argument-hint`, and whether to set `allowed-tools`/`model`) will be confirmed against current Claude Code docs during planning** via the claude-code-guide, since this is the one area dependent on external tooling behavior.

## 8. Docs updates

- **CLAUDE.md** — add a **Command** column to the Greenfield and Inherited run-order tables so each step shows its command (blank/"manual" for the 23 not-yet-built steps). Add a one-line "Slash commands" subsection pointing at `.claude/commands/`.
- **README.md** — update the quick-start to lead with `/intake <eng>` instead of the manual `New-Item` mkdir.
- **Spec (pass 1) deferred note / README deferred note** — amend to state that intake+discovery commands now exist; remaining step-commands, skills, and plugin packaging remain deferred.

## 9. Verification

- Extend `scripts/verify-scaffold.ps1` with a **commands check**: all 7 `.claude/commands/*.md` exist, each has valid frontmatter with `description` and `argument-hint`, and every agent name and template path referenced by a command resolves to an existing file.
- **Manual smoke test** (documented in the plan): create a throwaway `src/_smoke/request/req.md`, run `/intake _smoke` (pick greenfield), confirm it creates `delivery/project-request-brief.md` + `engagement.md` with step 1 ticked; then `/discovery-prep _smoke` produces the workshop plan and ticks step 2; delete `src/_smoke/`.
- The pristine-repo invariant still holds: everything commands create lives under `src/` (gitignored).

## 10. Out of scope (still deferred)

- The remaining 23 step-commands (backlog → refinement → planning → execution → review → retro → release; and inherited steps 5–14).
- Skills (multi-step procedures), a `/status` / `/next` helper, and plugin packaging.
- Auto-classification of greenfield vs inherited (explicitly chosen against in D3).

## 11. Assumptions & open questions

- **A1:** Slash commands can reliably instruct Claude to spawn a named subagent via the Task tool. (Confirm command format in planning — §7.)
- **A2:** `engagement.md` lives in `src/<eng>/` and is gitignored by the existing `src/*` rule — no `.gitignore` change needed.
- **A3:** The `created` date and step ticking are done at run time by the command prompt; nothing is hard-coded.
- **Q1 (resolved):** Delegate to agents — confirmed.
- **Q2 (resolved):** Include `engagement.md` state file — confirmed.
