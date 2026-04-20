# Adobe Campaign Classic Web Development Wiki - Complete Framework

This comprehensive documentation framework provides everything you need to develop professional web applications in Adobe Campaign Classic.

## 📚 What's Included

This wiki contains 10 core documentation files covering the complete development lifecycle:

### Core Guides

1. **00-INDEX.md** - Main navigation and overview
2. **01-GETTING-STARTED.md** - Prerequisites, setup, and first application
3. **02-ARCHITECTURE.md** - System design, patterns, and structure
4. **03-JSP-DEVELOPMENT.md** - Complete frontend development guide
5. **04-JSSP-API.md** - Backend API development with JSSP
6. **05-DATABASE-QUERIES.md** - QueryDef patterns and database access
7. **06-FRONTEND-PATTERNS.md** - CSS architecture, components, and UX
8. **07-SECURITY-PERFORMANCE.md** - Security best practices and optimization
9. **08-CODE-TEMPLATES.md** - Production-ready code templates
10. **09-TROUBLESHOOTING.md** - Common issues and solutions
11. **10-ADVANCED-PATTERNS.md** - Advanced topics: sessions, context, custom schemas

### Hands-On Walkthroughs
Step-by-step tutorials to build complete applications:

**Beginner Level:**
- [01-Simple Portal App](examples/Webapplications/01-simple-portal-app.md) - Card-based portal with search functionality
- [02-Interactive Table with AJAX](examples/Webapplications/02-interactive-table-ajax.md) - Data table with real-time updates

**Intermediate Level:**
- [03-Dashboard with Charts](examples/Webapplications/03-dashboard-with-charts.md) - Analytics dashboard with Chart.js
- [04-Multi-Page Application](examples/Webapplications/04-multi-page-application.md) - Wizard flow with session state

## 🎯 Quick Start

### For New Developers
1. Start with **00-INDEX.md** for overview
2. Read **01-GETTING-STARTED.md** to create your first webapp
3. Use **08-CODE-TEMPLATES.md** for quick implementations

### For Experienced Developers
1. Jump to **08-CODE-TEMPLATES.md** for ready-to-use code
2. Reference **05-DATABASE-QUERIES.md** for advanced queries
3. Check **04-JSSP-API.md** for API patterns

### For Specific Tasks
- **Building a dashboard**: JSP Development → Template 1
- **Creating an API**: JSSP API → Template 5
- **Complex queries**: Database Queries → Common Patterns
- **Adding filters**: JSP Development → Forms & Filters

## 💡 Key Features

### Real Production Code
- All examples based on your actual production files
- Battle-tested patterns and practices
- Complete, runnable code snippets

### Comprehensive Coverage
- Frontend: JSP, HTML, CSS, JavaScript
- Backend: JSSP, APIs, data access
- Database: QueryDef, joins, aggregations
- Components: Tables, filters, charts, forms

### Best Practices Included
- Security patterns
- Performance optimization
- Error handling
- Logging strategies
- Code organization

## 🏗️ Repository Structure

```
wiki/
├── 00-INDEX.md               # Navigation & quick reference
├── 01-GETTING-STARTED.md     # Setup & fundamentals
├── 02-ARCHITECTURE.md        # Design patterns & structure
├── 03-JSP-DEVELOPMENT.md     # Frontend JSP development
├── 04-JSSP-API.md            # Backend API development
├── 05-DATABASE-QUERIES.md    # QueryDef & data access
├── 06-FRONTEND-PATTERNS.md   # CSS & UI components
├── 07-SECURITY-PERFORMANCE.md # Security & optimization
├── 08-CODE-TEMPLATES.md      # Production-ready templates
├── 09-TROUBLESHOOTING.md     # Debugging & solutions
├── 10-ADVANCED-PATTERNS.md   # Sessions, context, custom schemas
│
└── examples/                 # Step-by-step walkthroughs
    ├── README.md             # Examples overview
    ├── Webapplications/      # Web application tutorials
    │   ├── README.md
    │   ├── 01-simple-portal-app.md
    │   ├── 02-interactive-table-ajax.md
    │   ├── 03-dashboard-with-charts.md
    │   └── 04-multi-page-application.md
    └── Scripts/              # Workflow script guides
        ├── README.md
        ├── 01-workflow-scripts-guide.md
        ├── 02-query-and-update-patterns.md
        ├── 03-etl-processing.md
        └── 04-delivery-management.md
```

