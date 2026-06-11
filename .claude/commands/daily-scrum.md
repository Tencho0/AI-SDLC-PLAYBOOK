---
description: Daily Scrum (recurring, both scenarios): produce a date-keyed Daily Scrum Support Summary, via the scrum-planning agent.
argument-hint: <engagement-slug> [date]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/daily-scrum** command for the AI-SDLC playbook. Arguments: **$ARGUMENTS**

This is a **recurring**, **shared** command — run it each standup, in either scenario. It uses one template for both tracks (no scenario branch).

1. **Resolve arguments.** Split `$ARGUMENTS` on whitespace: the first token is the engagement slug (`<eng>`), the remainder is an optional date (`<date>`). If `<eng>` is empty, ask the user for it. Validate `<eng>` as kebab-case `^[a-z0-9][a-z0-9-]*$` (reject slash, backslash, space, dot, `..`, or a reserved name). If `<date>` is empty, DEFAULT it to today's date (from the environment) in `YYYY-MM-DD` form — do not ask. If `<date>` is given, it MUST match `YYYY-MM-DD`; otherwise ask again.
2. **Load state.** Read `src/<eng>/engagement.md`. If it does not exist, STOP and tell the user: "No engagement found — run `/intake <eng>` first." Do not proceed.
3. **Soft prerequisite check.** Read `scenario` from the frontmatter to pick the pack to check, then confirm it exists — greenfield: `src/<eng>/delivery/sprint-planning-support-pack.md`; inherited: `src/<eng>/delivery/inherited-sprint-planning-support-pack.md`. If it is missing, WARN: "Setup & planning isn't complete (no sprint planning pack) — the daily scrum usually runs during an active sprint; proceeding anyway." Then CONTINUE — do not block. (If `scenario` is missing or malformed, skip the pack check and continue.)
4. **Derive the output path.** `<output>` = `src/<eng>/delivery/daily-scrum/<date>.md`. Create the `src/<eng>/delivery/daily-scrum/` folder if it does not exist.
5. **Delegate to the agent.** Use the Task tool to spawn the **scrum-planning** subagent (`subagent_type: scrum-planning`). Instruct it to: read the sprint planning pack and the recent `delivery/execution/` artifacts in `src/<eng>/delivery/` to understand the Sprint Goal and in-flight work; summarise progress toward the Sprint Goal, impediments, and the focus for **`<date>`**; fill the template `templates/shared/daily-scrum-support-summary.md`; write the completed artifact to `<output>`; and follow the template's governance footer (separate Observed facts / Assumptions / Risks / Recommendations / Open questions).
6. **Update state.** In `src/<eng>/engagement.md`: (a) ensure the frontmatter has `phase: execution` (change `phase:` to `execution` if it is anything else) and a `sprint:` marker (add `sprint: 1` if none exists; otherwise leave its value unchanged); (b) append to the `## Activity log` section the line `- <today> · sprint <N> · daily-scrum · <date> → delivery/daily-scrum/<date>.md`, where `<today>` is today's date from the environment and `<N>` is the current `sprint` value. If there is no `## Activity log` section yet, add it after the `## Completed steps` section. Do NOT modify the `## Completed steps` checklist.
7. **Report.** Tell the user what was produced (and where) and that this is a focus aid the Developers own — not for micromanagement. Continue the sprint loop (`/execution`, `/pr-review`, `/qa`). To start a new sprint, bump `sprint:` in `engagement.md`.

You orchestrate only — the agent produces the artifact and a human reviews it. Never paste secrets or production data.
