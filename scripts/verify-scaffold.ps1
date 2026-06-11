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
                'access-checklist','system-assessment','stabilization-goal'
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

Write-Host ""
if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
