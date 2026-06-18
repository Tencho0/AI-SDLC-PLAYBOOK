# Governance and Reviews

**Audience:** both

## Purpose
Explain the human-in-the-loop gates that apply to every AI-produced artifact, and the
Definition of Ready / Done checks that bracket a unit of work.

## The rule that shapes everything
AI cannot approve its own work — a human always approves. AI-generated code, requirements, tests,
and client communication each require the matching human review before they count as done. The full
set of seven guardrails is in [playbook/governance.md](../../playbook/governance.md).

## Where the gates fire
- **Requirements** (briefs, backlog, stories) → PO/BA validation.
- **Code** → human review before merge.
- **Tests** → QA/developer validation.
- **Client communication** (e.g. Teams drafts) → PM/PO review before sending.
- **Secrets/production data** → never pasted into AI tools.

## Ready and Done
- A story is **Ready** when business goal, role, behavior, acceptance criteria, dependencies, edge
  cases, risks, test scenarios, and open questions are clear —
  [playbook/definition-of-ready.md](../../playbook/definition-of-ready.md).
- An increment is **Done** when acceptance criteria pass, code + tests are in, AI self-review and
  human review are done, QA/security checked where needed, docs updated, no critical regression —
  [playbook/definition-of-done.md](../../playbook/definition-of-done.md).

## Every AI artifact separates
Observed facts · Assumptions · Risks · Recommendations · Open questions.

## Read more
- All seven guardrails: [playbook/governance.md](../../playbook/governance.md)
- For the client view of reviews: [for-clients.md](for-clients.md)
