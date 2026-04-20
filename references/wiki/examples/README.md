# Adobe Campaign Classic - Examples

**Step-by-step walkthroughs and production-tested patterns**

---

## Overview

This directory contains practical examples organized by type. Each section includes complete, working code that you can use as a starting point for your own implementations.

---

## Categories

### [Web Applications](Webapplications/README.md)

Build browser-based interfaces with JSP frontend and JSSP backend.

| Walkthrough | Level | Description |
|-------------|-------|-------------|
| [01 - Simple Portal](Webapplications/01-simple-portal-app.md) | Beginner | Card-based portal with search |
| [02 - Interactive Table](Webapplications/02-interactive-table-ajax.md) | Beginner | Data table with AJAX updates |
| [03 - Dashboard with Charts](Webapplications/03-dashboard-with-charts.md) | Intermediate | Analytics with Chart.js |
| [04 - Multi-Page Application](Webapplications/04-multi-page-application.md) | Intermediate | Wizard with session state |

---

### [Workflow Scripts](Scripts/README.md)

JavaScript automation for workflows and batch operations.

| Guide | Description |
|-------|-------------|
| [01 - Workflow Scripts Guide](Scripts/01-workflow-scripts-guide.md) | Fundamentals, logging, variables, error handling |
| [02 - Query and Update Patterns](Scripts/02-query-and-update-patterns.md) | QueryDef API, reading and updating data |
| [03 - ETL Processing](Scripts/03-etl-processing.md) | File handling, date logic, transformations |
| [04 - Delivery Management](Scripts/04-delivery-management.md) | Waves, typology, sender settings |

---

## Quick Start

### For Web Applications

1. Navigate to **Resources > Online > Web applications** in ACC
2. Create a new empty web application
3. Follow a [walkthrough](Webapplications/README.md) step by step
4. Reference the [Code Templates](../08-CODE-TEMPLATES.md) for production patterns

### For Workflow Scripts

1. Open or create a workflow in ACC
2. Add a **JavaScript code** activity
3. Use patterns from the [Scripts guides](Scripts/README.md)
4. Test with logging before running on production data

---

## Structure

```
examples/
├── README.md                    ← You are here
├── Webapplications/
│   ├── README.md                ← Web app overview
│   ├── 01-simple-portal-app.md
│   ├── 02-interactive-table-ajax.md
│   ├── 03-dashboard-with-charts.md
│   └── 04-multi-page-application.md
└── Scripts/
    ├── README.md                ← Scripts overview
    ├── 01-workflow-scripts-guide.md
    ├── 02-query-and-update-patterns.md
    ├── 03-etl-processing.md
    └── 04-delivery-management.md
```

---

## Learning Paths

### New to ACC Development

```
1. Read 01-GETTING-STARTED.md (root)
2. Try Webapplications/01-simple-portal-app.md
3. Learn Scripts/01-workflow-scripts-guide.md
4. Explore based on your needs
```

### Building a Dashboard

```
1. Webapplications/01-simple-portal-app.md (basics)
2. Webapplications/03-dashboard-with-charts.md
3. 04-JSSP-API.md for backend patterns
```

### Automating Delivery Updates

```
1. Scripts/01-workflow-scripts-guide.md (basics)
2. Scripts/02-query-and-update-patterns.md
3. Scripts/04-delivery-management.md
```

### Building ETL Workflows

```
1. Scripts/01-workflow-scripts-guide.md (basics)
2. Scripts/03-etl-processing.md
3. Scripts/04-delivery-management.md for automation patterns
```

---

## Related Documentation

| Document | Purpose |
|----------|---------|
| [Getting Started](../01-GETTING-STARTED.md) | ACC fundamentals |
| [JSP Development](../03-JSP-DEVELOPMENT.md) | Frontend patterns |
| [JSSP API](../04-JSSP-API.md) | Backend API patterns |
| [Database Queries](../05-DATABASE-QUERIES.md) | QueryDef reference |
| [Code Templates](../08-CODE-TEMPLATES.md) | Production-ready templates |
| [Troubleshooting](../09-TROUBLESHOOTING.md) | Common issues |

---

## Tips for Success

- **Start simple** - Get basic version working before adding features
- **Test frequently** - Run after each major change
- **Log everything** - Use `logInfo()` to track progress in scripts
- **Use code templates** - Reference [Code Templates](../08-CODE-TEMPLATES.md) for proven patterns
- **Read the guides** - Core documentation covers advanced patterns

---

**Choose your path:** [Web Applications](Webapplications/README.md) | [Workflow Scripts](Scripts/README.md)
