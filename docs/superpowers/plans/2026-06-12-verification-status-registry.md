# Verification Status Registry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a human-maintained `playbook/verification-status.md` registry that records which agents, commands, and MCP servers have been functionally exercised, with the scaffold verifier enforcing the registry never drifts from what's on disk.

**Architecture:** One central Markdown file with a table per component type (Agents / Commands / MCP servers / Skills-placeholder). A new `# 9.` block in `scripts/verify-scaffold.ps1` parses those tables and set-compares the listed names against the on-disk agent BaseNames (`$agentNames`), command BaseNames (`$cmdNames`), and `.mcp.json.example` server keys — failing on any missing or unknown row, and on any status cell that isn't the word `verified`/`untested`/`broken`. The verifier guards completeness only; status truthfulness stays human-owned. Verifier-first TDD: write the check, confirm it fails with the file absent, then create the file to go green.

**Tech Stack:** Windows PowerShell 5.1 (`scripts/verify-scaffold.ps1`), Markdown. No new dependencies.

**Spec:** `docs/superpowers/specs/2026-06-12-verification-status-registry-design.md`

---

## File Structure

| File | Responsibility |
|------|----------------|
| `playbook/verification-status.md` | **New.** The registry: legend + a table per component type, seeded with all 12 agents / 23 commands / 6 MCP servers at `untested`. Human-edited going forward. |
| `scripts/verify-scaffold.ps1` | **Modify.** Add a self-contained `# 9. Verification status registry` block (two local helper functions + checks) immediately before the final result lines. Reuses existing `$root`, `$agentNames`, `$cmdNames`, `$mcpExamplePath`, `Check`. |
| `CLAUDE.md` | **Modify.** One short `## Verification status` pointer section before `## Definition of Ready / Done`. |
| `README.md` | **Modify.** One new row in the "What's in here" table. |

No new agent, template, command, or MCP server. No run-order or slash-command change.

---

## Task 1: Add the verifier block (and confirm it fails correctly)

This writes the "test" first. With `playbook/verification-status.md` not yet created, the verifier MUST fail on exactly one new check (`exists: playbook/verification-status.md`) while sections 1–8 still pass and the script has no syntax error. **Do not commit in this task** — a red verifier must not be committed; Task 2 makes it green and commits both together.

**Files:**
- Modify: `scripts/verify-scaffold.ps1` (replace the final three lines)

- [ ] **Step 1: Replace the final result lines with the §9 block + the same result lines**

Use the Edit tool. The `old_string` is the current final three lines of the file (they appear exactly once, at the end):

```powershell
Write-Host ""
if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
```

Replace with (the §9 block, then the identical three result lines):

```powershell
# 9. Verification status registry — every on-disk agent/command/MCP server must have
#    exactly one status row; status must be verified|untested|broken (word match, emoji
#    optional). Human-maintained: the verifier guards completeness, not truthfulness.
function Get-RegistryRows($text, $section) {
  $m = [regex]::Match($text, '(?ms)^##\s+' + [regex]::Escape($section) + '\s*$(.*?)(?=^##\s|\z)')
  if (-not $m.Success) { return $null }
  $rows = foreach ($line in ($m.Groups[1].Value -split '\r?\n')) {
    if ($line -notmatch '^\s*\|') { continue }
    if ($line -match '^\s*\|\s*:?-{2,}') { continue }
    $cells = @(($line -split '\|') | ForEach-Object { $_.Trim() })
    if ($cells.Count -lt 3) { continue }
    $name = $cells[1]
    if ($name -in @('Agent','Command','Server') -or [string]::IsNullOrWhiteSpace($name)) { continue }
    [pscustomobject]@{ Name = $name; Status = $cells[2] }
  }
  return $rows
}
function Check-RegistryParity($rows, $onDisk, $label, $stripSlash) {
  if ($null -eq $rows) { Check $false "registry has a $label table"; return }
  $names = @(@($rows) | ForEach-Object { if ($stripSlash) { $_.Name -replace '^/','' } else { $_.Name } })
  foreach ($d in $onDisk) { Check ($names -contains $d) "registry lists ${label}: $d" }
  foreach ($n in ($names | Where-Object { $onDisk -notcontains $_ })) { Check $false "registry has unknown $label row: $n" }
}
$vsPath = Join-Path $root 'playbook/verification-status.md'
Check (Test-Path $vsPath) "exists: playbook/verification-status.md"
if (Test-Path $vsPath) {
  $vsText    = Get-Content $vsPath -Raw
  $agentRows = Get-RegistryRows $vsText 'Agents'
  $cmdRows   = Get-RegistryRows $vsText 'Commands'
  $srvRows   = Get-RegistryRows $vsText 'MCP servers'
  Check-RegistryParity $agentRows $agentNames 'agent'   $false
  Check-RegistryParity $cmdRows   $cmdNames   'command' $true
  $srvOnDisk = @()
  if (Test-Path $mcpExamplePath) {
    try { $srvOnDisk = @(((Get-Content $mcpExamplePath -Raw) | ConvertFrom-Json).mcpServers.PSObject.Properties.Name) } catch { $srvOnDisk = @() }
  }
  Check-RegistryParity $srvRows $srvOnDisk 'MCP server' $false
  foreach ($r in (@($agentRows) + @($cmdRows) + @($srvRows) | Where-Object { $_ })) {
    Check ($r.Status -match '\b(verified|untested|broken)\b') "registry status valid for '$($r.Name)': '$($r.Status)'"
  }
}

Write-Host ""
if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
```

