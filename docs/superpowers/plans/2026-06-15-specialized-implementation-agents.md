# Specialized Implementation Agents — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Split the single `implementation` agent into a layer-specialized family (`implementation-frontend`, `-backend`, `-data`, `-mobile`) with `implementation` rewritten as the orchestrator/integrator, routed through an upgraded `/execution` command, and keep every cross-referencing doc + the scaffold verifier internally consistent.

**Architecture:** Command-hosted fan-out — `/execution` (running in the main conversation) spawns `implementation` to scope a ticket into layers + a shared cross-layer contract, fans out to the layer specialists (parallel for greenfield with disjoint partitions; sequential `data → backend → frontend/mobile` for inherited behind a characterization-test gate), then spawns `implementation` to integrate the slices and commit. Subagents never spawn subagents; layer agents edit only their partition and never stage/commit during fan-out (the merge pass is sole stager+committer). Full design: [docs/superpowers/specs/2026-06-15-specialized-implementation-agents-design.md](../specs/2026-06-15-specialized-implementation-agents-design.md).

**Tech Stack:** Markdown agent/command/template files (Claude Code conventions); PowerShell 5.1 scaffold verifier (`scripts/verify-scaffold.ps1`); Claude Code subagents via the Task tool; MCP tool-pattern allowlists (`mcp__<server>__*`).

**Verification approach (read first):** This is a docs/config repo. The automated "test" is `scripts/verify-scaffold.ps1` — it checks structure (required agents present, frontmatter `name` matches filename, MCP tool wiring matches `$agentMcpMap`, template count == 30, and registry parity: every on-disk agent/command/server has exactly one `verification-status.md` row with a `verified|untested|broken` status). Most tasks are gated on running it. **The `/execution` runtime orchestration is prose, not executable code — there is no automated test that it fans out correctly. It is functionally verified only by running `/execution` against a real engagement, which is why its `verification-status.md` row stays `untested` until a human exercises it.** For prose tasks, the gate is: (a) verifier still passes, and (b) a read-through against the named spec section. Run the verifier with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
```

Expected when fully done: `ALL CHECKS PASSED` (exit 0) with **no** `WARN` lines.

---

## File structure

**Create (4 layer-agent files):**
- `.claude/agents/implementation-frontend.md` — frontend/UI layer specialist
- `.claude/agents/implementation-backend.md` — backend/API layer specialist
- `.claude/agents/implementation-data.md` — data/persistence layer specialist
- `.claude/agents/implementation-mobile.md` — mobile layer specialist

**Modify (10 consistency targets):**
- `.claude/agents/implementation.md` — rewrite to orchestrator/integrator role (name + tools unchanged)
- `.claude/commands/execution.md` — positional grammar + scope/fan-out/merge + concurrency + refreshed report
- `templates/shared/implementation-pack.md` and `templates/inherited/safe-change-pack.md` — add `## 0. Layer breakdown`
- `CLAUDE.md` — agents table (rewrite `implementation` row + 4 new rows), family note, run-order annotations
- `playbook/PLAYBOOK.md` — §3.1 roster re-role + 4 rows; Step 9 / Step 10 orchestration notes
- `README.md` — agent count 12 → 16
- `playbook/mcp.md` — §3 servers→agents map: 4 new rows
- `scripts/verify-scaffold.ps1` — extend `$expectedAgents` and `$agentMcpMap`
- `playbook/verification-status.md` — 4 new `untested` agent rows

**Commit convention:** plain commit messages, no `Co-Authored-By` trailer. Commit to `main` (matches this repo's established docs-on-main history).

---

## Task 0: Confirm green baseline

- [ ] **Step 1: Run the scaffold verifier before any change**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0), no WARN. If it is not already green, STOP and fix the pre-existing issue before starting.

---

## Task 1: Create `implementation-frontend` agent

**Files:**
- Create: `.claude/agents/implementation-frontend.md`
- Modify: `playbook/verification-status.md` (add one row)

- [ ] **Step 1: Create the agent file**

Create `.claude/agents/implementation-frontend.md` with exactly:

```markdown
---
name: implementation-frontend
description: Use during Sprint execution to implement the FRONTEND/UI slice of a ticket — web UI, components, client-side state, styling — as a layer specialist coordinated by the implementation orchestrator. Trigger cues — "frontend slice", "UI implementation", "build the component", "client-side", routed from /execution with a frontend layer.
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*
---

# Implementation Agent — Frontend / UI

## Purpose
Implements the **frontend/UI tier** of a ticket: web UI, components, client-side state, and styling. A layer specialist in the implementation family — the `implementation` orchestrator scopes the ticket; this agent builds only its tier.

## When to use / primary users
Greenfield Step 9 / Inherited Step 10, dispatched by `/execution` when a ticket touches the frontend layer — alone (single-layer fast path) or alongside other layers (multi-layer fan-out). Primary users: Frontend Developers, Tech Lead. For cross-cutting build or codebase/architecture analysis, use the `implementation` orchestrator instead.

## Inputs
- The per-layer brief from the orchestrator (scope, file partition, acceptance-criteria slice, cross-layer contract refs, scenario notes)
- The shared cross-layer contract (API shapes, shared types) — consumed as a FIXED input; do not invent your own cross-layer shapes
- The ticket / acceptance criteria, and the project repo at `src/<engagement>/<project-repo>/`
- For inherited work: the codebase/architecture map, business-rule recovery report, and the characterization-test baseline

## Outputs
- **Frontend code + slice-level dev tests written INTO the project repo**, within this layer's file partition only. Never write code into `delivery/`.
- **A returned pack-slice** as the final message — affected files/modules, implementation plan, code-change summary, tests added/updated, commands run, risks, doc updates, and a changed-file list. The orchestrator merges slices into the Implementation Pack / Safe Change Pack.
- In the single-layer fast path (running alone) this agent fills the pack template itself, including a one-row `## 0. Layer breakdown` and the governance footer.

