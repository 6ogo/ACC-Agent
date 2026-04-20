# ACC Wiki — By Task

Use this table to jump directly to the file and section that covers a specific task.
Anchors are best-effort based on known section headings; open the file to confirm.

---

## Core Development Tasks

| Task | File | Anchor / Section |
|------|------|-----------------|
| Understand ACC platform architecture | 02-ARCHITECTURE.md | top of file |
| Build a new web application (first time) | 01-GETTING-STARTED.md | #first-web-application |
| Use ready-made code templates | 08-CODE-TEMPLATES.md | top of file |
| Write a JSSP API endpoint | 04-JSSP-API.md | top of file |
| Handle HTTP request parameters in JSSP | 04-JSSP-API.md | (request handling section) |
| Set response headers (Content-Type, CORS) | 04-JSSP-API.md | (response headers section) |
| Handle authentication / logonEscalation | 04-JSSP-API.md | (auth section) |
| Return JSON from a JSSP endpoint | 04-JSSP-API.md | (JSON response section) |
| Pass form data from JSP to JSSP | 03-JSP-DEVELOPMENT.md | (form submission section) |
| Query the database with QueryDef | 05-DATABASE-QUERIES.md | top of file |
| Filter QueryDef results (WHERE conditions) | 05-DATABASE-QUERIES.md | (conditions/filters section) |
| Use NLWS patterns (nms.recipient, xtk.session) | 05-DATABASE-QUERIES.md | (NLWS section) |
| Execute raw SQL queries | 05-DATABASE-QUERIES.md | (SQL section) |
| Style a page / CSS patterns | 06-FRONTEND-PATTERNS.md | top of file |
| Build responsive layouts in ACC | 06-FRONTEND-PATTERNS.md | (layout section) |
| Optimise query performance | 07-SECURITY-PERFORMANCE.md | (performance section) |
| Apply rate limiting / throttle endpoints | 07-SECURITY-PERFORMANCE.md | (rate limiting section) |
| Secure JSSP endpoints | 07-SECURITY-PERFORMANCE.md | (security section) |
| Manage session / ctx variables | 10-ADVANCED-PATTERNS.md | #session-management |
| Use xtk.session.Write to persist data | 10-ADVANCED-PATTERNS.md | #xtksessionwrite-operations |
| Create or extend a custom schema | 10-ADVANCED-PATTERNS.md | #custom-schemas |

---

## Troubleshooting Tasks

| Task | File | Anchor / Section |
|------|------|-----------------|
| Troubleshoot empty query results | 09-TROUBLESHOOTING.md | #query-issues |
| Troubleshoot JSSP blank / empty response | 09-TROUBLESHOOTING.md | #javascript-errors |
| Debug authentication failures | 09-TROUBLESHOOTING.md | (auth section) |
| Diagnose session expiry issues | 09-TROUBLESHOOTING.md | (session section) |
| Resolve CORS errors from JSSP | 04-JSSP-API.md | (response headers / CORS section) |

---

## Workflow Scripting Examples

| Task | File | Anchor / Section |
|------|------|-----------------|
| Workflow script fundamentals | examples/Scripts/01-workflow-scripts-guide.md | top |
| Query and update records in a workflow | examples/Scripts/02-query-and-update-patterns.md | top |
| ETL file processing in a workflow | examples/Scripts/03-etl-processing.md | top |
| Manage deliveries / bulk sender update | examples/Scripts/04-delivery-management.md | top |

---

## Web Application Examples

| Task | File | Anchor / Section |
|------|------|-----------------|
| Build a portal or dashboard webapp | examples/Webapplications/01-simple-portal-app.md | top |
| Build an AJAX data table | examples/Webapplications/02-interactive-table-ajax.md | top |
| Build a Chart.js analytics dashboard | examples/Webapplications/03-dashboard-with-charts.md | top |
| Build a multi-page form wizard | examples/Webapplications/04-multi-page-application.md | top |

---

## Notes

- Anchors prefixed with `#` are heading anchors; navigate to the section heading in the file.
- Where an anchor is listed as "(section name)" the exact heading may vary — search the file for the keyword.
- If your task is not listed here, check `by-role.md` for broader guidance or open `00-INDEX.md` for the full topic index.
- If the topic is not in the wiki at all, see `gaps.md`.
