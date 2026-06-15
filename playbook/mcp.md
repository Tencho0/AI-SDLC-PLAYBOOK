# MCP Servers — Optional Integrations

The playbook ships a recommended set of six MCP servers, pre-wired to the agents that
fit their role. This guide explains how to enable them in a clone.

## 1. Purpose & pristine principle

`.mcp.json.example` is committed to the base repo — it contains placeholder values only
(public image/package names, `${ENV_VAR}` references, and public OAuth URLs). The real
`.mcp.json` is gitignored. Per-clone setup: copy the example to `.mcp.json`, delete the
servers you don't need, and supply credentials locally. No secret and no client-specific
URL is ever committed to the base.

## 2. Server reference

| Server | Tool prefix | What it gives agents | Transport | Auth |
|--------|-------------|---------------------|-----------|------|
| `github` | `mcp__github__*` | Read/write repos, issues, PRs, code search | stdio (Docker) | PAT via `$GITHUB_PERSONAL_ACCESS_TOKEN` |
| `atlassian` | `mcp__atlassian__*` | Jira issues, Confluence pages | Remote HTTP | Browser OAuth 2.1 (first use) |
| `ado` | `mcp__ado__*` | Azure DevOps repos, boards, pipelines, wiki | stdio (npx) | `az login` (`azcli` auth) |
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

### 4.1 Copy and trim

```powershell
Copy-Item .mcp.json.example .mcp.json
```

Open `.mcp.json` and delete the `mcpServers` entries for servers you won't use.
The file is gitignored — **never commit it**.

### 4.2 GitHub

Prerequisites: Docker Desktop running.

1. Create a GitHub Personal Access Token at `https://github.com/settings/tokens`.
   Minimum scopes: `repo` (read), `read:org`.
2. Set the environment variable (add to your shell profile or a local `.env`):
   ```
   GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
   ```
3. The Docker image (`ghcr.io/github/github-mcp-server`) pulls automatically on first use.

### 4.3 Azure DevOps

Prerequisites: Azure CLI installed.
- Windows: `winget install Microsoft.AzureCLI`
- macOS: `brew install azure-cli`

1. Log in: `az login`
2. Set your organisation name (just the name, not the full URL):
   ```
   AZURE_DEVOPS_ORG=your-org-name
   ```

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
5. Set environment variables:
   ```
   MS365_MCP_CLIENT_ID=<your-app-client-id>
   MS365_MCP_TENANT_ID=<your-azure-tenant-id>
   ```
6. On first use an OAuth browser flow prompts for sign-in.

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
   `.mcp.json.example` with `${ENV_VAR}` placeholders.
3. Add `mcp__<server>__*` to the `tools:` line of each agent that should use it
   (`.claude/agents/<agent>.md`).
4. If you updated the example: add the new key to the `$expKeys` array in
   `scripts/verify-scaffold.ps1` (the `# 8. MCP integration layer` block), and add the
   expected patterns to `$agentMcpMap` for the relevant agents.
5. Document the server in the §2 table and §4 setup section of this file.
