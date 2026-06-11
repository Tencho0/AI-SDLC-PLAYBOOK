---
description: Sprint execution (greenfield step 9 / inherited step 10): capture a ticket's implementation as an Implementation Pack (greenfield) or Safe Change Pack (inherited), via the implementation agent.
argument-hint: <engagement-slug> <ticket-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/execution** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it once per ticket worked in the sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the ticket id (`<ticket>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<ticket>` is empty, ask the user which ticket. Validate `<ticket>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 9; `<template>` = `templates/shared/implementation-pack.md`; `<pack>` = `Implementation Pack`.
   - **inherited** → `<step>` = 10; `<template>` = `templates/inherited/safe-change-pack.md`; `<pack>` = `Safe Change Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — execution usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/execution/<ticket>.md`. Create the `src/<eng>/delivery/execution/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the relevant prior artifacts in `src/<eng>/delivery/` (the refined story pack and sprint planning pack; for inherited, also the codebase & architecture map and business rule recovery report) and, if a cloned project repo is present under `src/<eng>/`, the repo itself; focus on ticket **`<ticket>`**; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). Code and tests go INTO the project repo, never into `delivery/`.
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · execution · <ticket> → delivery/execution/<ticket>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where), the current sprint, and a sensible next action: open the PR and run `/pr-review <eng> <pr>`, run `/qa <eng> <ticket>` for tests, and `/daily-scrum <eng>` at standup. To start a new sprint, bump `sprint:` in `engagement.md`. Sprint review / retrospective / release commands aren't built yet — run their agents manually per `CLAUDE.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
