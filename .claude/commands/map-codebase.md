---
description: Inherited stabilization (step 6): map the cloned codebase into a Codebase & Architecture Map, via the implementation agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/map-codebase** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its setup commands instead: `/initial-backlog`, `/architecture`, `/refine`, `/sprint-plan`."
4. **Check prerequisites & locate the repo.** First, confirm step 5 is done: `src/<eng>/delivery/business-rule-recovery-report.md` exists. If not, STOP with: "Business Rule Recovery Report missing — run `/recover-rules <eng>` first." Then locate the cloned project repo: a subdirectory of `src/<eng>/` other than `request/` and `delivery/` that actually contains the codebase (look for a `.git` directory or real source files). If there are none, STOP with: "No cloned project repo found under `src/<eng>/` — clone it into `src/<eng>/<project-repo>/` (access required) first." If there are several candidates, or the only candidate looks empty / non-code (e.g. a scratch or notes folder), ASK the user to confirm which folder is the project repo rather than guessing. Call the confirmed folder `<repo>`; produce nothing until a real repo is confirmed.
5. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the confirmed project repo at `src/<eng>/<repo>/` plus prior artifacts in `src/<eng>/delivery/` (system assessment, business rule recovery report); fill the template `templates/inherited/codebase-architecture-map.md`; write the completed artifact to `src/<eng>/delivery/codebase-architecture-map.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 6's line to `- [x] 6 Codebase & Architecture Map — delivery/codebase-architecture-map.md`. If no step-6 line exists, insert it in numeric order after step 5.
7. **Report next.** Tell the user what was produced and the next action: Run `/stabilization-backlog <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
