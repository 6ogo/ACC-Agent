# Web Applications in Adobe Campaign Classic

**Complete walkthroughs for building web applications from scratch**

---

## Overview

Web applications in Adobe Campaign Classic are browser-based interfaces built using JSP (frontend) and JSSP (backend API) files. They enable you to create portals, dashboards, data management tools, and interactive forms that integrate with Campaign data.

This section contains step-by-step walkthroughs that guide you through building real-world applications.

---

## Prerequisites

Before starting any walkthrough:

1. **Access** to an Adobe Campaign Classic instance
2. **Permissions** to create web applications (Resources > Online > Web applications)
3. **Basic knowledge** of JavaScript and HTML
4. **Familiarity** with ACC navigation (helpful but not required)

---

## Walkthroughs

| # | Title | Level | What You'll Build |
|---|-------|-------|-------------------|
| 01 | [Simple Portal Application](01-simple-portal-app.md) | Beginner | Card-based portal with search |
| 02 | [Interactive Table with AJAX](02-interactive-table-ajax.md) | Beginner | Data table with real-time updates |
| 03 | [Dashboard with Charts](03-dashboard-with-charts.md) | Intermediate | Analytics dashboard with Chart.js |
| 04 | [Multi-Page Application](04-multi-page-application.md) | Intermediate | Wizard flow with session state |

---

## Learning Path

**New to ACC web applications?** Follow this recommended order:

```
01-simple-portal-app.md     → Learn QueryDef basics and JSP templating
        ↓
02-interactive-table-ajax.md → Add JSSP APIs and AJAX calls
        ↓
03-dashboard-with-charts.md  → Aggregate queries and Chart.js
        ↓
04-multi-page-application.md → Session state and page navigation
```

---

## Application Structure

All ACC web applications follow this structure:

```
Web Application (in ACC interface)
├── Properties
│   ├── Internal name (used in URLs)
│   ├── Label (human-readable)
│   └── Access rights
├── Pages
│   ├── page1.jsp          # Frontend page
│   ├── page2.jsp          # Additional pages
│   └── api/
│       └── getData.jssp   # Backend API endpoint
├── Storage schema (optional)
└── Transitions (page flow)
```

---

## Quick Reference

### Creating a Web Application

1. Navigate to **Resources > Online > Web applications**
2. Click **New** (or right-click > New)
3. Choose **Empty web application**
4. Set the **Internal name** (no spaces, used in URLs)
5. Set the **Label** (human-readable name)
6. Click **Save**

### Key Concepts

| Concept | Description |
|---------|-------------|
| **JSP** | Frontend pages with HTML + embedded JavaScript |
| **JSSP** | Backend API endpoints returning JSON |
| **QueryDef** | API for querying Campaign database |
| **xtk.session.Write** | API for writing/updating data |
| **ctx.vars** | Session variables for state management |
| **logonEscalation** | Authentication for JSSP endpoints |

---

## Common Patterns

### Query and Display Data

```jsp
<%
var query = xtk.queryDef.create({
  queryDef: {
    schema: "nms:recipient",
    operation: "select",
    select: { node: [
      {expr: "@id"},
      {expr: "@firstName"},
      {expr: "@email"}
    ]}
  }
});
var results = query.ExecuteQuery();
%>
<% for each (var row in results.recipient) { %>
  <div><%= row.@firstName %> - <%= row.@email %></div>
<% } %>
```

### AJAX API Endpoint

```javascript
// api/getData.jssp
<%
logonEscalation("webapp");
response.setContentType("application/json");

var data = { success: true, items: [] };
// ... query and build response
document.write(JSON.stringify(data));
%>
```

---

## Related Documentation

- [JSP Development Guide](../../03-JSP-DEVELOPMENT.md) - Frontend patterns
- [JSSP API Guide](../../04-JSSP-API.md) - Backend API patterns
- [Code Templates](../../08-CODE-TEMPLATES.md) - Production-ready templates
- [Troubleshooting](../../09-TROUBLESHOOTING.md) - Common issues

---

**Ready to start?** Begin with [01 - Simple Portal Application](01-simple-portal-app.md)
