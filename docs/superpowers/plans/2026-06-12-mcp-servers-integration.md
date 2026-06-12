# MCP Servers Integration Layer — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a reusable, pristine MCP integration layer — `.mcp.json.example`, agent tool-allowlist wiring for all 12 agents, a setup guide, verifier checks, and doc updates — so a clone can connect agents to GitHub, Atlassian, Azure DevOps, Figma, Playwright, and Teams by copying one file and supplying credentials locally, with nothing secret committed.

**Architecture:** TDD order — extend the verifier first, then implement each deliverable to make the checks pass. All changes are edits to existing Markdown/PowerShell files or new plaintext files. No code generation beyond the PowerShell verifier block. The `.mcp.json.example` is committed (placeholders only); the real `.mcp.json` is gitignored.

**Tech Stack:** PowerShell 5.1 (verifier), JSON (MCP config example), Markdown (agents, guide, docs)

---

## File map

| File | Action | Responsibility |
|------|--------|---------------|
| `scripts/verify-scaffold.ps1` | Modify | Add §8 MCP verification block (77 new checks) |
| `.gitignore` | Modify | Add `.mcp.json` and `.env*` ignore rules |
| `.mcp.json.example` | Create | Declare 6 servers, placeholders only |
| `playbook/mcp.md` | Create | Full setup guide: server table, agents map, per-server auth, governance, extending |
| `.claude/agents/product-discovery.md` | Modify | Append `mcp__atlassian__*`, `mcp__ado__*`, `mcp__teams__*` to `tools:` |
| `.claude/agents/product-backlog.md` | Modify | Append `mcp__github__*`, `mcp__atlassian__*`, `mcp__ado__*` |
| `.claude/agents/scrum-planning.md` | Modify | Append `mcp__github__*`, `mcp__atlassian__*`, `mcp__ado__*`, `mcp__teams__*` |
| `.claude/agents/implementation.md` | Modify | Append `mcp__github__*`, `mcp__ado__*`, `mcp__figma__*`, `mcp__playwright__*` |
| `.claude/agents/code-review.md` | Modify | Append `mcp__github__*`, `mcp__ado__*`, `mcp__figma__*` |
| `.claude/agents/qa-test-design.md` | Modify | Append `mcp__github__*`, `mcp__atlassian__*`, `mcp__ado__*`, `mcp__playwright__*` |
| `.claude/agents/test-automation.md` | Modify | Append `mcp__github__*`, `mcp__ado__*`, `mcp__playwright__*` |
| `.claude/agents/devops.md` | Modify | Append `mcp__github__*`, `mcp__ado__*` |
| `.claude/agents/security-review.md` | Modify | Append `mcp__github__*`, `mcp__ado__*` |
| `.claude/agents/documentation.md` | Modify | Append `mcp__github__*`, `mcp__atlassian__*`, `mcp__ado__*` |
| `.claude/agents/support-incident.md` | Modify | Append `mcp__github__*`, `mcp__atlassian__*`, `mcp__ado__*`, `mcp__teams__*` |
| `.claude/agents/retrospective-insights.md` | Modify | Append `mcp__github__*`, `mcp__atlassian__*`, `mcp__ado__*`, `mcp__teams__*` |
| `CLAUDE.md` | Modify | Add "## MCP servers (optional integrations)" section |
| `README.md` | Modify | Add `.mcp.json.example` to "What's in here" table; add integrations note; update deferred section |

---

## Task 1: Write the tests — extend verify-scaffold.ps1 with the MCP block

**Files:**
- Modify: `scripts/verify-scaffold.ps1` (insert before the final summary block, after line ~118)

- [ ] **Step 1: Open the file and locate the insertion point**

  The final two lines of the script are:
  ```powershell
  Write-Host ""
  if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
  else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
  ```
  Insert the MCP block immediately before these lines (after the `$docx` check block).