## 📖 Documentation Structure

```
00-INDEX.md
├── Quick Navigation
├── By Task
├── By Role
└── External Resources

01-GETTING-STARTED.md
├── System Architecture
├── File Types (JSP vs JSSP)
├── Core Concepts
├── Creating First App
└── Common Patterns

02-ARCHITECTURE.md
├── Application Patterns
├── File Organization
├── Data Flow
├── Design Patterns
└── State Management

03-JSP-DEVELOPMENT.md
├── JSP Fundamentals
├── Page Structure
├── Styling Patterns
├── Data Retrieval
├── UI Components
├── Forms & Filters
├── Tables & Grids
└── Charts

04-JSSP-API.md
├── JSSP Fundamentals
├── API Structure
├── Request Handling
├── Data Operations (CRUD)
├── Response Patterns
├── Error Handling
├── Security
└── AJAX Integration

05-DATABASE-QUERIES.md
├── QueryDef Fundamentals
├── Select Operations
├── Where Conditions
├── Joins & Relationships
├── Aggregations
├── Ordering & Pagination
├── Performance Tips
└── Common Patterns

06-FRONTEND-PATTERNS.md
├── CSS Architecture
├── Component Library
├── Layout Patterns
├── Responsive Design
└── Interactive Elements

07-SECURITY-PERFORMANCE.md
├── Authentication
├── Input Validation
├── SQL Injection Prevention
├── Performance Optimization
├── Caching Strategies
└── Monitoring & Logging

08-CODE-TEMPLATES.md
├── Complete Applications
├── Portal/Dashboard
├── Data Tables
├── Filter Forms
├── API Templates
├── Charts
└── Utility Functions

09-TROUBLESHOOTING.md
├── Query Issues
├── JavaScript Errors
├── Display Issues
├── API Problems
└── Common Error Messages

10-ADVANCED-PATTERNS.md
├── Custom Schemas
├── Session Management
├── Context Variables
├── Custom Libraries
├── Admin Panel Patterns
└── Date Handling
```

## 🔍 How to Use This Documentation

### Method 1: Sequential Learning
Read files in order (01 → 03 → 04 → 05 → 08) for comprehensive understanding.

### Method 2: Reference Mode
1. Find the pattern you need in INDEX
2. Jump to relevant section
3. Copy template code
4. Customize for your needs

### Method 3: Example-Driven
1. Open 08-CODE-TEMPLATES.md
2. Find template matching your task
3. Copy and adapt the code
4. Reference other guides for details

## 🚀 Example Workflows

### Creating a Dashboard
1. Copy Template 1 or 2 from CODE-TEMPLATES
2. Update query in JSP-DEVELOPMENT guide
3. Customize styling from Frontend Patterns
4. Deploy and test

### Building an API
1. Copy Template 5 from CODE-TEMPLATES
2. Implement CRUD operations from JSSP-API
3. Add security from Security section
4. Test with AJAX from Integration section

### Adding Filters
1. Copy Template 4 from CODE-TEMPLATES
2. Build dynamic queries from DATABASE-QUERIES
3. Add UI from JSP-DEVELOPMENT
4. Connect with form handling

## 📝 Code Examples

All code examples follow these standards:
- ✅ Complete, working code
- ✅ Inline comments explaining key concepts
- ✅ Error handling included
- ✅ Based on real production code
- ✅ Performance considerations noted

## 🔧 Customization Guide

### Branding
Replace these elements in templates:
- CSS variables (`:root` section)
- Logo URLs
- Color schemes
- Font families

### Schemas
Update these based on your data model:
- Schema names (`nms:delivery`, `nms:recipient`, etc.)
- Field names (`@label`, `@state`, etc.)
- Relationships and joins

### Business Logic
Customize these for your requirements:
- Filter conditions
- Calculations
- Validation rules
- Error messages

## 🎨 Styling System

All templates use CSS variables for easy theming:

```css
:root {
  --primary: #005aa0;
  --primary-light: #4495d1;
  --primary-dark: #004880;
  --gray-light: #f5f7fa;
  --white: #fff;
  --radius: 8px;
  --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
```

Change these values to match your brand.

## 🔗 External Resources

### Adobe Documentation
- Deep Wiki: https://deepwiki.com/AdobeDocs/campaign-classic.en
- Official Docs: https://experienceleague.adobe.com/docs/campaign-classic/

### Community
- Stack Overflow: [adobe-campaign] tag
- Adobe Community Forums

## 🎯 Next Steps

1. **Read INDEX** - Get oriented
2. **Create test app** - Follow Getting Started
3. **Explore templates** - Try Code Templates
4. **Reference guides** - Use as needed

## 💬 Tips for Success

### Development Best Practices
- Always test in development environment first
- Use logging extensively (`logInfo`, `logError`)
- Follow the security patterns
- Keep queries efficient
- Document your custom code

### Code Organization
- One concern per file (separation of concerns)
- Reusable functions in utility files
- Consistent naming conventions
- Clear comments for complex logic

### Performance
- Select only needed fields
- Use appropriate query operations
- Limit result sets
- Avoid queries in loops
- Cache when possible

## 🛠️ Troubleshooting

Common issues and solutions:

**Query not working?**
→ Check DATABASE-QUERIES.md for syntax

**API returning errors?**
→ Review JSSP-API.md error handling section

**Styling issues?**
→ Check JSP-DEVELOPMENT.md styling patterns

**Performance problems?**
→ See DATABASE-QUERIES.md performance tips

## 📦 What You Can Build

With this framework, you can create:
- ✅ Dashboards and portals
- ✅ Analytics applications
- ✅ Admin interfaces
- ✅ Data tables with filtering
- ✅ REST-like APIs
- ✅ Charts and visualizations
- ✅ Form-based applications
- ✅ Real-time data displays

## 🔐 Security Notes

- Always use `logonEscalation("webapp")` in JSSP
- Sanitize user inputs
- Validate all parameters
- Use parameterized queries
- Check user permissions
- Log all operations

## 🎓 Learning Path

**Beginner**: INDEX → Getting Started → [Walkthrough 01](examples/Webapplications/01-simple-portal-app.md) → [Walkthrough 02](examples/Webapplications/02-interactive-table-ajax.md)
**Intermediate**: JSP Development → JSSP API → [Walkthrough 03](examples/Webapplications/03-dashboard-with-charts.md) → [Walkthrough 04](examples/Webapplications/04-multi-page-application.md)
**Advanced**: All guides + Advanced Patterns + deep customization

---

## 📄 File Summary

| File | Purpose |
|------|---------|
| 00-INDEX.md | Navigation and overview |
| 01-GETTING-STARTED.md | Setup and fundamentals |
| 02-ARCHITECTURE.md | Design patterns and structure |
| 03-JSP-DEVELOPMENT.md | Frontend JSP development |
| 04-JSSP-API.md | Backend API development |
| 05-DATABASE-QUERIES.md | QueryDef and data access |
| 06-FRONTEND-PATTERNS.md | CSS and UI components |
| 07-SECURITY-PERFORMANCE.md | Security and optimization |
| 08-CODE-TEMPLATES.md | Production-ready templates |
| 09-TROUBLESHOOTING.md | Common issues and solutions |
| 10-ADVANCED-PATTERNS.md | Advanced ACC patterns |
| **examples/Webapplications/** | |
| 01-simple-portal-app.md | Portal application walkthrough |
| 02-interactive-table-ajax.md | AJAX table walkthrough |
| 03-dashboard-with-charts.md | Dashboard walkthrough |
| 04-multi-page-application.md | Multi-page wizard walkthrough |
| **examples/Scripts/** | |
| 01-workflow-scripts-guide.md | Script fundamentals |
| 02-query-and-update-patterns.md | QueryDef patterns |
| 03-etl-processing.md | ETL and file handling |
| 04-delivery-management.md | Delivery automation |

---

**Happy Coding!**

For questions or issues, reference the relevant guide sections or check the external resources.
