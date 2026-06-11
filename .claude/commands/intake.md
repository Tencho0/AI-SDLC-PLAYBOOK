---
description: Start an engagement — bootstrap its folder, classify greenfield/inherited, and produce the first brief via the product-discovery agent.
argument-hint: <engagement-slug>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task
---
You are running the **/intake** command for the AI-SDLC playbook. Engagement slug: **$ARGUMENTS**

Work through these steps in order. Stop and ask the user wherever a step says to ask — you are in the main conversation, so interaction is expected.

1. **Resolve and validate the engagement slug.** If `$ARGUMENTS` is empty, ask the user for a short slug (e.g. `acme-portal`). Call it `<eng>`. The slug MUST be a simple kebab-case token matching `^[a-z0-9][a-z0-9-]*$` — only lowercase letters, digits, and hyphens. REJECT it and ask again if it contains a slash, backslash, space, a dot, `..`, or is a reserved name (`README`, `README.md`). This guarantees everything stays safely under `src/<eng>/` and preserves the pristine-repo invariant (a slug like `README.md` or one containing `/` or `..` would otherwise become trackable or escape `src/`).

2. **Detect existing / bootstrap.** If `src/<eng>/engagement.md` already exists, this engagement is already started: read it, show the user its `scenario` and completed steps, and ask whether to re-run intake. If they decline, STOP. If they proceed, treat this as a **RE-RUN** (`<rerun>` = true) and reuse the existing `scenario` exactly — do NOT re-classify. Otherwise `<rerun>` = false. Create `src/<eng>/request/` and `src/<eng>/delivery/` if they do not exist.

3. **Classify (first run only).** If `<rerun>` is false, ask the user: "Is **<eng>** a **greenfield** (new build) or **inherited** (existing/takeover) project?" Wait for the answer; do not guess. If `<rerun>` is true, skip this step — the scenario is fixed from step 2. (To change an engagement's scenario, start a new engagement under a different slug; flipping in place would orphan the prior scenario's artifacts.)

4. **Resolve the request.** Look in `src/<eng>/request/`. If it contains files, use them as the client request. If it is empty, ask the user to paste the request text or give a file path, then save what they provide to `src/<eng>/request/request.md` (or copy the file into `request/`).

5. **Produce the first brief — delegate.** Use the Task tool to spawn the **product-discovery** subagent (`subagent_type: product-discovery`). Instruct it to read the request in `src/<eng>/request/`, fill the template — `templates/greenfield/project-request-brief.md` for greenfield or `templates/inherited/takeover-request-brief.md` for inherited — and write the completed artifact to `src/<eng>/delivery/project-request-brief.md` (greenfield) or `src/<eng>/delivery/takeover-request-brief.md` (inherited), following the template's governance footer.

6. **Write or update the state file.**
   - **First run** (`<rerun>` false): create `src/<eng>/engagement.md` with frontmatter `engagement: <eng>`, `scenario: <chosen>`, `phase: discovery`, `created: <today's date from the environment>`, then a `## Completed steps` checklist using EXACTLY this format — step 1 checked with its output path, the rest unchecked.
     Greenfield:
     ```
     ## Completed steps
     - [x] 1 Project Request Brief — delivery/project-request-brief.md
     - [ ] 2 Discovery Workshop Plan
     - [ ] 3 Discovery Meeting Summary
     - [ ] 4 Product Goal Draft
     - [ ] 5 Initial Product Backlog Pack
     - [ ] 6 Architecture & Technical Foundation Pack
     - [ ] 7 Refined Story Pack
     - [ ] 8 Sprint Planning Support Pack
     ```
     Inherited:
     ```
     ## Completed steps
     - [x] 1 Takeover Request Brief — delivery/takeover-request-brief.md
     - [ ] 2 Access & Information Checklist
     - [ ] 3 Initial System Assessment
     - [ ] 4 Inherited Project Goal Draft
     - [ ] 5 Business Rule Recovery Report
     - [ ] 6 Codebase & Architecture Map
     - [ ] 7 Stabilization Product Backlog
     - [ ] 8 Inherited Refined Story Pack
     - [ ] 9 Inherited Sprint Planning Support Pack
     ```
   - **Re-run** (`<rerun>` true): do NOT reset progress. Leave the frontmatter and every already-checked step exactly as they were — only confirm step 1 stays checked and points at the brief you just regenerated. Preserve steps 2–4 and their checkmarks as-is.

7. **Report next step.** Summarize what was produced (and where), then tell the user the next command: `/discovery-prep <eng>` for greenfield, or `/access-checklist <eng>` for inherited. On a re-run, also remind them which later steps are already complete so they don't redo them.

You orchestrate only — the agent produces the brief and a human reviews it. Never paste secrets or production data into prompts.
