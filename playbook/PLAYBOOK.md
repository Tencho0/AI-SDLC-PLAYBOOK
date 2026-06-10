# AI-Assisted Scrum Delivery Model

_For Greenfield Projects and Inherited / Existing Projects in a Software Outsourcing Company_

## Executive Summary

This document defines a Scrum-compatible model for introducing AI across the full software delivery process in a software outsourcing company.

The company follows Scrum, so AI should not be introduced as a separate delivery methodology. Instead, AI should be embedded into existing Scrum events, artifacts, roles, and engineering practices.

The goal is to create an AI-assisted Scrum delivery model where AI helps teams:

- clarify client goals faster;
- create and refine Product Backlog items;
- improve Sprint Planning;
- support Developers during the Sprint;
- improve code review and QA;
- prepare better Sprint Reviews;
- extract insights from Retrospectives;
- improve documentation and knowledge retention;
- support both greenfield and inherited projects.

The model covers two main scenarios:

- **Greenfield Projects** — building a new project from scratch.
- **Inherited / Existing Projects** — taking over, stabilizing, maintaining, and evolving an existing system.

The core principle is:

> We still follow Scrum. AI supports Scrum delivery by improving clarity, quality, speed, and predictability, while humans remain accountable for decisions and outcomes.

## 1. AI-Assisted Scrum Vision

### 1.1 Vision

The company should operate with an AI-assisted Scrum delivery model where AI is integrated into:

- Product Backlog creation;
- Backlog Refinement;
- Sprint Planning;
- Sprint execution;
- code review;
- QA and testing;
- Sprint Review;
- Sprint Retrospective;
- release readiness;
- documentation;
- support and maintenance.

AI should help the Scrum Team make better decisions, but it should not replace the Scrum Team.

### 1.2 Main Objectives

The AI-assisted Scrum model should help the company achieve:

**Faster understanding**

AI helps the team quickly understand:

- client requests;
- business goals;
- existing documentation;
- meeting notes;
- codebases;
- risks;
- dependencies.

**Better Product Backlog quality**

AI helps create better backlog items with:

- clearer descriptions;
- stronger acceptance criteria;
- edge cases;
- risks;
- dependencies;
- test scenarios.

**Stronger Sprint Planning**

AI helps the Scrum Team prepare for Sprint Planning by identifying:

- unclear backlog items;
- dependencies;
- capacity risks;
- technical risks;
- test needs;
- Sprint Goal options.

**Better Sprint execution**

AI helps Developers and QA during the Sprint by assisting with:

- implementation planning;
- code understanding;
- code generation;
- debugging;
- refactoring;
- test generation;
- PR review;
- documentation updates.

**Better Sprint Review and Retrospective**

AI helps the team:

- prepare demo summaries;
- summarize completed work;
- capture stakeholder feedback;
- convert feedback into Product Backlog items;
- analyze recurring blockers;
- identify process improvements.

**Better knowledge retention**

AI helps create and maintain:

- README files;
- CLAUDE.md;
- architecture documentation;
- business rules;
- API documentation;
- testing guides;
- deployment runbooks;
- support knowledge bases.

## 2. Scrum-Compatible AI Principles

### Principle 1: AI supports Scrum, it does not replace Scrum

AI should not create a parallel process outside Scrum.

Instead, it should support:

- Product Backlog;
- Sprint Backlog;
- Increment;
- Product Goal;
- Sprint Goal;
- Definition of Done;
- Sprint Planning;
- Daily Scrum;
- Sprint Review;
- Sprint Retrospective;
- Backlog Refinement.

### Principle 2: Human accountability remains unchanged

AI can assist, but humans still own the work.

| Area | Human owner |
|------|-------------|
| Product Backlog priority | Product Owner |
| Requirements clarity | Product Owner / BA |
| Sprint planning decisions | Scrum Team |
| Technical implementation | Developers |
| Architecture decisions | Architect / Tech Lead |
| Testing quality | QA / Developers |
| Security decisions | Security owner / Tech Lead |
| Delivery communication | PM / Scrum Master / Delivery Manager |
| Client approval | Product Owner / Client stakeholders |

### Principle 3: AI outputs must become reviewable Scrum artifacts

AI should produce artifacts that can be reviewed by the team.

Examples:

- Product Backlog item draft;
- acceptance criteria;
- test scenarios;
- Sprint Goal options;
- implementation plan;
- PR review report;
- QA test pack;
- Sprint Review summary;
- Retrospective insights;
- documentation updates;
- risk register.

### Principle 4: AI should improve transparency

Scrum depends on transparency, inspection, and adaptation.

AI should make work more transparent by showing:

- unclear requirements;
- hidden assumptions;
- risks;
- dependencies;
- missing tests;
- documentation gaps;
- delivery blockers;
- technical debt.

### Principle 5: AI should be embedded into Definition of Ready and Definition of Done

AI should help check whether work is ready to start and complete enough to finish.

**AI-assisted Definition of Ready**

A Product Backlog item is ready for Sprint Planning when:

