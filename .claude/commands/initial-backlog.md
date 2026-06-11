---
description: Greenfield setup (step 5): turn the Product Goal into an Initial Product Backlog Pack, via the product-backlog agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/initial-backlog** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its setup commands instead: `/recover-rules`, `/map-codebase`, `/stabilization-backlog`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/product-goal-draft.md` exists (step 4 done). If unmet, STOP with: "Product Goal missing — run `/product-goal <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-backlog** subagent (`subagent_type: product-backlog`). Instruct it to: read all discovery artifacts in `src/<eng>/delivery/` (request brief, workshop plan, meeting summary, product goal draft); fill the template `templates/greenfield/initial-product-backlog-pack.md`; write the completed artifact to `src/<eng>/delivery/initial-product-backlog-pack.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 5's line to `- [x] 5 Initial Product Backlog Pack — delivery/initial-product-backlog-pack.md`. If no step-5 line exists (an engagement created before setup steps were tracked), insert it in numeric order after step 4.
7. **Report next.** Tell the user what was produced and the next action: Run `/architecture <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
