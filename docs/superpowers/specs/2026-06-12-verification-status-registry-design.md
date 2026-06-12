# Verification Status Registry — Design Spec

- **Date:** 2026-06-12
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** the completed command/agent build (Passes 1–6) and the MCP integration
  layer. This is a new, optional cross-cutting tracking layer — it adds no run-order step
  and no slash command.

---

## 1. Goal & Context

The playbook ships 12 agents, 23 commands, and 6 declared MCP servers. `scripts/verify-scaffold.ps1`
already provides **structural** verification — it confirms every agent / command / template / MCP
server is present and well-formed. What it cannot tell you is whether a given piece has been
**functionally exercised and works** ("I ran `/intake` end-to-end and it produced the right brief";
"the `github` MCP server actually connects and its tools are callable").

Functional status cannot be auto-detected in the pristine base: MCP servers need live client
credentials, and commands need a real engagement under the gitignored `src/`. So this status is
**human-maintained** — a person flips a row to *verified* once they have actually run the thing.

This spec adds a **central verification-status registry**: a single Markdown file listing every
agent, command, and MCP server with a human-set status, a last-checked date, and notes. The scaffold
verifier is extended to enforce that the registry never drifts out of sync with what is on disk —
every on-disk component must have exactly one row, and no row may name a component that does not
exist. The verifier does **not** judge whether a status is truthful (it cannot know functional
truth); it only guards completeness and well-formedness.

**Success criterion:** `playbook/verification-status.md` exists with an honest baseline (everything
*untested*), the verifier enforces row↔disk parity for agents/commands/MCP servers, and adding any
new agent/command/server in future forces a registry row (the verifier fails until it is added).

**Out of scope (YAGNI):**
- Auto-detecting functional status (needs credentials / a live engagement).
- Tracking external plugin skills (`superpowers:*`, `gsd:*`, etc.) — they are not part of this base.
- A slash command to edit statuses — the registry is plain Markdown; edit it directly.
- Per-engagement status under `src/<eng>/`.

## 2. Decisions (locked)

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **Central registry file** `playbook/verification-status.md`, one table per component type. | The user's selection. A single scannable place handles MCP servers (declared in JSON, no frontmatter) and future skills uniformly, without scattering status across 41 files. |
| D2 | **Status is human-maintained**, not auto-derived. The verifier guards structure only. | Functional "works when run" cannot be observed in the pristine base — no creds, no engagement. Claiming auto-verification would be dishonest. |
| D3 | **Status value is a word token** — `verified` / `untested` / `broken` — with an optional leading emoji (✅ / 🟡 / ❌) for readability. The verifier matches the **word**, ignoring any emoji. | Windows PowerShell 5.1 mangles emoji under default file encoding; matching ASCII words makes the check encoding-robust while keeping the human-facing emoji. |
| D4 | **Baseline = everything `untested`.** Notes capture what is already known (structural pass; `teams` package unconfirmed per MCP spec D7). | Honest: structural ≠ functional. Nothing has been exercised through a real engagement yet. The user flips rows to `verified` as they test. |
| D5 | **Verifier enforces row↔disk parity** for agents, commands, and MCP servers: every on-disk item has exactly one row; no row names a non-existent item; each status cell is a legal token. | Mirrors the verifier's existing discover-on-disk philosophy; makes the registry self-enforcing — a new/renamed/deleted component fails the build until the registry is reconciled. |
| D6 | **Skills section is a placeholder** (no rows; the playbook ships no skills yet). The verifier does **not** enforce skill rows until a `.claude/skills/` directory with skills exists. | Future-proofs the structure without inventing checks for things that do not exist (YAGNI). |
| D7 | **Commands are listed with a leading `/`** (`/intake`); the verifier strips a single leading `/` before matching against command file BaseNames. | `/intake` reads better in a human-facing doc; the normalization keeps matching exact. |

## 3. Deliverables

| File | Change |
|------|--------|
| `playbook/verification-status.md` | **New** — the registry (§4), seeded with all 12 agents, 23 commands, 6 MCP servers at `untested` |
| `scripts/verify-scaffold.ps1` | New `# 9. Verification status registry` block (§5) |
| `CLAUDE.md` | One-line pointer to the registry (§6) |
| `README.md` | Add `playbook/verification-status.md` to the "What's in here" table (§6) |

No new agent, template, command, or MCP server. No run-order or slash-command table change.

## 4. `playbook/verification-status.md` (new registry)

Structure:

```markdown
# Verification Status

Human-maintained record of which playbook pieces have been **functionally exercised and work**.
This is separate from `scripts/verify-scaffold.ps1`, which checks structure only. Update a row
when you have actually run the piece (not just confirmed it exists).

**Status legend:** ✅ `verified` — exercised and working · 🟡 `untested` — shipped/declared but
not yet run · ❌ `broken` — known not working (explain in Notes).

The status cell must contain one of the words `verified`, `untested`, or `broken` (the emoji is
optional decoration). `scripts/verify-scaffold.ps1` enforces that every agent, command, and MCP
server on disk has exactly one row here.

## Agents

| Agent | Status | Last checked | Notes |
|-------|--------|--------------|-------|
| product-discovery | 🟡 untested | — | structural pass; not yet run on a real engagement |
| product-backlog | 🟡 untested | — | |
| … (all 12) | 🟡 untested | — | |

## Commands

| Command | Status | Last checked | Notes |
|---------|--------|--------------|-------|
| /intake | 🟡 untested | — | structural pass; not yet run end-to-end |
| /discovery-prep | 🟡 untested | — | |
| … (all 23) | 🟡 untested | — | |

## MCP servers

| Server | Status | Last checked | Notes |
|--------|--------|--------------|-------|
| github | 🟡 untested | — | needs a PAT + Docker to exercise |
| atlassian | 🟡 untested | — | browser OAuth on first use |
| ado | 🟡 untested | — | needs `az login` |
| figma | 🟡 untested | — | browser OAuth on first use |
| playwright | 🟡 untested | — | no creds needed |
| teams | 🟡 untested | — | package/env vars illustrative, unconfirmed (MCP spec D7) |

## Skills

None yet — reusable skills are deferred (see `README.md`). Add a table here when the first
skill ships, and add the matching check to `scripts/verify-scaffold.ps1`.
```

