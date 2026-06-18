# Playbook Usage Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a task-oriented `docs/usage/` guide (8 pages, layered for the delivery team and clients) that explains how to run the Playbook and links into the existing docs rather than duplicating them.

**Architecture:** A flat folder of focused markdown pages plus a single `README.md` index (the "one line per entry" pattern of `MEMORY.md`). Every page links to the authoritative source (CLAUDE.md / PLAYBOOK.md / mcp.md / governance.md / DoR / DoD) instead of restating it. Publishing to the Klevret.SDLC ADO wiki is a documented manual step, not automation.

**Tech Stack:** Markdown only. Verification via `scripts/verify-scaffold.ps1` (PowerShell) and link-target existence checks (`Test-Path`). No build, no runtime, no new dependencies.

## Global Constraints

- **Additive only.** Do NOT modify `.claude/agents/`, `.claude/commands/`, `templates/`, or any existing `playbook/*.md` / root file. The only new tree is `docs/usage/`.
- **Link, don't duplicate.** Never copy a run-order table, the agent roster, or guardrail text verbatim. Reference it and link.
- **Relative links** from any `docs/usage/<file>.md`: repo root is `../../` (e.g. CLAUDE.md → `../../CLAUDE.md`); sibling usage pages are bare (`getting-started.md`).
- **Audience tag** on every page: first body line is `**Audience:** delivery | client | both`.
- **Page shape:** `# Title` → `**Audience:** …` → `## Purpose` (1–2 sentences) → the walkthrough/sections → `## Read more` (links block).
- **Commit style:** plain one-line message, **no** `Co-Authored-By` trailer (repo convention).
- **Verifier green:** `powershell -File scripts/verify-scaffold.ps1` must print `ALL CHECKS PASSED` (exit 0) after every commit.

**Canonical link targets** (relative from `docs/usage/`), all confirmed to exist:
`../../README.md`, `../../CLAUDE.md`, `../../playbook/PLAYBOOK.md`, `../../playbook/mcp.md`,
`../../playbook/governance.md`, `../../playbook/definition-of-ready.md`,
`../../playbook/definition-of-done.md`, `../../playbook/greenfield-vs-inherited.md`,
`../../mcp.env.example`, `../../scripts/setup-mcp.ps1`.

**Verification approach (all tasks):** there are no unit tests. Each task verifies by (a) `Test-Path` on every root file it links to, (b) running the scaffold verifier, and (c) a read-through against the page's content checklist. Sibling-page cross-links are validated globally in Task 8 (after all pages exist), so earlier pages may link forward to siblings.

---

### Task 1: getting-started.md

**Files:**
- Create: `docs/usage/getting-started.md`

**Links/Index contract:**
- Produces: page `getting-started.md` (delivery onboarding). Linked from README (Task 8) and from `running-an-engagement.md`.
- Consumes: nothing from sibling tasks.

- [ ] **Step 1: Write the page**

Create `docs/usage/getting-started.md` with this exact structure and content:

```markdown
# Getting Started

**Audience:** delivery

## Purpose
Get a clone of the Playbook configured and produce the first artifact for a new engagement.

## 1. Clone and orient
- Clone the base repo. Read [README.md](../../README.md) for what it is and
  [CLAUDE.md](../../CLAUDE.md) for the operating manual (agents, commands, workflow).
- Nothing project-specific is committed — all engagement work lives under `src/<engagement>/` (gitignored).

## 2. Configure MCP integrations (optional but recommended)
- `Copy-Item mcp.env.example .env`, fill in the tokens/org you have, then
  `powershell -File scripts/setup-mcp.ps1`.
- Reload the window, then verify/approve servers. Full per-server steps and the verify/approve
  gate are in [playbook/mcp.md](../../playbook/mcp.md) §4 and §4.8.

## 3. Create the engagement workspace
- Make `src/<engagement>/` with `request/` and `delivery/` subfolders; drop the raw client request in `request/`.

## 4. Classify the engagement
- Decide greenfield (new build) vs inherited (takeover) — see
  [playbook/greenfield-vs-inherited.md](../../playbook/greenfield-vs-inherited.md).

## 5. Produce the first artifact
- Run `/intake <engagement>` to bootstrap and produce the first brief, then follow the run order
  in [running-an-engagement.md](running-an-engagement.md).

## Read more
- Operating manual: [CLAUDE.md](../../CLAUDE.md)
- Full model: [playbook/PLAYBOOK.md](../../playbook/PLAYBOOK.md)
- Integrations: [playbook/mcp.md](../../playbook/mcp.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
'../../README.md','../../CLAUDE.md','../../playbook/mcp.md','../../playbook/greenfield-vs-inherited.md','../../playbook/PLAYBOOK.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: every line ends `-> True`.

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/getting-started.md
git commit -m "Add docs/usage/getting-started.md"
```

