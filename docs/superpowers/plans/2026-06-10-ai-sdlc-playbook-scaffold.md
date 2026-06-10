# AI-SDLC Playbook Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Turn the empty `AI-SDLC-PLAYBOOK` repo into a pristine, reusable base — operating manual, 12 specialized Claude Code subagents, ~30 output-pack templates, and the full delivery model in Markdown — that a team clones per engagement, with all project-specific data isolated under a gitignored `src/`.

**Architecture:** A flat content scaffold of Markdown + agent definitions. No runtime app, so "tests" = a structural verification script (`scripts/verify-scaffold.ps1`) written **first** (Task 1, fails immediately), then driven green as files are created. The `.docx` is converted to `playbook/*.md` and deleted. Everything project-specific lives in `src/` (gitignored). Spec: `docs/superpowers/specs/2026-06-10-ai-sdlc-playbook-scaffold-design.md`.

**Tech Stack:** Markdown, YAML frontmatter (Claude Code subagent format), PowerShell 5.1 (verification script, Windows-native), git.

**Branch:** `playbook-scaffold` (already created; spec already committed there).

---

## File map (what gets created)

```
CLAUDE.md                                  Task 7
README.md                                  Task 8
.gitignore                                 Task 1
scripts/verify-scaffold.ps1                Task 1
src/README.md                              Task 1
playbook/PLAYBOOK.md                       Task 2
playbook/governance.md                     Task 2
playbook/definition-of-ready.md            Task 2
playbook/definition-of-done.md             Task 2
playbook/greenfield-vs-inherited.md        Task 2
templates/shared/*.md            (10)      Task 3
templates/greenfield/*.md        (6)       Task 4
templates/inherited/*.md         (14)      Task 5
.claude/agents/*.md              (12)      Task 6
(delete) "AI-Assisted Scrum Delivery Model (1).docx"   Task 2
```

`scripts/` is the realization of spec §11's optional validation script — within approved scope.

---

## Authoring contracts (read once; referenced by Tasks 3–6)

### Template Authoring Contract

Every template file has this exact shape. Headings come **verbatim** from the doc's numbered list for that pack. Under each heading put a one-line italic guidance prompt. Every template ends with the standard **Governance footer**.

Fully-rendered reference example — `templates/greenfield/project-request-brief.md`:

```markdown
---
pack: Project Request Brief
scenario: greenfield
produced-by: product-discovery
review-owner: Sales / Delivery Manager / Architect / PO-BA
source: Greenfield Step 1
---

# Project Request Brief

> Produced at intake to decide whether to proceed with a new client request. Save the filled copy to `src/<engagement>/delivery/`.

## 1. Client summary
_Who the client is and the context of the request._

## 2. Business problem
_The core problem the client wants solved._

## 3. Desired outcome
_What success looks like for the client._

## 4. Known requirements
_Requirements stated explicitly so far._

## 5. Unknowns
_What is still unclear and must be clarified._

## 6. Initial assumptions
_Assumptions we are making to proceed._

## 7. Initial risks
_Early commercial, technical, and delivery risks._

## 8. Suggested clarification questions
_Questions to ask the client before committing._

## 9. Recommendation: proceed / clarify / decline
_The recommended next action with reasoning._

---
### Governance footer (required in every artifact)
- **Observed facts:**
- **Assumptions:**
- **Risks:**
- **Recommendations:**
- **Open questions:**
- **Human review owner:** Sales / Delivery Manager / Architect / PO-BA — _AI drafts; humans validate and approve._
```

Rules for all templates:
- `## N. <Heading>` headings must match the heading list in the task data **exactly and in order**.
- One italic guidance line under each heading (concise; describe what goes there).
- Always include the Governance footer; set its "Human review owner" to the template's `review-owner`.
- The intro blockquote: one line on when it's produced + "Save the filled copy to `src/<engagement>/delivery/`."

### Agent Authoring Contract

Every agent file (`.claude/agents/<name>.md`) has this exact shape. `name` MUST equal the filename without `.md`.

Fully-rendered reference example — `.claude/agents/product-discovery.md`:

```markdown
---
name: product-discovery
description: Use at engagement intake and discovery to turn a raw client request, discovery-meeting notes, or a takeover request into structured discovery artifacts. Trigger cues — "new client request", "discovery", "kickoff", "takeover", "assess this request", "discovery workshop".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
---

# Product Discovery Agent

## Purpose
Understands client goals, problems, and initial scope. Prepares discovery and produces the foundation for the Product Goal (greenfield) or Stabilization Goal (inherited).

## When to use / primary users
Greenfield Steps 1–4 and Inherited Steps 1, 2, 4. Primary users: Product Owner, BA, PM, Sales.

## Inputs
- The raw client request in `src/<engagement>/request/`
- Discovery / kickoff meeting notes
- Any client-supplied documentation
- For takeovers: current pain points, urgency, access situation

## Outputs
Fill the relevant template(s) and write the result to `src/<engagement>/delivery/`:
- Greenfield: `templates/greenfield/project-request-brief.md`, `discovery-workshop-plan.md`, `discovery-meeting-summary.md`, `product-goal-draft.md`
- Inherited: `templates/inherited/takeover-request-brief.md`, `access-information-checklist.md`, `inherited-project-goal-draft.md`

## Governance reminders
- **Human review owner:** PO / BA (Sales, Delivery Manager, Architect contribute).
- Separate **Observed facts / Assumptions / Risks / Recommendations / Open questions** in every output.
- AI drafts requirements; the Product Owner / BA validate them. Never paste secrets or production data.
```

Rules for all agents:
- Frontmatter keys: `name`, `description` (include trigger cues), `tools`.
- Body sections in this order: `## Purpose`, `## When to use / primary users`, `## Inputs`, `## Outputs` (with exact template paths), `## Governance reminders` (human review owner + facts/assumptions/risks discipline + any agent-specific rule).
- Tool scoping per the task data below.

---

## Task 1: Repo skeleton + verification harness (test-first)