- [ ] **Step 2: Insert the MCP verification block**

  Replace the exact final three lines:
  ```powershell
  Write-Host ""
  if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
  else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
  ```
  With:
  ```powershell
  # 8. MCP integration layer
  $mcpExamplePath = Join-Path $root '.mcp.json.example'
  Check (Test-Path $mcpExamplePath) "exists: .mcp.json.example"
  if (Test-Path $mcpExamplePath) {
    try {
      $mcpJson     = (Get-Content $mcpExamplePath -Raw) | ConvertFrom-Json
      $expKeys     = @('github','atlassian','ado','figma','playwright','teams')
      $actKeys     = @($mcpJson.mcpServers.PSObject.Properties.Name)
      $missing     = @($expKeys | Where-Object { $actKeys -notcontains $_ })
      $extra       = @($actKeys | Where-Object { $expKeys -notcontains $_ })
      Check ($missing.Count -eq 0 -and $extra.Count -eq 0) ".mcp.json.example mcpServers has exactly 6 keys (github,atlassian,ado,figma,playwright,teams)"
    } catch {
      Check $false ".mcp.json.example parses as valid JSON"
    }
  }
  Check ($gi -match '(?m)^\s*\.mcp\.json\s*$') ".gitignore ignores .mcp.json"
  $tracked = & git -C $root ls-files '.mcp.json' 2>$null
  Check ([string]::IsNullOrEmpty($tracked)) ".mcp.json is not git-tracked"
  Check (Test-Path (Join-Path $root 'playbook/mcp.md')) "exists: playbook/mcp.md"
  $agentMcpMap = [ordered]@{
    'product-discovery'      = @('mcp__atlassian__*','mcp__ado__*','mcp__teams__*')
    'product-backlog'        = @('mcp__github__*','mcp__atlassian__*','mcp__ado__*')
    'scrum-planning'         = @('mcp__github__*','mcp__atlassian__*','mcp__ado__*','mcp__teams__*')
    'implementation'         = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
    'code-review'            = @('mcp__github__*','mcp__ado__*','mcp__figma__*')
    'qa-test-design'         = @('mcp__github__*','mcp__atlassian__*','mcp__ado__*','mcp__playwright__*')
    'test-automation'        = @('mcp__github__*','mcp__ado__*','mcp__playwright__*')
    'devops'                 = @('mcp__github__*','mcp__ado__*')
    'security-review'        = @('mcp__github__*','mcp__ado__*')
    'documentation'          = @('mcp__github__*','mcp__atlassian__*','mcp__ado__*')
    'support-incident'       = @('mcp__github__*','mcp__atlassian__*','mcp__ado__*','mcp__teams__*')
    'retrospective-insights' = @('mcp__github__*','mcp__atlassian__*','mcp__ado__*','mcp__teams__*')
  }
  $allMcpServers = @('github','atlassian','ado','figma','playwright','teams')
  foreach ($agentName in $agentMcpMap.Keys) {
    $af = Join-Path $root ".claude/agents/$agentName.md"
    if (-not (Test-Path $af)) { Check $false "agent present for MCP wiring: $agentName"; continue }
    $fm = Get-Frontmatter $af
    if (-not $fm) { Check $false "agent frontmatter readable: $agentName"; continue }
    $toolsLine = Get-FmValue $fm 'tools'
    $expected  = $agentMcpMap[$agentName]
    foreach ($srv in $allMcpServers) {
      $pat        = "mcp__${srv}__*"
      $shouldHave = $expected -contains $pat
      $has        = $toolsLine -match [regex]::Escape($pat)
      Check ($shouldHave -eq $has) "agent $agentName tools: $pat $(if ($shouldHave) { 'present' } else { 'absent' })"
    }
  }

  Write-Host ""
  if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
  else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
  ```

---

## Task 2: Confirm the new tests fail

**Files:** none

- [ ] **Step 1: Run the verifier**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected: all pre-existing checks PASS; new MCP checks fail. The output should include lines like:
  ```
  FAIL  exists: .mcp.json.example
  FAIL  .gitignore ignores .mcp.json
  FAIL  exists: playbook/mcp.md
  FAIL  agent product-discovery tools: mcp__atlassian__* present
  FAIL  agent product-discovery tools: mcp__ado__* present
  FAIL  agent product-discovery tools: mcp__teams__* present
  ...
  ```
  (72 agent-pattern FAILs + 3 structural FAILs = ~75 failures total)

  If any pre-existing check FAILs, stop — something in the environment is already broken; fix it before proceeding.

---

## Task 3: Update .gitignore

**Files:**
- Modify: `.gitignore`

