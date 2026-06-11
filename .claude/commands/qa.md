---
description: QA & testing (greenfield step 12 / inherited step 11): turn a story's acceptance criteria into a QA Test Pack (greenfield) or Regression Test Pack (inherited), via the qa-test-design agent.
argument-hint: <engagement-slug> <story-id>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/qa** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it once per story/ticket tested in the sprint. It works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the story id (`<story>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<story>` is empty, ask the user which story. Validate `<story>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<template>`, `<pack>` for the rest of this command:
   - **greenfield** → `<step>` = 12; `<template>` = `templates/shared/qa-test-pack.md`; `<pack>` = `QA Test Pack`.
   - **inherited** → `<step>` = 11; `<template>` = `templates/inherited/regression-test-pack.md`; `<pack>` = `Regression Test Pack`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Soft prerequisite check.** Confirm the sprint-planning pack exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — QA usually runs after `/sprint-plan <eng>`; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/qa/<story>.md`. Create the `src/<eng>/delivery/qa/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **qa-test-design** subagent (`subagent_type: qa-test-design`). Instruct it to: read the relevant prior artifacts in `src/<eng>/delivery/` (the refined story pack with acceptance criteria; for inherited, also the business rule recovery report and codebase & architecture map for regression risks) and, if a cloned project repo is present under `src/<eng>/`, the repo itself; focus on story **`<story>`**; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · qa · <story> → delivery/qa/<story>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where) and a sensible next action: have QA validate the pack, automate the cases (no `/automate-tests` command yet — run the `test-automation` agent manually), and continue the sprint loop (`/execution`, `/pr-review`, `/daily-scrum`). To start a new sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
