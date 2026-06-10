# src/ — engagement workspace (gitignored)

Everything in this folder is **gitignored** (except this README) so the playbook repo
stays pristine and reusable across many projects.

## Layout — one folder per engagement

```
src/
└── <engagement>/            # short slug, e.g. acme-portal
    ├── request/             # drop the raw client request here
    ├── delivery/            # generated artifacts (briefs, backlogs, assessments, reports)
    └── <project-repo>/      # the project's OWN git repo, cloned here
```

- **Working analysis artifacts** → `delivery/`.
- **Durable project docs** (the project's own README, CLAUDE.md, ADRs) and **code/tests** → inside `<project-repo>/`.
- You can host multiple engagements side-by-side here; the playbook tooling is shared, the data stays isolated.
