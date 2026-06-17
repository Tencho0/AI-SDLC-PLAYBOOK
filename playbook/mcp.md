# MCP Servers — Optional Integrations

The playbook ships a recommended set of six MCP servers, pre-wired to the agents that
fit their role. This guide explains how to enable them in a clone.

## 1. Purpose & pristine principle

`.mcp.json.example` is committed to the base repo — it contains placeholder values only
(public image/package names, `${ENV_VAR}` references, and public OAuth URLs). The real
`.mcp.json` is gitignored. A second committed template, `mcp.env.example`, lists the
per-engagement secrets (tokens / org name) with blank values; you copy it to a gitignored
`.env`, fill it in, and run `scripts/setup-mcp.ps1` to generate `.mcp.json`. No secret and
no client-specific URL is ever committed to the base — the only files you edit per clone
(`.env`, `.mcp.json`) are both gitignored.

## 2. Server reference

| Server | Tool prefix | What it gives agents | Transport | Auth |
|--------|-------------|---------------------|-----------|------|
| `github` | `mcp__github__*` | Read/write repos, issues, PRs, code search | Remote HTTP | PAT via `$GITHUB_PERSONAL_ACCESS_TOKEN` (Bearer header) |
| `atlassian` | `mcp__atlassian__*` | Jira issues, Confluence pages | Remote HTTP | Browser OAuth 2.1 (first use) |
| `ado` | `mcp__ado__*` | Azure DevOps repos, boards, pipelines, wiki | stdio (npx) | PAT via `$AZURE_DEVOPS_PAT` (no Azure CLI) |
| `figma` | `mcp__figma__*` | Figma design files (read) | Remote HTTP | Browser OAuth (first use) |
| `playwright` | `mcp__playwright__*` | Browser automation, E2E, screenshots | stdio (npx) | None |
| `teams` | `mcp__teams__*` | Read Teams messages/channels, draft posts | stdio (npx) | Azure AD app + OAuth |

**Figma opt-ins (full tool access):**
- **Local Dev Mode server:** run the Figma desktop app, enable Dev Mode, then replace the
  `figma` entry in `.mcp.json` with:
  `{"command":"npx","args":["-y","figma-developer-mcp","--stdio"]}`
- **Plugin:** install `figma@claude-plugins-official` in Claude Code for the full Figma
  plugin toolset.

## 3. Servers → agents map

| Agent | github | atlassian | ado | figma | playwright | teams |
|-------|:------:|:---------:|:---:|:-----:|:----------:|:-----:|
| product-discovery | | ✓ | ✓ | | | ✓ |
| product-backlog | ✓ | ✓ | ✓ | | | |
| scrum-planning | ✓ | ✓ | ✓ | | | ✓ |
| implementation | ✓ | | ✓ | ✓ | ✓ | |
| implementation-frontend | ✓ | | ✓ | ✓ | ✓ | |
| implementation-backend | ✓ | | ✓ | | | |
| implementation-data | ✓ | | ✓ | | | |
| implementation-mobile | ✓ | | ✓ | ✓ | ✓ | |
| code-review | ✓ | | ✓ | ✓ | | |
| qa-test-design | ✓ | ✓ | ✓ | | ✓ | |
| test-automation | ✓ | | ✓ | | ✓ | |
| devops | ✓ | | ✓ | | | |
| security-review | ✓ | | ✓ | | | |
| documentation | ✓ | ✓ | ✓ | | | |
| support-incident | ✓ | ✓ | ✓ | | | ✓ |
| retrospective-insights | ✓ | ✓ | ✓ | | | ✓ |

Each agent's `tools:` allowlist contains `mcp__<server>__*` patterns for every ✓.
Unconfigured servers are inert — an unmatched pattern is harmless (D5).

## 4. Per-clone setup

### 4.1 Quickstart (fill one file, run one script)

```powershell
Copy-Item mcp.env.example .env      # then open .env and fill in tokens / org name
powershell -File scripts/setup-mcp.ps1
```

`setup-mcp.ps1` reads `.env`, substitutes the values into the wired `.mcp.json.example`
structure, and writes `.mcp.json`. It **drops any server whose required secret is missing
from `.env`**, so unconfigured servers never half-start; servers that need no secret
(`atlassian`, `figma`, `playwright`) are always wired and authenticate via browser OAuth /
no auth on first use. The script prints which servers are active and which were skipped.

Both `.env` and `.mcp.json` are gitignored — **never commit either**. Re-run the script
whenever you change `.env`, then restart the Claude session (or reload the window) so the
new `.mcp.json` is picked up. Per-server prerequisites and where each value comes from are
in §4.2–§4.7 below (and inline in `mcp.env.example`).

> **Manual alternative:** you can instead `Copy-Item .mcp.json.example .mcp.json`, delete
> the server entries you won't use, and replace the `${VAR}` placeholders with literal
> values by hand. The script just automates this.

### 4.2 GitHub