## Governance reminders
- **Human review owner:** Developer (frontend) / Tech Lead. AI cannot merge; human review required.
- During multi-layer fan-out: **edit only this layer's partition files; do NOT `git add`/stage, commit, push, or open PRs** — the merge pass is the sole stager+committer. Only in the single-layer fast path (no peers to race with) may this agent stage + commit, and only after confirming the work is truly single-layer.
- If the work needs another tier, **return `escalate: needs layers <…>` before staging/committing or any irreversible change** — never ship a partial cross-layer change.
- Consume the shared contract; flag needed changes to orchestrator-owned shared files (lockfiles, dependency manifests, DI/route registration, shared types) in the returned slice instead of editing them.
- Separate **Observed facts / Assumptions / Risks / Recommendations / Open questions** in the returned slice.
```

- [ ] **Step 2: Add the verification-status row**

In `playbook/verification-status.md`, in the `## Agents` table, replace:

```markdown
| implementation | 🟡 untested | — | — |
```

with:

```markdown
| implementation | 🟡 untested | — | — |
| implementation-frontend | 🟡 untested | — | — |
```

- [ ] **Step 3: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). You WILL see `WARN: unexpected agent file: implementation-frontend.md` — that is expected and non-fatal until Task 5 wires `$expectedAgents`. There must be **no** `CHECK(S) FAILED`.

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/implementation-frontend.md playbook/verification-status.md
git commit -m "Add implementation-frontend layer agent + registry row"
```

---

## Task 2: Create `implementation-backend` agent

**Files:**
- Create: `.claude/agents/implementation-backend.md`
- Modify: `playbook/verification-status.md` (add one row)

- [ ] **Step 1: Create the agent file**

Create `.claude/agents/implementation-backend.md` with exactly:

```markdown
---
name: implementation-backend
description: Use during Sprint execution to implement the BACKEND/API slice of a ticket — server-side logic, API endpoints, services, auth, business rules — as a layer specialist coordinated by the implementation orchestrator. Trigger cues — "backend slice", "API implementation", "service logic", "endpoint", "auth", routed from /execution with a backend layer.
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*
---

# Implementation Agent — Backend / API

## Purpose
Implements the **backend/API tier** of a ticket: server-side logic, API endpoints, services, authentication/authorization, and business rules. A layer specialist in the implementation family — the `implementation` orchestrator scopes the ticket; this agent builds only its tier.

## When to use / primary users
Greenfield Step 9 / Inherited Step 10, dispatched by `/execution` when a ticket touches the backend layer — alone (single-layer fast path) or alongside other layers (multi-layer fan-out). Primary users: Developers, Tech Lead. For cross-cutting build or codebase/architecture analysis, use the `implementation` orchestrator instead.

## Inputs
- The per-layer brief from the orchestrator (scope, file partition, acceptance-criteria slice, cross-layer contract refs, scenario notes)
- The shared cross-layer contract (API shapes, shared types, DB↔API field mappings) — consumed as a FIXED input; do not invent your own cross-layer shapes
- The ticket / acceptance criteria, and the project repo at `src/<engagement>/<project-repo>/`
- For inherited work: the codebase/architecture map, business-rule recovery report, and the characterization-test baseline

## Outputs
- **Backend/API code + slice-level dev tests written INTO the project repo**, within this layer's file partition only. Never write code into `delivery/`.
- **A returned pack-slice** as the final message — affected files/modules, implementation plan, code-change summary, tests added/updated, commands run, risks, doc updates, and a changed-file list. The orchestrator merges slices into the Implementation Pack / Safe Change Pack.
- In the single-layer fast path (running alone) this agent fills the pack template itself, including a one-row `## 0. Layer breakdown` and the governance footer.

## Governance reminders
- **Human review owner:** Developer / Tech Lead. AI cannot merge; human review required.
- During multi-layer fan-out: **edit only this layer's partition files; do NOT `git add`/stage, commit, push, or open PRs** — the merge pass is the sole stager+committer. Only in the single-layer fast path (no peers to race with) may this agent stage + commit, and only after confirming the work is truly single-layer.
- If the work needs another tier, **return `escalate: needs layers <…>` before staging/committing or any irreversible change** — never ship a partial cross-layer change.
- Consume the shared contract; flag needed changes to orchestrator-owned shared files (lockfiles, dependency manifests, DI/route registration, shared types) in the returned slice instead of editing them.
- Separate **Observed facts / Assumptions / Risks / Recommendations / Open questions** in the returned slice.
```

- [ ] **Step 2: Add the verification-status row**

In `playbook/verification-status.md`, in the `## Agents` table, replace:

```markdown
| implementation-frontend | 🟡 untested | — | — |
```

with:

```markdown
| implementation-frontend | 🟡 untested | — | — |
| implementation-backend | 🟡 untested | — | — |
```

