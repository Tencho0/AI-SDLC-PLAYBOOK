---
description: Inherited stabilization (step 5): reconstruct how the system behaves as a Business Rule Recovery Report, via the documentation agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/recover-rules** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its setup commands instead: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`."
4. **Check prerequisite.** Confirm `src/<eng>/delivery/inherited-project-goal-draft.md` exists (step 4 done). If unmet, STOP with: "Stabilization Goal missing — run `/stabilization-goal <eng>` first.". Produce nothing.
5. **Delegate to the agent.** Use the Task tool to spawn the **documentation** subagent (`subagent_type: documentation`). Instruct it to: read the prior inherited artifacts in `src/<eng>/delivery/` (takeover brief, access checklist, system assessment, project goal draft) and, if a project repo is cloned under `src/<eng>/`, the codebase itself; fill the template `templates/inherited/business-rule-recovery-report.md`; write the completed artifact to `src/<eng>/delivery/business-rule-recovery-report.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 5's line to `- [x] 5 Business Rule Recovery Report — delivery/business-rule-recovery-report.md`. If no step-5 line exists, insert it in numeric order after step 4.
7. **Report next.** Tell the user what was produced and the next action: Run `/map-codebase <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