Uses GitHub's remote hosted MCP server (`https://api.githubcopilot.com/mcp/`) — no Docker,
no local install. The PAT is sent as a Bearer `Authorization` header.

1. Create a GitHub Personal Access Token at `https://github.com/settings/tokens`.
   Minimum scopes: `repo` (read), `read:org`.
2. Add it to `.env`:
   ```
   GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
   ```
3. `setup-mcp.ps1` bakes the token into the `Authorization` header of the generated `.mcp.json`.

> **Prefer no token in config?** Use OAuth instead: drop the `headers` block from the
> `github` entry in `.mcp.json.example`, then run `/mcp` → `github` → Authenticate in the
> browser on first use (like `atlassian`/`figma`). Local-only alternatives (Docker image
> `ghcr.io/github/github-mcp-server`, or the standalone `github-mcp-server` binary) remain
> valid if a client policy requires GitHub traffic to stay off the hosted endpoint.

### 4.3 Azure DevOps

Uses a Personal Access Token (PAT) — no Azure CLI required.

1. Create a PAT at `https://dev.azure.com/<org>/_usersSettings/tokens`.
   Minimum read-only scopes: Work Items (Read), Code (Read), Project and Team (Read).
2. Add your org name and the raw PAT to `.env`:
   ```
   AZURE_DEVOPS_ORG=your-org-name
   AZURE_DEVOPS_PAT=<your-raw-pat>
   ```
   `setup-mcp.ps1` base64-encodes it into the `PERSONAL_ACCESS_TOKEN` form the server
   expects (base64 of `email:pat`); paste the raw token, not an encoded one.

> **Prefer Azure CLI auth?** Set the `ado` entry's `--authentication` back to `azcli`
> and drop its `env` block; then `az login` supplies the credential instead of a PAT.

### 4.4 Atlassian (Jira + Confluence)

No pre-configuration required. On first use the server opens a browser OAuth 2.1 flow —
approve access with your Atlassian account. The token is stored locally by the server.

### 4.5 Figma (remote, default)

No pre-configuration required. On first use the server opens a browser OAuth flow —
approve access with your Figma account.

For local Dev Mode or full plugin access see the opt-ins in §2.

### 4.6 Playwright

No configuration needed. The npx package installs on first use.

### 4.7 Teams

Prerequisites: an Azure App Registration with Microsoft Graph permissions.

1. In the Azure Portal → Azure Active Directory → App registrations → **New registration**.
2. Add **delegated** API permissions (Microsoft Graph):
   `ChannelMessage.Read.All`, `Chat.Read`, `Team.ReadBasic.All`.
3. Under "Authentication", add a mobile/desktop redirect URI: `http://localhost`.
4. Note the **Application (client) ID** and your **Directory (tenant) ID**.
5. Add to `.env`:
   ```
   MS365_MCP_CLIENT_ID=<your-app-client-id>
   MS365_MCP_TENANT_ID=<your-azure-tenant-id>
   ```
6. On first use an OAuth browser flow prompts for sign-in.

> **`--org-mode` is required for Teams.** The wired entry passes `--org-mode` (without it the
> server exposes only personal mail/calendar/OneDrive — **no** Teams/channel/chat tools) and
> `--read-only` (draft-only posture, per guardrail 5). `--org-mode` requires a work/school
> (Entra ID) account, not a personal one. To confirm the exact Graph permissions your config
> needs: `npx -y @softeria/ms-365-mcp-server --org-mode --list-permissions`.

> **Governance (guardrail 5):** Teams posting is client communication. Any messages
> composed by an agent are drafts — PM/PO must review and approve before sending.
> Default agent behaviour should be read-only.

## 5. Governance

- **Guardrail 6 (no secrets / prod data):** Use least-privilege, read-only tokens where
  possible. No secret or credential is ever committed. Store tokens in environment
  variables or shell profiles, not in files tracked by git.
- **Guardrail 5 (client communication):** Teams messages composed by agents are drafts.
  PM/PO must review and approve before sending.
- **Playwright scope:** Point the browser at test/staging environments only. Do not
  capture or log production data through the browser.
- Each server connects to the **client's own** systems via the client's credentials.
  Nothing client-specific is ever committed to the base.

## 6. Adding another server

1. Add the server entry to your local `.mcp.json`.
2. If the server is reusable (no client-specific values committed), add it to
   `.mcp.json.example` with `${ENV_VAR}` placeholders, and add any new `${ENV_VAR}`
   to `mcp.env.example` with a blank value + a short comment (so `setup-mcp.ps1`
   wires it from `.env`).
3. Add `mcp__<server>__*` to the `tools:` line of each agent that should use it
   (`.claude/agents/<agent>.md`).
4. If you updated the example: add the new key to the `$expKeys` array in
   `scripts/verify-scaffold.ps1` (the `# 8. MCP integration layer` block), and add the
   expected patterns to `$agentMcpMap` for the relevant agents.
5. Document the server in the §2 table and §4 setup section of this file.