- [ ] **Step 3: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). Expected WARNs for `implementation-frontend.md` and `implementation-backend.md` (cleared in Task 5). No `CHECK(S) FAILED`.

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/implementation-backend.md playbook/verification-status.md
git commit -m "Add implementation-backend layer agent + registry row"
```

---

## Task 3: Create `implementation-data` agent

**Files:**
- Create: `.claude/agents/implementation-data.md`
- Modify: `playbook/verification-status.md` (add one row)

- [ ] **Step 1: Create the agent file**

Create `.claude/agents/implementation-data.md` with exactly:

```markdown
---
name: implementation-data
description: Use during Sprint execution to implement the DATA/PERSISTENCE slice of a ticket — database schema, migrations, queries, ORM, data access — as a layer specialist coordinated by the implementation orchestrator. Highest-risk tier. Trigger cues — "data slice", "schema change", "migration", "query", "ORM", "data access", routed from /execution with a data layer.
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*
---

# Implementation Agent — Data / Persistence

## Purpose
Implements the **data/persistence tier** of a ticket: database schema, migrations, queries, ORM mappings, and data-access code. The **highest-risk tier** (migrations are hardest to reverse). A layer specialist in the implementation family — the `implementation` orchestrator scopes the ticket; this agent builds only its tier.

## When to use / primary users
Greenfield Step 9 / Inherited Step 10, dispatched by `/execution` when a ticket touches the data layer — alone (single-layer fast path) or alongside other layers (multi-layer fan-out; data runs first in the inherited safe order). Primary users: Developers (data), Tech Lead, Architect for schema-impacting change. For cross-cutting build or codebase/architecture analysis, use the `implementation` orchestrator instead.

## Inputs
- The per-layer brief from the orchestrator (scope, file partition, acceptance-criteria slice, cross-layer contract refs, scenario notes)
- The shared cross-layer contract (DB↔API field mappings, shared types) — consumed as a FIXED input; do not invent your own cross-layer shapes
- The ticket / acceptance criteria, and the project repo at `src/<engagement>/<project-repo>/`
- For inherited work: the codebase/architecture map, business-rule recovery report, and the characterization-test baseline that must capture current behavior before any migration

## Outputs
- **Data-tier code (schema/migrations/queries/access) + slice-level dev tests written INTO the project repo**, within this layer's file partition only. Never write code into `delivery/`.
- **A returned pack-slice** as the final message — affected files/modules, implementation plan, code-change summary, tests added/updated, commands run, risks (call out reversibility/rollback for migrations), doc updates, and a changed-file list. The orchestrator merges slices into the Implementation Pack / Safe Change Pack.
- In the single-layer fast path (running alone) this agent fills the pack template itself, including a one-row `## 0. Layer breakdown` and the governance footer.

## Governance reminders
- **Human review owner:** Developer (data) / Tech Lead — Architect for schema-impacting change. AI cannot merge; human review required.
- **Migrations are hardest to reverse:** for inherited work, do not change behavior until the orchestrator-coordinated characterization-test gate has captured a baseline; always note rollback/reversibility in the slice risks.
- During multi-layer fan-out: **edit only this layer's partition files; do NOT `git add`/stage, commit, push, or open PRs** — the merge pass is the sole stager+committer. Only in the single-layer fast path (no peers to race with) may this agent stage + commit, and only after confirming the work is truly single-layer.
- If the work needs another tier, **return `escalate: needs layers <…>` before staging/committing or any irreversible change** — never ship a partial cross-layer change.
- Consume the shared contract; flag needed changes to orchestrator-owned shared files (lockfiles, dependency manifests, shared types) in the returned slice instead of editing them.
- Separate **Observed facts / Assumptions / Risks / Recommendations / Open questions** in the returned slice.
```

- [ ] **Step 2: Add the verification-status row**

In `playbook/verification-status.md`, in the `## Agents` table, replace:

```markdown
| implementation-backend | 🟡 untested | — | — |
```

with:

```markdown
| implementation-backend | 🟡 untested | — | — |
| implementation-data | 🟡 untested | — | — |
```

- [ ] **Step 3: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). Expected WARNs for the three new agent files (cleared in Task 5). No `CHECK(S) FAILED`.

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/implementation-data.md playbook/verification-status.md
git commit -m "Add implementation-data layer agent + registry row"
```

---

## Task 4: Create `implementation-mobile` agent

**Files:**
- Create: `.claude/agents/implementation-mobile.md`
- Modify: `playbook/verification-status.md` (add one row)

- [ ] **Step 1: Create the agent file**

Create `.claude/agents/implementation-mobile.md` with exactly:

```markdown
---
name: implementation-mobile
description: Use during Sprint execution to implement the MOBILE slice of a ticket — iOS / Android / cross-platform app code — as a layer specialist coordinated by the implementation orchestrator. Trigger cues — "mobile slice", "iOS", "Android", "React Native", "Flutter", "mobile screen", routed from /execution with a mobile layer.
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*
---

# Implementation Agent — Mobile

## Purpose
Implements the **mobile tier** of a ticket: iOS, Android, or cross-platform app code. A layer specialist in the implementation family — the `implementation` orchestrator scopes the ticket; this agent builds only its tier.

## When to use / primary users
Greenfield Step 9 / Inherited Step 10, dispatched by `/execution` when a ticket touches the mobile layer — alone (single-layer fast path) or alongside other layers (multi-layer fan-out). Primary users: Mobile Developers, Tech Lead. For cross-cutting build or codebase/architecture analysis, use the `implementation` orchestrator instead.

## Inputs
- The per-layer brief from the orchestrator (scope, file partition, acceptance-criteria slice, cross-layer contract refs, scenario notes)
- The shared cross-layer contract (API shapes, shared types) — consumed as a FIXED input; do not invent your own cross-layer shapes
- The ticket / acceptance criteria, and the project repo at `src/<engagement>/<project-repo>/`
- For inherited work: the codebase/architecture map, business-rule recovery report, and the characterization-test baseline

