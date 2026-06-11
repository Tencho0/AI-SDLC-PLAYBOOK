---
description: Inherited takeover (step 3): assess the cloned project repo into an Initial System Assessment, via the implementation agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/system-assessment** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

1. **Resolve the engagement.** If `$ARGUMENTS` is empty, ask the user for the engagement slug. Call it `<eng>`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **inherited** engagements. If `engagement.md`'s `scenario` is not `inherited`, STOP and tell the user: "`<eng>` is classified as **greenfield** — use its discovery commands instead: `/discovery-prep`, `/discovery-summary`, `/product-goal`."
4. **Check prerequisites & locate the repo.** First, confirm step 2 is done: `src/<eng>/delivery/access-information-checklist.md` exists. If not, STOP with: "Access & Information Checklist missing — run `/access-checklist <eng>` first." Then locate the cloned project repo: a subdirectory of `src/<eng>/` other than `request/` and `delivery/` that actually contains the codebase (look for a `.git` directory or real source files). If there are none, STOP with: "No cloned project repo found under `src/<eng>/` — clone it into `src/<eng>/<project-repo>/` (access required) first." If there are several candidates, or the only candidate looks empty / non-code (e.g. a scratch or notes folder), ASK the user to confirm which folder is the project repo rather than guessing. Call the confirmed folder `<repo>`; produce nothing until a real repo is confirmed.
5. **Delegate to the agent.** Use the Task tool to spawn the **implementation** subagent (`subagent_type: implementation`). Instruct it to: read the confirmed project repo at `src/<eng>/<repo>/` plus prior artifacts in `src/<eng>/delivery/`; fill the template `templates/inherited/initial-system-assessment.md`; write the completed artifact to `src/<eng>/delivery/initial-system-assessment.md`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`, change step 3's line to `- [x] 3 Initial System Assessment — delivery/initial-system-assessment.md`.
7. **Report next.** Tell the user what was produced and the next action: Run `/stabilization-goal <eng>`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