- the business goal is clear;
- the user story is understandable;
- acceptance criteria exist;
- dependencies are known;
- risks are listed;
- test scenarios are considered;
- open questions are identified;
- the team understands the expected outcome.

**AI-assisted Definition of Done**

A Product Backlog item is done when:

- implementation is complete;
- acceptance criteria are satisfied;
- tests are added or updated;
- AI-assisted self-review is completed;
- human code review is completed;
- QA validation is completed where needed;
- documentation is updated where needed;
- no unresolved critical risks remain.

## 3. AI Agents Used in the Scrum Model

The company should not use one generic AI assistant for everything. It should define specialized AI agents or repeatable AI workflows.

### 3.1 Core AI Agents

| Agent | Purpose | Main users |
|-------|---------|------------|
| Product Discovery Agent | Understands client goals, problems, and initial scope | PO, BA, PM, Sales |
| Product Backlog Agent | Creates and refines epics, stories, and acceptance criteria | PO, BA, Scrum Team |
| Scrum Planning Agent | Supports Sprint Planning, Sprint Goal drafting, and risk analysis | Scrum Master, PM, Scrum Team |
| Implementation Agent | Helps Developers implement stories, fix bugs, and refactor | Developers |
| Code Review Agent | Performs first-pass PR review | Developers, Tech Lead |
| QA Test Design Agent | Generates manual test cases, edge cases, and regression checks | QA, BA, Developers |
| Test Automation Agent | Helps create automated tests | QA Automation, Developers |
| DevOps Agent | Supports CI/CD, deployments, environments, and logs | DevOps, Developers |
| Security Review Agent | Reviews code, architecture, and configuration for security risks | Security, Tech Lead |
| Documentation Agent | Creates and updates project documentation | Developers, BA, QA, PM |
| Support / Incident Agent | Helps triage support tickets and incidents | Support, Developers, PM |
| Retrospective Insights Agent | Analyzes Sprint patterns and improvement opportunities | Scrum Master, Scrum Team |

## 4. Shared AI-Assisted Scrum Flow

This is the general flow used for both greenfield and inherited projects:

Project Request
→ AI-assisted discovery / assessment
→ Product Goal definition
→ Initial Product Backlog creation
→ Backlog Refinement
→ Sprint Planning
→ Sprint execution
→ AI-assisted development, QA, and PR review
→ Sprint Review
→ Product Backlog adaptation
→ Sprint Retrospective
→ Improvement actions
→ Repeat
→ Release / support / evolution

The difference between greenfield and inherited projects is the content of the Product Backlog and the type of AI analysis needed.

## 5. Scenario A: Greenfield Projects Following Scrum

### 5.1 Greenfield Objective

For greenfield projects, AI should help the Scrum Team create clarity and structure from the beginning.

The main goal is:

> Use AI to turn a client idea into a clear Product Goal, strong Product Backlog, clean technical foundation, and predictable Sprint-based delivery.

### 5.2 Greenfield Scrum Flow Overview

Client Project Request
→ AI-assisted opportunity analysis
→ AI-assisted discovery preparation
→ Discovery meetings
→ AI meeting summarization and analysis
→ Product Goal definition
→ Initial Product Backlog creation
→ Initial architecture and technical foundation
→ Backlog Refinement
→ Sprint Planning
→ Sprint execution
→ AI-assisted development and testing
→ AI-assisted PR review
→ Sprint Review
→ Product Backlog adaptation
→ Sprint Retrospective
→ Release readiness
→ Maintenance and continuous improvement

### 5.3 Greenfield Flow Step-by-Step

#### Step 1: Client Project Request

**Goal**

Understand the client's request and decide whether to proceed.

**Roles involved**

- Sales
- Product Owner / BA
- PM / Scrum Master
- Solution Architect
- Delivery Manager

**AI usage**

Use AI to:

- summarize the client request;
- identify the business problem;
- identify the expected outcome;
- detect missing information;
- classify the project type;
- identify early risks;
- prepare clarification questions.

**AI output**

Project Request Brief

1. Client summary
2. Business problem
3. Desired outcome
4. Known requirements
5. Unknowns
6. Initial assumptions
7. Initial risks
8. Suggested clarification questions
9. Recommendation: proceed / clarify / decline

**Human review**

- Sales validates client context.
- Delivery Manager validates commercial fit.
- Architect validates technical concerns.
- PO/BA validates business understanding.

**Scrum connection**

This step happens before or during early Product Goal discovery. It prepares the team to define the initial product direction.

#### Step 2: AI-Assisted Discovery Preparation

**Goal**

Prepare for the discovery workshop with the client.

**Roles involved**

- PO / BA
- PM / Scrum Master
- Architect
- UX/UI Designer
- QA
- Sales

**AI usage**

Use AI to:

- define discovery goals;
- create a meeting agenda;
- generate stakeholder questions;
- prepare business questions;
- prepare technical questions;
- prepare UX questions;
- prepare security/compliance questions;
- identify assumptions to validate.

**AI output**

Discovery Workshop Plan

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

**Human review**

