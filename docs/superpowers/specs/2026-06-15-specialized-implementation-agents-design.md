# Specialized Implementation Agents — Design Spec

**Date:** 2026-06-15
**Status:** Approved (design) — pending implementation plan
**Topic:** Split the single `implementation` agent into a layer-specialized agent family with an orchestrator.

> **Revision note:** v3. v2 was revised after two adversarial verification passes (critics fact-checked it against the repo) — fixing a cross-layer-integrity blocker, the working-tree concurrency hazard, the inherited characterization-test sequencing, the arg-parsing grammar, the review-owner reconciliation, and the full set of repo files that must stay consistent (README, `playbook/mcp.md`, `playbook/PLAYBOOK.md`, `scripts/verify-scaffold.ps1`). v3 applies five reviewer patches: multi-layer hints still run a (constrained) scope pass; layer agents do **not** stage during parallel fan-out (no shared-index race); the sole-stager/committer rule is made explicit per flow; greenfield parallelism is gated on disjoint partitions with a sequential fallback; and the inherited characterization-test gate is explicitly orchestrator-coordinated.

---

## 1. Problem & goal

Today a single agent, [implementation.md](../../../.claude/agents/implementation.md), builds everything: it implements stories, fixes bugs, refactors, and performs codebase/architecture analysis across all tiers of any system. It is invoked by `/execution`, `/architecture`, `/map-codebase`, and `/system-assessment`.

**Goal:** introduce **specialized implementation agents that actually implement their own domain (layer)**, while keeping `implementation` as the brain that scopes a ticket and integrates the results. Specialization is **by layer/role** (not by technology stack), which keeps every agent **portable across clones** — the repo is a reusable base meant to serve many client engagements regardless of stack.

**Non-goals:**
- No technology-stack-specific agents (react/dotnet/python). Layer agents are stack-agnostic.
- No new infra/IaC implementation agent — that overlaps the existing `devops` agent.
- No rebuild of `test-automation` — it is already a specialized implementer (it writes real test code into the repo) and is left unchanged.
- No per-layer slash commands — all execution still routes through `/execution`.

## 2. Key constraint that shapes the design

In this repo (and Claude Code generally) **a subagent cannot spawn other subagents** — orchestration always runs in the *command* executing in the main conversation. Every existing `/`-command here spawns **exactly one** subagent via the Task tool (verified: each command file references `subagent_type` once; no command spawns multiple or parallel agents). Therefore "implementation = orchestrator" is realized as **command-hosted fan-out**: the `/execution` command drives the fan-out, while the `implementation` agent supplies the *intelligence* on both ends (scoping the ticket into layers + a shared contract, and integrating the slices into one pack).

**This parallel multi-agent fan-out (scope + N layers + merge) is a NEW pattern not yet exercised by any command in this repo** — the existing single-spawn pattern is precedent only for command-hosted orchestration, not for parallelism. The `/execution` upgrade is therefore the reference implementation and must define the concurrency rules in §5b explicitly rather than lean on precedent.

## 3. Agent family

| Agent | Role | Status |
|-------|------|--------|
| `implementation` | **Orchestrator + integrator + generalist analyst.** Scopes a ticket into participating layers, writes a per-layer brief **and a shared cross-layer contract**; after layer agents run, integrates their slices into one pack, verifies code-level cross-layer consistency, and is the **sole committer**. Still runs `/architecture`, `/map-codebase`, `/system-assessment` **solo** (no fan-out). | Rewritten |
| `implementation-frontend` | Web UI, components, client-side state, styling. | New |
| `implementation-backend` | Server-side logic, API endpoints, services, auth, business rules. | New |
| `implementation-data` | Database schema, migrations, queries, ORM, data access. Highest-risk tier. | New |
| `implementation-mobile` | iOS / Android / cross-platform app code. | New |
| `test-automation` | Existing specialized implementer for automated test code. Deep test suites stay under `/qa`; layer agents write only their own inline dev tests. | Unchanged |