- [ ] **Step 2: Run the verifier and confirm it fails for the right reason**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
```

Expected:
- No PowerShell ParserError / syntax error — the script runs to completion.
- Sections 1–8 all `PASS` (no regressions).
- Exactly one new failure: `FAIL  exists: playbook/verification-status.md`.
- No parity or status-token checks run yet (they're inside the `if (Test-Path $vsPath)` block, which is skipped while the file is absent).
- Final line: `1 CHECK(S) FAILED`, exit code 1.

If sections 1–8 fail or there's a parse error, the edit is wrong — fix it before moving on. **Do not commit.**

---

## Task 2: Create the registry file (verifier goes green) and commit

**Files:**
- Create: `playbook/verification-status.md`
- Commit: `scripts/verify-scaffold.ps1` + `playbook/verification-status.md`

- [ ] **Step 1: Create `playbook/verification-status.md`**

Write this exact content:

```markdown
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
```

- [ ] **Step 2: Run the verifier and confirm it's green**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1 | Select-Object -Last 1
```

Expected: `ALL CHECKS PASSED` (exit 0). The §9 block now finds the file, all 12 agent / 23 command / 6 server rows match on-disk, and every Status contains `untested`.

If anything fails, read the FAIL line — the most likely cause is a typo in a row name or a missing row. Fix the registry (not the verifier) and re-run until green.

- [ ] **Step 3: Commit**

```powershell
git add scripts/verify-scaffold.ps1 playbook/verification-status.md
git commit -m @'
Add verification status registry + verifier parity check

playbook/verification-status.md tracks which agents/commands/MCP servers have been
functionally exercised (human-maintained, seeded at untested). verify-scaffold.ps1
section 9 enforces every on-disk agent/command/server has exactly one row and a valid
status word, so the registry can't drift.
'@
```

(Plain commit message — no Claude co-author trailer, per repo convention.)

---

## Task 3: Prove the drift guard works (negative tests, no commit)

A test that can't fail is worthless. Confirm each guard fires, then restore the file with `git checkout` (it's committed as of Task 2). **No commit in this task.**

**Files:**
- Temporarily edit then restore: `playbook/verification-status.md`

- [ ] **Step 1: Missing row → FAIL**

Edit `playbook/verification-status.md`: delete the entire `| /qa | 🟡 untested | — | — |` line. Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
```

Expected: a `FAIL  registry lists command: qa` line and exit 1.

Restore:

```powershell
git checkout -- playbook/verification-status.md
```

- [ ] **Step 2: Unknown row → FAIL**

Edit the file: add a bogus line under the Commands table, e.g. after the `/qa` row:
`| /nope | 🟡 untested | — | — |`. Run the verifier.

Expected: a `FAIL  registry has unknown command row: nope` line (the `/` is stripped before matching) and exit 1.

Restore:

```powershell
git checkout -- playbook/verification-status.md
```

- [ ] **Step 3: Bad status word → FAIL**

Edit the file: change the `github` server's Status cell from `🟡 untested` to `🟡 working`. Run the verifier.

Expected: a `FAIL  registry status valid for 'github': '🟡 working'` line (or with the emoji shown as mojibake — the point is it FAILs) and exit 1.

Restore:

```powershell
git checkout -- playbook/verification-status.md
```

- [ ] **Step 4: Confirm green again**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1 | Select-Object -Last 1
```