- BA validates business questions.
- Architect validates technical questions.
- PM validates meeting structure.
- QA adds early testability questions.

**Scrum connection**

This supports Product Goal discovery and Product Backlog creation.

#### Step 3: Discovery Meetings and AI Meeting Analysis

**Goal**

Understand client goals, workflows, users, constraints, and success criteria.

**Roles involved**

- PO / BA
- PM / Scrum Master
- Architect
- Client stakeholders
- UX/UI Designer
- QA

**AI usage**

After each meeting, use AI to:

- summarize the discussion;
- extract business goals;
- identify user roles;
- identify workflows;
- extract decisions;
- list open questions;
- detect contradictions;
- identify risks;
- identify assumptions;
- suggest next steps.

**AI output**

Discovery Meeting Summary

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

**Human review**

- BA validates requirement interpretation.
- PM validates action items.
- Architect validates technical implications.
- Client validates key assumptions.

**Scrum connection**

The output supports the Product Goal and initial Product Backlog.

#### Step 4: Product Goal Definition

**Goal**

Define the overall product objective that guides the Product Backlog.

**Roles involved**

- Product Owner
- BA
- PM / Scrum Master
- Client stakeholders
- Architect
- Delivery Manager

**AI usage**

Use AI to:

- synthesize discovery findings;
- propose Product Goal options;
- connect business goals with product outcomes;
- identify measurable success criteria;
- identify MVP boundaries.

**AI output**

Product Goal Draft

1. Product vision
2. Business outcome
3. Target users
4. Core value proposition
5. Success criteria
6. MVP boundary
7. Future expansion areas
8. Open strategic questions

**Human review**

- Product Owner owns the Product Goal.
- Client validates business direction.
- Delivery Manager validates feasibility.
- Architect validates technical implications.

**Scrum connection**

This becomes the commitment connected to the Product Backlog.

#### Step 5: Initial Product Backlog Creation

**Goal**

Convert discovery into an initial Product Backlog.

**Roles involved**

- Product Owner
- BA
- QA
- Developers
- Architect
- PM / Scrum Master

**AI usage**

Use AI to:

- create epics;
- create user stories;
- generate acceptance criteria;
- identify dependencies;
- identify risks;
- suggest story splitting;
- identify MVP vs later scope;
- generate early test scenarios.

**AI output**

Initial Product Backlog Pack

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

**Human review**

- Product Owner owns backlog prioritization.
- BA validates business meaning.
- QA validates testability.
- Developers validate technical feasibility.
- Architect validates architectural implications.

**Scrum connection**

This creates the initial Product Backlog.

#### Step 6: Technical Foundation and Architecture Planning

**Goal**

Define the technical approach before major Sprint execution begins.

**Roles involved**

- Architect
- Tech Lead
- Developers
- DevOps
- QA Automation
- Security Owner

**AI usage**

Use AI to:

- compare architecture options;
- generate ADRs;
- propose module boundaries;
- propose API design;
- propose data model;
- define security baseline;
- define testing strategy;
- define deployment strategy;
- create initial CLAUDE.md;
- prepare repo setup guidance.

**AI output**

Architecture and Technical Foundation Pack

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

**Human review**

- Architect owns final design.
- Tech Lead validates implementation practicality.
- DevOps validates CI/CD approach.
- Security owner validates security decisions.
- QA validates test strategy.

**Scrum connection**

Technical foundation items become Product Backlog items. The team should avoid creating a large upfront design phase. Architecture should support near-term Sprint delivery and evolve through the backlog.

#### Step 7: Backlog Refinement

**Goal**

Prepare Product Backlog items for future Sprints.

**Roles involved**

- Product Owner
- BA
- Developers
- QA
- Architect / Tech Lead
- Scrum Master / PM

**AI usage**

Use AI to:

- check story clarity;
- generate or improve acceptance criteria;
- identify edge cases;
- identify dependencies;
- identify risks;
- suggest story splitting;
- suggest test scenarios;
- identify open questions.

**AI output**

Refined Story Pack

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

**Human review**

- Product Owner confirms priority and business value.
- BA validates requirement clarity.
- Developers validate technical feasibility.
- QA validates testability.

**Scrum connection**

This supports ongoing Product Backlog Refinement.

#### Step 8: Sprint Planning

**Goal**

Select Product Backlog items for the Sprint and define a Sprint Goal.

**Roles involved**

- Product Owner
- Developers
- Scrum Master
- QA
- Tech Lead
- Architect if needed

**AI usage**

Use AI to:

- summarize candidate backlog items;
- check readiness;
- identify dependencies;
- identify delivery risks;
- suggest Sprint Goal options;
- suggest task breakdown;
- identify testing and DevOps work;
- identify capacity concerns.

**AI output**

Sprint Planning Support Pack

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

**Human review**

- Product Owner explains priority.
- Developers select work they believe can be completed.
- Scrum Master facilitates.
- QA confirms testing needs.
- Team agrees on Sprint Goal.

**Scrum connection**

This supports Sprint Planning and the creation of the Sprint Backlog.

#### Step 9: Sprint Execution — AI-Assisted Development