**Each layer agent:**
- Implements **only its own tier's code** into the cloned project repo at `src/<engagement>/<project-repo>/`. Never writes code into `delivery/`.
- **Consumes the shared cross-layer contract** (see §5b) as a fixed input — it must NOT invent its own cross-layer API shapes, shared types, or DB↔API field mappings.
- **Owns only its partitioned files.** During multi-layer fan-out it **edits only those files and returns its changed-file list — it does NOT `git add`/stage, commit, push, or open PRs** (the shared git index would race under parallelism); the merge pass is the sole stager and committer (see §5b). Shared/cross-cutting files (lockfiles, dependency manifests, DI/route registration, shared type/contract files) are owned by the orchestrator, not a layer agent. *(Exception: in the single-layer fast path the lone agent has no peers to race with, so it may stage and commit itself — see §5 step 6d.)*
- **Returns** its slice of the pack as its final message (affected files/modules, implementation plan, code-change summary, tests added/updated, commands run, risks, doc updates) — it does **not** write the shared pack file, so parallel layer agents never collide on the delivery artifact.
- May **escalate**: if it discovers work outside its tier, it returns an explicit `escalate: needs layers <X,Y>` signal **before committing or staging anything** instead of silently shipping a partial change (see §5 step 6d).
- Keeps the standard governance footer: **Observed facts / Assumptions / Risks / Recommendations / Open questions**.
- Is **scenario-aware** (greenfield vs inherited) via the orchestrator's brief; for inherited work it preserves recovered business rules and works under the characterization-test gate defined in §5b.

## 4. Scoped toolsets

Specialization means narrower, sharper tool allowlists per agent. Frontmatter `tools:` lines (tokens match existing agents verbatim):

| Agent | `tools:` |
|-------|----------|
| `implementation-frontend` | `Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*` |
| `implementation-backend` | `Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*` |
| `implementation-data` | `Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*` |
| `implementation-mobile` | `Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*` |
| `implementation` (orchestrator) | unchanged — keeps the full current set: `Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*` |

Rationale: Figma + Playwright belong to the visual/UI tiers (frontend, mobile); backend and data drop them to stay scoped. All keep GitHub + Azure DevOps for repo/work-item access. Unconfigured MCP servers are inert, so an unused pattern is harmless (consistent with current agents).

**Git discipline:** although layer agents hold `Bash` and `mcp__github__*` (so they can run builds/tests and read repo state), during multi-layer fan-out they **must not `git add`/stage, commit, push, or open PRs** — staging on a shared index races under parallelism, so all index/commit operations are reserved for the merge pass. *(Only in the single-layer fast path, where the agent runs alone, may it stage and commit.)* This is stated in each layer agent's body and enforced by convention (see §5b).

**Verifier enforcement:** these scoped toolsets are only machine-checked once the four agents are added to `scripts/verify-scaffold.ps1`'s `$agentMcpMap` (§8 item 8). Until then they would be unverified; the spec requires that update so §4 is enforced, not advisory.

## 5. Orchestration flow (`/execution` upgrade)

The existing command [.claude/commands/execution.md](../../../.claude/commands/execution.md) has **8 numbered steps**: (1) resolve args, (2) load state, (3) branch on scenario, (4) soft prerequisite check, (5) derive output path, (6) delegate to the agent, (7) update state, (8) report. The upgrade **preserves steps 1–5 and 7–8** and **replaces step 6** (the single "delegate") with the scope → fan-out → merge flow below. It also **refreshes the stale step-8 report text** that says sprint-review/retro/release commands "aren't built yet" (they now exist).

New argument grammar — **positional, not spelling-based**:

`/execution <engagement-slug> <ticket-id> [layer …]`
- token 1 = engagement slug
- token 2 = **exactly one** ticket id (positional; required)
- tokens 3..N = optional layer hints, each validated against the closed set `{frontend, backend, data, mobile}`

The current "remainder is the ticket id" rule is **redefined**: ticket id is exactly token 2, so a layer name can never be mistaken for a ticket id and vice-versa — **position decides, not spelling** (e.g. `/execution acme data` → ticket id is `data`, no layer hint; `/execution acme PROJ-1 data` → ticket `PROJ-1`, layer hint `data`). Validate each layer token; reject unknown layer words with a clear message. This positional grammar is intentionally scoped to `/execution` (the only recurring command that takes trailing layer hints); the sibling commands `/qa` and `/pr-review` keep their simpler "remainder = id" rule by design.

Replacement for step 6:

- **6a. Scope pass** — spawn `implementation` to read the refined story pack + sprint planning pack (+ for inherited, the codebase/architecture map and business-rule recovery report) and the cloned repo, and **return** (a) the set of participating layers, (b) per-layer briefs incl. file-ownership partitions (§5a), (c) the execution order + parallel-vs-sequential decision (§5b), and (d) a shared cross-layer contract (§5b). **A layer hint controls only *which layers* participate, never *whether* the scope pass runs:**
  - **no hint** → the scope pass detects the participating layers itself, then produces (b)–(c), plus (d) the shared contract **only if it detects two or more layers**; if it detects exactly one layer, it routes to the 6d fast path (no contract).
  - **one layer hint** → skip the scope pass and go straight to the single-layer fast path (6d); no contract is needed (a single layer has no cross-layer boundary).
  - **multiple layer hints** → the participating layers are **fixed to the hint**, but the scope pass **still runs as constrained planning** over exactly those layers to produce the briefs, partitions, execution order, and shared contract.

  The shared contract (d) is produced whenever **two or more** layers participate; the fast path (6d) is the explicit winner whenever the participating-layer count is exactly 1.
- **6b. Fan-out** — dispatch the participating layer agents per the concurrency rules in §5b (parallel for greenfield *with disjoint partitions*, sequential otherwise), passing each its brief, partition, the shared contract, the ticket id, the scenario, and relevant prior artifacts. Each implements its slice **in its partition files only — no `git add`/staging, no commits** — and returns its pack-slice plus its changed-file list.
- **6c. Merge pass** — spawn `implementation` to: integrate the returned slices, **verify code-level cross-layer consistency against the shared contract**, **re-dispatch** any layer agent whose code violates the contract (a bounded remediation loop, default max 1 re-dispatch per layer, then surface to the human), **stage and commit** the reconciled change as the **sole stager + committer**, and **write** the completed `<template>` to `src/<eng>/delivery/execution/<ticket>.md`. The merge pass MAY itself make small integrating code edits (e.g. wiring a shared type), but **only within orchestrator-owned shared/cross-cutting files (§5b.2) — never inside a layer's partition**; after any such edit it **re-runs the code-level contract conformance check** before committing.
- **6d. Single-layer fast path** — if exactly one layer participates (hinted or scope-derived), skip the contract/merge passes and spawn that one layer agent directly. **Ordering matters:** the agent first performs layer-scope discovery — if it finds cross-tier work it returns `escalate: needs layers <…>` **before committing, staging, or making any irreversible change**, leaving a clean tree, and the command **promotes the ticket to the multi-layer flow** (which then runs under the §5b deferred-staging rules with the merge pass as sole stager+committer). Otherwise — **only after confirming the work is truly single-layer** — it implements, then **stages and commits** and **writes the pack itself** (orchestrator-lite; it is its own sole stager+committer, with no peers to race), filling the template's governance footer and layer-appropriate review note exactly as the merge pass would (preserving guardrails 1/2/7). **For the inherited scenario, the orchestrator-coordinated characterization-test gate (§5b.5) runs only *after* layer-scope discovery confirms the work is truly single-layer, and before this agent mutates code** — so an escalating ticket runs the gate exactly once (post-promotion, inside the multi-layer flow), never twice. A lone data migration is the highest-risk case and must not ship without a behavior baseline. (Caveat: a single layer agent sees only its tier's brief, so coverage is *not* literally identical to today's generalist — the escalation path is the safety net.)

**Cost note (no silent caps):** multi-layer tickets spawn up to `1 (scope) + N (layers) + ≤N (re-dispatch) + 1 (merge)` agents. This is intentional and disclosed; the single-layer fast path keeps simple tickets to one spawn.

## 5a. Per-layer brief (contract between scope pass and layer agents)

Each layer's brief is a small structured block the orchestrator emits and the command passes verbatim into the layer agent:
- **layer** — one of `{frontend, backend, data, mobile}`
- **scope** — what this layer must implement for the ticket
- **files/modules** — the files/areas this layer owns for this ticket (its partition)
- **acceptance-criteria slice** — the AC items this layer satisfies
- **cross-layer contract refs** — which parts of the shared contract (§5b) this layer consumes/produces
- **scenario notes** — greenfield vs inherited; for inherited, the characterization-test baseline to honor

