#requires -Version 5.1
# Structural verification for the AI-SDLC Playbook scaffold.
$root = Split-Path -Parent $PSScriptRoot
$script:fail = 0
function Check($cond, $msg) {
  if ($cond) { Write-Host "PASS  $msg" -ForegroundColor Green }
  else { Write-Host "FAIL  $msg" -ForegroundColor Red; $script:fail++ }
}

# 1. Required reference files
$refFiles = @(
  'CLAUDE.md','README.md','.gitignore',
  'playbook/PLAYBOOK.md','playbook/governance.md',
  'playbook/definition-of-ready.md','playbook/definition-of-done.md',
  'playbook/greenfield-vs-inherited.md','src/README.md'
)
foreach ($f in $refFiles) { Check (Test-Path (Join-Path $root $f)) "exists: $f" }

# 2. Agents (12) — frontmatter present and name matches filename
$agents = 'product-discovery','product-backlog','scrum-planning','implementation',
          'code-review','qa-test-design','test-automation','devops',
          'security-review','documentation','support-incident','retrospective-insights'
foreach ($a in $agents) {
  $p = Join-Path $root ".claude/agents/$a.md"
  if (-not (Test-Path $p)) { Check $false "agent file: $a.md"; continue }
  $txt = Get-Content $p -Raw
  $m = [regex]::Match($txt, '(?s)^---\s*\r?\n(.*?)\r?\n---')
  Check ($m.Success) "agent frontmatter: $a.md"
  if ($m.Success) {
    $nm = [regex]::Match($m.Groups[1].Value, '(?m)^name:\s*(.+?)\s*$')
    Check ($nm.Success -and $nm.Groups[1].Value.Trim() -eq $a) "agent name matches filename: $a"
  }
}

# 3. Templates (30) — present with frontmatter containing produced-by
$shared = 'refined-story-pack','sprint-planning-support-pack','daily-scrum-support-summary',
          'implementation-pack','ai-pr-review-report','qa-test-pack','sprint-review-pack',
          'retrospective-insights-pack','release-readiness-pack','security-review-report'
$green  = 'project-request-brief','discovery-workshop-plan','discovery-meeting-summary',
          'product-goal-draft','initial-product-backlog-pack','architecture-technical-foundation-pack'
$inh    = 'takeover-request-brief','access-information-checklist','initial-system-assessment',
          'inherited-project-goal-draft','business-rule-recovery-report','codebase-architecture-map',
          'stabilization-product-backlog','inherited-refined-story-pack','inherited-sprint-planning-support-pack',
          'safe-change-pack','regression-test-pack','inherited-sprint-review-pack',
          'inherited-retrospective-insights-pack','modernization-roadmap'
$groups = [ordered]@{ shared = $shared; greenfield = $green; inherited = $inh }
$tpl = 0
foreach ($g in $groups.Keys) {
  foreach ($t in $groups[$g]) {
    $tpl++
    $p = Join-Path $root "templates/$g/$t.md"
    if (-not (Test-Path $p)) { Check $false "template: $g/$t.md"; continue }
    $txt = Get-Content $p -Raw
    Check ([regex]::IsMatch($txt,'(?s)^---\s*\r?\n.*?produced-by:.*?\r?\n---')) "template frontmatter: $g/$t.md"
  }
}
Check ($tpl -eq 30) "template count == 30 (declared $tpl)"

# 4. .gitignore keeps repo pristine
$gi = Get-Content (Join-Path $root '.gitignore') -Raw
Check ($gi -match '(?m)^\s*src/\*\s*$') ".gitignore ignores src/*"
Check ($gi -match '(?m)^\s*!src/README\.md\s*$') ".gitignore un-ignores src/README.md"

# 5. .docx removed
$docx = Get-ChildItem $root -Filter *.docx -Recurse -ErrorAction SilentlyContinue
Check (-not $docx) "no .docx files remain"

# 6. Slash commands (7) — present with frontmatter (description + argument-hint)
$commands = 'intake','discovery-prep','discovery-summary','product-goal',
            'access-checklist','system-assessment','stabilization-goal'
foreach ($c in $commands) {
  $p = Join-Path $root ".claude/commands/$c.md"
  if (-not (Test-Path $p)) { Check $false "command: $c.md"; continue }
  $txt = Get-Content $p -Raw
  $m = [regex]::Match($txt, '(?s)^---\s*\r?\n(.*?)\r?\n---')
  Check ($m.Success) "command frontmatter: $c.md"
  if ($m.Success) {
    Check ([regex]::IsMatch($m.Groups[1].Value,'(?m)^description:\s*\S')) "command has description: $c.md"
    Check ([regex]::IsMatch($m.Groups[1].Value,'(?m)^argument-hint:\s*\S')) "command has argument-hint: $c.md"
  }
}

Write-Host ""
if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
