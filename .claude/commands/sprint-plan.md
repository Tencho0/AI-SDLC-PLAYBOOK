---
description: Sprint Planning (greenfield step 8 / inherited step 9): produce the Sprint Planning Support Pack, via the scrum-planning agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/sprint-plan** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

This command works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template and step — it does not reject either track.

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<prereq>`, `<template>`, `<output>`, `<pack>`, `<state-line>` for the rest of this command:
   - **greenfield** → `<step>` = 8; `<prereq>` = `src/<eng>/delivery/refined-story-pack.md`; `<template>` = `templates/shared/sprint-planning-support-pack.md`; `<output>` = `src/<eng>/delivery/sprint-planning-support-pack.md`; `<pack>` = `Sprint Planning Support Pack`; `<state-line>` = `- [x] 8 Sprint Planning Support Pack — delivery/sprint-planning-support-pack.md`.
   - **inherited** → `<step>` = 9; `<prereq>` = `src/<eng>/delivery/inherited-refined-story-pack.md`; `<template>` = `templates/inherited/inherited-sprint-planning-support-pack.md`; `<output>` = `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`; `<pack>` = `Inherited Sprint Planning Support Pack`; `<state-line>` = `- [x] 9 Inherited Sprint Planning Support Pack — delivery/inherited-sprint-planning-support-pack.md`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Check prerequisite.** Confirm `<prereq>` exists. If unmet, STOP with — greenfield: "Refined Story Pack missing — run `/refine <eng>` first." · inherited: "Inherited Refined Story Pack missing — run `/refine <eng>` first." Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **scrum-planning** subagent (`subagent_type: scrum-planning`). Instruct it to: read the refined story pack and prior backlog artifacts in `src/<eng>/delivery/`; fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step `<step>`'s line to `<state-line>`. If no line for that step exists, insert `<state-line>` in numeric order.
7. **Report next.** Tell the user what was produced and the next action: Setup & planning is complete. The next steps are the recurring per-sprint events (greenfield: sprint execution, daily scrum, code review, QA…; inherited: safe execution, regression QA…) — their commands aren't built yet, so run their agents manually per `CLAUDE.md`'s run-order table.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