**Files:**
- Create: `.gitignore`
- Create: `src/README.md`
- Create: `scripts/verify-scaffold.ps1`

- [ ] **Step 1: Create `.gitignore`**

```gitignore
# Keep the playbook pristine — no project-specific data is ever committed.
src/*
!src/README.md

# OS / editor noise
.DS_Store
Thumbs.db
```

- [ ] **Step 2: Create `src/README.md`**

```markdown
# src/ — engagement workspace (gitignored)

Everything in this folder is **gitignored** (except this README) so the playbook repo
stays pristine and reusable across many projects.

## Layout — one folder per engagement

```
src/
└── <engagement>/            # short slug, e.g. acme-portal
    ├── request/             # drop the raw client request here
    ├── delivery/            # generated artifacts (briefs, backlogs, assessments, reports)
    └── <project-repo>/      # the project's OWN git repo, cloned here
```

- **Working analysis artifacts** → `delivery/`.
- **Durable project docs** (the project's own README, CLAUDE.md, ADRs) and **code/tests** → inside `<project-repo>/`.
- You can host multiple engagements side-by-side here; the playbook tooling is shared, the data stays isolated.
```

- [ ] **Step 3: Create `scripts/verify-scaffold.ps1`**

```powershell
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

Write-Host ""
if ($script:fail -eq 0) { Write-Host "ALL CHECKS PASSED" -ForegroundColor Green; exit 0 }
else { Write-Host "$script:fail CHECK(S) FAILED" -ForegroundColor Red; exit 1 }
```

- [ ] **Step 4: Run the verifier — expect it to FAIL**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: many `FAIL` lines (playbook/CLAUDE/templates/agents missing) and exit code 1. This confirms the harness works.

- [ ] **Step 5: Confirm `.gitignore` keeps `src/` pristine**

Run:
```powershell
New-Item -ItemType Directory -Force src/_probe/request | Out-Null
New-Item -ItemType File -Force src/_probe/request/foo.txt | Out-Null
git status --porcelain
Remove-Item -Recurse -Force src/_probe
```
Expected: `git status` shows only `src/README.md` (and the new tooling), NOT `src/_probe/...`.

- [ ] **Step 6: Commit**

```powershell
git add .gitignore src/README.md scripts/verify-scaffold.ps1
git commit -m "Add repo skeleton, .gitignore, and structural verifier"
```

---

## Task 2: Convert the .docx to Markdown and split into `playbook/`

**Files:**
- Create: `playbook/PLAYBOOK.md`, `playbook/governance.md`, `playbook/definition-of-ready.md`, `playbook/definition-of-done.md`, `playbook/greenfield-vs-inherited.md`
- Delete: `AI-Assisted Scrum Delivery Model (1).docx`

- [ ] **Step 1: Extract the raw text from the .docx**

Run:
```powershell
Add-Type -AssemblyName System.IO.Compression.FileSystem
$path = (Get-ChildItem -Filter *.docx | Select-Object -First 1).FullName
$zip = [System.IO.Compression.ZipFile]::OpenRead($path)
$entry = $zip.Entries | Where-Object { $_.FullName -eq 'word/document.xml' }
$reader = New-Object System.IO.StreamReader($entry.Open())
$xml = $reader.ReadToEnd(); $reader.Close(); $zip.Dispose()
$xml = $xml -replace '</w:p>', "`n" -replace '<w:br[^>]*/>', "`n" -replace '<w:tab[^>]*/>', "`t"
$text = ($xml -replace '<[^>]+>', '') -replace '&amp;','&' -replace '&lt;','<' -replace '&gt;','>' -replace '&quot;','"' -replace '&apos;',"'"
Set-Content -Path playbook/_raw.txt -Value $text -Encoding utf8
```
Expected: `playbook/_raw.txt` created (~14 sections of text).

- [ ] **Step 2: Author `playbook/PLAYBOOK.md` from the raw text**

Read `playbook/_raw.txt` and render it as clean Markdown preserving ALL 14 sections, every numbered list, and every step's structure (Goal / Roles involved / AI usage / AI output / Human review / Scrum connection). Reconstruct as proper Markdown **tables** the three places the doc stored tables as flat lines:
- §2 Principle 2 "Area / Human owner" ownership table
- §3.1 "Agent / Purpose / Main users" table
- §11 "Greenfield vs Inherited" comparison table

Use `#`/`##`/`###` for the section hierarchy (Executive Summary, 1. Vision … 14. Final Recommended Operating Model). Title: `# AI-Assisted Scrum Delivery Model`.

- [ ] **Step 3: Create `playbook/governance.md`** (extract §13)

```markdown
# Governance Rules

1. **AI cannot approve its own work.** AI can review, suggest, and summarize. Humans approve.
2. **AI-generated code requires human review.** No AI-generated code is merged without human review.
3. **AI-generated requirements require PO/BA validation.** AI drafts backlog items; the Product Owner or BA validates them.
4. **AI-generated tests require QA/developer validation.** AI generates tests; QA and Developers validate correctness.
5. **AI-generated client communication requires PM/PO review.** AI drafts status updates, release notes, and summaries; humans send them.
6. **AI must not receive secrets or unsafe production data.** Credentials, private keys, tokens, and production-sensitive data are never pasted into AI tools.
7. **AI assumptions must be visible.** Every AI output separates: Observed facts · Assumptions · Risks · Recommendations · Open questions.
```

- [ ] **Step 4: Create `playbook/definition-of-ready.md`** (extract §9)

```markdown
# AI-Enhanced Definition of Ready

A Product Backlog item is **Ready** for Sprint Planning when AI and the team have checked:

1. Business goal is clear
2. User role is clear
3. Expected behavior is clear
4. Acceptance criteria exist
5. Dependencies are identified
6. Edge cases are considered
7. Risks are listed
8. Test scenarios are suggested
9. Open questions are visible
10. The team understands the item well enough to plan it
```

