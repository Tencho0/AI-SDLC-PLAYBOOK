#requires -Version 5.1
# Structural verification for the AI-SDLC Playbook scaffold.
# Discovers files on disk (rather than trusting a frozen name list), validates
# frontmatter with line-anchored regexes, and checks that every template/agent a
# command or agent references actually resolves.
$root = Split-Path -Parent $PSScriptRoot
$script:fail = 0
function Check($cond, $msg) {
  if ($cond) { Write-Host "PASS  $msg" -ForegroundColor Green }
  else { Write-Host "FAIL  $msg" -ForegroundColor Red; $script:fail++ }
}
function Warn($msg) { Write-Host "WARN  $msg" -ForegroundColor Yellow }

# Extract the YAML frontmatter block (between the first pair of --- fences at the
# very start of the file). Returns $null when there is no real frontmatter — a
# stray markdown '---' rule mid-body does NOT count, because of the \A anchor.
function Get-Frontmatter($path) {
  $txt = Get-Content $path -Raw
  $m = [regex]::Match($txt, '(?s)\A---\s*\r?\n(.*?)\r?\n---')
  if ($m.Success) { return $m.Groups[1].Value } else { return $null }
}
# Read a scalar key from a frontmatter block (line-anchored), stripping surrounding quotes.
function Get-FmValue($fm, $key) {
  $m = [regex]::Match($fm, "(?m)^$key" + ':\s*(.+?)\s*$')
  if (-not $m.Success) { return $null }
  return $m.Groups[1].Value.Trim().Trim('"').Trim("'")
}

# 1. Required reference files
$refFiles = @(
  'CLAUDE.md','README.md','.gitignore',
  'playbook/PLAYBOOK.md','playbook/governance.md',
  'playbook/definition-of-ready.md','playbook/definition-of-done.md',
  'playbook/greenfield-vs-inherited.md','src/README.md'
)
foreach ($f in $refFiles) { Check (Test-Path (Join-Path $root $f)) "exists: $f" }

# 2. Agents — required set present; every DISCOVERED agent has valid frontmatter (name == filename)
$expectedAgents = 'product-discovery','product-backlog','scrum-planning','implementation',
                  'implementation-frontend','implementation-backend','implementation-data','implementation-mobile',
                  'code-review','qa-test-design','test-automation','devops',
                  'security-review','documentation','support-incident','retrospective-insights'
$agentFiles = @(Get-ChildItem (Join-Path $root '.claude/agents') -Filter *.md -ErrorAction SilentlyContinue)
$agentNames = @($agentFiles | ForEach-Object { $_.BaseName })
foreach ($a in $expectedAgents) { Check ($agentNames -contains $a) "agent present: $a" }
foreach ($x in ($agentNames | Where-Object { $expectedAgents -notcontains $_ })) { Warn "unexpected agent file: $x.md" }
foreach ($f in $agentFiles) {
  $fm = Get-Frontmatter $f.FullName
  Check ($null -ne $fm) "agent frontmatter: $($f.Name)"
  if ($fm) { Check ((Get-FmValue $fm 'name') -eq $f.BaseName) "agent name matches filename: $($f.BaseName)" }
}

# 3. Templates — required set present; DISCOVERED count matches; each has produced-by frontmatter
$expected = [ordered]@{
  shared = @('refined-story-pack','sprint-planning-support-pack','daily-scrum-support-summary',
             'implementation-pack','ai-pr-review-report','qa-test-pack','sprint-review-pack',
             'retrospective-insights-pack','release-readiness-pack','security-review-report')
  greenfield = @('project-request-brief','discovery-workshop-plan','discovery-meeting-summary',
                 'product-goal-draft','initial-product-backlog-pack','architecture-technical-foundation-pack')
  inherited = @('takeover-request-brief','access-information-checklist','initial-system-assessment',
                'inherited-project-goal-draft','business-rule-recovery-report','codebase-architecture-map',
                'stabilization-product-backlog','inherited-refined-story-pack','inherited-sprint-planning-support-pack',
                'safe-change-pack','regression-test-pack','inherited-sprint-review-pack',
                'inherited-retrospective-insights-pack','modernization-roadmap')
}
$expectedTotal = 30
foreach ($g in $expected.Keys) {
  foreach ($t in $expected[$g]) { Check (Test-Path (Join-Path $root "templates/$g/$t.md")) "template present: $g/$t.md" }
}
$tplFiles = @(Get-ChildItem (Join-Path $root 'templates') -Recurse -Filter *.md -ErrorAction SilentlyContinue)
Check ($tplFiles.Count -eq $expectedTotal) "template count == $expectedTotal (found $($tplFiles.Count) on disk)"
foreach ($f in $tplFiles) {
  $fm = Get-Frontmatter $f.FullName
  if ($null -eq $fm) { Check $false "template frontmatter: $($f.Name)"; continue }
  Check ($null -ne (Get-FmValue $fm 'produced-by')) "template produced-by: $($f.Name)"
}