**Goal**

Implement Sprint Backlog items and create a usable Increment.

**Roles involved**

- Developers
- QA
- Tech Lead
- Architect when needed
- DevOps when needed

**AI usage**

Use AI to:

- analyze a ticket before coding;
- identify affected files;
- propose implementation plan;
- generate code in small steps;
- explain existing code;
- generate tests;
- debug errors;
- refactor;
- update documentation;
- prepare PR summary.

**AI output**

Implementation Pack

1. Ticket understanding
2. Affected files/modules
3. Implementation plan
4. Code changes
5. Tests added/updated
6. Commands run
7. Risks
8. Documentation updates
9. PR summary

**Human review**

- Developer owns the implementation.
- Tech Lead reviews complex changes.
- QA validates behavior.
- Architect reviews architectural impact when needed.

**Scrum connection**

This happens during the Sprint and contributes to the Increment.

#### Step 10: Daily Scrum Support

**Goal**

Help Developers inspect progress toward the Sprint Goal and adapt the plan.

**Roles involved**

- Developers
- Scrum Master
- QA when involved in Sprint work

**AI usage**

Use AI to:

- summarize blockers;
- identify stale items;
- detect Sprint Goal risk;
- summarize what changed since yesterday;
- suggest follow-up actions;
- identify dependencies between active items.

**AI output**

Daily Scrum Support Summary

1. Progress toward Sprint Goal
2. Blockers
3. At-risk Sprint Backlog items
4. Dependencies
5. Suggested follow-ups
6. Items needing team discussion

**Human review**

- Developers decide how to adapt the plan.
- Scrum Master helps remove blockers.
- AI should not be used for micromanagement.

**Scrum connection**

This supports Daily Scrum without replacing team discussion.

#### Step 11: AI-Assisted Code Review

**Goal**

Improve PR quality before human review and merge.

**Roles involved**

- Developers
- Tech Lead
- QA
- Security Owner when needed

**AI usage**

Use AI to:

- summarize PR changes;
- compare implementation with acceptance criteria;
- identify missing tests;
- detect risky code;
- check error handling;
- check security concerns;
- check architecture consistency;
- identify documentation needs;
- generate QA regression notes.

**AI output**

AI PR Review Report

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

**Human review**

- Human reviewer approves or rejects PR.
- AI cannot approve its own work.
- Tech Lead owns final technical quality.

**Scrum connection**

This supports the Definition of Done.

#### Step 12: QA and Testing During the Sprint

**Goal**

Validate that the Sprint Backlog item meets acceptance criteria and does not introduce defects.

**Roles involved**

- QA
- Developers
- BA
- Product Owner
- QA Automation

**AI usage**

Use AI to:

- generate test cases from acceptance criteria;
- generate negative test cases;
- identify edge cases;
- create regression checklist;
- suggest automation candidates;
- generate API/UI test drafts;
- analyze failed tests;
- draft bug reports.

**AI output**

QA Test Pack

1. Positive test cases
2. Negative test cases
3. Edge cases
4. Permission tests
5. Regression checks
6. Automation candidates
7. Test data
8. Bug report drafts
9. QA risk notes

**Human review**

- QA owns test validation.
- Developers own automated test correctness.
- Product Owner validates business acceptance where needed.

**Scrum connection**

This supports the Increment and Definition of Done.

#### Step 13: Sprint Review

**Goal**

Inspect the Increment with stakeholders and adapt the Product Backlog.

**Roles involved**

- Scrum Team
- Product Owner
- Client stakeholders
- PM / Delivery Manager
- QA
- Developers

**AI usage**

Use AI to:

- prepare demo script;
- summarize completed work;
- map completed work to Sprint Goal;
- prepare stakeholder-friendly release notes;
- capture feedback;
- extract new backlog items;
- summarize decisions;
- identify scope changes.

**AI output**

Sprint Review Pack

1. Sprint Goal summary
2. Completed Product Backlog items
3. Demo flow
4. Known limitations
5. Stakeholder feedback
6. Decisions made
7. New backlog items
8. Scope changes
9. Follow-up actions

**Human review**

- Product Owner updates Product Backlog.
- Stakeholders provide feedback.
- Scrum Team discusses next adaptations.

**Scrum connection**

This supports Sprint Review and Product Backlog adaptation.

#### Step 14: Sprint Retrospective

**Goal**

Improve the team's quality and effectiveness.

**Roles involved**

- Scrum Team
- Scrum Master
- PM if acting as Scrum facilitator
- Tech Lead
- QA

**AI usage**

Use AI to:

- analyze Sprint metrics;
- summarize recurring blockers;
- group retrospective feedback into themes;
- identify delays;
- compare planned vs completed work;
- suggest improvement experiments;
- track previous retrospective action items.

**AI output**

Retrospective Insights Pack

1. What went well
2. What did not go well
3. Recurring blockers
4. Process issues
5. Quality issues
6. Communication issues
7. AI usage observations
8. Suggested improvements
9. Action items for next Sprint

**Human review**