---

### Task 2: running-an-engagement.md

**Files:**
- Create: `docs/usage/running-an-engagement.md`

**Links/Index contract:**
- Produces: page `running-an-engagement.md` (the run-order walkthrough). Linked from README and `getting-started.md`.

- [ ] **Step 1: Write the page**

Create `docs/usage/running-an-engagement.md`:

```markdown
# Running an Engagement

**Audience:** delivery

## Purpose
Walk through the numbered run order for an engagement and show which command + agent drives each
step and where each artifact lands. The authoritative step sequence lives in PLAYBOOK.md; this page
is the operator's quick path.

## Pick your track
- **Greenfield** (new build): steps 1–15.
- **Inherited** (takeover): steps 1–14.
See [greenfield-vs-inherited.md](../../playbook/greenfield-vs-inherited.md) to classify.

## How a step works
Each step maps to one slash command that orchestrates in the main conversation and delegates the
artifact to a mapped agent, writing it under `src/<engagement>/delivery/`. The command/agent/template
map per step is in [CLAUDE.md](../../CLAUDE.md) (run-order tables); the authoritative narrative is
[PLAYBOOK.md](../../playbook/PLAYBOOK.md) §5 (greenfield) and §6 (inherited).

## Greenfield path (commands in order)
`/intake` → `/discovery-prep` → `/discovery-summary` → `/product-goal` → `/initial-backlog` →
`/architecture` → `/refine` → `/sprint-plan` → then the per-sprint loop (see
[running-a-sprint.md](running-a-sprint.md)) → `/release-readiness`.

## Inherited path (commands in order)
`/intake` → `/access-checklist` → `/system-assessment` → `/stabilization-goal` → `/recover-rules` →
`/map-codebase` → `/stabilization-backlog` → `/refine` → `/sprint-plan` → then the per-sprint loop →
`/modernize`.

## Where artifacts go
- Linear setup/planning artifacts: `src/<engagement>/delivery/`.
- Recurring sprint artifacts: `src/<engagement>/delivery/<activity>/<item>.md`, with an `## Activity log` in `engagement.md`.
- Durable project docs and code: inside the cloned project repo at `src/<engagement>/<project-repo>/`.

