---
description: Release readiness (greenfield step 15): assess a release into a release-keyed Release Readiness Pack, via the devops agent.
argument-hint: <engagement-slug> <release-label>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/release-readiness** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring** command — run it per release candidate. It is for **greenfield** engagements; inherited engagements run `/modernize` instead.

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is the release label (`<release>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<release>` is empty, ask the user which release (e.g. `v1.2` or `sprint-3`). Validate `<release>` as a path-safe token: REJECT it (and ask again) if it contains `/`, `\`, whitespace, or `..`, or starts with `.` or `-`. This keeps the artifact safely under `src/<eng>/delivery/`.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Scenario guard.** This command is for **greenfield** engagements. If `engagement.md`'s `scenario` is not `greenfield`, STOP and tell the user: "`<eng>` is classified as **inherited** — its milestone wrap-up is `/modernize <eng>` (Modernization Roadmap), not release readiness."
4. **Soft prerequisite check.** Confirm `src/<eng>/delivery/sprint-planning-support-pack.md` exists. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — release readiness usually runs late in an active sprint; proceeding anyway." Then CONTINUE — do not block.
5. **Derive the output path.** `<output>` = `src/<eng>/delivery/release-readiness/<release>.md`. Create the `src/<eng>/delivery/release-readiness/` folder if it does not exist.
6. **Delegate to the agent.** Use the Task tool to spawn the **devops** subagent (`subagent_type: devops`). Instruct it to: read the prior artifacts in `src/<eng>/delivery/` (sprint planning pack, the release's `delivery/qa/` and `delivery/pr-review/` artifacts) and, if a cloned project repo is present under `src/<eng>/`, its CI/CD config and environment info; assess deployment readiness, rollback plan, and go/no-go for release **`<release>`**; fill the template `templates/shared/release-readiness-pack.md`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions). The agent never deploys autonomously — a human approves the deploy.
7. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · release-readiness · <release> → delivery/release-readiness/<release>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
8. **Report.** Tell the user what was produced (and where) and that a human (DevOps / PO) owns the go/no-go and the deploy — the pack is advisory and the `devops` agent never deploys autonomously. Continue the sprint loop or close out the milestone.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
