---
description: Inherited stabilization (step 7): turn assessment findings into a Stabilization Product Backlog, via the product-backlog agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/stabilization-backlog** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its setup commands instead: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/codebase-architecture-map.md` exists (step 6 done). If unmet, STOP with: "Codebase & Architecture Map missing — run `/map-codebase <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-backlog** subagent (`subagent_type: product-backlog`). Instruct it to: read all inherited artifacts in `src/<eng>/delivery/` (system assessment, business rule recovery report, codebase & architecture map, project goal draft); fill the template `templates/inherited/stabilization-product-backlog.md`; write the completed artifact to `src/<eng>/delivery/stabilization-product-backlog.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 7's line to `- [x] 7 Stabilization Product Backlog — delivery/stabilization-product-backlog.md`. If no step-7 line exists, insert it in numeric order after step 6.
7. **Report next.** Tell the user what was produced and the next action: Run `/refine <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