- [ ] **Step 5: Create `playbook/definition-of-done.md`** (extract §10)

```markdown
# AI-Enhanced Definition of Done

A Product Backlog item is **Done** when:

1. Acceptance criteria are satisfied
2. Code is implemented
3. Tests are added or updated
4. AI-assisted self-review is completed
5. Human PR review is completed
6. QA validation is completed where needed
7. Security concerns are checked where needed
8. Documentation is updated where needed
9. No critical regression risk remains
10. The Increment is usable
```

- [ ] **Step 6: Create `playbook/greenfield-vs-inherited.md`** (extract §11 + the §5.2 / §6.2 flow overviews)

Render the §11 comparison table as a Markdown table with columns **Area | Greenfield Scrum Flow | Inherited Scrum Flow**, followed by two subsections "## Greenfield flow overview" and "## Inherited flow overview" containing the arrow-flows from §5.2 and §6.2.

- [ ] **Step 7: Delete the raw text scratch file and the original .docx**

```powershell
Remove-Item playbook/_raw.txt
Remove-Item *.docx
```
Expected: no `.docx` and no `_raw.txt` remain.

- [ ] **Step 8: Run verifier (playbook checks now pass)**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 9 `playbook/`+`src` `exists:` checks PASS and "no .docx files remain" PASSES. Templates/agents/CLAUDE still FAIL (not built yet).

- [ ] **Step 9: Commit**

```powershell
git add playbook/ ; git add -A
git commit -m "Convert delivery model to Markdown; split governance, DoR, DoD; remove .docx"
```

---

## Task 3: `templates/shared/` — 10 templates

**Files:** Create `templates/shared/<name>.md` for each block below.

Follow the **Template Authoring Contract**. For each file: set frontmatter (`scenario: shared`), use the exact heading list, add one italic guidance line per heading, append the Governance footer with the file's review-owner.

- [ ] **Step 1: Create the 10 shared templates**

```
#### refined-story-pack.md
pack="Refined Story Pack"  produced-by=product-backlog  review-owner="Product Owner / BA"  source="Greenfield Step 7 / §7.1"
1. Story summary
2. Business value
3. Acceptance criteria
4. Dependencies
5. Edge cases
6. Technical notes
7. QA notes
8. Risks
9. Open questions
10. Definition of Ready status

#### sprint-planning-support-pack.md
pack="Sprint Planning Support Pack"  produced-by=scrum-planning  review-owner="Scrum Team"  source="Greenfield Step 8 / §7.2"
1. Candidate backlog items
2. Readiness check
3. Suggested Sprint Goal options
4. Dependencies
5. Risks
6. Suggested task breakdown
7. QA work needed
8. DevOps work needed
9. Open questions
10. Sprint confidence level

#### daily-scrum-support-summary.md
pack="Daily Scrum Support Summary"  produced-by=scrum-planning  review-owner="Developers"  source="Greenfield Step 10 / §7.3"
1. Progress toward Sprint Goal
2. Blockers
3. At-risk Sprint Backlog items
4. Dependencies
5. Suggested follow-ups
6. Items needing team discussion

#### implementation-pack.md
pack="Implementation Pack"  produced-by=implementation  review-owner="Developer / Tech Lead"  source="Greenfield Step 9 / §7.4"
1. Ticket understanding
2. Affected files/modules
3. Implementation plan
4. Code changes
5. Tests added/updated
6. Commands run
7. Risks
8. Documentation updates
9. PR summary

#### ai-pr-review-report.md
pack="AI PR Review Report"  produced-by=code-review  review-owner="Human reviewer / Tech Lead"  source="Greenfield Step 11"
1. Summary of changes
2. Acceptance criteria coverage
3. Missing tests
4. Risky areas
5. Security concerns
6. Architecture concerns
7. Regression risks
8. Suggested improvements
9. Documentation needs
10. Human reviewer checklist

#### qa-test-pack.md
pack="QA Test Pack"  produced-by=qa-test-design  review-owner="QA"  source="Greenfield Step 12"
1. Positive test cases
2. Negative test cases
3. Edge cases
4. Permission tests
5. Regression checks
6. Automation candidates
7. Test data
8. Bug report drafts
9. QA risk notes

#### sprint-review-pack.md
pack="Sprint Review Pack"  produced-by=scrum-planning  review-owner="Product Owner / Scrum Team"  source="Greenfield Step 13 / §7.5"
1. Sprint Goal summary
2. Completed Product Backlog items
3. Demo flow
4. Known limitations
5. Stakeholder feedback
6. Decisions made
7. New backlog items
8. Scope changes
9. Follow-up actions

#### retrospective-insights-pack.md
pack="Retrospective Insights Pack"  produced-by=retrospective-insights  review-owner="Scrum Team"  source="Greenfield Step 14 / §7.6"
1. What went well
2. What did not go well
3. Recurring blockers
4. Process issues
5. Quality issues
6. Communication issues
7. AI usage observations
8. Suggested improvements
9. Action items for next Sprint

#### release-readiness-pack.md
pack="Release Readiness Pack"  produced-by=devops  review-owner="Product Owner / QA / DevOps / PM"  source="Greenfield Step 15"
1. Release summary
2. Completed features
3. Fixed bugs
4. Known issues
5. Test status
6. Deployment checklist
7. Rollback plan
8. Support notes
9. Client communication draft
10. Documentation updates

#### security-review-report.md
pack="Security Review Report"  produced-by=security-review  review-owner="Security Owner / Tech Lead"  source="§3.1 Security Review Agent + DoD security checks"
1. Scope reviewed
2. Authentication & authorization findings
3. Input validation & injection risks
4. Secrets & credential handling
5. Dependency & supply-chain risks
6. Configuration & infrastructure risks
7. Data protection & privacy
8. Severity-ranked findings
9. Remediation recommendations
10. Residual risks & open questions
```

- [ ] **Step 2: Run verifier — shared template checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 10 `template: shared/...` + `template frontmatter: shared/...` checks PASS.