Expected: `ALL CHECKS PASSED`. `git status --porcelain` should show no changes to the registry (fully restored).

---

## Task 4: Cross-reference the registry in CLAUDE.md and README.md, then commit

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`
- Commit: both

- [ ] **Step 1: Add the CLAUDE.md pointer**

Use the Edit tool on `CLAUDE.md`. The heading `## Definition of Ready / Done` appears once.

`old_string`:

```
## Definition of Ready / Done
```

`new_string`:

```
## Verification status

Which agents, commands, and MCP servers have been **functionally exercised and work** is tracked in `playbook/verification-status.md` (human-maintained — flip a row to `verified` once you've actually run the piece). The scaffold verifier keeps that registry in sync with what's on disk; it does not judge whether a status is truthful.

## Definition of Ready / Done
```

- [ ] **Step 2: Add the README "What's in here" table row**

Use the Edit tool on `README.md`.

`old_string`:

```
| `scripts/verify-scaffold.ps1` | Structural self-check for the scaffold |
| `.mcp.json.example` | Six pre-wired MCP server declarations (placeholders only; real config is gitignored) |
```

`new_string`:

```
| `scripts/verify-scaffold.ps1` | Structural self-check for the scaffold |
| `playbook/verification-status.md` | Human-maintained record of which agents/commands/MCP servers are verified working |
| `.mcp.json.example` | Six pre-wired MCP server declarations (placeholders only; real config is gitignored) |
```

- [ ] **Step 3: Run the verifier (docs changes must not break it)**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1 | Select-Object -Last 1
```

Expected: `ALL CHECKS PASSED`.

- [ ] **Step 4: Commit**

```powershell
git add CLAUDE.md README.md
git commit -m @'
Reference the verification-status registry in CLAUDE.md and README

Adds a Verification status pointer to CLAUDE.md and a What's-in-here row to README so
readers can find playbook/verification-status.md.
'@
```

---

## Task 5: Final verification

**Files:** none (verification only)

- [ ] **Step 1: Full verifier run**

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1 | Select-Object -Last 1
```

Expected: `ALL CHECKS PASSED`, exit 0.

- [ ] **Step 2: Clean working tree**

```powershell
git status --porcelain
```

Expected: empty (everything committed across Tasks 2 and 4).

- [ ] **Step 3: Confirm the self-enforcing behavior is documented for the future**

Sanity-check that the registry's Commands table lists all 23 commands in `$expectedCmds`. This is the synergy guard: when `/automate-tests` (or any new command/agent/server) later ships, section 9 will FAIL until its row is added — exactly the intended drift protection. No action needed beyond confirming green.

---

## Self-Review (completed by plan author)

**Spec coverage:**
- Spec §3 deliverable `playbook/verification-status.md` → Task 2. ✓
- Spec §3 verifier block → Task 1. ✓
- Spec §3 CLAUDE.md pointer → Task 4 Step 1. ✓
- Spec §3 README row → Task 4 Step 2. ✓
- Spec §5 checks (existence, agent/command/server parity, no-unknown, status token, Skills not enforced) → all in the Task 1 block; Skills section has no check (D6). ✓
- Spec §8 verification (write-fails-first, green, three negative checks, synergy) → Tasks 1, 2, 3, 5. ✓
- Spec D3 status = word token, emoji optional → status regex `\b(verified|untested|broken)\b` matches the word regardless of emoji encoding. ✓
- Spec D7 commands shown with `/`, verifier strips it → `$stripSlash` on the command parity call. ✓

**Placeholder scan:** No TBD/TODO; all code blocks complete; registry seed is the full 12/23/6 list; every step shows exact content and commands. ✓

**Type/name consistency:** Helper names (`Get-RegistryRows`, `Check-RegistryParity`) defined once and called consistently. Reused script variables (`$root`, `$agentNames`, `$cmdNames`, `$mcpExamplePath`, `Check`) all exist in `verify-scaffold.ps1` (lines 6, 43, 86, 121, 8 respectively). Section headings in the seed (`## Agents`, `## Commands`, `## MCP servers`) exactly match the strings passed to `Get-RegistryRows`. ✓
