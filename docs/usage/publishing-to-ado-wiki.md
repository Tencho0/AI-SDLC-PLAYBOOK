# 📤 Publishing to the ADO Wiki

**Audience:** 🛠️ Delivery team

## Purpose
Publish this usage guide into the engagement's Azure DevOps project wiki on demand. The
repo stays canonical; the wiki is a published mirror you refresh when ready.

## Prerequisites
- The `ado` MCP server is connected (see [playbook/mcp.md](../../playbook/mcp.md) §4.3 and §4.8).
- The PAT used for `ado` has the **Wiki (Read & Write)** scope — the read-only setup PAT cannot
  publish pages. Add it to the token in ADO, then re-run `scripts/setup-mcp.ps1` (or just reload if
  you edited the existing token in place).
- The target project has a wiki. Discover it with the `ado` tool `wiki_list_wikis`; if none exists,
  create a project wiki once in the ADO UI (Project → Overview → Wiki → Create project wiki) and note its id/name.

## Page mapping (stable paths)
Each file maps to a fixed wiki page path under one parent so re-publishing **updates** the same page
instead of creating duplicates:

| Repo file | Wiki page path |
|-----------|----------------|
| `docs/usage/README.md` | `/AI-SDLC Playbook` (parent landing page) |
| `docs/usage/getting-started.md` | `/AI-SDLC Playbook/Getting Started` |
| `docs/usage/running-an-engagement.md` | `/AI-SDLC Playbook/Running an Engagement` |
| `docs/usage/running-a-sprint.md` | `/AI-SDLC Playbook/Running a Sprint` |
| `docs/usage/governance-and-reviews.md` | `/AI-SDLC Playbook/Governance and Reviews` |
| `docs/usage/for-clients.md` | `/AI-SDLC Playbook/For Clients` |
| `docs/usage/publishing-to-ado-wiki.md` | `/AI-SDLC Playbook/Publishing to the ADO Wiki` |
| `docs/usage/adding-a-page.md` | `/AI-SDLC Playbook/Adding a Page` |

The README is published as the `/AI-SDLC Playbook` **parent** page; create it first, since the
others are its children. All eight pages are published so no in-guide link is left dangling.

## Publish process
1. Ask an agent (with `ado` access) to "publish the usage guide to the <project> wiki."
2. It creates the parent `/AI-SDLC Playbook` page first, then each child, calling the `ado` tool
   `wiki_create_or_update_page` with the page path and the file's contents.
3. **Link handling during publish:** sibling `*.md` links are rewritten to their wiki page paths
   (e.g. `(getting-started.md)` → `(/AI-SDLC Playbook/Getting Started)`) so in-wiki navigation works.
   Repo-relative links (`../../...`, e.g. to CLAUDE.md / PLAYBOOK.md) are left as-is and **do not
   resolve in the wiki** — the repo stays the canonical reference for those.
4. **Table of contents (wiki-only):** insert `[[_TOC_]]` on its own line after the audience badge on the longer pages (Getting Started, Running an Engagement, Running a Sprint, Governance and Reviews). It is NOT kept in the repo files because GitHub renders `[[_TOC_]]` as literal text.
5. Re-running repeats the same paths, so existing pages are updated, not duplicated.

## Governance
Publishing is client-visible. The delivery team reviews content before publishing; never include
anything from `.env` or `src/` (secrets / client-confidential).

## 📚 Read more
- ADO MCP setup: [playbook/mcp.md](../../playbook/mcp.md)
- Adding/extending pages: [adding-a-page.md](adding-a-page.md)