- Scrum Team chooses improvements.
- Scrum Master tracks action items.
- AI does not replace the retrospective conversation.

**Scrum connection**

This supports Sprint Retrospective.

#### Step 15: Release Readiness and Handover

**Goal**

Prepare the Increment for release, deployment, and support.

**Roles involved**

- Product Owner
- PM
- Developers
- QA
- DevOps
- Support
- Tech Lead

**AI usage**

Use AI to:

- summarize release scope;
- generate release notes;
- check known issues;
- generate deployment checklist;
- prepare rollback plan;
- prepare support notes;
- update documentation;
- draft client communication.

**AI output**

Release Readiness Pack

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

**Human review**

- Product Owner confirms release value.
- QA confirms quality.
- DevOps approves deployment.
- PM approves client communication.

**Scrum connection**

This supports delivering a usable Increment.

## 6. Scenario B: Inherited / Existing Projects Following Scrum

### 6.1 Inherited Project Objective

For inherited projects, AI should help the Scrum Team understand the existing system before changing it.

The main goal is:

> Use AI to convert an unknown existing system into a manageable Product Backlog of stabilization, documentation, testing, support, modernization, and new feature work.

The key rule is:

> Understand first, stabilize second, change third.

### 6.2 Inherited Scrum Flow Overview

Client Takeover Request
→ AI-assisted takeover analysis
→ Access and information collection
→ AI-assisted system assessment
→ Product Goal / Stabilization Goal definition
→ Initial Stabilization Product Backlog
→ Backlog Refinement
→ Sprint Planning
→ Sprint execution with codebase understanding
→ Regression-focused QA
→ AI-assisted PR review
→ Sprint Review
→ Product Backlog adaptation
→ Sprint Retrospective
→ Modernization roadmap
→ Ongoing support and evolution

### 6.3 Inherited Flow Step-by-Step

#### Step 1: Client Takeover Request

**Goal**

Understand why the client wants to transfer or continue an existing project.

**Roles involved**

- Sales
- Product Owner / BA
- PM / Scrum Master
- Solution Architect
- Tech Lead
- Delivery Manager

**AI usage**

Use AI to:

- summarize the takeover request;
- identify current pain points;
- identify urgency;
- classify project condition;
- identify commercial risks;
- identify technical unknowns;
- generate takeover questions;
- prepare initial assessment approach.

**AI output**

Takeover Request Brief

1. System summary
2. Why client needs help
3. Current pain points
4. Business criticality
5. Known urgent issues
6. Unknowns
7. Initial risks
8. Required access
9. Suggested assessment approach

**Human review**

- Sales validates client relationship.
- Delivery Manager validates commercial risk.
- Architect validates technical risk.
- PM validates communication plan.

**Scrum connection**

This prepares the initial Product Goal or Stabilization Goal.

#### Step 2: Access and Information Collection

**Goal**

Collect enough information to assess the existing system.

**Roles involved**

- PM / Scrum Master
- Tech Lead
- Architect
- DevOps
- BA
- QA
- Security Owner
- Client stakeholders

**AI usage**

Use AI to:

- create an access checklist;
- compare received materials against required materials;
- identify missing documentation;
- identify access blockers;
- classify missing information by risk;
- prepare follow-up request for the client.

**AI output**

Access and Information Checklist

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

**Human review**

- PM coordinates access.
- Tech Lead validates repository access.
- DevOps validates environment access.
- Security validates credential handling.

**Scrum connection**

Access collection creates backlog items for assessment and stabilization.

#### Step 3: AI-Assisted System Assessment

**Goal**

Create a first understanding of the system.

**Roles involved**

- Tech Lead
- Architect
- Developers
- DevOps
- QA
- PM

**AI usage**

Use AI to:

- summarize repository structure;
- identify tech stack;
- identify main modules;
- identify entry points;
- identify external integrations;
- identify database access patterns;
- identify build/run process;
- identify missing documentation;
- identify obvious risks.

**AI output**

Initial System Assessment

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

**Human review**

- Tech Lead validates technical accuracy.
- Architect validates architectural interpretation.
- Developers verify build/run process.
- PM converts risks into client communication.

**Scrum connection**

Assessment findings become Product Backlog items.

#### Step 4: Product Goal / Stabilization Goal Definition

**Goal**

Define what the team should achieve first with the inherited project.

**Roles involved**

- Product Owner
- PM / Scrum Master
- Client stakeholders
- Tech Lead
- Architect
- QA
- Support

**AI usage**

Use AI to:

- synthesize system assessment;
- identify first business priority;
- define stabilization objective;
- separate urgent fixes from long-term modernization;
- propose Product Goal options;
- define success criteria.

**AI output**

Inherited Project Goal Draft

1. Current state summary
2. Business priority
3. Stabilization goal
4. Success criteria
5. Urgent issues
6. Short-term focus
7. Long-term modernization direction
8. Key risks

**Human review**

- Product Owner owns the Product Goal.
- Client validates business priority.
- Tech Lead validates technical feasibility.
- QA validates quality focus.

**Scrum connection**

This becomes the guiding goal for the Product Backlog.

