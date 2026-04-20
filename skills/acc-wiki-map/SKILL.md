---
name: acc-wiki-map
description: This skill should be used when a user asks where a topic is documented in the ACC wiki, such as "where in the wiki is X", "which file covers authentication", "locate ACC documentation for QueryDef", "find the ACC wiki section for JSSP", "which guide covers web applications in ACC", or "ACC wiki section for workflows". Also use when routing a question to the appropriate wiki file or section.
version: 0.1.0
---

# ACC Wiki Map

This skill helps agents and users quickly navigate the ACC wiki without scanning all files.

## Wiki Location

The wiki lives at `${CLAUDE_PLUGIN_ROOT}/references/wiki/` (or a path explicitly provided by the agent at runtime). It contains **11 numbered core guide files** plus an `examples/` directory:

| # | File | Topic |
|---|------|-------|
| 00 | 00-INDEX.md | Master index and navigation |
| 01 | 01-GETTING-STARTED.md | Setup, first web application |
| 02 | 02-ARCHITECTURE.md | ACC platform architecture overview |
| 03 | 03-JSP-DEVELOPMENT.md | JSP page development |
| 04 | 04-JSSP-API.md | JSSP server-side JavaScript and API endpoints |
| 05 | 05-DATABASE-QUERIES.md | QueryDef, SQL, database access patterns |
| 06 | 06-FRONTEND-PATTERNS.md | CSS, HTML, UI patterns |
| 07 | 07-SECURITY-PERFORMANCE.md | Auth, security hardening, performance |
| 08 | 08-CODE-TEMPLATES.md | Ready-made reusable code snippets |
| 09 | 09-TROUBLESHOOTING.md | Debugging and error resolution |
| 10 | 10-ADVANCED-PATTERNS.md | Session management, xtk.session.Write, custom schemas |

The `examples/` directory is split into two sections:
- `examples/Scripts/` — four workflow scripting guides (01–04)
- `examples/Webapplications/` — four web application guides (01–04)

## How to Use This Skill

1. **Check `references/by-role.md` first** if you know the user's role (developer, architect, troubleshooter). It maps roles to the most relevant files.
2. **Check `references/by-task.md`** if you have a concrete task (e.g. "query the database", "handle authentication"). It maps tasks directly to files and anchors.
3. **Check `references/gaps.md`** before attempting to answer a question — if the topic is listed there, the wiki does not cover it and you should direct the user to Adobe Experience League instead.
4. Only open individual wiki files after narrowing down with the above references.

## Routing Logic

- For role-based routing → `references/by-role.md`
- For task-based routing → `references/by-task.md`
- For topics not in the wiki → `references/gaps.md`
- For a full topic index → `references/wiki/00-INDEX.md`

## Additional Resources

| File | Purpose |
|------|---------|
| `references/by-role.md` | Maps user roles (Developer, Architect, Troubleshooter, etc.) to relevant wiki files |
| `references/by-task.md` | Maps concrete tasks to the specific file and section that covers them |
| `references/gaps.md` | Lists topics NOT covered by the wiki; agents should redirect to Adobe Experience League for these |