## Outputs
- **Mobile code + slice-level dev tests written INTO the project repo**, within this layer's file partition only. Never write code into `delivery/`.
- **A returned pack-slice** as the final message — affected files/modules, implementation plan, code-change summary, tests added/updated, commands run, risks, doc updates, and a changed-file list. The orchestrator merges slices into the Implementation Pack / Safe Change Pack.
- In the single-layer fast path (running alone) this agent fills the pack template itself, including a one-row `## 0. Layer breakdown` and the governance footer.

## Governance reminders
- **Human review owner:** Developer (mobile) / Tech Lead. AI cannot merge; human review required.
- During multi-layer fan-out: **edit only this layer's partition files; do NOT `git add`/stage, commit, push, or open PRs** — the merge pass is the sole stager+committer. Only in the single-layer fast path (no peers to race with) may this agent stage + commit, and only after confirming the work is truly single-layer.
- If the work needs another tier, **return `escalate: needs layers <…>` before staging/committing or any irreversible change** — never ship a partial cross-layer change.
- Consume the shared contract; flag needed changes to orchestrator-owned shared files (lockfiles, dependency manifests, shared types) in the returned slice instead of editing them.
- Separate **Observed facts / Assumptions / Risks / Recommendations / Open questions** in the returned slice.
```

- [ ] **Step 2: Add the verification-status row**

In `playbook/verification-status.md`, in the `## Agents` table, replace:

```markdown
| implementation-data | 🟡 untested | — | — |
```

with:

```markdown
| implementation-data | 🟡 untested | — | — |
| implementation-mobile | 🟡 untested | — | — |
```

- [ ] **Step 3: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). Expected WARNs for the four new agent files (cleared in Task 5). No `CHECK(S) FAILED`.

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/implementation-mobile.md playbook/verification-status.md
git commit -m "Add implementation-mobile layer agent + registry row"
```

---

## Task 5: Wire the four agents into the scaffold verifier

This clears the WARNs and makes the scoped MCP toolsets machine-enforced.

**Files:**
- Modify: `scripts/verify-scaffold.ps1` (`$expectedAgents` at the `# 2. Agents` block; `$agentMcpMap` at the `# 8. MCP integration layer` block)

- [ ] **Step 1: Extend `$expectedAgents`**

In `scripts/verify-scaffold.ps1`, replace:

```powershell
$expectedAgents = 'product-discovery','product-backlog','scrum-planning','implementation',
                  'code-review','qa-test-design','test-automation','devops',
                  'security-review','documentation','support-incident','retrospective-insights'
```

with:

```powershell
$expectedAgents = 'product-discovery','product-backlog','scrum-planning','implementation',
                  'implementation-frontend','implementation-backend','implementation-data','implementation-mobile',
                  'code-review','qa-test-design','test-automation','devops',
                  'security-review','documentation','support-incident','retrospective-insights'
```

- [ ] **Step 2: Extend `$agentMcpMap`**

In `scripts/verify-scaffold.ps1`, replace:

```powershell
  'implementation'         = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'code-review'            = @('mcp__github__*','mcp__ado__*','mcp__figma__*')
```

with:

```powershell
  'implementation'          = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'implementation-frontend' = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'implementation-backend'  = @('mcp__github__*','mcp__ado__*')
  'implementation-data'     = @('mcp__github__*','mcp__ado__*')
  'implementation-mobile'   = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'code-review'             = @('mcp__github__*','mcp__ado__*','mcp__figma__*')
```

- [ ] **Step 3: Run the verifier — now fully clean**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0) with **no WARN lines** for the new agents, and new passing checks: `agent implementation-frontend tools: mcp__figma__* present`, `agent implementation-backend tools: mcp__figma__* absent`, etc. If any `agent <name> tools: <pattern> present/absent` check FAILS, the agent's `tools:` line in its `.md` does not match `$agentMcpMap` — fix the agent file's `tools:` line to match Task 1–4 exactly.

- [ ] **Step 4: Commit**

```bash
git add scripts/verify-scaffold.ps1
git commit -m "Wire four layer agents into the scaffold verifier (expected set + MCP map)"
```

---

## Task 6: Rewrite `implementation` to the orchestrator role

Keep `name:` and `tools:` unchanged (so the verifier stays green); rewrite the description and body.

**Files:**
- Modify: `.claude/agents/implementation.md`

- [ ] **Step 1: Overwrite the file**

Replace the entire contents of `.claude/agents/implementation.md` with exactly:

```markdown
---
name: implementation
description: Use during the Sprint to ORCHESTRATE a ticket across layer specialists (frontend/backend/data/mobile) — scope it into layers, produce a shared cross-layer contract, integrate the slices, and commit — and to run codebase/architecture analysis for new and inherited systems. Trigger cues — "implement this ticket", "fix this bug", "refactor", "analyze the codebase", "system assessment", "safe change", "architecture foundation".
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*
---

# Implementation Agent (Orchestrator)

## Purpose
The brain of the implementation family. For a ticket, this agent **scopes** the work into layers, writes a per-layer brief and a **shared cross-layer contract**, then — after the layer specialists implement their slices — **integrates** the slices into one pack, verifies code-level cross-layer consistency, and is the **sole stager+committer**. It also remains the **generalist analyst**: it runs `/architecture`, `/map-codebase`, and `/system-assessment` solo (no fan-out).

## When to use / primary users
Greenfield Steps 6, 9; Inherited Steps 3, 6, 10. Primary users: Developers, Tech Lead. During `/execution` it delegates the actual tier code to the layer specialists: `implementation-frontend`, `implementation-backend`, `implementation-data`, `implementation-mobile`. The command (`/execution`) hosts the fan-out — this agent supplies the intelligence on both ends (scope + merge); subagents cannot spawn subagents.

## Inputs
- The ticket / bug, acceptance criteria, business rules, regression risks
- The project repo in `src/<engagement>/<project-repo>/`
- The refined story pack and sprint planning pack; for inherited, the codebase & architecture map and business-rule recovery report
- For the merge pass: the layer specialists' returned pack-slices and changed-file lists

## Outputs
Fill the relevant template(s) and write the result to `src/<engagement>/delivery/`:
- `templates/shared/implementation-pack.md` (merged pack, with a `## 0. Layer breakdown`)
- `templates/inherited/safe-change-pack.md` (merged pack, with a `## 0. Layer breakdown`)
- `templates/greenfield/architecture-technical-foundation-pack.md`
- `templates/inherited/initial-system-assessment.md`
- `templates/inherited/codebase-architecture-map.md`

