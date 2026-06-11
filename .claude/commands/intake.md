---
description: Start an engagement — bootstrap its folder, classify greenfield/inherited, and produce the first brief via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/intake** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

Work through these steps in order. Stop and ask the user wherever a step says to ask — you are in the main conversation, so interaction is expected.

1. **Resolve the engagement slug.** If `$ARGUMENTS` is empty, ask the user for a short slug (e.g. `acme-portal`). Call it `<eng>`.

2. **Bootstrap the workspace.** Create `src/<eng>/request/` and `src/<eng>/delivery/` if they do not exist. If `src/<eng>/engagement.md` already exists, show its `scenario` and completed steps and ask the user whether to re-run intake before continuing; stop if they decline.

3. **Classify (always ask).** Ask the user: "Is **<eng>** a **greenfield** (new build) or **inherited** (existing/takeover) project?" Wait for the answer. Do not guess.

4. **Resolve the request.** Look in `src/<eng>/request/`. If it contains files, use them as the client request. If it is empty, ask the user to paste the request text or give a file path, then save what they provide to `src/<eng>/request/request.md` (or copy the file into `request/`).

5. **Produce the first brief — delegate.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to read the request in `src/<eng>/request/`, fill the template — `templates/greenfield/project-request-brief.md` for greenfield or `templates/inherited/takeover-request-brief.md` for inherited — and write the completed artifact to `src/<eng>/delivery/project-request-brief.md` (greenfield) or `src/<eng>/delivery/takeover-request-brief.md` (inherited), following the template's governance footer.

6. **Write the state file.** Create `src/<eng>/engagement.md` with frontmatter `engagement: <eng>`, `scenario: <chosen>`, `phase: discovery`, `created: <today's date from the environment>`, then a `## Completed steps` checklist seeded for the chosen scenario with step 1 checked and pointing at the artifact from step 5:
   - greenfield: `1 Project Request Brief`, `2 Discovery Workshop Plan`, `3 Discovery Meeting Summary`, `4 Product Goal Draft`
   - inherited: `1 Takeover Request Brief`, `2 Access & Information Checklist`, `3 Initial System Assessment`, `4 Inherited Project Goal Draft`

7. **Report next step.** Summarize what was produced (and where), then tell the user the next command: `/discovery-prep <eng>` for greenfield, or `/access-checklist <eng>` for inherited.

You orchestrate only — the agent produces the brief and a human reviews it. Never paste secrets or production data into prompts.
