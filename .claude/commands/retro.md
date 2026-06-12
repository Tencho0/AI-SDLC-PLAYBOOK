---
description: Retrospective (greenfield step 14 / inherited step 13): produce a sprint-keyed Retrospective Insights Pack, via the retrospective-insights agent.
argument-hint: <engagement-slug> [sprint-number]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/retro** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it after each sprint review. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional sprint number (`<sprint>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<sprint>` is empty, DEFAULT it to the current `sprint:` value in `engagement.md`'s frontmatter — or `1` if there is no `sprint:` marker yet. Validate `<sprint>` as a positive integer `^[0-9]+$`; otherwise ask again. The output key is `sprint-<sprint>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 14; `<template>` = `templates/shared/retrospective-insights-pack.md`; `<pack>` = `Retrospective Insights Pack`.
   - **inherited** → `<step>` = 13; `<template>` = `templates/inherited/inherited-retrospective-insights-pack.md`; `<pack>` = `Inherited Retrospective Insights Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — the retrospective usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/retro/sprint-<sprint>.md`. Create the `src/<eng>/delivery/retro/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **retrospective-insights** subagent (`subagent_type: retrospective-insights`). Instruct it to: read the sprint review pack for this sprint (`delivery/sprint-review/sprint-<sprint>.md` if present) plus the sprint's `delivery/execution/`, `delivery/qa/`, and `delivery/pr-review/` artifacts and any prior `delivery/retro/` packs (to track recurring patterns and prior action items); surface blockers, estimation misses, and quality/communication patterns for **sprint <sprint>** and propose improvement experiments; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · retro · sprint-<sprint> → delivery/retro/sprint-<sprint>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where), that the team owns the improvements (AI only surfaces patterns), and the next action: start the next sprint — bump `sprint:` in `engagement.md` and continue the execution loop (re-run `/sprint-plan <eng>` if you re-plan the backlog).

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