The seed lists the full real names (§7 enumerates them). `Last checked` is `—` until first run.

## 5. Verifier extension

Add a `# 9. Verification status registry` block to `scripts/verify-scaffold.ps1`, after the MCP
block (§8). It reuses the already-discovered `$agentNames` and `$cmdNames`, and discovers the MCP
server keys (from `.mcp.json.example`, already parsed in §8, or re-read).

Checks:

- `playbook/verification-status.md` **exists**.
- Parse the file into sections by `^## <heading>` and, within each of **Agents**, **Commands**,
  **MCP servers**, extract the table's data rows — the first column is the component name. Skip the
  header row and the `|---|` separator row. Trim whitespace; for commands strip one leading `/`.
- **Agents:** the set of names in the Agents table === the set of on-disk agent BaseNames
  (`$agentNames`). Report any **missing** (on disk, not in table) and any **unknown** (in table,
  not on disk) as FAIL.
- **Commands:** same set-equality against `$cmdNames` (after stripping leading `/`).
- **MCP servers:** same set-equality against the 6 keys in `.mcp.json.example`.
- **Status tokens:** for every data row across the three sections, the Status column contains
  exactly one of `verified` / `untested` / `broken` (case-insensitive word match; emoji ignored).
  FAIL otherwise.
- The block does **not** read the Skills section (placeholder; D6).
- Verifier still ends **`ALL CHECKS PASSED`**, exit 0.

Parsing approach (PowerShell 5.1, robust): read the file `-Raw`; for each target section, regex
`(?ms)^##\s+<Section>\s*$(.*?)(?=^##\s|\z)` to capture the block; within it match data rows with
`(?m)^\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|` and drop the header (`Agent`/`Command`/`Server`) and the
separator (`---`) rows. Match status with `\b(verified|untested|broken)\b`.

## 6. CLAUDE.md & README updates

- **CLAUDE.md** — add a one-line pointer (e.g. near the Governance/verify material): "Track which
  agents/commands/MCP servers have been functionally exercised in `playbook/verification-status.md`
  (human-maintained; the scaffold verifier keeps it in sync with what's on disk)." No table change.
- **README.md** — add a row to the "What's in here" table:
  `| `playbook/verification-status.md` | Human-maintained record of which agents/commands/MCP servers are verified working |`.

## 7. Seed contents (authoritative lists)

- **Agents (12):** product-discovery, product-backlog, scrum-planning, implementation, code-review,
  qa-test-design, test-automation, devops, security-review, documentation, support-incident,
  retrospective-insights.
- **Commands (23):** /intake, /discovery-prep, /discovery-summary, /product-goal, /access-checklist,
  /system-assessment, /stabilization-goal, /initial-backlog, /architecture, /recover-rules,
  /map-codebase, /stabilization-backlog, /refine, /sprint-plan, /execution, /daily-scrum, /pr-review,
  /qa, /sprint-review, /retro, /release-readiness, /modernize, /security-review.
- **MCP servers (6):** github, atlassian, ado, figma, playwright, teams.

Note: `security-review` exists as **both** an agent and a command; they live in separate sections,
so there is no collision.

## 8. Verification (how we test this change)

TDD on the verifier, consistent with the MCP layer's approach:

1. Add the §5 block to the verifier first; run it and confirm it **FAILS** (registry file absent)
   while §1–§8 still pass.
2. Create `playbook/verification-status.md` per §4/§7; re-run → **ALL CHECKS PASSED**.
3. Negative checks (manual, documented in the plan, then reverted): delete one command row → expect
   a "missing" FAIL; add a bogus row (`/nope`) → expect an "unknown" FAIL; set a status cell to
   `working` → expect a status-token FAIL. Restore the file → green.
4. Synergy check: this registry's command list (23) matches `$expectedCmds`; when `/automate-tests`
   later ships, the verifier will FAIL until its row is added — confirming the self-enforcing
   behavior.

Pristine-repo invariant holds; commits carry no Claude co-author.

## 9. Governance notes

- The registry records **process truth**, not a quality gate: a `verified` row is a human's
  attestation that they ran the piece. It does not replace human review of any AI output
  (guardrails 1–5 still apply).
- Never record secrets or client-specific data in Notes — keep entries generic
  (e.g. "needs a PAT", not the PAT). Upholds guardrail 6.

## 10. Assumptions & open questions

- **A1:** A single central Markdown table is the right granularity (vs. per-file frontmatter) —
  confirmed by the user.
- **A2:** PowerShell 5.1 can reliably parse the Markdown tables with the §5 regexes; matching status
  by ASCII word (D3) sidesteps emoji-encoding fragility. *Confirm during planning by running the
  verifier.*
- **A3:** The Skills section stays a no-op in the verifier until `.claude/skills/` exists (D6); the
  "how to add a skill" note reminds a future author to wire the check.
