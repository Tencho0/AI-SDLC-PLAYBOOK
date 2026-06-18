# Playbook Usage Documentation — Design Spec

**Date:** 2026-06-16
**Status:** Approved (design) — pending implementation plan
**Topic:** Add a task-oriented "how to use this Playbook" guide under `docs/usage/`, layered for the delivery team and clients, that links into the existing docs and can be published on-demand to the Klevret.SDLC Azure DevOps wiki.

---

## 1. Problem & goal

The repo already has the **operating manual** ([CLAUDE.md](../../../CLAUDE.md)), the **full model**
([playbook/PLAYBOOK.md](../../../playbook/PLAYBOOK.md)), **reference docs** (governance, DoR/DoD,
[mcp.md](../../../playbook/mcp.md)), and **builder specs** (`docs/superpowers/`). What it lacks is a
single, discoverable *"how do I actually run this day-to-day"* usage guide for someone picking the
base up to deliver an engagement.

**Goal:** add a usage guide that is easy to read, easy to extend over time, and avoids duplicating
the authoritative docs. It is authored in the repo (canonical) and can be published on-demand into
the **Klevret.SDLC** Azure DevOps wiki for the team to read in ADO.

**Non-goals:**
- Not a rewrite or replacement of CLAUDE.md / PLAYBOOK.md — those stay authoritative.
- Not an automated/CI wiki sync — publishing is a manual, on-demand step (see §6).
- No new agents, commands, or templates.

## 2. Decisions captured (from brainstorming)

| Axis | Decision |
|------|----------|
| Destination | **Both** — repo is canonical; published into the Klevret.SDLC ADO wiki. |
| Audience | **Both, layered** — a deeper guide for the delivery team + a short client orientation. |
| Scope | **Task-oriented layer** — "how do I do X" walkthroughs that **link** into the existing docs (minimal duplication, low drift). |
| Sync | **Manual on-demand** via the `ado` MCP (`wiki_create_or_update_page`); no automation to maintain. |

## 3. Location & structure

A new top-level **`docs/usage/`** folder — canonical, versioned with the base, kept separate from
the builder history in `docs/superpowers/`. Flat files with a single index, mirroring the
"one line per entry" pattern of `MEMORY.md` so that adding a page is trivial:

```
docs/usage/
  README.md                  # index + "who reads what"; links to the reference docs
  getting-started.md         # [delivery] clone -> configure (.env / setup-mcp / verify) -> classify -> first run
  running-an-engagement.md   # [delivery] run-order walkthrough (greenfield + inherited), command/agent per step
  running-a-sprint.md        # [delivery] recurring loop: /execution, /daily-scrum, /pr-review, /qa, /sprint-review, /retro
  governance-and-reviews.md  # [both]     the 7 guardrails, human approval gates, DoR/DoD
  for-clients.md             # [client]   orientation: the flow, artifacts you'll approve, your responsibilities
  publishing-to-ado-wiki.md  # [delivery] how to sync this guide into the Klevret.SDLC wiki via the ado MCP
  adding-a-page.md           # [delivery] the convention for adding/extending pages over time
```

The layering is expressed by an **audience tag** per page rather than subfolders, keeping the tree
flat and the "add a page" step to one file + one index line.

## 4. Page set (task-oriented, links into existing docs)

Every page is a walkthrough that **links** to the authoritative source instead of restating it.

| File | Audience | Purpose | Links into |
|------|----------|---------|-----------|
| `README.md` | both | Index of the guide with a one-line hook + audience tag per page; "start here" + map of the reference docs. | CLAUDE.md, PLAYBOOK.md, mcp.md |
| `getting-started.md` | delivery | Clone the base, configure MCP (`Copy-Item mcp.env.example .env` → `setup-mcp.ps1` → verify/approve), classify greenfield vs inherited, produce the first artifact. | mcp.md §4 + §4.8, greenfield-vs-inherited.md, CLAUDE.md (engagement workflow) |
| `running-an-engagement.md` | delivery | The numbered run order for each track (greenfield 1–15, inherited 1–14): which command + agent drives each step and where the artifact lands. | PLAYBOOK.md §5/§6, CLAUDE.md run-order tables |
| `running-a-sprint.md` | delivery | The recurring per-sprint command loop and how items are keyed (ticket / PR / story / date). | CLAUDE.md slash-commands section |
| `governance-and-reviews.md` | both | The 7 guardrails, the human approval gates, and Definition of Ready / Done in practice. | governance.md, definition-of-ready.md, definition-of-done.md |
| `for-clients.md` | client | What the AI-assisted flow is, which artifacts the client sees and approves, their review responsibilities, what not to expect. | governance.md (guardrails 1–5) |
| `publishing-to-ado-wiki.md` | delivery | The manual sync process and the stable file→wiki-page mapping (see §6). | mcp.md (ado server), §6 of this spec |
| `adding-a-page.md` | delivery | The maintainability convention (see §5) so anyone/any agent extends the guide consistently. | this spec §5 |

