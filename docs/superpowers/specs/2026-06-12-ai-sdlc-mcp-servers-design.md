# AI-SDLC MCP Servers Integration Layer — Design Spec

- **Date:** 2026-06-12
- **Author:** Tencho Bostandzhiev (with Claude)
- **Status:** Approved for implementation planning
- **Builds on:** the completed command/agent build (Passes 1–6). This is a new, optional
  cross-cutting layer — it adds no run-order step and no slash command.

---

## 1. Goal & Context

The playbook ships 12 agents and 23 commands but **no MCP configuration** — there is no
`.mcp.json`, no `.claude/settings.json`, and no mention of MCP anywhere. Agents therefore can
only use their built-in tools (`Read`, `Grep`, `Glob`, `Write`, `Edit`, `Bash`, `WebSearch`,
`WebFetch`). Connecting them to the systems a delivery team actually uses — source host, issue
tracker, design tool, browser, comms — requires an MCP layer.

This spec adds a **reusable, pristine MCP integration layer**: the playbook *declares* a
recommended set of six servers and *pre-wires* each agent to the servers that fit its role, so a
configured server "just works" for the right agents and an unconfigured one stays inert. It
follows the repo's iron rule — **the base stays pristine; no secrets or client-specific data are
ever committed** — by shipping a placeholder-only `.mcp.json.example` and gitignoring the real
`.mcp.json`.

**Recommended servers (selected by the user):** GitHub, Atlassian (Jira + Confluence), Azure
DevOps, Figma, Playwright, Microsoft Teams.

**Success criterion:** a clone can copy `.mcp.json.example` → `.mcp.json`, trim to the servers it
uses, supply credentials locally (env / `az login` / OAuth), and the right agents can call those
servers' tools — with **nothing secret or client-specific committed** and the verifier green.

**Out of scope (YAGNI):** an `/mcp-setup` command; per-engagement MCP config under `src/<eng>/`;
Sentry/Linear servers; auto-installing Docker/Node/`az`; plugin packaging (still deferred,
Pass 7).

## 2. Decisions (locked)

| # | Decision | Rationale |
|---|----------|-----------|
| D1 | **Convention + agent wiring.** Ship the server declarations *and* add `mcp__<server>__*` patterns to the relevant agents' `tools:` allowlists, so configured servers are usable by the right agents automatically. | Agents carry a restrictive `tools:` allowlist; without the `mcp__*` patterns they cannot call MCP tools, so declarations alone would be half a feature. |
| D2 | **Six recommended servers:** `github`, `atlassian`, `ado`, `figma`, `playwright`, `teams`. | The user's selection; covers source host, issue tracker + docs, design, browser/E2E, and comms. |
| D3 | **`.mcp.json.example` committed (placeholders only); real `.mcp.json` gitignored.** Per clone: copy → trim → set credentials. | Most pristine — the live config (which may carry a client org/URL) and all secrets stay local; no failed-connection noise from servers an engagement doesn't use; matches the `src/*` gitignore philosophy. |
| D4 | **No secret is ever written into committed files.** GitHub/Teams read tokens from `${ENV}` placeholders; Atlassian/Figma use browser OAuth (URL only); ADO uses `az login` (`azcli`); Playwright needs nothing. | The committed example contains only placeholders, public URLs, and public image/package names — safe by construction. Upholds governance guardrail 6. |
| D5 | **Agent `tools:` patterns are committed regardless of which servers a clone enables; unmatched patterns are inert.** | A permission pattern for an unconfigured server is harmless — no tool exists to match it, so it does nothing. This keeps the wiring uniform and reusable. |
| D6 | **Figma defaults to the remote server** (`https://mcp.figma.com/mcp`) in the example; the local Dev Mode server and the `figma@claude-plugins-official` plugin are documented as opt-ins for full tool access. | Remote needs no secret and no running desktop app — the safest committable default. (Resolves Q2.) |
| D7 | **Teams uses a Microsoft Graph–based npx server** (`@softeria/ms-365-mcp-server`) needing an Azure App Registration + OAuth; flagged as the most setup-heavy and governance-sensitive server. | The official Microsoft path (Agent Connectors / Work IQ / M365 Agents Toolkit) is enterprise/Copilot-Studio-oriented, not a simple `mcp add`. The Graph server is the realistic Claude Code path. Posting to Teams is client communication → guardrail 5. (Resolves Q1, subject to confirmation in planning.) |

## 3. Deliverables