Code / tests are written INTO the project repo by the layer specialists (and by this agent only for orchestrator-owned shared/cross-cutting files during the merge pass).

## Orchestration responsibilities (during `/execution`)
- **Scope:** detect participating layers (or accept the layer hint), produce per-layer briefs incl. file partitions, the execution order, the parallel-vs-sequential decision, and the shared cross-layer contract (API shapes, shared types, DB↔API field mappings, route names). A single participating layer skips scope/merge (fast path).
- **Concurrency:** greenfield runs specialists in parallel only when partitions are disjoint (else at most one re-partition, then fall back to sequential); inherited runs sequentially `data → backend → frontend/mobile` behind an **orchestrator-coordinated characterization-test gate** (reuse existing tests, generate a minimal baseline, or hand off to `/qa` → `test-automation` when too broad) — the gate applies to single- and multi-layer tickets.
- **Merge:** integrate slices, verify code-level conformance to the contract, re-dispatch a violating specialist (max 1 re-dispatch per layer, then surface to the human), make integrating edits only in orchestrator-owned shared files (re-checking the contract afterward), **stage and commit** as sole stager+committer, and write the merged pack.

## Governance reminders
- **Human review owner:** Developer (Tech Lead reviews complex changes; QA validates; Architect for architectural impact). AI cannot merge; human review required.
- Layer specialists do **not** stage/commit during fan-out — only this agent (merge pass), or the lone fast-path specialist, stages and commits.
- For inherited code, prefer characterization tests before changing behavior. Deep automated tests stay with `/qa` → `test-automation`.
- Separate **Observed facts / Assumptions / Risks / Recommendations / Open questions** in every output.
```

- [ ] **Step 2: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0), no WARN. (`name: implementation` still matches the filename; the `tools:` line is unchanged so `$agentMcpMap['implementation']` still matches.)

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/implementation.md
git commit -m "Rewrite implementation agent as the layer orchestrator/integrator"
```

---

## Task 7: Upgrade the `/execution` command

**Files:**
- Modify: `.claude/commands/execution.md`

- [ ] **Step 1: Overwrite the file**

Replace the entire contents of `.claude/commands/execution.md` with exactly:

```markdown
---
description: Sprint execution (greenfield step 9 / inherited step 10): orchestrate a ticket across layer specialists and capture it as an Implementation Pack (greenfield) or Safe Change Pack (inherited), via the implementation agent.
argument-hint: <engagement-slug> <ticket-id> [layer ...]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/execution** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it once per ticket worked in the sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template. `implementation` is the **orchestrator**: it scopes the ticket into layers and delegates each slice to a layer specialist (`implementation-frontend`, `implementation-backend`, `implementation-data`, `implementation-mobile`), then integrates the slices. Code/tests go INTO the project repo; the merged pack goes into `delivery/`.

1. **Resolve arguments (positional).** Split `$ARGUMENTS` on whitespace. **Token 1** is the engagement slug (`<eng>`); **token 2** is exactly the ticket id (`<ticket>`); **tokens 3..N** are optional layer hints. If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<ticket>` is empty, ask which ticket. Validate `<ticket>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. Validate each layer hint against the closed set `{frontend, backend, data, mobile}`; reject any unknown layer word with a clear message. Position decides, not spelling — a layer name in token 2 is the ticket id, not a hint (e.g. `/execution acme data` → ticket `data`, no hint; `/execution acme PROJ-1 data` → ticket `PROJ-1`, hint `data`).
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>`:
   - **greenfield** → `<step>` = 9; `<template>` = `templates/shared/implementation-pack.md`; `<pack>` = `Implementation Pack`.
   - **inherited** → `<step>` = 10; `<template>` = `templates/inherited/safe-change-pack.md`; `<pack>` = `Safe Change Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — execution usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/execution/<ticket>.md`. Create the `src/<eng>/delivery/execution/` folder if it does not exist.
