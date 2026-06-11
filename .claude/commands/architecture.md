---
description: Greenfield setup (step 6): set the technical foundation as an Architecture & Technical Foundation Pack, via the implementation agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/architecture** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its setup commands instead: `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/initial-product-backlog-pack.md` exists (step 5 done). If unmet, STOP with: "Initial Product Backlog missing — run `/initial-backlog <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the discovery + backlog artifacts in `src/<eng>/delivery/` (product goal draft, initial product backlog pack); fill the template `templates/greenfield/architecture-technical-foundation-pack.md`; write the completed artifact to `src/<eng>/delivery/architecture-technical-foundation-pack.md`; record where `security-review` and `documentation` should follow up in the pack's Recommendations / Open questions; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 6's line to `- [x] 6 Architecture & Technical Foundation Pack — delivery/architecture-technical-foundation-pack.md`. If no step-6 line exists, insert it in numeric order after step 5.
7. **Report next.** Tell the user what was produced and the next action: Run `/refine <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