#### Step 5: Business Rule Recovery

**Goal**

Recover how the system actually works.

**Roles involved**

- BA
- Developers
- QA
- Support
- Product Owner
- Client stakeholders

**AI usage**

Use AI to:

- extract business rules from code;
- summarize historical tickets;
- identify user roles;
- identify permissions;
- reconstruct workflows;
- compare documentation with implementation;
- detect unclear behavior;
- generate client validation questions;
- suggest regression test cases.

**AI output**

Business Rule Recovery Report

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

**Human review**

- BA validates business meaning.
- Developers validate code interpretation.
- QA validates test scenarios.
- Client confirms unclear behavior.

**Scrum connection**

Recovered rules improve Product Backlog quality and support future refinement.

#### Step 6: Architecture and Codebase Mapping

**Goal**

Understand system structure, dependencies, and risky areas.

**Roles involved**

- Architect
- Tech Lead
- Developers
- DevOps
- QA

**AI usage**

Use AI to:

- map modules;
- identify dependencies;
- trace critical flows;
- identify coupling;
- identify anti-patterns;
- map database access;
- map external integrations;
- identify fragile areas;
- identify modernization opportunities.

**AI output**

Codebase and Architecture Map

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

**Human review**

- Architect approves architecture assessment.
- Tech Lead validates codebase interpretation.
- DevOps validates deployment findings.
- QA uses critical flows for regression planning.

**Scrum connection**

This creates technical Product Backlog items and supports Sprint Planning.

#### Step 7: Initial Stabilization Product Backlog Creation

**Goal**

Create a Product Backlog focused on making the inherited system manageable.

**Roles involved**

- Product Owner
- BA
- PM / Scrum Master
- Tech Lead
- Developers
- QA
- DevOps
- Security Owner
- Support

**AI usage**

Use AI to:

- convert assessment findings into backlog items;
- create stabilization epics;
- prioritize risks;
- create documentation tasks;
- create testing tasks;
- create DevOps tasks;
- create security tasks;
- create urgent bug-fix items;
- identify modernization candidates.

**AI output**

Stabilization Product Backlog

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

**Human review**

- Product Owner owns ordering.
- Tech Lead validates technical priority.
- QA validates testing priority.
- DevOps validates operational priority.
- Client validates business priority.

**Scrum connection**

This becomes the initial Product Backlog for inherited project delivery.

#### Step 8: Backlog Refinement for Inherited Projects

**Goal**

Prepare inherited project items for safe Sprint execution.

**Roles involved**

- Product Owner
- BA
- Developers
- QA
- Tech Lead
- DevOps
- Support

**AI usage**

Use AI to:

- clarify bug reports;
- identify affected modules;
- recover expected behavior;
- identify regression risk;
- suggest characterization tests;
- define acceptance criteria;
- define validation steps;
- identify client questions.

**AI output**

Inherited Refined Story Pack

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

**Human review**

- Product Owner confirms priority.
- BA validates business behavior.
- Developers validate technical impact.
- QA validates regression coverage.

**Scrum connection**

This supports Product Backlog Refinement with higher focus on regression risk.

#### Step 9: Sprint Planning for Inherited Projects

**Goal**

Select work for the Sprint based on business value, stabilization value, and risk reduction.

**Roles involved**

- Product Owner
- Developers
- Scrum Master
- QA
- Tech Lead
- DevOps
- Support if needed

**AI usage**

Use AI to:

- summarize candidate backlog items;
- identify risk-reduction value;
- identify dependencies;
- identify regression testing effort;
- suggest Sprint Goal options;
- identify unknowns;
- suggest safe sequencing.

**AI output**

Inherited Sprint Planning Support Pack

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

**Human review**

- Product Owner explains priority.
- Developers select work.
- QA confirms testing effort.
- Scrum Master facilitates.
- Tech Lead validates risk.

**Scrum connection**

This supports Sprint Planning and Sprint Backlog creation.

#### Step 10: Sprint Execution — Safe Development and Bug Fixing

**Goal**

Make changes without breaking hidden legacy behavior.

**Roles involved**

- Developers
- QA
- Tech Lead
- BA
- Support
- Architect when needed

**AI usage**

Use AI to:

- explain the affected module;
- trace the bug;
- identify affected files;
- identify business rules involved;
- identify regression risks;
- generate implementation plan;
- generate characterization tests;
- assist with small code changes;
- update documentation;
- prepare PR risk notes.

**AI output**

Safe Change Pack

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

**Human review**

- Developer owns the fix.
- Tech Lead reviews impact.
- QA validates regression.
- BA/client validates business behavior when needed.

**Scrum connection**

This supports Sprint execution and Increment creation.

#### Step 11: Regression-Focused QA

**Goal**

Protect existing behavior while changing the system.

**Roles involved**

- QA
- Developers
- QA Automation
- BA
- Support

**AI usage**

Use AI to:

- generate regression test cases;
- identify critical flows;
- create smoke test checklist;
- generate characterization tests;
- connect historical bugs to tests;
- identify automation candidates;
- analyze test gaps.

