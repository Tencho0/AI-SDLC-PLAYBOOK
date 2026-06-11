---
description: Inherited takeover (step 4): define the Stabilization Goal, via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/stabilization-goal** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is a greenfield engagement — use its discovery commands instead: `/discovery-prep`, `/discovery-summary`, `/product-goal`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/initial-system-assessment.md` exists (step 3 done). If unmet, STOP with: "System assessment missing — run `/system-assessment <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to: read all inherited artifacts in `src/<eng>/delivery/` (takeover brief, access checklist, system assessment); fill the template `templates/inherited/inherited-project-goal-draft.md`; write the completed artifact to `src/<eng>/delivery/inherited-project-goal-draft.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 4's line to `- [x] 4 Inherited Project Goal Draft — delivery/inherited-project-goal-draft.md`.
7. **Report next.** Tell the user what was produced and the next action: Discovery/assessment phase complete. The next step is Business Rule Recovery (step 5); its command isn't built yet — run the `documentation` agent manually per `CLAUDE.md`'s run-order table.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
