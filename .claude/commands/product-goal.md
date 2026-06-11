---
description: Greenfield discovery (step 4): synthesize discovery into a Product Goal Draft, via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/product-goal** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its discovery commands instead: `/access-checklist`, `/system-assessment`, `/stabilization-goal`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/discovery-meeting-summary.md` exists (step 3 done). If unmet, STOP with: "Discovery summary missing — run `/discovery-summary <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to: read all discovery artifacts in `src/<eng>/delivery/` (brief, workshop plan, meeting summary); fill the template `templates/greenfield/product-goal-draft.md`; write the completed artifact to `src/<eng>/delivery/product-goal-draft.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 4's line to `- [x] 4 Product Goal Draft — delivery/product-goal-draft.md`.
7. **Report next.** Tell the user what was produced and the next action: Discovery phase complete. Run `/initial-backlog <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