6. **Orchestrate (scope → fan-out → merge).** `implementation` is the brain on both ends; layer specialists implement only their tier. Subagents cannot spawn subagents, so YOU host the fan-out via the Task tool.
   - **6a. Scope.** Determine the participating layers. If layer hints were given, the participating layers are fixed to the hint. If **no** hint, spawn the **implementation** subagent (`subagent_type: implementation`) to read the refined story pack + sprint planning pack (+ for inherited, the codebase & architecture map and business-rule recovery report) and the cloned repo under `src/<eng>/`, and return the participating layers. Then:
     - **exactly one participating layer** (hinted or detected) → go to **6d fast path**; no contract needed.
     - **two or more** → spawn **implementation** (if not already running for scope) to return, for those fixed layers: per-layer briefs (scope, file partition, acceptance-criteria slice, contract refs, scenario notes), the execution order, the parallel-vs-sequential decision, and a **shared cross-layer contract** (API shapes, shared types, DB↔API field mappings, route names).
   - **6b. Concurrency decision.** Greenfield runs the specialists **in parallel only when their file partitions are disjoint**; if partitions overlap on shared files (lockfiles, dependency manifests, shared contracts/DTOs, generated clients, route/DI registration), attempt **at most one** re-partition, and if overlap remains **fall back to sequential** in a safe order. Inherited always runs **sequentially** in safe order `data → backend → frontend/mobile` behind an orchestrator-coordinated **characterization-test gate** that captures current behavior **before any layer mutates code** (the gate also applies to the 6d fast path; the orchestrator may reuse existing tests, generate a minimal baseline, or hand off to `/qa` → `test-automation` when too broad).
   - **6c. Fan-out.** For each participating layer, spawn its specialist subagent (`subagent_type: implementation-frontend` | `implementation-backend` | `implementation-data` | `implementation-mobile`), passing the per-layer brief, the shared contract, `<ticket>`, the scenario, and the relevant prior artifacts. Each implements its slice **in its partition files only — it does NOT `git add`/stage, commit, push, or open PRs** — and returns its pack-slice plus a changed-file list. Send parallel specialists in one message with multiple Task calls; run them one at a time when 6b requires sequential.
   - **6d. Merge / fast path.**
     - **Multi-layer:** spawn **implementation** to integrate the returned slices, **verify code-level cross-layer consistency against the contract**, **re-dispatch** any specialist whose code violates it (max 1 re-dispatch per layer, then surface to the human), make any integrating edits **only in orchestrator-owned shared files** (re-checking the contract afterward), **stage and commit** as the **sole stager+committer**, and write the completed `<template>` to `<output>` with a `## 0. Layer breakdown` listing the participating layers, contributing agents, and per-layer review owners.
     - **Single-layer fast path:** spawn the one layer specialist directly. It first does layer-scope discovery; if it finds cross-tier work it returns `escalate: needs layers <…>` **before staging/committing or any irreversible change**, and you re-run from 6a as a multi-layer ticket. Otherwise — after confirming single-layer scope (and, for inherited, after the characterization gate) — it implements, **stages and commits**, and writes `<template>` to `<output>` itself, filling the governance footer and a one-row `## 0. Layer breakdown`.
   - In all cases: code and tests go INTO the project repo, never into `delivery/`; deep automated tests remain `/qa` → `test-automation` (the orchestrator MAY require that handoff for risky inherited / regression-heavy changes).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · execution · <ticket> → delivery/execution/<ticket>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where), which layers participated, the current sprint, and sensible next actions: open the PR and run `/pr-review <eng> <pr>`, run `/qa <eng> <ticket>` for tests, and `/daily-scrum <eng>` at standup. To start a new sprint, bump `sprint:` in `engagement.md`. Wrap up the sprint with `/sprint-review <eng>` then `/retro <eng>`, and run `/release-readiness <eng> <release>` (greenfield) or `/modernize <eng>` (inherited) when ready.

You orchestrate only — the agents produce the artifacts and a human reviews them. Never paste secrets or production data.
```

- [ ] **Step 2: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). (The command keeps `description:` and `argument-hint:` frontmatter, which is all the verifier checks for commands; the `/execution` registry row already exists.)

- [ ] **Step 3: Read-through against the spec**

Read the new `.claude/commands/execution.md` against spec §5, §5a, §5b. Confirm: positional grammar (token 2 = ticket), one-hint → fast path, multi-hint → constrained scope, no staging in fan-out, sole stager+committer = merge pass, escalation before any irreversible change, inherited sequential + gate. (No automated test covers runtime behavior — this read-through is the gate.)

- [ ] **Step 4: Commit**

```bash
git add .claude/commands/execution.md
git commit -m "Upgrade /execution to orchestrate layer specialists (scope/fan-out/merge)"
```

---

## Task 8: Add `## 0. Layer breakdown` to both packs

**Files:**
- Modify: `templates/shared/implementation-pack.md`
- Modify: `templates/inherited/safe-change-pack.md`

- [ ] **Step 1: Edit the Implementation Pack**

In `templates/shared/implementation-pack.md`, replace:

```markdown
> Produced while implementing a story or fix to capture the change and its reasoning. Save the filled copy to `src/<engagement>/delivery/`.

## 1. Ticket understanding
```

with:

```markdown
> Produced while implementing a story or fix to capture the change and its reasoning. Save the filled copy to `src/<engagement>/delivery/`.

## 0. Layer breakdown
_Which layers participated, the contributing agent(s), and each layer's review owner. A single-layer ticket has one row. Content contributed by a specific layer is tagged `**(layer)**` under the sections below._

| Layer | Contributing agent | Review owner |
|-------|--------------------|--------------|
| | | |

## 1. Ticket understanding
```

- [ ] **Step 2: Edit the Safe Change Pack**

In `templates/inherited/safe-change-pack.md`, replace:

```markdown
> Produced to plan and make a low-risk change to inherited code without breaking hidden behavior. Save the filled copy to `src/<engagement>/delivery/`.

## 1. Issue summary
```

with:

```markdown
> Produced to plan and make a low-risk change to inherited code without breaking hidden behavior. Save the filled copy to `src/<engagement>/delivery/`.

## 0. Layer breakdown
_Which layers participated, the contributing agent(s), and each layer's review owner. A single-layer ticket has one row. Content contributed by a specific layer is tagged `**(layer)**` under the sections below._

| Layer | Contributing agent | Review owner |
|-------|--------------------|--------------|
| | | |

## 1. Issue summary
```