| File | Change |
|------|--------|
| `.mcp.json.example` | **New** — declares all 6 servers, placeholders only (§4) |
| `.gitignore` | Add `.mcp.json` and `.env*` (§5) |
| `playbook/mcp.md` | **New** — servers→agents map, per-server setup/auth, governance, "add another server" (§7) |
| `.claude/agents/*.md` | Append `mcp__<server>__*` patterns to `tools:` per the §6 matrix (all 12 agents — every agent gets at least the git-host server) |
| `CLAUDE.md` | New short "MCP servers (optional integrations)" section + pointer (§8) |
| `README.md` | Add `.mcp.json.example` to the "What's in here" table; one-line integrations note (§8) |
| `scripts/verify-scaffold.ps1` | New MCP checks (§9) |

No new agent, template, or command. No run-order or slash-command table change.

## 4. `.mcp.json.example` (committed — placeholders only)

```jsonc
{
  "mcpServers": {
    "github": {
      "command": "docker",
      "args": ["run","-i","--rm","-e","GITHUB_PERSONAL_ACCESS_TOKEN","ghcr.io/github/github-mcp-server"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}" }
    },
    "atlassian": { "type": "http", "url": "https://mcp.atlassian.com/v1/mcp" },
    "ado": {
      "command": "npx",
      "args": ["-y","@azure-devops/mcp","${AZURE_DEVOPS_ORG}","--authentication","azcli"]
    },
    "figma": { "type": "http", "url": "https://mcp.figma.com/mcp" },
    "playwright": { "command": "npx", "args": ["-y","@playwright/mcp@latest"] },
    "teams": {
      "command": "npx",
      "args": ["-y","@softeria/ms-365-mcp-server"],
      "env": { "MS365_MCP_CLIENT_ID": "${MS365_MCP_CLIENT_ID}", "MS365_MCP_TENANT_ID": "${MS365_MCP_TENANT_ID}" }
    }
  }
}
```

**Auth model per server (no secret in the file):**

| Server | Transport | Auth | Committed config |
|--------|-----------|------|------------------|
| `github` | stdio (Docker) | PAT via `${GITHUB_PERSONAL_ACCESS_TOKEN}` | image + env placeholder |
| `atlassian` | remote http | browser OAuth 2.1 | URL only |
| `ado` | stdio (npx) | `az login` (`--authentication azcli`) | package + `${AZURE_DEVOPS_ORG}` arg |
| `figma` | remote http | browser OAuth | URL only |
| `playwright` | stdio (npx) | none | package only |
| `teams` | stdio (npx) | Azure-AD app + OAuth | package + `${MS365_MCP_*}` placeholders |

The Teams package and env-var names are **illustrative** and confirmed during planning (D7).
The example uses real published image/package names for the other five.

## 5. `.gitignore`

```
# Local MCP config may carry client org/URLs — keep the base pristine.
.mcp.json
# Local env files hold MCP tokens — never commit secrets.
.env
.env.*
```

`.mcp.json.example` remains tracked; the real `.mcp.json` is ignored. The existing `src/*`
rules are untouched.

## 6. Agent → server wiring matrix

Each ✓ = append `mcp__<server>__*` to that agent's `tools:` frontmatter line. Patterns are inert
when the server isn't configured (D5).

| Agent | github | atlassian | ado | figma | playwright | teams |
|-------|:--:|:--:|:--:|:--:|:--:|:--:|
| product-discovery | | ✓ | ✓ | | | ✓ |
| product-backlog | ✓ | ✓ | ✓ | | | |
| scrum-planning | ✓ | ✓ | ✓ | | | ✓ |
| implementation | ✓ | | ✓ | ✓ | ✓ | |
| code-review | ✓ | | ✓ | ✓ | | |
| qa-test-design | ✓ | ✓ | ✓ | | ✓ | |
| test-automation | ✓ | | ✓ | | ✓ | |
| devops | ✓ | | ✓ | | | |
| security-review | ✓ | | ✓ | | | |
| documentation | ✓ | ✓ | ✓ | | | |
| support-incident | ✓ | ✓ | ✓ | | | ✓ |
| retrospective-insights | ✓ | ✓ | ✓ | | | ✓ |