# 4. Commands — required set present; each DISCOVERED command has description + argument-hint
$expectedCmds = 'intake','discovery-prep','discovery-summary','product-goal',
                'access-checklist','system-assessment','stabilization-goal',
                'initial-backlog','architecture','recover-rules','map-codebase',
                'stabilization-backlog','refine','sprint-plan',
                'execution','daily-scrum','pr-review','qa',
                'sprint-review','retro','release-readiness','modernize',
                'security-review'
$cmdFiles = @(Get-ChildItem (Join-Path $root '.claude/commands') -Filter *.md -ErrorAction SilentlyContinue)
$cmdNames = @($cmdFiles | ForEach-Object { $_.BaseName })
foreach ($c in $expectedCmds) { Check ($cmdNames -contains $c) "command present: $c" }
foreach ($x in ($cmdNames | Where-Object { $expectedCmds -notcontains $_ })) { Warn "unexpected command file: $x.md" }
foreach ($f in $cmdFiles) {
  $fm = Get-Frontmatter $f.FullName
  Check ($null -ne $fm) "command frontmatter: $($f.Name)"
  if ($fm) {
    Check ($null -ne (Get-FmValue $fm 'description')) "command description: $($f.Name)"
    Check ($null -ne (Get-FmValue $fm 'argument-hint')) "command argument-hint: $($f.Name)"
  }
}

# 5. Link integrity — every templates/ path and subagent_type named in an agent or command resolves
foreach ($f in (@($agentFiles) + @($cmdFiles))) {
  $txt = Get-Content $f.FullName -Raw
  foreach ($mm in [regex]::Matches($txt, 'templates/[A-Za-z0-9_./-]+\.md')) {
    Check (Test-Path (Join-Path $root $mm.Value)) "link resolves: $($mm.Value) (in $($f.Name))"
  }
  foreach ($mm in [regex]::Matches($txt, 'subagent_type:\s*`?([a-z][a-z-]*)`?')) {
    Check ($agentNames -contains $mm.Groups[1].Value) "subagent exists: $($mm.Groups[1].Value) (in $($f.Name))"
  }
}

# 6. .gitignore keeps repo pristine
$gi = Get-Content (Join-Path $root '.gitignore') -Raw
Check ($gi -match '(?m)^\s*src/\*\s*$') ".gitignore ignores src/*"
Check ($gi -match '(?m)^\s*!src/README\.md\s*$') ".gitignore un-ignores src/README.md"

# 7. No committed .docx — scan the tree but EXCLUDE gitignored src/ (engagement deliverables may legitimately be .docx)
$srcPrefix = (Join-Path $root 'src') + [System.IO.Path]::DirectorySeparatorChar
$docx = Get-ChildItem $root -Filter *.docx -Recurse -ErrorAction SilentlyContinue |
        Where-Object { -not $_.FullName.StartsWith($srcPrefix, [System.StringComparison]::OrdinalIgnoreCase) }
Check (-not $docx) "no .docx files remain (outside src/)"

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
  'implementation'          = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'implementation-frontend' = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'implementation-backend'  = @('mcp__github__*','mcp__ado__*')
  'implementation-data'     = @('mcp__github__*','mcp__ado__*')
  'implementation-mobile'   = @('mcp__github__*','mcp__ado__*','mcp__figma__*','mcp__playwright__*')
  'code-review'             = @('mcp__github__*','mcp__ado__*','mcp__figma__*')
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
