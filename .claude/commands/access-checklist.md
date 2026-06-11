---
description: Inherited takeover (step 2): produce the Access & Information Checklist from the request, via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/access-checklist** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is a greenfield engagement — use its discovery commands instead: `/discovery-prep`, `/discovery-summary`, `/product-goal`."
4. **Check prerequisite.** Confirm step 1 is checked in `engagement.md` and `src/<eng>/delivery/takeover-request-brief.md` exists. If unmet, STOP with: "Intake isn't complete — run `/intake <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to: read the request in `src/<eng>/request/` and `src/<eng>/delivery/takeover-request-brief.md`; fill the template `templates/inherited/access-information-checklist.md`; write the completed artifact to `src/<eng>/delivery/access-information-checklist.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 2's line to `- [x] 2 Access & Information Checklist — delivery/access-information-checklist.md`.
7. **Report next.** Tell the user what was produced and the next action: Once the client grants access, clone the project repo into `src/<eng>/<project-repo>/`, then run `/system-assessment <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