- [ ] **Step 3: Run the verifier**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). The template count check (`template count == 30`) still holds — we edited, not added — and `produced-by:` is unchanged on both files.

- [ ] **Step 4: Commit**

```bash
git add templates/shared/implementation-pack.md templates/inherited/safe-change-pack.md
git commit -m "Add Layer breakdown section to Implementation Pack and Safe Change Pack"
```

---

## Task 9: Update `CLAUDE.md` (agents table, family note, run-order)

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Rewrite the `implementation` agents-table row and add four rows**

In `CLAUDE.md`, in the Agents table, replace:

```markdown
| `implementation` | Build stories, fix bugs, refactor, codebase analysis | Implementation Pack, Safe Change Pack, Architecture/System/Codebase docs | Developer / Tech Lead |
```

with:

```markdown
| `implementation` | Orchestrate a ticket across layers, integrate the slices, commit; plus codebase/architecture analysis | Implementation Pack, Safe Change Pack, Architecture/System/Codebase docs | Developer / Tech Lead |
| `implementation-frontend` | Implement the frontend/UI slice of a ticket | Frontend code + returned pack-slice | Developer (frontend) / Tech Lead |
| `implementation-backend` | Implement the backend/API slice of a ticket | Backend code + returned pack-slice | Developer / Tech Lead |
| `implementation-data` | Implement the data/persistence slice of a ticket | Data code/migrations + returned pack-slice | Developer (data) / Tech Lead |
| `implementation-mobile` | Implement the mobile slice of a ticket | Mobile code + returned pack-slice | Developer (mobile) / Tech Lead |
```

- [ ] **Step 2: Add the family note after the Agents table**

In `CLAUDE.md`, replace:

```markdown
Invoke an agent with the Task/Agent tool (`subagent_type` = agent name), or let Claude auto-route via the agent's `description`. Each agent file lists the exact template(s) it fills.
```

with:

```markdown
Invoke an agent with the Task/Agent tool (`subagent_type` = agent name), or let Claude auto-route via the agent's `description`. Each agent file lists the exact template(s) it fills.

**Layer-specialized implementation family.** `implementation` is an **orchestrator**: for a multi-tier ticket it scopes the work into layers and delegates each slice to a layer specialist — `implementation-frontend`, `implementation-backend`, `implementation-data`, `implementation-mobile` — then integrates the slices into one pack and is the sole committer. Single-tier tickets route straight to one specialist (the `/execution` fast path). `implementation` still runs `/architecture`, `/map-codebase`, and `/system-assessment` solo. Full design: `docs/superpowers/specs/2026-06-15-specialized-implementation-agents-design.md`.
```

- [ ] **Step 3: Annotate Greenfield run-order Step 9**

In `CLAUDE.md`, in the Greenfield table, replace:

```markdown
| 9 | Sprint execution | `implementation` | `templates/shared/implementation-pack.md` | `/execution` |
```

with:

```markdown
| 9 | Sprint execution | `implementation` (orchestrator → `implementation-frontend`/`-backend`/`-data`/`-mobile`) | `templates/shared/implementation-pack.md` | `/execution` |
```

- [ ] **Step 4: Annotate Inherited run-order Step 10**

In `CLAUDE.md`, in the Inherited table, replace:

```markdown
| 10 | Safe execution | `implementation` | `templates/inherited/safe-change-pack.md` | `/execution` |
```

with:

```markdown
| 10 | Safe execution | `implementation` (orchestrator → layer agents, sequential `data → backend → frontend/mobile`) | `templates/inherited/safe-change-pack.md` | `/execution` |
```

- [ ] **Step 5: Run the verifier and commit**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). (CLAUDE.md is only checked for existence; these are content edits.)

```bash
git add CLAUDE.md
git commit -m "Document the layer implementation family in CLAUDE.md (table, note, run-order)"
```

---

## Task 10: Update `playbook/PLAYBOOK.md` (authoritative roster + step narratives)

**Files:**
- Modify: `playbook/PLAYBOOK.md`

- [ ] **Step 1: Re-role the roster and add four rows (§3.1)**

In `playbook/PLAYBOOK.md`, replace:

```markdown
| Implementation Agent | Helps Developers implement stories, fix bugs, and refactor | Developers |
```

with:

```markdown
| Implementation Agent (orchestrator) | Scopes a ticket into layers, delegates to layer specialists, integrates their work, and is the sole committer; also runs codebase/architecture analysis solo | Developers, Tech Lead |
| Implementation Agent — Frontend | Implements the frontend/UI tier (web UI, components, client state, styling) | Developers (frontend), Tech Lead |
| Implementation Agent — Backend | Implements the backend/API tier (server logic, endpoints, services, auth, business rules) | Developers, Tech Lead |
| Implementation Agent — Data | Implements the data tier (schema, migrations, queries, ORM, data access) | Developers (data), Tech Lead, Architect |
| Implementation Agent — Mobile | Implements the mobile tier (iOS/Android/cross-platform) | Developers (mobile), Tech Lead |
```

- [ ] **Step 2: Add the orchestration note to greenfield Step 9**

In `playbook/PLAYBOOK.md`, in `#### Step 9: Sprint Execution — AI-Assisted Development`, replace:

```markdown
- prepare PR summary.

**AI output**
```

with:

```markdown
- prepare PR summary.

> **Layer orchestration (`/execution`):** for multi-tier tickets the **implementation orchestrator** scopes the work into layers (frontend / backend / data / mobile), delegates each slice to the matching layer specialist agent (in parallel when file partitions are disjoint, else sequential), then integrates the slices into one Implementation Pack as the sole committer. Single-tier tickets route straight to one specialist.

**AI output**
```

