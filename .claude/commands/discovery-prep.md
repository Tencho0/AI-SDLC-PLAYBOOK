---
description: Greenfield discovery (step 2): produce the Discovery Workshop Plan from the request, via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/discovery-prep** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its discovery commands instead: `/access-checklist`, `/system-assessment`, `/stabilization-goal`."
4. **Check prerequisite.** Confirm step 1 is checked in `engagement.md` and `src/<eng>/delivery/project-request-brief.md` exists. If unmet, STOP with: "Intake isn't complete — run `/intake <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to: read the request in `src/<eng>/request/` and `src/<eng>/delivery/project-request-brief.md`; fill the template `templates/greenfield/discovery-workshop-plan.md`; write the completed artifact to `src/<eng>/delivery/discovery-workshop-plan.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 2's line to `- [x] 2 Discovery Workshop Plan — delivery/discovery-workshop-plan.md`.
7. **Report next.** Tell the user what was produced and the next action: Run your discovery workshop, save the meeting notes into `src/<eng>/request/`, then run `/discovery-summary <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
