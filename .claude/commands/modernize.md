---
description: Modernization (inherited step 14): produce or update the engagement's living Modernization Roadmap, via the documentation agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/modernize** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This produces a single **living** Modernization Roadmap for the engagement (re-running updates it in place). It is for **inherited** engagements; greenfield engagements run `/release-readiness` instead.

1. **Resolve arguments.** `$ARGUMENTS` is just the engagement slug (`<eng>`); there is no second argument. If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name).
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — its release wrap-up is `/release-readiness <eng> <release>`, not modernization."
4. **Soft prerequisite check.** Confirm `src/<eng>/delivery/inherited-sprint-planning-support-pack.md` exists. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — modernization usually follows stabilization; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/modernization-roadmap.md` (a single living document — no per-instance subfolder).
6. **Delegate to the agent.** Use the Task tool to spawn the **documentation** subagent (`subagent_type: documentation`). Instruct it to: read the inherited analysis artifacts in `src/<eng>/delivery/` (initial system assessment, business rule recovery report, codebase & architecture map, stabilization backlog) and, if a cloned project repo is present under `src/<eng>/`, the repo; propose a prioritized, risk-aware modernization roadmap (incremental steps, sequencing, risks); fill the template `templates/inherited/modernization-roadmap.md`; write the completed artifact to `<output>` — if `<output>` already exists, UPDATE it in place (use Edit for surgical changes rather than regenerating wholesale); and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · modernize → delivery/modernization-roadmap.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value (this line omits an item token because the roadmap is a single living doc). If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced or updated (and where) and the next action: PO / Architect / Client review the roadmap; feed prioritized items back into the backlog via `/stabilization-backlog <eng>` or `/refine <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
