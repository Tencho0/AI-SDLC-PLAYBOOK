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
2. Open Claude Code here and run `/intake <engagement>` (e.g. `/intake acme-portal`). It creates the workspace, asks greenfield vs inherited, takes the request (from `src/<engagement>/request/` or by prompt), and produces the first brief.
3. Follow the command it points you to next — greenfield: `/discovery-prep` → `/discovery-summary` → `/product-goal`; inherited: `/access-checklist` → `/system-assessment` → `/stabilization-goal`.
4. For inherited projects, clone the project's own repo into `src/<engagement>/<project-repo>/` when access is granted (before `/system-assessment`).

Everything under `src/` is gitignored, so this base never accumulates client data and can be reused across many projects.

## Reusing across projects

Either re-clone per engagement, or keep multiple engagements side-by-side under `src/<engagement-a>/`, `src/<engagement-b>/`, … — the playbook tooling is shared, the data stays isolated.

## Verify the scaffold

Optional structural self-check (Windows PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File scripts/verify-scaffold.ps1
```

On macOS/Linux use PowerShell 7 (`pwsh scripts/verify-scaffold.ps1`). The check is optional — the scaffold is plain Markdown, so you can skip it if PowerShell isn't available.

## Deferred (future passes)

The intake + discovery slash commands (`/intake` and the six discovery step commands) are built. Still deferred: commands for the remaining steps (backlog → planning → execution → review → retro → release / modernization), reusable skills, and plugin packaging — see `docs/superpowers/specs/`.