- [ ] **Step 1: Append the MCP ignore rules**

  Current `.gitignore` content:
  ```
  # Keep the playbook pristine — no project-specific data is ever committed.
  src/*
  !src/README.md

  # OS / editor noise
  .DS_Store
  Thumbs.db
  ```

  Replace with:
  ```
  # Keep the playbook pristine — no project-specific data is ever committed.
  src/*
  !src/README.md

  # Local MCP config may carry client org/URLs — keep the base pristine.
  .mcp.json
  # Local env files hold MCP tokens — never commit secrets.
  .env
  .env.*

  # OS / editor noise
  .DS_Store
  Thumbs.db
  ```

- [ ] **Step 2: Run the verifier**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected: `.gitignore ignores .mcp.json` — **PASS**. `.mcp.json is not git-tracked` — **PASS** (file doesn't exist yet, `git ls-files` returns empty). Everything else still fails.

---

## Task 4: Create .mcp.json.example

**Files:**
- Create: `.mcp.json.example`

- [ ] **Step 1: Create the file**

  ```json
  {
    "mcpServers": {
      "github": {
        "command": "docker",
        "args": ["run", "-i", "--rm", "-e", "GITHUB_PERSONAL_ACCESS_TOKEN", "ghcr.io/github/github-mcp-server"],
        "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_PERSONAL_ACCESS_TOKEN}" }
      },
      "atlassian": {
        "type": "http",
        "url": "https://mcp.atlassian.com/v1/mcp"
      },
      "ado": {
        "command": "npx",
        "args": ["-y", "@azure-devops/mcp", "${AZURE_DEVOPS_ORG}", "--authentication", "azcli"]
      },
      "figma": {
        "type": "http",
        "url": "https://mcp.figma.com/mcp"
      },
      "playwright": {
        "command": "npx",
        "args": ["-y", "@playwright/mcp@latest"]
      },
      "teams": {
        "command": "npx",
        "args": ["-y", "@softeria/ms-365-mcp-server"],
        "env": {
          "MS365_MCP_CLIENT_ID": "${MS365_MCP_CLIENT_ID}",
          "MS365_MCP_TENANT_ID": "${MS365_MCP_TENANT_ID}"
        }
      }
    }
  }
  ```

- [ ] **Step 2: Run the verifier**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected: `exists: .mcp.json.example` — **PASS**; `.mcp.json.example mcpServers has exactly 6 keys` — **PASS**. Agent-pattern FAILs remain.

---

## Task 5: Create playbook/mcp.md

**Files:**
- Create: `playbook/mcp.md`

- [ ] **Step 1: Create the file**

  ```markdown
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
  ```

- [ ] **Step 2: Run the verifier**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected: `exists: playbook/mcp.md` — **PASS**. Agent-pattern FAILs remain.

---

## Task 6: Wire all 12 agents — append MCP patterns to tools: lines

**Files:**
- Modify: all 12 files under `.claude/agents/`

Apply one Edit per agent. The pattern is always: append `, mcp__<x>__*, ...` to the end of the existing `tools:` line.

- [ ] **Step 1: product-discovery**

  Find:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch, mcp__atlassian__*, mcp__ado__*, mcp__teams__*
  ```

- [ ] **Step 2: product-backlog**

  Find:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch, mcp__github__*, mcp__atlassian__*, mcp__ado__*
  ```

  > Note: product-discovery and product-backlog have the same current `tools:` line. Be sure to edit the correct file for each.

- [ ] **Step 3: scrum-planning**

  Find:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch, mcp__github__*, mcp__atlassian__*, mcp__ado__*, mcp__teams__*
  ```

- [ ] **Step 4: implementation**

  Find:
  ```
  tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*, mcp__figma__*, mcp__playwright__*
  ```

- [ ] **Step 5: code-review**

  Find:
  ```
  tools: Read, Grep, Glob, Write, Bash
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, Bash, mcp__github__*, mcp__ado__*, mcp__figma__*
  ```

- [ ] **Step 6: qa-test-design**

  Find:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch, mcp__github__*, mcp__atlassian__*, mcp__ado__*, mcp__playwright__*
  ```

- [ ] **Step 7: test-automation**

  Find:
  ```
  tools: Read, Grep, Glob, Write, Edit, Bash
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, Edit, Bash, mcp__github__*, mcp__ado__*, mcp__playwright__*
  ```

- [ ] **Step 8: devops**

  Find:
  ```
  tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*
  ```

- [ ] **Step 9: security-review**

  Find:
  ```
  tools: Read, Grep, Glob, Write, Bash, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, Bash, WebSearch, WebFetch, mcp__github__*, mcp__ado__*
  ```

- [ ] **Step 10: documentation**

  Find:
  ```
  tools: Read, Grep, Glob, Write, Edit, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, Edit, WebSearch, WebFetch, mcp__github__*, mcp__atlassian__*, mcp__ado__*
  ```

- [ ] **Step 11: support-incident**

  Find:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch, mcp__github__*, mcp__atlassian__*, mcp__ado__*, mcp__teams__*
  ```

- [ ] **Step 12: retrospective-insights**

  Find:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch
  ```
  Replace with:
  ```
  tools: Read, Grep, Glob, Write, WebSearch, WebFetch, mcp__github__*, mcp__atlassian__*, mcp__ado__*, mcp__teams__*
  ```

  > Note: product-discovery, scrum-planning, support-incident, and retrospective-insights all gain `mcp__atlassian__*, mcp__ado__*, mcp__teams__*` but product-discovery lacks github while the others do not. Apply edits to the correct file paths.

- [ ] **Step 13: Run the verifier**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected: all 72 agent-pattern checks now **PASS**. All structural MCP checks **PASS**. Output ends:
  ```
  ALL CHECKS PASSED
  ```

  If any check still fails, diff the failing agent's `tools:` line against the matrix in §6 of the spec and correct it.

---

## Task 7: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Insert the MCP section**

  Find the line:
  ```
  Full rules: `playbook/governance.md`.
  ```

  Replace with:
  ```
  Full rules: `playbook/governance.md`.

  ## MCP servers (optional integrations)

  The playbook ships `.mcp.json.example` declaring six pre-wired servers: **GitHub**,
  **Atlassian** (Jira + Confluence), **Azure DevOps**, **Figma**, **Playwright**, and
  **Microsoft Teams**. Each agent's `tools:` allowlist already includes the
  `mcp__<server>__*` patterns for the servers that fit its role.

  To enable integrations in a clone:

  1. `Copy-Item .mcp.json.example .mcp.json` — the real `.mcp.json` is gitignored; never commit it.
  2. Delete unused server entries from `.mcp.json`.
  3. Supply credentials locally (env vars / `az login` / browser OAuth on first use).
  4. Full setup instructions: `playbook/mcp.md`.

  **Servers are optional and inert when unconfigured** — an unmatched `mcp__*` pattern is
  harmless. Never commit secrets or client-specific data (guardrail 6). Teams posting is
  client communication — draft only, PM/PO review required (guardrail 5).
  ```

- [ ] **Step 2: Verify no verifier regression**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected: **ALL CHECKS PASSED** (CLAUDE.md is not checked structurally beyond existence).

---

## Task 8: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add .mcp.json.example to the "What's in here" table**

  Find:
  ```
  | `scripts/verify-scaffold.ps1` | Structural self-check for the scaffold |
  | `docs/superpowers/` | The design spec and this implementation plan |
  ```

  Replace with:
  ```
  | `scripts/verify-scaffold.ps1` | Structural self-check for the scaffold |
  | `.mcp.json.example` | Six pre-wired MCP server declarations (placeholders only; real config is gitignored) |
  | `docs/superpowers/` | The design spec and this implementation plan |
  ```

- [ ] **Step 2: Add an "Integrations (optional)" section after "## Verify the scaffold"**

  Find:
  ```
  ## Deferred (future passes)
  ```

  Replace with:
  ```
  ## Integrations (optional)

  Copy `.mcp.json.example` → `.mcp.json`, trim to the servers you need, supply credentials locally,
  and the right agents can call those servers' tools. Full instructions: `playbook/mcp.md`.

  ## Deferred (future passes)
  ```

- [ ] **Step 3: Update the deferred section to note MCP ships**

  Find:
  ```
  Still optional / deferred: an `/automate-tests` command, reusable skills (e.g. a `/status`–`/next` navigator), and plugin packaging — see `docs/superpowers/specs/`.
  ```

  Replace with:
  ```
  Still optional / deferred: an `/automate-tests` command, reusable skills (e.g. a `/status`–`/next` navigator), and plugin packaging. MCP server integration now ships — see `playbook/mcp.md`.
  ```

---

## Task 9: Final verifier run + smoke test

**Files:** none (read-only verification)

- [ ] **Step 1: Run the verifier — confirm ALL CHECKS PASSED**

  ```powershell
  powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
  ```

  Expected output ends with:
  ```
  ALL CHECKS PASSED
  ```

  If anything fails, fix the specific failing check before proceeding.

- [ ] **Step 2: Smoke test — copy the example and confirm git status is clean**

  ```powershell
  Copy-Item .mcp.json.example .mcp.json
  git status
  ```

  Expected: `git status` shows nothing to commit (the copy is gitignored). The `.mcp.json` file does not appear in staged or unstaged changes.

- [ ] **Step 3: Confirm the copy parses as valid JSON**

  ```powershell
  Get-Content .mcp.json -Raw | ConvertFrom-Json | Select-Object -ExpandProperty mcpServers
  ```

  Expected: output lists six properties: `github`, `atlassian`, `ado`, `figma`, `playwright`, `teams`. No parse error.

- [ ] **Step 4: Delete the test copy**

  ```powershell
  Remove-Item .mcp.json
  ```

  The repo is now pristine — no local `.mcp.json` remains.

---

## Task 10: Commit

- [ ] **Step 1: Stage all changes**

  ```powershell
  git add .mcp.json.example .gitignore playbook/mcp.md CLAUDE.md README.md scripts/verify-scaffold.ps1 .claude/agents/product-discovery.md .claude/agents/product-backlog.md .claude/agents/scrum-planning.md .claude/agents/implementation.md .claude/agents/code-review.md .claude/agents/qa-test-design.md .claude/agents/test-automation.md .claude/agents/devops.md .claude/agents/security-review.md .claude/agents/documentation.md .claude/agents/support-incident.md .claude/agents/retrospective-insights.md docs/superpowers/plans/2026-06-12-mcp-servers-integration.md
  ```

- [ ] **Step 2: Commit**

  ```powershell
  git commit -m "Add MCP servers integration layer (GitHub, Atlassian, ADO, Figma, Playwright, Teams)"
  ```

  Plain message — no co-author trailer.

- [ ] **Step 3: Verify clean state**

  ```powershell
  git status
  ```

  Expected: `nothing to commit, working tree clean`.

---

## Self-review

### Spec coverage

| Spec section | Tasks covering it |
|---|---|
| §3 `.mcp.json.example` | Task 4 |
| §3 `.gitignore` | Task 3 |
| §3 `playbook/mcp.md` | Task 5 |
| §3 agent `tools:` wiring (all 12) | Task 6 |
| §3 `CLAUDE.md` update | Task 7 |
| §3 `README.md` update | Task 8 |
| §3 `scripts/verify-scaffold.ps1` | Task 1 |
| §4 six-server JSON | Task 4 |
| §5 `.gitignore` rules | Task 3 |
| §6 agent→server matrix (all ✓) | Task 6 |
| §7 `playbook/mcp.md` sections 1–6 | Task 5 |
| §8 CLAUDE.md section text | Task 7 |
| §8 README table + integrations note + deferred | Task 8 |
| §9 verifier checks (7 structural + 72 pattern) | Tasks 1, 2, 9 |
| §10 governance in `playbook/mcp.md` | Task 5 §5 |
| D3 pristine — example committed, real gitignored | Tasks 3, 4, 9 |
| D4 no secret committed | Task 4 (env placeholders only) |
| D5 inert patterns | covered by agent wiring note |
| D6 Figma remote default + opt-ins documented | Task 5 §2, §4.5 |
| D7 Teams `@softeria/ms-365-mcp-server` | Task 4 + Task 5 §4.7 |

All spec requirements covered. No gaps found.

### Placeholder scan

No TBD, TODO, "implement later", "add appropriate …", or "similar to Task N" language present.

### Type/naming consistency

All agent names match the filenames exactly. All server keys (`github`, `atlassian`, `ado`, `figma`, `playwright`, `teams`) are consistent across the example JSON, the verifier `$expKeys`, the `$agentMcpMap`, and `playbook/mcp.md`. Tool pattern format `mcp__<server>__*` is identical in every agent step and in the verifier map.