**Rationale:** git-host servers (github/ado) go to every build/review/ops agent; issue-tracker +
Confluence (atlassian) and ADO boards/wiki to backlog/planning/discovery/docs/retro/support;
**figma** to the agents that build/verify UI (implementation, code-review); **playwright** to the
agents that exercise a running app (qa-test-design, test-automation, implementation); **teams** to
the comms-facing agents (discovery, planning, support, retro). This is the default mapping —
adjustable by editing a `tools:` line (and the verifier's expected map, §9).

## 7. `playbook/mcp.md` (new guide)

Sections:

1. **Purpose & pristine principle** — example committed; real `.mcp.json` + all secrets local-only.
2. **Server table** — server · what it gives · transport · auth · tool prefix (the §4 table, expanded).
3. **Servers → agents map** — the §6 matrix.
4. **Per-clone setup** — `copy .mcp.json.example .mcp.json`; delete unused servers; then per server:
   GitHub (create a read-scoped PAT, set `GITHUB_PERSONAL_ACCESS_TOKEN`, Docker running);
   ADO (`az login`, set `AZURE_DEVOPS_ORG`); Atlassian & Figma (OAuth on first use);
   Playwright (none); Teams (Azure App Registration → Graph perms → set `MS365_MCP_*`, OAuth).
   Note the Figma local-desktop and `figma@claude-plugins-official` opt-ins (D6).
5. **Governance notes** — §10.
6. **How to add another server** — edit `.mcp.json` + add `mcp__<server>__*` to the relevant
   agent's `tools:` + add the expected pattern to `verify-scaffold.ps1` + document it here.

## 8. CLAUDE.md & README updates

- **CLAUDE.md** — add a short "## MCP servers (optional integrations)" section: the playbook ships
  `.mcp.json.example` declaring GitHub / Atlassian / Azure DevOps / Figma / Playwright / Teams;
  copy it to the gitignored `.mcp.json` and configure per `playbook/mcp.md`; agents are pre-wired
  to use the servers that fit their role; servers are **optional and inert when unconfigured**;
  never commit secrets or client data (guardrail 6); Teams posting is client comms (guardrail 5).
  No run-order/slash-command table change (MCP is cross-cutting, not a step).
- **README.md** — add `.mcp.json.example` to the "What's in here" table; add one line under an
  "Integrations (optional)" note pointing to `playbook/mcp.md`. The "Deferred" list is unchanged
  apart from noting MCP integration now ships (plugin packaging remains the deferred item).

## 9. Verification

Extend `scripts/verify-scaffold.ps1` with an MCP block:

- `.mcp.json.example` **exists**, **parses as JSON**, and its `mcpServers` has exactly the 6
  expected keys: `github`, `atlassian`, `ado`, `figma`, `playwright`, `teams`.
- `.gitignore` **ignores `.mcp.json`** (line present).
- `.mcp.json` is **not git-tracked** (guards against an accidental `git add`).
- `playbook/mcp.md` **exists**.
- **Agent allowlist map:** for each agent in the §6 matrix, its `tools:` line contains exactly the
  `mcp__<server>__*` patterns the matrix assigns it — no missing, no extra. (Catches drift in
  either direction.)
- Verifier must end **`ALL CHECKS PASSED`**, exit 0.

**Manual smoke test** (documented in the plan): `copy .mcp.json.example .mcp.json`; confirm
`git status` shows nothing to commit (the copy is ignored); confirm the file parses; optionally
`claude mcp list` shows the six servers (connection state depends on local creds). Delete the
local copy. Pristine-repo invariant holds; commits carry no Claude co-author.

## 10. Governance notes (carried into `playbook/mcp.md` and agent caveats)

- **Guardrail 6 (no secrets / prod data):** use least-privilege, read-only tokens where possible;
  point Playwright at test/staging, never production data; no secret is ever committed (D4).
- **Guardrail 5 (client communication):** Teams posting is client communication → draft-only,
  PM/PO review before sending; default to read.
- Each server connects to the **client's own** systems via the client's auth; nothing
  client-specific is committed to the base.

## 11. Assumptions & open questions

- **A1:** Adding `mcp__<server>__*` patterns to a subagent's `tools:` allowlist is the correct
  mechanism for granting that subagent MCP access in Claude Code, and unmatched patterns are inert
  (no error) when the server isn't configured. *Confirm during planning.*
- **A2:** Remote OAuth servers (Atlassian, Figma) need no committed config beyond the URL; OAuth
  happens in-session on first use.
- **A3:** Claude Code `.mcp.json` supports `${VAR}` expansion and `"type": "http"` remote servers
  (verified against current docs).
- **Q1 (resolved, confirm in planning):** Teams server = `@softeria/ms-365-mcp-server` (Graph-based,
  Azure-AD app + OAuth). Swap only if a better-maintained package is found during planning (D7).
- **Q2 (resolved):** Figma defaults to the **remote** server; local-desktop + plugin documented as
  opt-ins (D6).