- [ ] **Step 3: Commit**

```powershell
git add templates/shared
git commit -m "Add 10 shared output-pack templates"
```

---

## Task 4: `templates/greenfield/` — 6 templates

**Files:** Create `templates/greenfield/<name>.md`. `project-request-brief.md` is already fully rendered in the Template Authoring Contract — create it exactly as shown there. Build the other 5 from the blocks below (`scenario: greenfield`).

- [ ] **Step 1: Create the 6 greenfield templates**

```
#### project-request-brief.md
(Use the fully-rendered example in the Template Authoring Contract verbatim.)

#### discovery-workshop-plan.md
pack="Discovery Workshop Plan"  produced-by=product-discovery  review-owner="BA / Architect / PM / QA"  source="Greenfield Step 2"
1. Discovery goals
2. Meeting agenda
3. Stakeholders needed
4. Business questions
5. User workflow questions
6. Technical questions
7. Integration questions
8. Security/compliance questions
9. Non-functional requirement questions
10. Expected outputs from the workshop

#### discovery-meeting-summary.md
pack="Discovery Meeting Summary"  produced-by=product-discovery  review-owner="BA / PM / Architect / Client"  source="Greenfield Step 3"
1. Meeting overview
2. Business goals
3. User roles
4. Core workflows
5. Functional requirements mentioned
6. Non-functional requirements mentioned
7. Decisions made
8. Open questions
9. Assumptions
10. Risks
11. Action items
12. Suggested next steps

#### product-goal-draft.md
pack="Product Goal Draft"  produced-by=product-discovery  review-owner="PO / Client / Delivery Manager / Architect"  source="Greenfield Step 4"
1. Product vision
2. Business outcome
3. Target users
4. Core value proposition
5. Success criteria
6. MVP boundary
7. Future expansion areas
8. Open strategic questions

#### initial-product-backlog-pack.md
pack="Initial Product Backlog Pack"  produced-by=product-backlog  review-owner="PO / BA / QA / Developers / Architect"  source="Greenfield Step 5"
1. Epics
2. User stories
3. Acceptance criteria
4. Business rules
5. User roles
6. Permission matrix
7. Dependencies
8. Risks
9. Test scenario ideas
10. Open questions
11. MVP / Phase 2 separation

#### architecture-technical-foundation-pack.md
pack="Architecture & Technical Foundation Pack"  produced-by=implementation  review-owner="Architect / Tech Lead / DevOps / Security / QA"  source="Greenfield Step 6"
1. Architecture overview
2. Technology stack
3. Component boundaries
4. API strategy
5. Data model approach
6. Security baseline
7. Testing strategy
8. CI/CD approach
9. ADRs
10. Technical risks
11. Repository setup recommendations
12. CLAUDE.md draft
```

- [ ] **Step 2: Run verifier — greenfield template checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 6 `template: greenfield/...` checks PASS.

- [ ] **Step 3: Commit**

```powershell
git add templates/greenfield
git commit -m "Add 6 greenfield output-pack templates"
```

---

## Task 5: `templates/inherited/` — 14 templates

**Files:** Create `templates/inherited/<name>.md` (`scenario: inherited`) from the blocks below.

- [ ] **Step 1: Create the 14 inherited templates**

