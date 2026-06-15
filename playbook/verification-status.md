# Verification Status

Human-maintained record of which playbook pieces have been **functionally exercised and work**.
This is separate from `scripts/verify-scaffold.ps1`, which checks structure only. Update a row
when you have actually run the piece (not just confirmed it exists).

**Status legend:** ✅ `verified` — exercised and working · 🟡 `untested` — shipped/declared but
not yet run · ❌ `broken` — known not working (explain in Notes).

The Status cell must contain one of the words `verified`, `untested`, or `broken` (the emoji is
optional decoration). `scripts/verify-scaffold.ps1` (section 9) enforces that every agent, command,
and MCP server on disk has exactly one row here, and that each Status is one of those words. It does
**not** judge whether a status is truthful — that's on you.

## Agents

| Agent | Status | Last checked | Notes |
|-------|--------|--------------|-------|
| product-discovery | 🟡 untested | — | — |
| product-backlog | 🟡 untested | — | — |
| scrum-planning | 🟡 untested | — | — |
| implementation | 🟡 untested | — | — |
| implementation-frontend | 🟡 untested | — | — |
| implementation-backend | 🟡 untested | — | — |
| implementation-data | 🟡 untested | — | — |
| code-review | 🟡 untested | — | — |
| qa-test-design | 🟡 untested | — | — |
| test-automation | 🟡 untested | — | — |
| devops | 🟡 untested | — | — |
| security-review | 🟡 untested | — | — |
| documentation | 🟡 untested | — | — |
| support-incident | 🟡 untested | — | — |
| retrospective-insights | 🟡 untested | — | — |

## Commands

| Command | Status | Last checked | Notes |
|---------|--------|--------------|-------|
| /intake | 🟡 untested | — | — |
| /discovery-prep | 🟡 untested | — | — |
| /discovery-summary | 🟡 untested | — | — |
| /product-goal | 🟡 untested | — | — |
| /access-checklist | 🟡 untested | — | — |
| /system-assessment | 🟡 untested | — | — |
| /stabilization-goal | 🟡 untested | — | — |
| /initial-backlog | 🟡 untested | — | — |
| /architecture | 🟡 untested | — | — |
| /recover-rules | 🟡 untested | — | — |
| /map-codebase | 🟡 untested | — | — |
| /stabilization-backlog | 🟡 untested | — | — |
| /refine | 🟡 untested | — | — |
| /sprint-plan | 🟡 untested | — | — |
| /execution | 🟡 untested | — | — |
| /daily-scrum | 🟡 untested | — | — |
| /pr-review | 🟡 untested | — | — |
| /qa | 🟡 untested | — | — |
| /sprint-review | 🟡 untested | — | — |
| /retro | 🟡 untested | — | — |
| /release-readiness | 🟡 untested | — | — |
| /modernize | 🟡 untested | — | — |
| /security-review | 🟡 untested | — | — |

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

None yet — reusable skills are deferred (see `README.md`). When the first skill ships, add a
`## Skills` table here (same columns) and add a parity check for `.claude/skills/` to
`scripts/verify-scaffold.ps1` (section 9).