**Layer-classification heuristic (scope pass):** infer participating layers from the refined story / acceptance criteria and the repo's structure (presence of UI dirs, API/service dirs, schema/migration dirs, mobile project dirs). When ambiguous, the scope pass errs toward **including** a layer (under-classification is the dangerous direction) and the merge/escalation path corrects over-inclusion cheaply.

## 5b. Concurrency, isolation & cross-layer integrity

This section resolves the v1 blocker (conflicting cross-layer contracts) and the working-tree race.

1. **Shared cross-layer contract** — the scope pass produces an explicit contract artifact (API request/response shapes, shared types, DB↔API field mappings, route names). All participating layer agents consume it as a fixed input; none invents its own. The contract is owned by the orchestrator and lives with the brief (not committed as product code unless it corresponds to a real shared source file, which the orchestrator owns).
2. **File-ownership partition** — each layer agent may write only files in its partition (from the brief). Cross-cutting/shared files (lockfiles, dependency manifests, DI/route registration, shared type files) are **orchestrator-owned**; layer agents flag needed changes to them in their returned slice instead of editing them.
3. **Deferred staging & commits** — during multi-layer fan-out, layer agents **edit their partition files only and return a changed-file list; they do NOT `git add`/stage, commit, or push.** The merge pass is the **sole stager and committer**, so concurrent agents never touch the shared git index. *(The single-layer fast path — §5 step 6d — is the only case where the lone agent stages + commits itself, since it has no peers to race with.)*
4. **Greenfield = parallel (only when partitions are disjoint)** — layer agents run concurrently, safe given points 1–3 **and** the disjoint-partition guard in point 6.
5. **Inherited = sequential + characterization gate (orchestrator-coordinated)** — before any layer mutates code, a baseline **characterization-test step locks current behavior**; then layer agents run **sequentially in safe order `data → backend → frontend/mobile`** (migrations are hardest to reverse, so data goes first and behavior is captured before each change). **`implementation` owns and coordinates the gate**: it may reuse existing tests, generate a minimal behavior baseline directly, or hand off to `/qa` → `test-automation` when the baseline is too broad to write inline. This honors the playbook's "characterization tests before changing behavior" rule, which is unsequenceable under naive parallelism. The gate applies to **both** the single-layer fast path and the multi-layer flow.
6. **Parallel only when partitions are disjoint (else fall back to sequential)** — greenfield parallel fan-out (point 4) is used **only** when the scope pass confirms the layer partitions are cleanly disjoint. If partitions overlap on shared files (lockfiles, dependency manifests, shared contracts/DTOs, generated API clients, route/DI registration), `/execution` resolves it with a **single bounded, terminating decision**: attempt **at most one** re-partition (default max 1) to make the layers disjoint; **if overlap still remains, fall back to sequential execution in a safe order** — the mandatory terminal state, so the guard can never loop. Overlap on *orchestrator-owned* shared files is expected — those are written by the merge pass, not a layer agent — and does not by itself force sequential mode.

## 6. Output / template strategy

- Keep the **single artifact** at the existing path `src/<eng>/delivery/execution/<ticket>.md` (file, not folder) — no path-convention change.
- Layer agents **return** their slices; the orchestrator (merge pass) writes the one merged file, labelling contributions by layer. In the single-layer fast path, the one layer agent writes the file.
- **Template change** to [implementation-pack.md](../../../templates/shared/implementation-pack.md) and [safe-change-pack.md](../../../templates/inherited/safe-change-pack.md): add a new **"## 0. Layer breakdown"** section (placed before the existing section 1 — "1. Ticket understanding" in the Implementation Pack, "1. Issue summary" in the Safe Change Pack) that lists the participating layer(s), the contributing agent(s), and each layer's review owner; and adopt a per-layer label convention `**(layer)**` prefix for content contributed by a specific layer under the existing numbered sections. Single-layer artifacts carry a one-row Layer breakdown and otherwise look as they do today.
- `produced-by:` frontmatter stays `implementation` (the orchestrator owns the pack contract); the actual contributing agent(s) are named in the Layer breakdown. This keeps registry/verifier expectations stable.

## 7. Scenario handling & governance