```
#### takeover-request-brief.md
pack="Takeover Request Brief"  produced-by=product-discovery  review-owner="Sales / Delivery Manager / Architect / PM"  source="Inherited Step 1"
1. System summary
2. Why client needs help
3. Current pain points
4. Business criticality
5. Known urgent issues
6. Unknowns
7. Initial risks
8. Required access
9. Suggested assessment approach

#### access-information-checklist.md
pack="Access & Information Checklist"  produced-by=product-discovery  review-owner="PM / Tech Lead / DevOps / Security"  source="Inherited Step 2"
1. Repository access
2. Documentation received
3. Database schema availability
4. Deployment information
5. CI/CD access
6. Issue tracker access
7. Support ticket history
8. Test suite availability
9. Monitoring/logging access
10. Missing information
11. Blockers
12. Client follow-up questions

#### initial-system-assessment.md
pack="Initial System Assessment"  produced-by=implementation  review-owner="Tech Lead / Architect / Developers / PM"  source="Inherited Step 3"
1. System purpose
2. Technology stack
3. Repository structure
4. Main modules
5. Entry points
6. Build and run process
7. Database overview
8. External integrations
9. Test coverage overview
10. Deployment overview
11. Documentation gaps
12. Initial risks
13. Recommended next assessment items

#### inherited-project-goal-draft.md
pack="Inherited Project Goal Draft"  produced-by=product-discovery  review-owner="PO / Client / Tech Lead / QA"  source="Inherited Step 4"
1. Current state summary
2. Business priority
3. Stabilization goal
4. Success criteria
5. Urgent issues
6. Short-term focus
7. Long-term modernization direction
8. Key risks

#### business-rule-recovery-report.md
pack="Business Rule Recovery Report"  produced-by=documentation  review-owner="BA / Developers / QA / Client"  source="Inherited Step 5"
1. Current workflows
2. User roles
3. Permissions
4. Business rules found in code
5. Business rules found in documentation
6. Business rules found in historical tickets
7. Contradictions
8. Unclear behavior
9. Client validation questions
10. Regression test candidates

#### codebase-architecture-map.md
pack="Codebase & Architecture Map"  produced-by=implementation  review-owner="Architect / Tech Lead / DevOps / QA"  source="Inherited Step 6"
1. Architecture style
2. Module structure
3. Main layers
4. Critical flows
5. API boundaries
6. Database access patterns
7. External integrations
8. Authentication and authorization
9. Coupling and dependencies
10. High-risk areas
11. Refactoring candidates
12. Modernization opportunities

#### stabilization-product-backlog.md
pack="Stabilization Product Backlog"  produced-by=product-backlog  review-owner="PO / Tech Lead / QA / DevOps / Client"  source="Inherited Step 7"
1. Urgent defects
2. Documentation recovery items
3. Business rule validation items
4. Regression testing items
5. DevOps stabilization items
6. Security remediation items
7. Technical debt items
8. Modernization candidates
9. New feature requests
10. Client decision items

#### inherited-refined-story-pack.md
pack="Inherited Refined Story Pack"  produced-by=product-backlog  review-owner="PO / BA / Developers / QA"  source="Inherited Step 8"
1. Issue or feature summary
2. Current behavior
3. Expected behavior
4. Business rules involved
5. Affected modules
6. Regression risks
7. Acceptance criteria
8. Suggested tests
9. Open questions
10. Definition of Ready status

#### inherited-sprint-planning-support-pack.md
pack="Inherited Sprint Planning Support Pack"  produced-by=scrum-planning  review-owner="PO / Developers / QA / Scrum Master / Tech Lead"  source="Inherited Step 9"
1. Candidate items
2. Business value
3. Stabilization value
4. Technical risk
5. Regression risk
6. Dependencies
7. Suggested Sprint Goal options
8. Suggested safe sequence
9. Testing effort
10. Sprint confidence level

#### safe-change-pack.md
pack="Safe Change Pack"  produced-by=implementation  review-owner="Developer / Tech Lead / QA / BA"  source="Inherited Step 10"
1. Issue summary
2. Root cause hypothesis
3. Affected files
4. Business rules involved
5. Regression risks
6. Suggested tests
7. Implementation plan
8. Code changes
9. Documentation updates
10. PR risk notes

#### regression-test-pack.md
pack="Regression Test Pack"  produced-by=qa-test-design  review-owner="QA / Developers / BA / Support"  source="Inherited Step 11"
1. Critical business flows
2. High-risk modules
3. Historical bug scenarios
4. Manual regression tests
5. Automated test candidates
6. Characterization tests
7. Smoke test checklist
8. Test data requirements
9. Release validation checklist

#### inherited-sprint-review-pack.md
pack="Inherited Sprint Review Pack"  produced-by=scrum-planning  review-owner="PO / Client / Scrum Team"  source="Inherited Step 12"
1. Sprint Goal summary
2. Completed fixes
3. Completed stabilization work
4. Documentation created
5. Tests added
6. Risks reduced
7. Remaining risks
8. Demo flow
9. Stakeholder feedback
10. New backlog items

#### inherited-retrospective-insights-pack.md
pack="Inherited Retrospective Insights Pack"  produced-by=retrospective-insights  review-owner="Scrum Team / Tech Lead"  source="Inherited Step 13"
1. What went well
2. What slowed us down
3. Unknowns discovered
4. Recurring legacy risks
5. Testing gaps
6. Communication issues
7. Documentation gaps
8. AI usage observations
9. Suggested improvements
10. Action items for next Sprint

#### modernization-roadmap.md
pack="Modernization Roadmap"  produced-by=documentation  review-owner="PO / Architect / Client"  source="Inherited Step 14"
1. Current state summary
2. Pain points
3. Technical debt themes
4. Modernization options
5. Quick wins
6. Medium-term improvements
7. Long-term architecture changes
8. Cost/risk/benefit analysis
9. Recommended phases
10. Product Backlog items
```

- [ ] **Step 2: Run verifier — all 30 template checks + count pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 14 `template: inherited/...` checks PASS and `template count == 30` PASSES.

- [ ] **Step 3: Commit**

```powershell
git add templates/inherited
git commit -m "Add 14 inherited output-pack templates"
```

---

## Task 6: `.claude/agents/` — 12 subagent stubs

**Files:** Create `.claude/agents/<name>.md`. `product-discovery.md` is fully rendered in the Agent Authoring Contract — create it exactly as shown. Build the other 11 from the blocks below, following the contract's section order and rules.

