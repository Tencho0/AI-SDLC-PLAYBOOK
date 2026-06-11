---
description: Greenfield discovery (step 3): summarize discovery-meeting notes into a Discovery Meeting Summary, via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/discovery-summary** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — use its discovery commands instead: `/access-checklist`, `/system-assessment`, `/stabilization-goal`."
4. **Check prerequisite & identify the notes.** Confirm `src/<eng>/delivery/discovery-workshop-plan.md` exists (step 2 done). Then identify which file(s) in `src/<eng>/request/` hold the discovery-meeting notes — they are the file(s) added *after* intake; the original client request is typically `request.md`. If you cannot tell them apart, ask the user which file holds the meeting notes. Call that path `<notes-file>`. If no meeting notes exist beyond the original request, STOP with: "No discovery-meeting notes found — run `/discovery-prep <eng>`, hold the workshop, and add the notes to `src/<eng>/request/` first." Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Tell it explicitly that the discovery-meeting notes are at `<notes-file>` — summarize THOSE, and treat the original client request as background context only, not as meeting content — plus the prior artifacts in `src/<eng>/delivery/`; fill the template `templates/greenfield/discovery-meeting-summary.md`; write the completed artifact to `src/<eng>/delivery/discovery-meeting-summary.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 3's line to `- [x] 3 Discovery Meeting Summary — delivery/discovery-meeting-summary.md`.
7. **Report next.** Tell the user what was produced and the next action: Run `/product-goal <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