- [ ] **Step 3: Add the orchestration note to inherited Step 10**

In `playbook/PLAYBOOK.md`, in `#### Step 10: Sprint Execution — Safe Development and Bug Fixing`, replace:

```markdown
- prepare PR risk notes.

**AI output**
```

with:

```markdown
- prepare PR risk notes.

> **Layer orchestration (`/execution`):** for multi-tier tickets the **implementation orchestrator** scopes the work into layers and runs the layer specialists **sequentially** in safe order (`data → backend → frontend/mobile`) behind an orchestrator-coordinated characterization-test gate that captures current behavior before any change; it then integrates the slices into one Safe Change Pack as the sole committer. The gate applies to single-tier tickets too.

**AI output**
```

- [ ] **Step 4: Run the verifier and commit**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). (PLAYBOOK.md is checked for existence only.)

```bash
git add playbook/PLAYBOOK.md
git commit -m "Reconcile PLAYBOOK roster and Step 9/10 narratives with the layer family"
```

---

## Task 11: Update `README.md` and `playbook/mcp.md`

**Files:**
- Modify: `README.md`
- Modify: `playbook/mcp.md`

- [ ] **Step 1: Bump the agent count in README**

In `README.md`, replace:

```markdown
| `.claude/agents/` | 12 specialized subagents |
```

with:

```markdown
| `.claude/agents/` | 16 specialized subagents |
```

- [ ] **Step 2: Add four rows to the mcp.md servers→agents map (§3)**

In `playbook/mcp.md`, replace:

```markdown
| implementation | ✓ | | ✓ | ✓ | ✓ | |
| code-review | ✓ | | ✓ | ✓ | | |
```

with:

```markdown
| implementation | ✓ | | ✓ | ✓ | ✓ | |
| implementation-frontend | ✓ | | ✓ | ✓ | ✓ | |
| implementation-backend | ✓ | | ✓ | | | |
| implementation-data | ✓ | | ✓ | | | |
| implementation-mobile | ✓ | | ✓ | ✓ | ✓ | |
| code-review | ✓ | | ✓ | ✓ | | |
```

- [ ] **Step 3: Run the verifier and commit**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0). (README.md and mcp.md are checked for existence only; the servers→agents map is documentation, not machine-checked against agents.)

```bash
git add README.md playbook/mcp.md
git commit -m "Update README agent count (16) and mcp.md servers-agents map for layer agents"
```

---

## Task 12: Final acceptance sweep (against spec §10)

**Files:** none modified unless a check fails.

- [ ] **Step 1: Full verifier — must be clean**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED` (exit 0) with **no WARN lines at all**. (Maps to spec AC1 + AC5.)

- [ ] **Step 2: Confirm the four agents exist with correct toolsets**

Run (Grep tool): search `tools:` in `.claude/agents/implementation-frontend.md`, `-backend.md`, `-data.md`, `-mobile.md`.
Expected: frontend + mobile include `mcp__figma__*` and `mcp__playwright__*`; backend + data do **not** (only `mcp__github__*, mcp__ado__*`). (Maps to spec §4 / AC1.)

- [ ] **Step 3: Confirm consistency coverage across docs**

Run (Grep tool) for `implementation-frontend|implementation-backend|implementation-data|implementation-mobile` across the repo. Expected matches in: the 4 agent files, `.claude/agents/implementation.md`, `.claude/commands/execution.md`, `CLAUDE.md`, `playbook/PLAYBOOK.md`, `playbook/mcp.md`, `playbook/verification-status.md`, `scripts/verify-scaffold.ps1`, and the spec. (Maps to spec AC5.)
Also confirm: `README.md` shows `16 specialized subagents` (not 12); `templates/` still has 30 files with the new `## 0. Layer breakdown` in both packs. (Maps to AC4/AC5.)

- [ ] **Step 4: Confirm the solo-analysis commands are untouched**

Run (Grep tool) for `subagent_type: implementation` in `.claude/commands/architecture.md`, `map-codebase.md`, `system-assessment.md`.
Expected: each still spawns `implementation` solo (unchanged). (Maps to spec AC6.)

- [ ] **Step 5: Commit any fixes (if Steps 1–4 surfaced gaps)**

If everything passed with no changes, there is nothing to commit. Otherwise:

```bash
git add -A
git commit -m "Fix consistency gaps found in the layer-agents acceptance sweep"
```

- [ ] **Step 6: Flag what remains human-verified**

Note to the operator: the `/execution` runtime orchestration (scope/fan-out/merge, concurrency, escalation) has **no automated test**. Functionally verify it by running `/execution` against a real engagement, then flip the relevant rows in `playbook/verification-status.md` from `untested` to `verified`. (Maps to spec AC2/AC3, which are exercised, not statically checked.)

---

## Notes for the executor

- **Frequent commits:** one commit per task (already specified). Each commit keeps the verifier green (exit 0); Tasks 1–4 emit expected WARNs that Task 5 clears.
- **No app code / no unit tests here:** the scaffold verifier + grep assertions are the only automated gates. Do not invent a test framework.
- **Exact strings matter:** the `Edit`/replace blocks above are exact — match whitespace and the `🟡` emoji in the registry verbatim.
- **Order dependency:** Tasks 1–4 must precede Task 5 (you cannot list an agent in `$expectedAgents` before its file exists, or the verifier fails `agent present`). Everything after Task 5 is independent and may be reordered.
