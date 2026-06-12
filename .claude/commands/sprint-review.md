---
description: Sprint Review (greenfield step 13 / inherited step 12): produce a sprint-keyed Sprint Review Pack, via the scrum-planning agent.
argument-hint: <engagement-slug> [sprint-number]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/sprint-review** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it at the end of each sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional sprint number (`<sprint>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<sprint>` is empty, DEFAULT it to the current `sprint:` value in `engagement.md`'s frontmatter — or `1` if there is no `sprint:` marker yet. Validate `<sprint>` as a positive integer `^[0-9]+$`; otherwise ask again. The output key is `sprint-<sprint>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 13; `<template>` = `templates/shared/sprint-review-pack.md`; `<pack>` = `Sprint Review Pack`.
   - **inherited** → `<step>` = 12; `<template>` = `templates/inherited/inherited-sprint-review-pack.md`; `<pack>` = `Inherited Sprint Review Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — the sprint review usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/sprint-review/sprint-<sprint>.md`. Create the `src/<eng>/delivery/sprint-review/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **scrum-planning** subagent (`subagent_type: scrum-planning`). Instruct it to: read the sprint planning pack and the sprint's `delivery/execution/`, `delivery/qa/`, and `delivery/pr-review/` artifacts in `src/<eng>/delivery/` to see what was committed vs delivered; summarise the increment, demo notes, and stakeholder feedback for **sprint <sprint>**; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · sprint-review · sprint-<sprint> → delivery/sprint-review/sprint-<sprint>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where) and a sensible next action: run `/retro <eng> <sprint>` for the same sprint; greenfield teams also run `/release-readiness <eng> <release>` when cutting a release. To start the next sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