## 5. Maintainability conventions ("easy to add over time")

Four conventions keep adding a page to a ~2-minute task:

1. **One index.** `README.md` lists every page as `- [Title](file.md) — one-line hook [audience]`.
   Adding a page = drop the file + add one index line (the `MEMORY.md` pattern the user already uses).
2. **Link, don't duplicate.** Authoritative content stays in CLAUDE.md / PLAYBOOK.md / mcp.md /
   governance.md / DoR / DoD. Usage pages link to it; they never restate rosters, run-orders, or
   guardrail text.
3. **Consistent page shape.** Each page: a one-line `audience:` note, **Purpose**, the **Steps /
   walkthrough**, and a **Read more** links block. Predictable to read and to author.
4. **`adding-a-page.md`** documents 1–3 explicitly, including the publish step (§6), so the convention
   is self-describing.

## 6. ADO wiki sync (manual, on-demand)

Documented in `publishing-to-ado-wiki.md`:

- **Prerequisite:** the Klevret.SDLC project has a wiki. If none exists, create a project wiki once
  (ADO UI or API); record its identifier. The `ado` MCP exposes `wiki_list_wikis` to discover it.
- **Mapping:** each `docs/usage/<file>.md` maps to a **stable** wiki page path under a single parent,
  e.g. `/AI-SDLC Playbook/<Title>`. The mapping table lives in `publishing-to-ado-wiki.md`.
- **Process:** the operator asks an agent to "publish the usage guide"; the agent reads `docs/usage/`,
  and for each file calls `wiki_create_or_update_page` at its mapped path. Stable paths mean re-runs
  **update** existing pages rather than creating duplicates.
- **Canonical source stays the repo.** The wiki is a published mirror; edits are made in the repo and
  re-published. Drift is acceptable between publishes and resolved by the next publish.
- **Governance:** publishing client-facing content is subject to the playbook guardrails — the
  delivery team reviews before publishing; nothing secret or client-confidential from `.env`/`src/`
  is ever included.

## 7. Out of scope / deferred

- **Automated/scripted sync** (`scripts/sync-wiki.ps1`) — deferred; revisit if publishing becomes
  frequent enough to warrant one-command sync. Noted as a future option, not built.
- **Per-audience subfolders** — rejected for now in favour of a flat tree + audience tags.
- **Wiki-only or pointer-only hosting** — rejected; repo is canonical and the wiki carries full
  mirrored content.

## 8. Acceptance criteria

1. `docs/usage/` exists with the eight files in §3, each following the page shape in §5.4.
2. `README.md` is an index listing every page with a one-line hook + audience tag; it links to
   CLAUDE.md, PLAYBOOK.md, and mcp.md as the reference set.
3. Every usage page links to (does not duplicate) the authoritative source for its topic; no run-order
   table, agent roster, or guardrail text is copied verbatim.
4. `getting-started.md`, `running-an-engagement.md`, and `running-a-sprint.md` cover both greenfield
   and inherited tracks and reference the correct commands/agents.
5. `for-clients.md` is readable by a non-technical stakeholder and frames the governance/approval role.
6. `publishing-to-ado-wiki.md` documents the prerequisite, the stable file→page mapping, and the
   `ado`-MCP publish process such that a re-run updates rather than duplicates pages.
7. `adding-a-page.md` documents the maintainability convention (§5) end to end.
8. The scaffold verifier still exits 0 (the new folder is additive and unverified by design; it must
   not introduce WARNs).
