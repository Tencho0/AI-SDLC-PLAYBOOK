# 🚀 Getting Started

**Audience:** 🛠️ Delivery team

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

## 📚 Read more
- Operating manual: [CLAUDE.md](../../CLAUDE.md)
- Full model: [playbook/PLAYBOOK.md](../../playbook/PLAYBOOK.md)
- Integrations: [playbook/mcp.md](../../playbook/mcp.md)
