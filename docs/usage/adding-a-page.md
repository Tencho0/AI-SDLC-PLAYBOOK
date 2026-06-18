# Adding a Page

**Audience:** delivery

## Purpose
Keep this guide easy to extend. Adding a page is a ~2-minute, four-step job.

## Steps
1. **Create the file** `docs/usage/<name>.md` using the standard page shape:
   `# Title` → `**Audience:** delivery | client | both` → `## Purpose` (1–2 sentences) →
   your sections → `## Read more` (links).
2. **Link, don't duplicate.** Point to the authoritative source — [CLAUDE.md](../../CLAUDE.md),
   [PLAYBOOK.md](../../playbook/PLAYBOOK.md), [mcp.md](../../playbook/mcp.md),
   [governance.md](../../playbook/governance.md) — instead of restating it. Use relative links
   (repo root is `../../`; sibling pages are bare names).
3. **Add one index line** to [README.md](README.md):
   `- [Title](<name>.md) — one-line hook [audience]`.
4. **Publish (optional)** per [publishing-to-ado-wiki.md](publishing-to-ado-wiki.md): add a row to
   its mapping table and re-run the publish.

## Conventions recap
- One index (README), one audience tag per page, consistent page shape, link over duplicate.
- Run `powershell -File scripts/verify-scaffold.ps1` after changes; it must print `ALL CHECKS PASSED`.

## Read more
- Index: [README.md](README.md)
- Publishing: [publishing-to-ado-wiki.md](publishing-to-ado-wiki.md)