Tool scoping: analysis/authoring agents → `Read, Grep, Glob, Write, WebSearch, WebFetch`. Code-touching (`implementation`, `test-automation`, `devops`) → add `Edit, Bash`. `code-review` → `Read, Grep, Glob, Bash` (no Edit — reviews, doesn't fix).

- [ ] **Step 1: Create the 12 agent files**

```
#### product-discovery.md
(Use the fully-rendered example in the Agent Authoring Contract verbatim.)

#### product-backlog.md
description: Use to create or refine the Product Backlog — epics, user stories, acceptance criteria, and a stabilization backlog for takeovers. Trigger cues — "create backlog", "write user stories", "acceptance criteria", "refine story", "stabilization backlog", "split this story".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
Purpose: Creates and refines epics, stories, and acceptance criteria; turns discovery or assessment findings into a prioritizable Product Backlog.
When/users: Greenfield Steps 5,7; Inherited Steps 7,8. Users: PO, BA, Scrum Team.
Inputs: discovery/assessment artifacts in delivery/, the Product/Stabilization Goal, existing backlog, codebase in src/ (for inherited).
Outputs: templates/greenfield/initial-product-backlog-pack.md, templates/shared/refined-story-pack.md, templates/inherited/stabilization-product-backlog.md, templates/inherited/inherited-refined-story-pack.md → delivery/.
Governance owner: Product Owner (BA business meaning, QA testability, Developers feasibility). Agent rule: AI drafts backlog items; PO/BA validate before they enter the Sprint.

#### scrum-planning.md
description: Use to support Scrum events — Sprint Planning, Daily Scrum, and Sprint Review. Drafts Sprint Goal options, readiness/risk checks, task breakdowns, and review summaries. Trigger cues — "sprint planning", "sprint goal", "daily scrum", "sprint review", "plan the sprint", "demo summary".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
Purpose: Supports Sprint Planning, Sprint Goal drafting, risk analysis, Daily Scrum focus, and Sprint Review preparation.
When/users: Greenfield Steps 8,10,13; Inherited Steps 9,12. Users: Scrum Master, PM, Scrum Team.
Inputs: refined backlog items, capacity info, prior delivery artifacts, Sprint Goal, increment status.
Outputs: templates/shared/sprint-planning-support-pack.md, daily-scrum-support-summary.md, sprint-review-pack.md; templates/inherited/inherited-sprint-planning-support-pack.md, inherited-sprint-review-pack.md → delivery/.
Governance owner: Scrum Team / Scrum Master. Agent rule: AI suggests Sprint Goal options and sequencing; the Developers decide what to commit. Not for micromanagement.

#### implementation.md
description: Use during the Sprint to implement stories, fix bugs, and refactor safely — including codebase/architecture analysis for new and inherited systems. Trigger cues — "implement this ticket", "fix this bug", "refactor", "analyze the codebase", "system assessment", "safe change", "architecture foundation".
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch
Purpose: Helps Developers plan and implement changes, analyze existing code, and make changes without breaking hidden legacy behavior.
When/users: Greenfield Steps 6,9; Inherited Steps 3,6,10. Users: Developers, Tech Lead.
Inputs: the ticket/bug, the project repo in src/<engagement>/<project-repo>/, acceptance criteria, business rules, regression risks.
Outputs: templates/shared/implementation-pack.md; templates/greenfield/architecture-technical-foundation-pack.md; templates/inherited/initial-system-assessment.md, codebase-architecture-map.md, safe-change-pack.md → delivery/. Code/tests are written INTO the project repo.
Governance owner: Developer (Tech Lead reviews complex changes; QA validates; Architect for architectural impact). Agent rule: AI cannot merge; human review required. For inherited code, prefer characterization tests before changing behavior.

#### code-review.md
description: Use for a first-pass PR review before human review — coverage vs acceptance criteria, risky code, security, regressions. Trigger cues — "review this PR", "review the diff", "pre-merge review", "PR review report".
tools: Read, Grep, Glob, Bash
Purpose: Performs a first-pass PR review to improve quality before human review and merge.
When/users: Greenfield Step 11 / §7. Users: Developers, Tech Lead, QA, Security when needed.
Inputs: the PR diff / branch in the project repo, the linked acceptance criteria, the test suite.
Outputs: templates/shared/ai-pr-review-report.md → delivery/.
Governance owner: Human reviewer / Tech Lead. Agent rule: AI cannot approve its own or anyone's PR — it produces a report; a human approves or rejects.

#### qa-test-design.md
description: Use to design tests from acceptance criteria — positive/negative/edge cases, permission tests, and regression packs for inherited systems. Trigger cues — "write test cases", "QA test pack", "edge cases", "regression tests", "test plan", "characterization tests".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
Purpose: Generates manual test cases, edge cases, and regression checks from acceptance criteria and critical flows.
When/users: Greenfield Step 12; Inherited Step 11. Users: QA, BA, Developers.
Inputs: acceptance criteria, business rules, critical flows, historical bugs, the project repo.
Outputs: templates/shared/qa-test-pack.md; templates/inherited/regression-test-pack.md → delivery/.
Governance owner: QA. Agent rule: AI drafts tests; QA owns validation and Developers own automated-test correctness.

#### test-automation.md
description: Use to create automated tests (unit/integration/API/UI) from QA test packs and acceptance criteria, written into the project repo. Trigger cues — "automate these tests", "write automated tests", "add CI tests", "convert test pack to code".
tools: Read, Grep, Glob, Write, Edit, Bash
Purpose: Helps create automated tests from manual test packs and acceptance criteria.
When/users: Sprint execution + regression (Greenfield Step 12 / Inherited Step 11). Users: QA Automation, Developers.
Inputs: the QA Test Pack / Regression Test Pack in delivery/, the project repo and its existing test framework.
Outputs: automated test CODE written INTO the project repo (src/<engagement>/<project-repo>/). No standalone Markdown pack; summarize what was added in the Implementation Pack or PR.
Governance owner: QA Automation / Developers. Agent rule: humans validate automated-test correctness; follow the project's existing test conventions.

#### devops.md
description: Use for CI/CD, environments, deployment, and release readiness — deployment checklists, rollback plans, log/failure analysis. Trigger cues — "set up CI/CD", "deployment checklist", "release readiness", "rollback plan", "analyze CI failure", "pipeline".
tools: Read, Grep, Glob, Write, Edit, Bash, WebSearch, WebFetch
Purpose: Supports CI/CD, deployments, environments, and logs; prepares release readiness.
When/users: Greenfield Step 15; supports Inherited stabilization. Users: DevOps, Developers.
Inputs: the project repo, CI/CD config, environment/deployment info, release scope, logs.
Outputs: templates/shared/release-readiness-pack.md → delivery/; pipeline/config changes INTO the project repo.
Governance owner: DevOps. Agent rule: never autonomous production deployment; humans approve deploys; never expose secrets/production data.

#### security-review.md
description: Use to review code, architecture, and configuration for security risks — auth, injection, secrets, dependencies, data protection. Trigger cues — "security review", "check for vulnerabilities", "secrets handling", "threat check", "security baseline".
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
Purpose: Reviews code, architecture, and configuration for security risks and proposes remediations.
When/users: Greenfield Step 6 (security baseline) + per-PR when needed; Inherited stabilization. Users: Security Owner, Tech Lead.
Inputs: the project repo, architecture/config, dependency manifests, the PR diff when relevant.
Outputs: templates/shared/security-review-report.md → delivery/.
Governance owner: Security Owner / Tech Lead. Agent rule: report-only; humans own security decisions. Never paste real secrets/credentials into prompts.

#### documentation.md
description: Use to create/update project documentation — README, project CLAUDE.md, ADRs, architecture docs, business-rule recovery, and the modernization roadmap. Trigger cues — "write the README", "document this", "create ADR", "recover business rules", "modernization roadmap", "architecture docs".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
Purpose: Creates and maintains project documentation and recovers/records how an inherited system works.
When/users: Continuous; Inherited Steps 5,14. Users: Developers, BA, QA, PM.
Inputs: the project repo, delivery artifacts, code, historical tickets, meeting notes.
Outputs: templates/inherited/business-rule-recovery-report.md, modernization-roadmap.md → delivery/. DURABLE docs (project README, CLAUDE.md, ADRs, architecture docs) are written INTO the project repo.
Governance owner: Developers / BA / PM. Agent rule: durable client-owned docs live in the project repo, not in delivery/.

#### support-incident.md
description: Use to triage support tickets and incidents — classify, find probable cause, suggest next steps, and link to regression coverage. Trigger cues — "triage this ticket", "incident", "production issue", "bug report triage", "support queue".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
Purpose: Helps triage support tickets and incidents and connects them to regression coverage.
When/users: Ongoing support/maintenance (both scenarios). Users: Support, Developers, PM.
Inputs: the ticket/incident, the project repo, historical tickets, logs/monitoring access.
Outputs: incident/triage notes written to delivery/ (lightweight — summary, severity, probable cause, affected area, suggested next step, regression-test candidate). No standalone numbered pack.
Governance owner: Support / Developers / PM. Agent rule: separate facts/assumptions/risks; never paste production data or secrets.

#### retrospective-insights.md
description: Use after a Sprint to analyze patterns — recurring blockers, estimation misses, quality/communication issues — and propose improvement experiments. Trigger cues — "retrospective", "retro insights", "what slowed us down", "analyze the sprint", "improvement actions".
tools: Read, Grep, Glob, Write, WebSearch, WebFetch
Purpose: Analyzes Sprint patterns and improvement opportunities; tracks previous retro actions.
When/users: Greenfield Step 14; Inherited Step 13 / §7.6. Users: Scrum Master, Scrum Team.
Inputs: Sprint metrics, blockers, planned-vs-completed work, prior retro action items, delivery artifacts.
Outputs: templates/shared/retrospective-insights-pack.md; templates/inherited/inherited-retrospective-insights-pack.md → delivery/.
Governance owner: Scrum Master / Scrum Team. Agent rule: AI surfaces patterns; the team chooses improvements. AI does not replace the retro conversation.
```

- [ ] **Step 2: Run verifier — agent checks pass**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: all 12 `agent frontmatter` + `agent name matches filename` checks PASS.

- [ ] **Step 3: Commit**

```powershell
git add .claude/agents
git commit -m "Add 12 specialized subagent stubs"
```

---

## Task 7: `CLAUDE.md` — the operating manual (the brain)

**Files:** Create `CLAUDE.md` at repo root.

- [ ] **Step 1: Create `CLAUDE.md`**

```markdown
# AI-Assisted Scrum Delivery — Engagement Operating Manual

This repository is a **reusable base** for running AI-assisted Scrum delivery on client engagements. It stays pristine: it ships only reusable tooling (this manual, the playbook, specialized agents, and output templates). **All project-specific data lives under `src/` and is gitignored** — so one clone serves many projects.

> Full model: `playbook/PLAYBOOK.md`. This file is the quick operating manual.

## Engagement workflow

1. **Create the workspace:** `src/<engagement>/` with `request/` and `delivery/` subfolders.
2. **Add the request:** put the raw client request in `src/<engagement>/request/`.
3. **Classify:** **greenfield** (new build) vs **inherited** (existing/takeover) — see `playbook/greenfield-vs-inherited.md`.
4. **Run agents per step:** invoke the relevant agent (below); write each artifact to `src/<engagement>/delivery/`.
5. **Clone the project repo:** into `src/<engagement>/<project-repo>/`. Durable project docs (its own README, CLAUDE.md, ADRs) and code/tests go INSIDE that repo, not in `delivery/`.

Nothing project-specific is ever committed to this playbook repo.

## Agents

| Agent | Use it for | Produces | Human review owner |
|-------|-----------|----------|--------------------|
| `product-discovery` | Intake & discovery; product/stabilization goal | Request/Takeover Brief, Discovery Workshop Plan, Meeting Summary, Goal Draft, Access Checklist | PO / BA |
| `product-backlog` | Epics, stories, acceptance criteria, stabilization backlog | Initial/Stabilization Backlog, Refined Story Pack | Product Owner |
| `scrum-planning` | Sprint Planning, Daily Scrum, Sprint Review | Sprint Planning Support Pack, Daily Scrum Summary, Sprint Review Pack | Scrum Team |
| `implementation` | Build stories, fix bugs, refactor, codebase analysis | Implementation Pack, Safe Change Pack, Architecture/System/Codebase docs | Developer / Tech Lead |
| `code-review` | First-pass PR review before human review | AI PR Review Report | Human reviewer / Tech Lead |
| `qa-test-design` | Test cases, edge cases, regression packs | QA Test Pack, Regression Test Pack | QA |
| `test-automation` | Automated tests (written into the project repo) | Test code in project repo | QA Automation / Developers |
| `devops` | CI/CD, deployment, release readiness | Release Readiness Pack | DevOps |
| `security-review` | Security review of code/arch/config | Security Review Report | Security Owner / Tech Lead |
| `documentation` | Project docs, ADRs, business-rule recovery, modernization | Business Rule Recovery, Modernization Roadmap, project docs | Developers / BA / PM |
| `support-incident` | Triage support tickets & incidents | Triage notes in delivery/ | Support / Developers / PM |
| `retrospective-insights` | Analyze Sprint patterns & improvements | Retrospective Insights Pack | Scrum Master / Scrum Team |

Invoke an agent with the Task/Agent tool (`subagent_type` = agent name), or let Claude auto-route via the agent's `description`. Each agent file lists the exact template(s) it fills.

## Templates (output packs)

- **Shared** (both scenarios): `templates/shared/`
- **Greenfield**: `templates/greenfield/`
- **Inherited**: `templates/inherited/`

Copy the relevant template into `src/<engagement>/delivery/` (or the project repo for durable docs) and fill it.

## Governance guardrails (always apply)

1. AI cannot approve its own work — humans approve.
2. AI-generated code requires human review before merge.
3. AI-generated requirements require PO/BA validation.
4. AI-generated tests require QA/developer validation.
5. AI-generated client communication requires PM/PO review.
6. Never paste secrets, credentials, or production data into AI tools.
7. Every AI output separates: **Observed facts · Assumptions · Risks · Recommendations · Open questions.**

Full rules: `playbook/governance.md`.

## Definition of Ready / Done

- **Ready:** business goal, user role, expected behavior, acceptance criteria, dependencies, edge cases, risks, test scenarios, and open questions are clear. Full list: `playbook/definition-of-ready.md`.
- **Done:** acceptance criteria pass, code implemented, tests added/updated, AI self-review + human review done, QA/security checked where needed, docs updated, no critical regression risk, increment usable. Full list: `playbook/definition-of-done.md`.

## Path convention

`<engagement>` = a short slug for the client/project (e.g. `acme-portal`). Everything for that engagement lives in `src/<engagement>/`.
```

- [ ] **Step 2: Run verifier — `CLAUDE.md` exists check passes**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `exists: CLAUDE.md` PASSES.

- [ ] **Step 3: Commit**

```powershell
git add CLAUDE.md
git commit -m "Add CLAUDE.md operating manual (agent + template index, governance, DoR/DoD)"
```

---

## Task 8: `README.md` — how to start an engagement

**Files:** Modify `README.md` (currently just `# AI-SDLC-PLAYBOOK`).

- [ ] **Step 1: Replace `README.md` content**

```markdown
# AI-SDLC Playbook

A reusable, pristine base for running **AI-assisted Scrum delivery** on client engagements — for both **greenfield** (new) and **inherited** (existing/takeover) projects. Clone it, drop in a client request, and you immediately have specialized Claude Code agents + a full library of output templates wired to the delivery model.

## What's in here

| Path | What it is |
|------|-----------|
| `CLAUDE.md` | Operating manual, auto-loaded by Claude Code |
| `playbook/` | The full AI-Assisted Scrum Delivery Model (canonical reference) |
| `.claude/agents/` | 12 specialized subagents |
| `templates/` | 30 output "packs" (shared / greenfield / inherited) |
| `src/` | **Gitignored** workspace for all project-specific data |
| `scripts/verify-scaffold.ps1` | Structural self-check for the scaffold |
| `docs/superpowers/` | The design spec and this implementation plan |

## Start a new engagement

1. Get a clean copy of this repo (clone, or "Use this template" on GitHub).
2. Create the workspace:
   ```powershell
   New-Item -ItemType Directory -Force src/<engagement>/request, src/<engagement>/delivery
   ```
3. Drop the client request into `src/<engagement>/request/`.
4. Open Claude Code here and follow the workflow in `CLAUDE.md`.
5. Clone the project's own repo into `src/<engagement>/<project-repo>/`.

Everything under `src/` is gitignored, so this base never accumulates client data and can be reused across many projects.

## Reusing across projects

Either re-clone per engagement, or keep multiple engagements side-by-side under `src/<engagement-a>/`, `src/<engagement-b>/`, … — the playbook tooling is shared, the data stays isolated.

## Verify the scaffold

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
```

## Deferred (future passes)

Slash commands that orchestrate the agents, reusable skills, and plugin packaging are intentionally not included yet — see `docs/superpowers/specs/2026-06-10-ai-sdlc-playbook-scaffold-design.md`.
```

- [ ] **Step 2: Commit**

```powershell
git add README.md
git commit -m "Rewrite README as engagement quick-start guide"
```

---

## Task 9: Final verification & branch wrap-up

- [ ] **Step 1: Full verifier run — everything green**

Run: `powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1`
Expected: `ALL CHECKS PASSED`, exit code 0.

- [ ] **Step 2: Confirm pristine-repo invariant**

Run:
```powershell
git status --porcelain
git ls-files src/
```
Expected: working tree clean; `git ls-files src/` lists ONLY `src/README.md`.

- [ ] **Step 3: Spot-check link integrity**

Run:
```powershell
Get-ChildItem .claude/agents/*.md | ForEach-Object {
  $c = Get-Content $_ -Raw
  [regex]::Matches($c,'templates/[^\s`)]+\.md') | ForEach-Object {
    if (-not (Test-Path $_.Value)) { Write-Host "BROKEN LINK in $($_.Value)" -ForegroundColor Red }
  }
}
```
Expected: no `BROKEN LINK` output.

- [ ] **Step 4: Report completion**

Summarize: files created, verifier result, and that `main` can now fast-forward / PR from `playbook-scaffold`. Do NOT merge or push unless the user asks.

---

## Self-review (completed by plan author)

**Spec coverage:** D1 native CC → Tasks 6,7. D2 scaffold-only → whole plan; commands/skills deferred (README §Deferred). D3 operating-manual → Task 7. D4 pristine repo → Task 1 `.gitignore` + Task 9 invariant check. D5 project data in `src/` → Task 1 `src/README.md`. D6 gitignored clone → `.gitignore` + `src/README.md`. D7 docx→md + delete → Task 2. D8 artifact location split → encoded in agent Outputs (Task 6) + `src/README.md` + CLAUDE.md. Repo structure §4 → Tasks 1–8. 12 agents §8 → Task 6. 30 templates §9 → Tasks 3–5 (10+6+14=30). Verification §11 → Task 1 script + Task 9. Build order §12 → Task sequence.

**Placeholder scan:** No "TBD/TODO/handle appropriately". Heading lists are concrete and exhaustive; two fully-rendered reference files (project-request-brief, product-discovery) anchor the format; `<engagement>`/`<project-repo>`/`<name>` are intentional path variables, not gaps.

**Type/name consistency:** Agent names, template filenames, and `produced-by` values are identical across the verifier (Task 1), the template data (Tasks 3–5), the agent data (Task 6), and the CLAUDE.md index (Task 7). Template count asserted == 30. `code-review` tools exclude `Edit` consistently with its "report-only" rule.
