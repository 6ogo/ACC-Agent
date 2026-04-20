# Adobe Campaign Classic Web Application Development Wiki

**Complete Guide to Building Professional Web Applications in Adobe Campaign Classic**

---

## 📚 Documentation Structure

### Core Guides
1. **[Getting Started](01-GETTING-STARTED.md)** - Overview, prerequisites, and quick start
2. **[Architecture Guide](02-ARCHITECTURE.md)** - System design, patterns, and structure
3. **[JSP Development](03-JSP-DEVELOPMENT.md)** - Frontend development with JSP
4. **[JSSP API Development](04-JSSP-API.md)** - Backend APIs with JSSP
5. **[Database & Queries](05-DATABASE-QUERIES.md)** - QueryDef, data access patterns
6. **[Frontend Patterns](06-FRONTEND-PATTERNS.md)** - Styling, components, UX
7. **[Security & Performance](07-SECURITY-PERFORMANCE.md)** - Best practices, optimization
8. **[Code Templates](08-CODE-TEMPLATES.md)** - Ready-to-use code snippets
9. **[Troubleshooting](09-TROUBLESHOOTING.md)** - Common issues and solutions
10. **[Advanced Patterns](10-ADVANCED-PATTERNS.md)** - Sessions, context variables, custom schemas

### Hands-On Walkthroughs
Complete step-by-step tutorials to build real applications:

| Walkthrough | Description | Level |
|-------------|-------------|-------|
| [01-Simple Portal App](examples/Webapplications/01-simple-portal-app.md) | Card-based portal with search functionality | Beginner |
| [02-Interactive Table](examples/Webapplications/02-interactive-table-ajax.md) | Data table with AJAX real-time updates | Beginner |
| [03-Dashboard with Charts](examples/Webapplications/03-dashboard-with-charts.md) | Analytics dashboard with Chart.js | Intermediate |
| [04-Multi-Page Application](examples/Webapplications/04-multi-page-application.md) | Multi-step wizard with sessions | Intermediate |

→ **[View All Examples](examples/README.md)** | **[Workflow Scripts](examples/Scripts/README.md)**

---

## 🎯 Quick Navigation

### By Task
- **Build a new webapp** → [Getting Started](01-GETTING-STARTED.md)
- **Create a dashboard** → [JSP Development](03-JSP-DEVELOPMENT.md#dashboard-pattern)
- **Build an API** → [JSSP API Development](04-JSSP-API.md)
- **Query data** → [Database & Queries](05-DATABASE-QUERIES.md)
- **Style components** → [Frontend Patterns](06-FRONTEND-PATTERNS.md)
- **Optimize performance** → [Security & Performance](07-SECURITY-PERFORMANCE.md)
- **Create custom schema** → [Advanced Patterns](10-ADVANCED-PATTERNS.md#custom-schemas)
- **Manage sessions** → [Advanced Patterns](10-ADVANCED-PATTERNS.md#session-management)
- **Pass context variables** → [Advanced Patterns](10-ADVANCED-PATTERNS.md#context-variables)
- **Write data to database** → [Advanced Patterns](10-ADVANCED-PATTERNS.md#xtksessionwrite-operations)
- **Learn by building** → [Hands-On Walkthroughs](examples/README.md)

### By Role
- **Frontend Developer** → JSP Development, Frontend Patterns
- **Backend Developer** → JSSP API, Database & Queries
- **Full Stack** → Architecture, all development guides
- **Designer** → Frontend Patterns
- **DevOps** → Security & Performance

---

## 💡 Key Concepts

### Web Application Types
1. **Portal/Dashboard** - Overview pages with cards/navigation
2. **Analytics Tool** - Data visualization with charts/tables
3. **Admin Interface** - Configuration and management tools
4. **API Endpoint** - JSSP for AJAX/JSON responses
5. **Report Generator** - Data extraction and presentation

### Technology Stack
- **Frontend**: JSP, HTML5, CSS3, JavaScript (ES5)
- **Backend**: JSSP (JavaScript Server Pages), E4X XML
- **Database**: PostgreSQL via xtk.queryDef API
- **Libraries**: Chart.js, External CDNs
- **Schemas**: nms:*, xtk:*, custom schemas

---

## 📖 Documentation Standards

### Code Examples
All examples follow these conventions:
- **Real-world patterns** from production code
- **Complete, runnable** code snippets
- **Inline comments** explaining key concepts
- **Error handling** included
- **Performance considerations** noted

### File Naming
- **JSP files**: `descriptiveName.jsp` (frontend pages)
- **JSSP files**: `apiEndpoint.jssp` (backend APIs)
- **Schemas**: `namespace:entityName` (e.g., `nms:delivery`)

---

## 🚀 Getting Started

### Prerequisites
- Adobe Campaign Classic instance access
- Web application creation permissions
- Basic JavaScript knowledge
- Understanding of HTML/CSS

### First Web Application
```javascript
// 1. Create new web application in ACC interface
// 2. Choose "Empty web application"
// 3. Add JSP page with this minimal template:

<!DOCTYPE html>
<html>
<head>
  <title>My First Webapp</title>
</head>
<body>
  <h1>Hello from Adobe Campaign!</h1>
  <%
    // Server-side JavaScript
    var currentDate = new Date();
    document.write("<p>Server time: " + currentDate + "</p>");
  %>
</body>
</html>
```

### Development Workflow
1. **Plan** - Define requirements and data needs
2. **Design** - Create wireframes and data models
3. **Develop** - Build JSP pages and JSSP APIs
4. **Test** - Verify functionality and performance
5. **Deploy** - Publish to production instance
6. **Monitor** - Track usage and errors

---

## 📚 External Resources

### Official Adobe Documentation
- [Campaign Classic Documentation](https://experienceleague.adobe.com/docs/campaign-classic/)
- [JavaScript API Reference](https://experienceleague.adobe.com/developer/campaign-api/)
- [Schema Reference](https://docs.adobe.com/content/help/en/campaign-classic/technicalresources/api/index.html)

### Deep Wiki Reference
https://deepwiki.com/AdobeDocs/campaign-classic.en

### Community Resources
- Adobe Campaign Community Forums
- Stack Overflow (tag: adobe-campaign)
- GitHub examples and templates

---

## 🔄 Version History

### v1.0 (Current)
- Complete development framework
- Production patterns from real applications
- Security and performance guidelines
- Comprehensive code templates

---

## 🤝 Contributing

### How to Use This Wiki
1. **Start with Getting Started** for overview
2. **Follow the numbered guides** in sequence
3. **Use Code Templates** for quick implementation
4. **Refer to Troubleshooting** when issues arise

### Best Practices
- Always test in development environment first
- Follow security guidelines
- Use provided templates as starting points
- Document your custom code
- Share patterns that work well

---

## 📞 Support

### Internal Resources
- Technical documentation team
- Developer community
- Code review process

### Reporting Issues
When encountering problems:
1. Check [Troubleshooting Guide](09-TROUBLESHOOTING.md)
2. Review related code examples
3. Verify query syntax
4. Check browser console for errors
5. Document steps to reproduce

---

**Ready to start?** → Begin with [Getting Started](01-GETTING-STARTED.md)
