# AI-SDLC Security Review Slash Command — Design Spec

- **Date:** 2026-06-12
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** `2026-06-12-ai-sdlc-review-retro-release-commands-design.md` (pass 5 — review/retro/release-modernization commands)

---

## 1. Goal & Context

Passes 2–5 gave every numbered run-order step a slash command. The one remaining gap is the
**cross-cutting `security-review` event**: after Pass 5, `CLAUDE.md`'s cross-cutting note read
"only security review remains without a command." Pass 6 (the optional "reusable skills" pass)
is scoped — by the user — to **just the `/security-review` command**. The `/status`–`/next`
navigator and a `/next-sprint` helper were considered and deliberately left out.

`/security-review` delegates to the existing `security-review` agent to produce a
`Security Review Report`. Unlike the sprint-loop commands, security review is genuinely
**cross-phase**: the agent's own "when to use" is "Greenfield Step 6 (security baseline) +
per-PR when needed; Inherited stabilization." It can run during setup (the architecture/security
baseline, *before* any sprint), per-PR, during stabilization, or ad-hoc on the codebase. That
nature drives two deliberate deviations from the Pass-4/5 recurring-command shape (§5).

**Success criterion:** `/security-review <eng> [target]` writes
`src/<eng>/delivery/security-review/<target>.md` via the `security-review` agent, records the
run in the `## Activity log`, and works in both scenarios and at any phase. The verifier stays
green at 23 commands.

**Out of scope:** the `/status`–`/next` navigator, the `/next-sprint` helper, an
`/automate-tests` command, and plugin packaging (Pass 7).

## 2. Decisions (locked)

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **`/security-review` is a shared, cross-cutting command** (both scenarios, one template, no scenario branch) — like `/pr-review`. It reads `scenario` for nothing; there is a single template `templates/shared/security-review-report.md`. | Security review is not per-track; the report template is shared. |
| D2 | **Keyed by an optional `[target]` label that defaults to `baseline`.** Output `delivery/security-review/<target>.md`. Other targets: `pr-42`, `v1.2`, `codebase`. The label is a path-safe token. | "Security baseline" is the agent's primary use, so `baseline` is the natural default; a label also lets per-PR / per-release reviews coexist as separate artifacts (like `/pr-review`'s id). |
| D3 | **No sprint-planning soft gate.** The only hard gate is "engagement exists" (missing → run `/intake`). There is **no** "sprint-planning pack missing" warning. | Security review legitimately runs *before* sprint planning (the step-6 baseline); the Pass-4/5 warning would mis-fire. This is a deliberate, documented deviation. |
| D4 | **Does NOT mutate the `phase` or `sprint` frontmatter markers.** It still appends one `## Activity log` line, but includes the `· sprint <N> ·` token **only if a `sprint:` marker already exists**; it never creates `phase: execution` or `sprint: 1`. The `## Completed steps` checklist is untouched. | Forcing `phase: execution` + `sprint: 1` during a setup-time security baseline would misrepresent the engagement's state. Recording the event without mutating phase/sprint keeps the log honest across phases. |
| D5 | **Delegates to the `security-review` agent via Task; report-only.** The agent reads the cloned repo (if present), architecture/config, dependency manifests, and the PR diff when the target names a PR. It never edits project code (the agent has no `Edit` tool). | Same delegate-only invariant as every command; security decisions stay with humans. |

## 3. Command

`.claude/commands/security-review.md`. `$ARGUMENTS` = `<slug> [target]`.

| Command | argument-hint | Scenario | Delegates to | Template → output |
|---------|---------------|----------|--------------|-------------------|
| `/security-review <eng> [target]` | `<engagement-slug> [target]` | shared (no branch) | `security-review` | `templates/shared/security-review-report.md` → `delivery/security-review/<target>.md` |

The `security-review` agent and the `security-review-report.md` template already exist. Pass 6
adds **one command only** — no new agent or template.

## 4. Engagement state file — read, log, but do not mutate markers

`/security-review` reads `engagement.md` (to confirm the engagement exists and to read a
`sprint:` marker if one is present) and appends one `## Activity log` line. It does **not** set
`phase`/`sprint` and does **not** touch `## Completed steps` (D4). If there is no `## Activity
log` section yet, it is created after `## Completed steps`.

Activity-log line:

```markdown
- <today> · sprint <N> · security-review · <target> → delivery/security-review/<target>.md   # when a sprint: marker exists
- <today> · security-review · <target> → delivery/security-review/<target>.md                # when no sprint: marker exists
```

`<today>` is the run date from the environment. The `· sprint <N> ·` token is included only
when `engagement.md` already has a `sprint:` marker (i.e. the engagement has entered the
recurring loop); during an early security baseline it is omitted.

## 5. Command anatomy

Standard frontmatter contract:

```markdown
---
description: <one line; no surrounding quotes, matching existing commands>
argument-hint: <engagement-slug> [target]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
```

Body (6 steps):