- **Greenfield** → fills `templates/shared/implementation-pack.md` (Implementation Pack). **Inherited** → fills `templates/inherited/safe-change-pack.md` (Safe Change Pack). The existing `/execution` scenario branch is reused; behavior differs only per §5b (parallel vs sequential+characterization).
- **Human review owners** — anchored to the repo's existing vocabulary (Developer / Tech Lead / QA / Architect; the playbook does not define "DBA"/"Mobile Developer" roles). The base owner remains **Developer / Tech Lead**; the Layer breakdown notes the contributing layer as a sub-specialization, e.g. *Developer (frontend) / Tech Lead*, *Developer (data) / Tech Lead — Architect for schema-impacting change*. The **produced artifact's footer/frontmatter `review-owner:` is whatever the template declares** (greenfield `Developer / Tech Lead`; inherited `Developer / Tech Lead / QA / BA`); the per-layer sub-specialization is recorded in the Layer breakdown, not by rewriting the template owner. This reconciles §6's minimal-template-change goal with AC7.
- All seven governance guardrails from `playbook/governance.md` continue to apply unchanged (no secrets/production data; human review before merge; facts/assumptions/risks separation in every artifact). AI cannot approve/merge its own work.

## 8. Repo-convention updates (to keep the base internally consistent)

1. **New agent files:** `.claude/agents/implementation-frontend.md`, `implementation-backend.md`, `implementation-data.md`, `implementation-mobile.md` — same frontmatter shape (`name`, `description` with trigger cues, `tools`) and body sections (`## Purpose`, `## When to use / primary users`, `## Inputs`, `## Outputs`, `## Governance reminders`) as existing agents.
2. **Rewrite** `.claude/agents/implementation.md` — Purpose and "When to use" updated to describe the orchestrate-scope-integrate-commit role plus the retained solo analysis duties; cross-reference the four layer agents.
3. **`/execution` command** — `.claude/commands/execution.md`: new positional layer-hint grammar, the scope/fan-out/merge replacement of step 6, the §5b concurrency rules, and a refresh of the stale step-8 report text.
4. **`CLAUDE.md`** — Agents table: rewrite the `implementation` row and add four layer-agent rows (review owners per §7); add a short "Layer-specialized implementation family & routing" note. Run-order tables: annotate **Greenfield Step 9** and **Inherited Step 10** to show orchestration (command stays `/execution`).
5. **`playbook/PLAYBOOK.md`** — CLAUDE.md defers to this as the authoritative model. Update §3.1 "Core AI Agents" roster (re-role Implementation Agent + add the four layer agents) and reconcile the §5 Step 9 / §6 Step 10 narrative so the authoritative sequence matches the agent files.
6. **`README.md`** — update the agent count (currently `12 specialized subagents` on line 11) to **16**; add a one-line note about the layer family if the prose warrants it.
7. **`playbook/mcp.md`** — append four rows to the §3 "Servers → agents map" matching the §4 allowlists (frontend/mobile include figma+playwright; backend/data do not), since CLAUDE.md and README point to this map as the authoritative servers→agents reference.
8. **`scripts/verify-scaffold.ps1`** — extend the hardcoded `$expectedAgents` list (so the four new agents don't emit "unexpected agent file" WARNs) **and** the `$agentMcpMap` (so the §4 scoped toolsets are actually enforced, not silently skipped).
9. **`playbook/verification-status.md`** — add four rows (one per new agent) at status **`untested`** (the legend's valid "shipped but not yet run" word — `unverified` is NOT a valid status and would fail the verifier's `verified|untested|broken` check), with `—` for Last checked / Notes.
10. **Templates** — the "## 0. Layer breakdown" addition from §6 to both packs.

## 9. Out of scope / deferred seams

- **Automatic** cross-layer E2E test delegation to `test-automation` on *every* execution — not built; `/qa` → `test-automation` remains the owner of deep automated tests and layer agents write only slice-level dev tests. **However**, the orchestrator MAY *require* a `/qa` → `test-automation` handoff for risky inherited or regression-heavy changes — a **discretionary** gate the orchestrator invokes by judgment, not an automatic step for every ticket.
- **Infra/IaC implementation agent** — explicitly not created (overlaps `devops`).
- **Per-layer slash commands** — not created; `/execution` is the single entry point.
- **Nested-subagent orchestration** (Approach B) — rejected due to the platform constraint in §2.
- **Git-worktree isolation per layer agent** — considered as an alternative to deferred-commits (§5b.3); rejected for now as heavier than file-partition + single-committer, but noted as a future option if file partitions prove insufficient.

## 10. Acceptance criteria

1. Four new agent files exist with scoped toolsets per §4 and the standard body sections; `implementation.md` is rewritten to the orchestrator/integrator/committer role; the four agents are added to `verify-scaffold.ps1`'s `$expectedAgents` and `$agentMcpMap` so §4 is machine-enforced (no WARN noise).
2. `/execution` uses the positional grammar (§5), runs scope → fan-out → merge for multi-layer tickets, and the single-layer fast path (one spawn) for single-layer tickets — for **both** greenfield and inherited scenarios.
3. **Concurrency/integrity:** greenfield multi-layer runs parallel **only when file partitions are disjoint** (otherwise it falls back to sequential or re-partitions — §5b.6), with deferred staging + a shared contract; inherited runs sequentially (`data → backend → frontend/mobile`) behind an orchestrator-coordinated characterization-test gate that covers **both** single-layer (fast path) and multi-layer tickets; layer agents **never `git add`/stage or commit during fan-out** — the merge pass is sole stager+committer, verifies code-level contract conformance, confines its own edits to orchestrator-owned files (re-checking the contract after them), and re-dispatches on violation. The single-layer fast-path agent may stage+commit itself, but only after confirming single-layer scope; escalation happens before any commit/stage/irreversible change. A multi-layer hint still triggers a (constrained) scope pass for briefs, partitions, order, and contract.
4. A single-layer ticket produces an artifact shaped like today's at `delivery/execution/<ticket>.md` (plus a one-row Layer breakdown); a multi-layer ticket produces one merged pack with a populated Layer breakdown and per-layer-labelled content; every artifact retains the governance footer.
5. **Consistency:** CLAUDE.md, run-order tables, `playbook/PLAYBOOK.md`, `README.md` (count → 16), `playbook/mcp.md` §3, `playbook/verification-status.md` (four `untested` rows), `scripts/verify-scaffold.ps1`, and both templates are all updated; the scaffold verifier exits 0 with **no WARNs** attributable to the new agents.
6. `/architecture`, `/map-codebase`, `/system-assessment` are unchanged and still spawn `implementation` solo.
7. Each produced artifact retains the template's `review-owner` footer, with the per-layer sub-specialization recorded in the Layer breakdown (no clash with the template owner).

## 11. Decisions captured from brainstorming

- **Split axis:** by layer/role (portable across clients). *(rejected: by stack, by task type)*
- **Roster:** frontend, backend, data, mobile; `test-automation` kept as-is; no infra agent.
- **Routing model:** `implementation` = orchestrator, realized as command-hosted fan-out. *(rejected: command-only routing, explicit-invocation-only, nested subagents)*
- **Scope of build:** Approach A — full orchestrator (agents + scoped tools + rewritten `implementation` + `/execution` upgrade + run-order/template/verification-status/PLAYBOOK/README/mcp/verifier updates).
- **Mobile agent name:** `implementation-mobile` (groups with the family in `.claude/agents/`).
- **Multi-layer cost:** double `implementation` pass (scope + merge) accepted for a clean integrated pack; single-layer fast path avoids it.
- **Test boundary:** deep automated tests stay with `/qa` → `test-automation`; layer agents write slice-level dev tests only. The orchestrator MAY require a `/qa` → `test-automation` handoff for risky inherited / regression-heavy changes (discretionary, not automatic).
- **Concurrency (v2):** greenfield parallel; inherited sequential `data → backend → frontend/mobile` behind a characterization gate; file-partition + shared contract + single-committer merge pass.
- **Reviewer patches (v3):** (1) multi-layer hints still run a constrained scope pass (hint fixes *which* layers, not *whether* scope runs); (2) layer agents do **not** `git add`/stage during parallel fan-out — they edit + return changed-file lists; the merge pass is sole stager+committer; (3) sole-stager/committer is explicit per flow — merge pass for multi-layer, lone agent for the fast path after confirming single-layer scope; (4) greenfield parallelism requires disjoint partitions, else fall back to sequential or re-partition; (5) the inherited characterization-test gate is orchestrator-coordinated (reuse / generate minimal baseline / hand off to `test-automation`).