## Read more
- Step-by-step tables: [CLAUDE.md](../../CLAUDE.md)
- Authoritative model: [PLAYBOOK.md](../../playbook/PLAYBOOK.md)
- The recurring loop: [running-a-sprint.md](running-a-sprint.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
'../../playbook/greenfield-vs-inherited.md','../../CLAUDE.md','../../playbook/PLAYBOOK.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: every line `-> True`.

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/running-an-engagement.md
git commit -m "Add docs/usage/running-an-engagement.md"
```

---

### Task 3: running-a-sprint.md

**Files:**
- Create: `docs/usage/running-a-sprint.md`

**Links/Index contract:**
- Produces: page `running-a-sprint.md` (recurring per-sprint loop). Linked from README and `running-an-engagement.md`.

- [ ] **Step 1: Write the page**

Create `docs/usage/running-a-sprint.md`:

```markdown
# Running a Sprint

**Audience:** delivery

## Purpose
Drive the recurring per-sprint commands once an engagement is set up and planned.

## The recurring loop (both tracks)
Run these repeatedly, keyed by item id; they write item-keyed artifacts under
`src/<eng>/delivery/<activity>/` and append to the `## Activity log` in `engagement.md`:
- `/execution <eng> <ticket> [layer …]` — implement a ticket (orchestrates layer specialists).
- `/daily-scrum <eng> [date]` — daily standup summary.
- `/pr-review <eng> <pr>` — first-pass AI PR review.
- `/qa <eng> <story>` — test design for a story.

## Sprint boundaries
- The loop commands set `phase: execution` and a `sprint:` marker on first run. To start a new sprint, bump `sprint:` in `engagement.md`.
- Wrap-up: `/sprint-review <eng> [sprint]` → `/retro <eng> [sprint]`, then `/release-readiness` (greenfield) or `/modernize` (inherited).
- Cross-cutting anytime: `/security-review <eng> [target]` (does not change phase/sprint markers).

## Governance gates
Every artifact passes a human review gate — see [governance-and-reviews.md](governance-and-reviews.md).

## Read more
- Command reference and keying rules: [CLAUDE.md](../../CLAUDE.md) (Slash commands section)
- Where this sits in the engagement: [running-an-engagement.md](running-an-engagement.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
'../../CLAUDE.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: `-> True`.

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/running-a-sprint.md
git commit -m "Add docs/usage/running-a-sprint.md"
```

---

### Task 4: governance-and-reviews.md

**Files:**
- Create: `docs/usage/governance-and-reviews.md`

**Links/Index contract:**
- Produces: page `governance-and-reviews.md`. Linked from README, `running-a-sprint.md`, and `for-clients.md`.

- [ ] **Step 1: Write the page**

Create `docs/usage/governance-and-reviews.md`:

```markdown
# Governance and Reviews

**Audience:** both

## Purpose
Explain the human-in-the-loop gates that apply to every AI-produced artifact, and the
Definition of Ready / Done checks that bracket a unit of work.

## The rule that shapes everything
AI cannot approve its own work — a human always approves. AI-generated code, requirements, tests,
and client communication each require the matching human review before they count as done. The full
set of seven guardrails is in [playbook/governance.md](../../playbook/governance.md).

## Where the gates fire
- **Requirements** (briefs, backlog, stories) → PO/BA validation.
- **Code** → human review before merge.
- **Tests** → QA/developer validation.
- **Client communication** (e.g. Teams drafts) → PM/PO review before sending.
- **Secrets/production data** → never pasted into AI tools.

## Ready and Done
- A story is **Ready** when business goal, role, behavior, acceptance criteria, dependencies, edge
  cases, risks, test scenarios, and open questions are clear —
  [playbook/definition-of-ready.md](../../playbook/definition-of-ready.md).
- An increment is **Done** when acceptance criteria pass, code + tests are in, AI self-review and
  human review are done, QA/security checked where needed, docs updated, no critical regression —
  [playbook/definition-of-done.md](../../playbook/definition-of-done.md).

## Every AI artifact separates
Observed facts · Assumptions · Risks · Recommendations · Open questions.

## Read more
- All seven guardrails: [playbook/governance.md](../../playbook/governance.md)
- For the client view of reviews: [for-clients.md](for-clients.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
'../../playbook/governance.md','../../playbook/definition-of-ready.md','../../playbook/definition-of-done.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: every line `-> True`.

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/governance-and-reviews.md
git commit -m "Add docs/usage/governance-and-reviews.md"
```

---

### Task 5: for-clients.md

**Files:**
- Create: `docs/usage/for-clients.md`

**Links/Index contract:**
- Produces: page `for-clients.md` (client orientation). Linked from README and `governance-and-reviews.md`.

- [ ] **Step 1: Write the page**

Create `docs/usage/for-clients.md`:

```markdown
# For Clients

**Audience:** client

## Purpose
A short orientation for client stakeholders (PO, sponsors, client developers) on how the
AI-assisted delivery works and where you fit.

## What this is
We run normal Scrum delivery, with AI assistants drafting artifacts (briefs, backlog, plans, review
packs, test cases) and people reviewing and approving them. AI accelerates the drafting; it does not
replace your decisions.

## What you'll see and approve
- **Discovery & requirements:** a request brief, discovery summaries, a product/stabilization goal,
  and a backlog — you (PO/BA) validate these.
- **Each increment:** working software plus a short pack describing what changed — your team reviews
  before merge.
- **Each sprint:** a review/demo summary and a retrospective.

## Your responsibilities
- Validate AI-drafted requirements and priorities.
- Approve (or reject) increments at the review gate.
- Approve any client-facing communication before it is sent.

## What not to expect
- AI never approves its own work — every output waits for a human gate.
- No secrets or production data go into the AI tools.
- Estimates and plans are drafts for the team to confirm, not commitments made by the AI.

## Read more
- The gates in detail: [governance-and-reviews.md](governance-and-reviews.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
Test-Path 'docs/usage/governance-and-reviews.md'
```
Expected: `True` (created in Task 4; if running out of order, this is validated globally in Task 8).

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/for-clients.md
git commit -m "Add docs/usage/for-clients.md"
```

---

### Task 6: publishing-to-ado-wiki.md

**Files:**
- Create: `docs/usage/publishing-to-ado-wiki.md`

**Links/Index contract:**
- Produces: page `publishing-to-ado-wiki.md` (manual sync process). Linked from README and `adding-a-page.md`.

- [ ] **Step 1: Write the page**

Create `docs/usage/publishing-to-ado-wiki.md`:

```markdown
# Publishing to the ADO Wiki

**Audience:** delivery

## Purpose
Publish this usage guide into the engagement's Azure DevOps wiki (e.g. Klevret.SDLC) on demand. The
repo stays canonical; the wiki is a published mirror you refresh when ready.

## Prerequisites
- The `ado` MCP server is connected (see [playbook/mcp.md](../../playbook/mcp.md) §4.3 and §4.8).
- The target project has a wiki. Discover it with the `ado` tool `wiki_list_wikis`; if none exists,
  create a project wiki once in the ADO UI and note its id/name.

## Page mapping (stable paths)
Each file maps to a fixed wiki page path under one parent so re-publishing **updates** the same page
instead of creating duplicates:

| Repo file | Wiki page path |
|-----------|----------------|
| `docs/usage/README.md` | `/AI-SDLC Playbook/Overview` |
| `docs/usage/getting-started.md` | `/AI-SDLC Playbook/Getting Started` |
| `docs/usage/running-an-engagement.md` | `/AI-SDLC Playbook/Running an Engagement` |
| `docs/usage/running-a-sprint.md` | `/AI-SDLC Playbook/Running a Sprint` |
| `docs/usage/governance-and-reviews.md` | `/AI-SDLC Playbook/Governance and Reviews` |
| `docs/usage/for-clients.md` | `/AI-SDLC Playbook/For Clients` |
| `docs/usage/adding-a-page.md` | `/AI-SDLC Playbook/Adding a Page` |

(`publishing-to-ado-wiki.md` itself is delivery-internal and need not be published.)

## Publish process
1. Ask an agent (with `ado` access) to "publish the usage guide to the <project> wiki."
2. For each row in the mapping, it calls the `ado` tool `wiki_create_or_update_page` with the page
   path and the file's contents. Relative repo links won't resolve in the wiki — keep that in mind or
   adjust to wiki-relative links during publish.
3. Re-running repeats the same paths, so existing pages are updated, not duplicated.

## Governance
Publishing is client-visible. The delivery team reviews content before publishing; never include
anything from `.env` or `src/` (secrets / client-confidential).

## Read more
- ADO MCP setup: [playbook/mcp.md](../../playbook/mcp.md)
- Adding/extending pages: [adding-a-page.md](adding-a-page.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
'../../playbook/mcp.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: `-> True`.

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/publishing-to-ado-wiki.md
git commit -m "Add docs/usage/publishing-to-ado-wiki.md"
```

---

### Task 7: adding-a-page.md

**Files:**
- Create: `docs/usage/adding-a-page.md`

**Links/Index contract:**
- Produces: page `adding-a-page.md` (maintainability convention). Linked from README.

- [ ] **Step 1: Write the page**

Create `docs/usage/adding-a-page.md`:

```markdown
# Adding a Page

**Audience:** delivery

## Purpose
Keep this guide easy to extend. Adding a page is a ~2-minute, four-step job.

## Steps
1. **Create the file** `docs/usage/<name>.md` using the standard page shape:
   `# Title` → `**Audience:** delivery | client | both` → `## Purpose` (1–2 sentences) →
   your sections → `## Read more` (links).
2. **Link, don't duplicate.** Point to the authoritative source — [CLAUDE.md](../../CLAUDE.md),
   [PLAYBOOK.md](../../playbook/PLAYBOOK.md), [mcp.md](../../playbook/mcp.md),
   [governance.md](../../playbook/governance.md) — instead of restating it. Use relative links
   (repo root is `../../`; sibling pages are bare names).
3. **Add one index line** to [README.md](README.md):
   `- [Title](<name>.md) — one-line hook [audience]`.
4. **Publish (optional)** per [publishing-to-ado-wiki.md](publishing-to-ado-wiki.md): add a row to
   its mapping table and re-run the publish.

## Conventions recap
- One index (README), one audience tag per page, consistent page shape, link over duplicate.
- Run `powershell -File scripts/verify-scaffold.ps1` after changes; it must print `ALL CHECKS PASSED`.

## Read more
- Index: [README.md](README.md)
- Publishing: [publishing-to-ado-wiki.md](publishing-to-ado-wiki.md)
```

- [ ] **Step 2: Verify link targets exist**

Run:
```powershell
'../../CLAUDE.md','../../playbook/PLAYBOOK.md','../../playbook/mcp.md','../../playbook/governance.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: every line `-> True`.

- [ ] **Step 3: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```bash
git add docs/usage/adding-a-page.md
git commit -m "Add docs/usage/adding-a-page.md"
```

---

### Task 8: README.md index + global verification

**Files:**
- Create: `docs/usage/README.md`

**Links/Index contract:**
- Consumes: all seven sibling pages from Tasks 1–7 (they must exist before the index links resolve).
- Produces: the guide's entry point and index.

- [ ] **Step 1: Write the index**

Create `docs/usage/README.md`:

```markdown
# Using the AI-SDLC Playbook

A task-oriented guide to running the Playbook. It tells you *how to do X* and links to the
authoritative reference docs for the detail. New here? Start with **Getting Started**.

## Reference docs (the source of truth)
- [CLAUDE.md](../../CLAUDE.md) — operating manual: agents, commands, workflow.
- [playbook/PLAYBOOK.md](../../playbook/PLAYBOOK.md) — the full model.
- [playbook/mcp.md](../../playbook/mcp.md) — MCP integrations setup.

## For the delivery team
- [Getting Started](getting-started.md) — clone, configure MCP, classify, first run. [delivery]
- [Running an Engagement](running-an-engagement.md) — the run order, command + agent per step. [delivery]
- [Running a Sprint](running-a-sprint.md) — the recurring per-sprint command loop. [delivery]
- [Publishing to the ADO Wiki](publishing-to-ado-wiki.md) — sync this guide into the project wiki. [delivery]
- [Adding a Page](adding-a-page.md) — how to extend this guide. [delivery]

## For everyone / clients
- [Governance and Reviews](governance-and-reviews.md) — the human approval gates, DoR/DoD. [both]
- [For Clients](for-clients.md) — orientation for client stakeholders. [client]
```

- [ ] **Step 2: Verify the index resolves and every sibling exists**

Run:
```powershell
'README.md','getting-started.md','running-an-engagement.md','running-a-sprint.md','governance-and-reviews.md','for-clients.md','publishing-to-ado-wiki.md','adding-a-page.md' | ForEach-Object { "$_ -> $(Test-Path (Join-Path 'docs/usage' $_))" }
```
Expected: all 8 lines `-> True`.

- [ ] **Step 3: Global link sweep (no broken relative links)**

Run this to list every relative link target across the guide and flag missing ones:
```powershell
Get-ChildItem docs/usage -Filter *.md | ForEach-Object {
  $dir = $_.DirectoryName
  Select-String -Path $_.FullName -Pattern '\]\(([^)#]+)' -AllMatches |
    ForEach-Object { $_.Matches } | ForEach-Object {
      $rel = $_.Groups[1].Value
      if ($rel -notmatch '^https?://') {
        $p = Join-Path $dir $rel
        if (-not (Test-Path $p)) { "MISSING: $rel (in $($_.Path))" }
      }
    }
}
```
Expected: **no output** (every relative link resolves). Fix any `MISSING:` line before continuing.

- [ ] **Step 4: Run the scaffold verifier**

Run: `powershell -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0) — confirms the additive folder broke nothing.

- [ ] **Step 5: Commit**

```bash
git add docs/usage/README.md
git commit -m "Add docs/usage/README.md index for the usage guide"
```

---

## Self-Review

**1. Spec coverage:**
- §3 structure (8 files) → Tasks 1–8 create exactly those files. ✓
- §4 page purposes/links → each task's content matches the §4 row. ✓
- §5 maintainability (index, link-don't-duplicate, page shape, adding-a-page) → README index (Task 8), Global Constraints, page shape per page, Task 7. ✓
- §6 ADO wiki sync (prerequisite, stable mapping, process, governance) → Task 6. ✓
- §8 AC1–AC8 → AC1/AC2 Task 8 + all; AC3 Global Constraints "link don't duplicate"; AC4 Tasks 1–3; AC5 Task 5; AC6 Task 6; AC7 Task 7; AC8 verifier step in every task. ✓

**2. Placeholder scan:** No TBD/TODO; every page's full content is shown; commands are concrete with expected output. ✓

**3. Type/name consistency:** File names, the audience tag format, the page shape, and the relative-link convention (`../../`) are identical across all tasks; README index entries match the created filenames; the ADO mapping table lists the same filenames. ✓