1. **Resolve args.** Split `$ARGUMENTS`: first token = `<eng>`, remainder = optional `<target>`.
   If `<eng>` empty, ask. Validate `<eng>` with the slug rule `^[a-z0-9][a-z0-9-]*$` (reject
   slash, backslash, space, dot, `..`, reserved names). If `<target>` is empty, default it to
   `baseline`. Validate `<target>` as a path-safe token: reject `/`, `\`, whitespace, `..`, or a
   leading `.`/`-`.
2. **Load state.** Read `src/<eng>/engagement.md`. Missing → STOP: "No engagement found — run
   `/intake <eng>` first." Do not proceed. (This is the only gate — security review is
   cross-phase, so there is no sprint-planning prerequisite.)
3. **Derive output + ensure folder.** `<output>` = `src/<eng>/delivery/security-review/<target>.md`.
   Create `src/<eng>/delivery/security-review/` if absent.
4. **Delegate via Task.** Spawn the `security-review` subagent (`subagent_type: security-review`).
   Instruct it to: review the security posture for **`<target>`** — read the cloned project repo
   under `src/<eng>/` if present (its code, architecture/config, and dependency manifests), the
   relevant `src/<eng>/delivery/` artifacts (architecture pack, codebase map, PR-review reports),
   and, when `<target>` names a PR, that PR's diff; cover auth, injection, secrets handling,
   dependencies, and data protection; fill `templates/shared/security-review-report.md`; write
   `<output>`; follow the governance footer (Observed facts / Assumptions / Risks /
   Recommendations / Open questions). The agent produces a **report only** — it never modifies
   project code and never decides security outcomes.
5. **Record the run.** Append one `## Activity log` line (§4), creating the section after
   `## Completed steps` if absent. Do **not** set `phase`/`sprint` and do **not** modify the
   `## Completed steps` checklist.
6. **Report.** State what was produced (and where) and that a human (Security Owner / Tech Lead)
   owns remediation and the security decision — the report is advisory. Suggest re-running
   `/security-review <eng> <target>` per PR/release as the codebase evolves.

Governance footer (identical to all commands): "You orchestrate only — the agent produces the
artifact and a human reviews it. Never paste secrets or production data."

## 6. Docs updates

- **`CLAUDE.md`** —
  - Update the **cross-cutting note**: security review now has a command, so all cross-cutting
    events are covered. Change "…only security review remains without a command" to list
    `/security-review` among the commanded events.
  - Update the **Slash-commands** section: add a line noting `/security-review <eng> [target]`
    as the cross-cutting security command (both scenarios, any phase, keyed by target), and
    remove "the optional `security-review` command" from the closing "what remains unbuilt" list
    (only reusable skills — a `/status`–`/next` navigator — and plugin packaging remain).
  - No run-order **table** change: security review is cross-cutting, not a numbered step
    (greenfield step 6 already lists `security-review` as an `/architecture` collaborator).
- **`README.md`** — drop `security-review` from the "Deferred (future passes)" list; what remains
  optional is an `/automate-tests` command, reusable skills, and plugin packaging.

## 7. Verification

- **Extend `scripts/verify-scaffold.ps1`:** add `'security-review'` to `$expectedCmds` (total 23):
  ```powershell
  $expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                  'access-checklist','system-assessment','stabilization-goal',
                  'initial-backlog','architecture','recover-rules','map-codebase',
                  'stabilization-backlog','refine','sprint-plan',
                  'execution','daily-scrum','pr-review','qa',
                  'sprint-review','retro','release-readiness','modernize',
                  'security-review'
  ```
  No other verifier change needed: it discovers command files, validates `description` +
  `argument-hint` frontmatter, warns on unexpected files, and checks that every `templates/…`
  path and `subagent_type:` resolves. `templates/shared/security-review-report.md` and the
  `security-review` agent both exist, so those checks pass. Verifier must end `ALL CHECKS
  PASSED`, exit 0.
- **Manual smoke test** (documented in the plan): on a throwaway greenfield engagement that has
  only been through `/intake` (so `phase: discovery`, no `sprint:` marker), run
  `/security-review smoke6` (no target) → confirm it writes
  `delivery/security-review/baseline.md`, appends an `## Activity log` line **without** a
  `· sprint N ·` token, and leaves `phase`/`sprint`/`## Completed steps` unchanged (proving the
  cross-phase deviations). Confirm `git status` shows nothing under `src/smoke6/`. Clean up.
  (Use a slug that passes the slug rule — `smoke6`, not `_smoke6`.)
- Pristine-repo invariant holds; commits carry no Claude co-author.

## 8. Assumptions & open questions

- **A1:** The `security-review` agent and `templates/shared/security-review-report.md` already
  exist (verified); Pass 6 adds no agent or template.
- **A2:** Not mutating `phase`/`sprint` (D4) is the correct behavior for a cross-phase command —
  it would otherwise misreport a setup-time baseline as execution. This is the one place
  `/security-review` intentionally differs from the other recurring commands.
- **A3:** Defaulting `<target>` to `baseline` (D2) covers the most common first use; explicit
  labels (`pr-42`, `v1.2`) let multiple point-in-time reviews coexist.
- **Q1 (resolved):** Pass 6 scope → `/security-review` only (navigator and `/next-sprint`
  deferred), per the scoping decision.