**AI output**

Regression Test Pack

1. Critical business flows
2. High-risk modules
3. Historical bug scenarios
4. Manual regression tests
5. Automated test candidates
6. Characterization tests
7. Smoke test checklist
8. Test data requirements
9. Release validation checklist

**Human review**

- QA owns regression testing.
- Developers validate automated tests.
- BA validates business coverage.
- Support validates recurring issue coverage.

**Scrum connection**

This strengthens Definition of Done for inherited projects.

#### Step 12: Sprint Review for Inherited Projects

**Goal**

Show progress not only in features, but also in stabilization and risk reduction.

**Roles involved**

- Scrum Team
- Product Owner
- Client stakeholders
- PM / Delivery Manager
- Support

**AI usage**

Use AI to:

- summarize completed fixes;
- summarize stabilization work;
- show risk reduction;
- explain known remaining risks;
- prepare demo flow;
- capture stakeholder feedback;
- create new backlog items.

**AI output**

Inherited Sprint Review Pack

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

**Human review**

- Product Owner updates Product Backlog.
- Client validates business progress.
- Scrum Team adapts next steps.

**Scrum connection**

This supports Sprint Review and Product Backlog adaptation.

#### Step 13: Sprint Retrospective for Inherited Projects

**Goal**

Improve how the team handles unknown systems, legacy risk, and client communication.

**Roles involved**

- Scrum Team
- Scrum Master
- PM
- Tech Lead
- QA

**AI usage**

Use AI to:

- analyze recurring blockers;
- identify knowledge gaps;
- identify repeated legacy issues;
- summarize estimation misses;
- identify quality risks;
- suggest improvement actions;
- track previous retro actions.

**AI output**

Inherited Retrospective Insights Pack

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

**Human review**

- Scrum Team chooses improvements.
- Scrum Master tracks actions.
- Tech Lead owns technical process improvements.

**Scrum connection**

This supports Sprint Retrospective.

#### Step 14: Modernization Roadmap

**Goal**

Move from reactive maintenance to controlled long-term evolution.

**Roles involved**

- Product Owner
- Architect
- Tech Lead
- PM
- Developers
- QA
- DevOps
- Client stakeholders

**AI usage**

Use AI to:

- analyze technical debt;
- group modernization opportunities;
- compare refactor vs rewrite options;
- estimate risk and value;
- create phased roadmap;
- generate ADRs;
- identify backlog items for future Sprints.

**AI output**

Modernization Roadmap

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

**Human review**

- Product Owner aligns with business value.
- Architect owns technical direction.
- Client approves investment.
- Scrum Team pulls roadmap items into future Sprints.

**Scrum connection**

Modernization work enters the Product Backlog and is delivered through Sprints.

## 7. Scrum Event Mapping

### 7.1 Backlog Refinement

AI supports:

- story clarification;
- acceptance criteria generation;
- edge-case discovery;
- risk detection;
- story splitting;
- test scenario generation;
- dependency analysis.

Output: Refined Story Pack

Human owner: Product Owner / BA.

### 7.2 Sprint Planning

AI supports:

- Sprint Goal options;
- readiness check;
- dependency check;
- capacity risk analysis;
- task breakdown;
- test effort identification.

Output: Sprint Planning Support Pack

Human owner: Scrum Team.

### 7.3 Daily Scrum

AI supports:

- blocker summary;
- Sprint Goal risk detection;
- stale item detection;
- dependency reminders.

Output: Daily Scrum Support Summary

Human owner: Developers.

### 7.4 Sprint Execution

AI supports:

- coding;
- debugging;
- refactoring;
- test generation;
- documentation;
- PR summaries.

Output: Implementation Pack

Human owner: Developers.

### 7.5 Sprint Review

AI supports:

- demo preparation;
- Sprint Goal summary;
- completed work summary;
- stakeholder feedback extraction;
- backlog update suggestions.

Output: Sprint Review Pack

Human owner: Product Owner / Scrum Team.

### 7.6 Sprint Retrospective

AI supports:

- pattern analysis;
- blocker grouping;
- improvement suggestions;
- previous action tracking;
- quality and process insights.

Output: Retrospective Insights Pack

Human owner: Scrum Team.

## 8. Scrum Artifact Mapping

### 8.1 Product Backlog

AI helps create and refine:

- epics;
- user stories;
- bugs;
- technical debt items;
- documentation tasks;
- test tasks;
- DevOps tasks;
- security tasks;
- modernization tasks.

Human owner: Product Owner.

### 8.2 Sprint Backlog

AI helps:

- break stories into tasks;
- identify implementation steps;
- identify risks;
- identify testing tasks;
- identify documentation tasks;
- detect dependencies.

Human owner: Developers.

### 8.3 Increment

AI helps:

- validate Definition of Done;
- generate tests;
- review code;
- prepare release notes;
- update documentation;
- check release readiness.

Human owner: Scrum Team.

## 9. AI-Enhanced Definition of Ready

A Product Backlog item is ready when AI and the team have checked:

