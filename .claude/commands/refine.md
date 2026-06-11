---
description: Backlog refinement (greenfield step 7 / inherited step 8): refine a backlog item to Ready as a Refined Story Pack, via the product-backlog agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/refine** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

This command works for **both** scenarios; it reads `scenario` from `engagement.md` and picks the right template and step — it does not reject either track.

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Branch on scenario.** Read `scenario` from `engagement.md`'s frontmatter and fix `<step>`, `<prereq>`, `<template>`, `<output>`, `<pack>`, `<state-line>` for the rest of this command:
   - **greenfield** → `<step>` = 7; `<prereq>` = `src/<eng>/delivery/architecture-technical-foundation-pack.md`; `<template>` = `templates/shared/refined-story-pack.md`; `<output>` = `src/<eng>/delivery/refined-story-pack.md`; `<pack>` = `Refined Story Pack`; `<state-line>` = `- [x] 7 Refined Story Pack — delivery/refined-story-pack.md`.
   - **inherited** → `<step>` = 8; `<prereq>` = `src/<eng>/delivery/stabilization-product-backlog.md`; `<template>` = `templates/inherited/inherited-refined-story-pack.md`; `<output>` = `src/<eng>/delivery/inherited-refined-story-pack.md`; `<pack>` = `Inherited Refined Story Pack`; `<state-line>` = `- [x] 8 Inherited Refined Story Pack — delivery/inherited-refined-story-pack.md`.
   - any other value → STOP and tell the user `engagement.md`'s `scenario` is malformed (expected `greenfield` or `inherited`); re-run `/intake <eng>`.
4. **Check prerequisite.** Confirm `<prereq>` exists. If unmet, STOP with — greenfield: "Architecture & Technical Foundation Pack missing — run `/architecture <eng>` first." · inherited: "Stabilization Product Backlog missing — run `/stabilization-backlog <eng>` first." Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-backlog** subagent (`subagent_type: product-backlog`). Instruct it to: read the relevant prior artifacts in `src/<eng>/delivery/` (greenfield: initial product backlog pack + architecture pack; inherited: stabilization product backlog + codebase & architecture map); fill the template `<template>`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). If the user named a specific backlog item to refine, refine that one; otherwise refine the top-priority item from the backlog and state which item you refined.
6. **Update state.** In `src/<eng>/engagement.md`, change step `<step>`'s line to `<state-line>`. If no line for that step exists, insert `<state-line>` in numeric order.
7. **Report next.** Tell the user what was produced and the next action: Run `/sprint-plan <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
