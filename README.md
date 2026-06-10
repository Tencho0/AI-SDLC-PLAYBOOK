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