1. Business goal is clear
2. User role is clear
3. Expected behavior is clear
4. Acceptance criteria exist
5. Dependencies are identified
6. Edge cases are considered
7. Risks are listed
8. Test scenarios are suggested
9. Open questions are visible
10. Team understands the item well enough to plan it

## 10. AI-Enhanced Definition of Done

A Product Backlog item is done when:

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

## 11. Greenfield vs Inherited Scrum Comparison

| Area | Greenfield Scrum Flow | Inherited Scrum Flow |
|------|-----------------------|----------------------|
| First goal | Define Product Goal and create initial backlog | Understand current system and define stabilization goal |
| First AI activity | Discovery analysis | System assessment |
| Product Backlog content | Features, architecture setup, UX, tests, CI/CD, docs | Bugs, risks, docs, regression tests, tech debt, security, modernization |
| Refinement focus | Clarifying new requirements | Recovering current behavior and regression risk |
| Sprint Planning focus | Building valuable features | Balancing fixes, stabilization, and new work |
| Development focus | Build cleanly from standards | Change safely with impact analysis |
| QA focus | Validate new requirements | Protect existing behavior |
| Sprint Review focus | Demo new product value | Show fixes, stability, risk reduction, and progress |
| Retrospective focus | Improve delivery speed and collaboration | Improve legacy understanding, estimation, and risk handling |
| Main AI benefit | Creates clarity and structure early | Discovers reality and reduces takeover risk |

## 12. Practical Rollout Plan

### Phase 1: Add AI to Scrum events

Start with:

1. AI meeting summaries after discovery/client meetings
2. AI backlog item clarity checks before refinement
3. AI acceptance criteria suggestions
4. AI Sprint Planning risk checks
5. AI PR review before human review
6. AI QA test case generation
7. AI Sprint Review summaries
8. AI Retrospective pattern analysis

### Phase 2: Add scenario-specific workflows

For greenfield projects:

1. AI Product Goal drafting
2. AI initial Product Backlog creation
3. AI architecture option comparison
4. AI project bootstrap support
5. AI release and handover documentation

For inherited projects:

1. AI system assessment
2. AI codebase mapping
3. AI business rule recovery
4. AI risk register creation
5. AI regression test recovery
6. AI stabilization backlog creation
7. AI modernization roadmap

### Phase 3: Add engineering automation

Introduce:

1. Claude Code for codebase-aware development
2. Claude Code subagents for specialized workflows
3. AI-assisted PR reviews
4. AI test generation
5. AI CI/CD failure analysis
6. AI documentation updates
7. AI support ticket triage

### Phase 4: Add governance and tool integrations

Introduce controlled integrations with:

1. GitHub / GitLab / Azure DevOps
2. Jira / Azure Boards
3. Confluence / Notion
4. CI/CD systems
5. Monitoring/logging tools
6. Documentation repositories

Rules:

1. Start read-only where possible
2. Require human approval for write actions
3. Never allow autonomous production deployment
4. Never expose secrets or production data
5. Keep auditability of AI-assisted decisions

## 13. Governance Rules

**Rule 1: AI cannot approve its own work**

AI can review, suggest, and summarize. Humans approve.

**Rule 2: AI-generated code requires human review**

No AI-generated code should be merged without human review.

**Rule 3: AI-generated requirements require PO/BA validation**

AI can draft backlog items, but the Product Owner or BA validates them.

**Rule 4: AI-generated tests require QA/developer validation**

AI can generate tests, but QA and Developers validate correctness.

**Rule 5: AI-generated client communication requires PM/PO review**

AI can draft status updates, release notes, and summaries, but humans send them.

**Rule 6: AI must not receive secrets or unsafe production data**

Credentials, private keys, tokens, and production-sensitive data should not be pasted into AI tools.

**Rule 7: AI assumptions must be visible**

AI outputs should clearly separate:

- Observed facts
- Assumptions
- Risks
- Recommendations
- Open questions

## 14. Final Recommended Operating Model

The company should define its approach as:

**AI-Assisted Scrum Delivery**

Not:

AI delivery methodology

The final model is:

- Scrum remains the delivery framework.
- AI becomes a support layer across Scrum events, artifacts, and engineering practices.
- Humans remain accountable.
- AI improves clarity, speed, quality, documentation, and predictability.

For greenfield projects:

Client idea
→ AI-assisted discovery
→ Product Goal
→ Initial Product Backlog
→ Refinement
→ Sprint Planning
→ AI-assisted Sprint execution
→ Sprint Review
→ Retrospective
→ Release and support

For inherited projects:

Takeover request
→ AI-assisted system assessment
→ Stabilization Goal
→ Stabilization Product Backlog
→ Refinement
→ Sprint Planning
→ Safe AI-assisted Sprint execution
→ Regression-focused QA
→ Sprint Review
→ Retrospective
→ Modernization and support

The key distinction is:

- In greenfield projects, AI helps the Scrum Team create clarity and structure early.
- In inherited projects, AI helps the Scrum Team discover reality, reduce risk, and evolve safely.

This makes AI a practical part of Scrum delivery, not a replacement for Scrum.
