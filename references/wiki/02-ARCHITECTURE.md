# Architecture Guide

Complete guide to web application architecture in Adobe Campaign Classic.

## Table of Contents
1. [System Overview](#system-overview)
2. [Application Patterns](#application-patterns)
3. [File Organization](#file-organization)
4. [Data Flow](#data-flow)
5. [Design Patterns](#design-patterns)
6. [Multi-Page Applications](#multi-page-applications)
7. [State Management](#state-management)

---

## System Overview

### ACC Web Application Stack

```
┌─────────────────────────────────────────────┐
│           User Browser                      │
│  ┌──────────────┐    ┌──────────────┐      │
│  │   HTML/CSS   │    │  JavaScript  │      │
│  └──────────────┘    └──────────────┘      │
└─────────────────────────────────────────────┘
                    ▲
                    │ HTTPS
                    ▼
┌─────────────────────────────────────────────┐
│      Adobe Campaign Classic Server          │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │   Web Application Engine             │  │
│  │   ┌────────────┐   ┌──────────────┐ │  │
│  │   │    JSP     │   │    JSSP      │ │  │
│  │   │  (Pages)   │   │   (APIs)     │ │  │
│  │   └────────────┘   └──────────────┘ │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │   Business Logic Layer               │  │
│  │   ┌────────────────────────────────┐ │  │
│  │   │  xtk.queryDef (Data Access)    │ │  │
│  │   │  xtk.session.Write (Persist)   │ │  │
│  │   │  JavaScript Functions          │ │  │
│  │   └────────────────────────────────┘ │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │   Database Layer (PostgreSQL)        │  │
│  │   ┌────────────────────────────────┐ │  │
│  │   │  Schemas: nms:*, xtk:*, lf:*   │ │  │
│  │   │  Tables, Views, Indexes        │ │  │
│  │   └────────────────────────────────┘ │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

### Component Interaction

```
JSP Page Request
    ↓
1. User accesses /webApp/myApp
    ↓
2. JSP engine executes server-side code
    ↓
3. Queries database via xtk.queryDef
    ↓
4. Generates HTML with data
    ↓
5. Sends HTML to browser
    ↓
6. Browser renders page
    ↓
7. User interacts (clicks, forms)
    ↓
8. AJAX calls JSSP APIs
    ↓
9. JSSP processes, returns JSON
    ↓
10. JavaScript updates page
```

---

## Application Patterns

### Pattern 1: Simple Single Page Application

**Use Case**: Dashboard, report viewer, simple form

```
myApp/
  └── index.jsp          # Complete application in one file
```

**Architecture**:
```javascript
// index.jsp
<%
// 1. Query data
var data = xtk.queryDef.create(...).ExecuteQuery();

// 2. Render HTML
%>
<html>
  <head>
    <style>/* Styles */</style>
  </head>
  <body>
    <%
    // 3. Display data
    for each(var item in data) {
      document.write("<div>" + item + "</div>");
    }
    %>
    <script>
    // 4. Client-side interactions
    </script>
  </body>
</html>
```

### Pattern 2: Multi-Page Application

**Use Case**: Portal with multiple views, complex workflows

```
myApp/
  ├── index.jsp          # Landing/portal page
  ├── analytics.jsp      # Analytics view
  ├── admin.jsp          # Admin interface
  └── api/
      └── data.jssp      # API endpoint
```

**Navigation**:
```javascript
// index.jsp - Portal with links
<a href="/webApp/myApp?page=analytics">Analytics</a>
<a href="/webApp/myApp?page=admin">Admin</a>

// Router logic
<%
var page = request.getParameter('page') || 'home';
switch(page) {
  case 'analytics':
    // Include or redirect to analytics.jsp
    break;
  case 'admin':
    // Include or redirect to admin.jsp
    break;
  default:
    // Show home
}
%>
```

### Pattern 3: SPA with API Backend

**Use Case**: Interactive dashboard, real-time data

```
myApp/
  ├── index.jsp          # Frontend shell
  └── api/
      ├── list.jssp      # GET data
      ├── update.jssp    # UPDATE data
      └── create.jssp    # CREATE data
```

**Architecture**:
```javascript
// index.jsp - Minimal server-side rendering
<html>
  <body>
    <div id="app"></div>
    <script>
    // All logic in JavaScript
    fetch('/jssp/api/list.jssp')
      .then(r => r.json())
      .then(data => renderApp(data));
    </script>
  </body>
</html>

// api/list.jssp - Pure API
<%
logonEscalation("webapp");
response.contentType = "application/json";
var data = fetchData();
document.write(JSON.stringify(data));
%>
```

### Pattern 4: Hybrid Application

**Use Case**: Complex app with multiple concerns

```
myApp/
  ├── portal.jsp         # Landing page
  ├── dashboard.jsp      # Main dashboard
  ├── reports/
  │   ├── monthly.jsp
  │   └── annual.jsp
  ├── api/
  │   ├── analytics.jssp
  │   └── config.jssp
  └── shared/
      └── utils.js       # Shared utilities
```

---

## File Organization

### Recommended Structure

```
webApplication/
├── pages/
│   ├── index.jsp               # Entry point
│   ├── dashboard.jsp           # Main views
│   ├── analytics.jsp
│   └── admin.jsp
│
├── api/                        # Backend APIs
│   ├── data/
│   │   ├── list.jssp
│   │   ├── get.jssp
│   │   └── update.jssp
│   └── config/
│       └── options.jssp
│
├── components/                 # Reusable components
│   ├── header.jsp              # Shared header
│   ├── footer.jsp              # Shared footer
│   └── navigation.jsp          # Navigation menu
│
└── lib/                        # Utility functions
    ├── queries.js              # Query helpers
    ├── formatters.js           # Data formatters
    └── validators.js           # Input validation
```

### Naming Conventions

```javascript
// Files
myApplication.jsp              # camelCase for pages
dataList.jssp                  # camelCase for APIs
user-profile.jsp               # kebab-case acceptable

// Functions
function getUserData() {}      // camelCase
function calculateTotal() {}   // camelCase

// Variables
var totalCount = 0;            // camelCase
var USER_ROLE = "admin";       // UPPER_CASE for constants

// CSS Classes
.card-container {}             // kebab-case
.nav-item {}                   // kebab-case
```

---

## Data Flow

### Server-Side Rendering (JSP)

```
┌──────────────┐
│ User Request │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│  JSP Engine          │
│  - Execute queries   │
│  - Process logic     │
│  - Generate HTML     │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  Complete HTML       │
│  sent to browser     │
└──────────────────────┘
```

### Client-Side Updates (AJAX + JSSP)

```
┌──────────────┐
│ User Action  │
└──────┬───────┘
       │
       ▼
┌──────────────────────┐
│  JavaScript Event    │
│  - Fetch API call    │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  JSSP API            │
│  - Process request   │
│  - Return JSON       │
└──────┬───────────────┘
       │
       ▼
┌──────────────────────┐
│  JavaScript          │
│  - Update DOM        │
│  - No page reload    │
└──────────────────────┘
```

### Data Flow Example

```javascript
// 1. User loads page
// portal.jsp
<%
var apps = xtk.queryDef.create(...).ExecuteQuery();
%>
<div id="apps">
  <% for each(var app in apps.webApp) { %>
    <div><%= app.label %></div>
  <% } %>
</div>

// 2. User clicks "Refresh"
<button onclick="refreshApps()">Refresh</button>

// 3. AJAX call to API
<script>
function refreshApps() {
  fetch('/jssp/api/apps.jssp')
    .then(r => r.json())
    .then(data => {
      // 4. Update UI without reload
      updateAppsDisplay(data);
    });
}
</script>

// 4. JSSP returns fresh data
// api/apps.jssp
<%
logonEscalation("webapp");
response.contentType = "application/json";
var apps = xtk.queryDef.create(...).ExecuteQuery();
document.write(JSON.stringify(apps));
%>
```

---

## Design Patterns

### Pattern: Repository

**Centralize data access logic**

```javascript
// lib/deliveryRepository.js
<%
var DeliveryRepository = {
  
  getById: function(id) {
    var query = xtk.queryDef.create(
      <queryDef schema="nms:delivery" operation="get">
        <select>
          <node expr="@id"/>
          <node expr="@label"/>
        </select>
        <where>
          <condition expr={"@id = " + id}/>
        </where>
      </queryDef>
    );
    return query.ExecuteQuery();
  },
  
  list: function(filters) {
    var conditions = this._buildConditions(filters);
    var query = xtk.queryDef.create(
      <queryDef schema="nms:delivery" operation="select">
        <select>
          <node expr="@id"/>
          <node expr="@label"/>
        </select>
        <where>
          <condition expr={conditions}/>
        </where>
      </queryDef>
    );
    return query.ExecuteQuery();
  },
  
  _buildConditions: function(filters) {
    var conditions = ["1=1"];
    if (filters.name) {
      conditions.push("@label LIKE '%" + filters.name + "%'");
    }
    return conditions.join(' AND ');
  }
};
%>

// Usage in JSP
<%
var delivery = DeliveryRepository.getById(123);
var deliveries = DeliveryRepository.list({name: "Newsletter"});
%>
```

### Pattern: Service Layer

**Encapsulate business logic**

```javascript
// lib/deliveryService.js
<%
var DeliveryService = {
  
  getDeliveryWithStats: function(id) {
    // Get delivery
    var delivery = DeliveryRepository.getById(id);
    
    // Get stats
    var stats = this._calculateStats(id);
    
    // Combine
    return {
      delivery: delivery,
      stats: stats
    };
  },
  
  _calculateStats: function(deliveryId) {
    var query = xtk.queryDef.create(
      <queryDef schema="nms:broadLogRcp" operation="select">
        <select>
          <node expr="Count(@id)" alias="sent"/>
          <node expr="Sum(Case(When(@status=2, 1, 0)))" alias="opened"/>
        </select>
        <where>
          <condition expr={"@delivery-id = " + deliveryId}/>
        </where>
      </queryDef>
    );
    return query.ExecuteQuery();
  }
};
%>
```

### Pattern: Presenter/Formatter

**Format data for display**

```javascript
// lib/presenters.js
<%
var DeliveryPresenter = {
  
  format: function(delivery) {
    return {
      id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3141607156">[email&#160;protected]</a>(),
      label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="cea1e38ea3a7">[email&#160;protected]</a>(),
      state: this.formatState(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bfc9decfff">[email&#160;protected]</a>()),
      date: this.formatDate(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6a0a0d050c032a06020105">[email&#160;protected]</a>())
    };
  },
  
  formatState: function(state) {
    var states = {
      '0': 'Draft',
      '1': 'Sent',
      '2': 'Failed'
    };
    return states[state] || 'Unknown';
  },
  
  formatDate: function(dateStr) {
    try {
      var date = new Date(dateStr);
      return date.toLocaleDateString();
    } catch(e) {
      return dateStr;
    }
  },
  
  formatList: function(deliveries) {
    var formatted = [];
    for each(var delivery in deliveries.delivery) {
      formatted.push(this.format(delivery));
    }
    return formatted;
  }
};
%>
```

---

## Multi-Page Applications

### Approach 1: Multiple JSP Files

```javascript
// index.jsp - Portal
<html>
  <body>
    <nav>
      <a href="dashboard.jsp">Dashboard</a>
      <a href="reports.jsp">Reports</a>
    </nav>
  </body>
</html>

// dashboard.jsp - Separate page
<%
var data = fetchDashboardData();
%>
<html>
  <body>
    <h1>Dashboard</h1>
    <!-- Display data -->
  </body>
</html>
```

### Approach 2: Single File Router

```javascript
// app.jsp
<%
var page = request.getParameter('page') || 'home';

function renderPage(pageName) {
  switch(pageName) {
    case 'dashboard':
      return renderDashboard();
    case 'reports':
      return renderReports();
    default:
      return renderHome();
  }
}

function renderDashboard() {
  var data = fetchDashboardData();
  %>
  <h1>Dashboard</h1>
  <div><%= data %></div>
  <%
}

function renderHome() {
  %>
  <h1>Home</h1>
  <nav>
    <a href="?page=dashboard">Dashboard</a>
    <a href="?page=reports">Reports</a>
  </nav>
  <%
}
%>

<html>
  <body>
    <% renderPage(page); %>
  </body>
</html>
```

### Approach 3: Tab-Based Navigation

```javascript
// Single page with hidden/shown sections
<html>
  <body>
    <div class="tabs">
      <button onclick="showTab('overview')">Overview</button>
      <button onclick="showTab('details')">Details</button>
    </div>
    
    <div id="overview-tab" class="tab-content">
      <% renderOverview(); %>
    </div>
    
    <div id="details-tab" class="tab-content" style="display:none">
      <% renderDetails(); %>
    </div>
    
    <script>
    function showTab(tabName) {
      document.querySelectorAll('.tab-content').forEach(function(tab) {
        tab.style.display = 'none';
      });
      document.getElementById(tabName + '-tab').style.display = 'block';
    }
    </script>
  </body>
</html>
```

---

## State Management

### Session State (Server-Side)

```javascript
// Store in session
<%
session.addValue("userPreferences", {
  theme: "dark",
  language: "en"
});

// Retrieve from session
var prefs = session.getValue("userPreferences");
%>
```

### URL Parameters (Stateless)

```javascript
// Pass state via URL
<a href="?page=details&id=123&filter=active">View Details</a>

// Read state
<%
var page = request.getParameter('page');
var id = request.getParameter('id');
var filter = request.getParameter('filter');
%>
```

### Client-Side State (JavaScript)

```javascript
// Store in JavaScript variables
<script>
var appState = {
  currentPage: 'dashboard',
  filters: {},
  data: []
};

function updateState(newState) {
  appState = Object.assign({}, appState, newState);
  render();
}
</script>
```

### Local Storage (Persistent Client State)

```javascript
<script>
// Save to localStorage
function saveFilters(filters) {
  localStorage.setItem('filters', JSON.stringify(filters));
}

// Load from localStorage
function loadFilters() {
  var saved = localStorage.getItem('filters');
  return saved ? JSON.parse(saved) : {};
}
</script>
```

---

## Best Practices

### Separation of Concerns

```javascript
// ❌ BAD: Everything mixed
<%
var query = xtk.queryDef.create(...);
var data = query.ExecuteQuery();
%>
<html>
<style>.card { color: red; }</style>
<body>
<% for each(var item in data) { %>
  <div style="padding:10px"><%= item %></div>
<% } %>
<script>console.log('loaded');</script>
</body>
</html>

// ✅ GOOD: Separated
<%
// Data layer
var data = DataService.fetchData();
var formatted = Presenter.format(data);
%>
<html>
<head>
  <style>
  /* Styling */
  .card { color: red; }
  </style>
</head>
<body>
  <% for each(var item in formatted) { %>
    <div class="card"><%= item %></div>
  <% } %>
  
  <script>
  // Behavior
  initializeApp();
  </script>
</body>
</html>
```

### Reusability

```javascript
// Create reusable components
// components/card.jsp
<%
function renderCard(title, content) {
  %>
  <div class="card">
    <h3><%= title %></h3>
    <div><%= content %></div>
  </div>
  <%
}
%>

// Use in multiple pages
<% renderCard("Title", "Content"); %>
```

### Scalability

```javascript
// Use pagination for large datasets
var pageSize = 50;
var page = parseInt(request.getParameter('page') || '1');

var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" 
            operation="select" 
            lineCount={pageSize}
            startLine={(page-1) * pageSize}>
    <!-- query definition -->
  </queryDef>
);
```

---

## Architecture Checklist

**Planning Phase:**
- [ ] Define application type (SPA, multi-page, hybrid)
- [ ] Identify data sources and schemas
- [ ] Plan URL structure
- [ ] Design navigation flow
- [ ] Define API endpoints needed

**Development Phase:**
- [ ] Organize files logically
- [ ] Separate concerns (data, display, behavior)
- [ ] Create reusable components
- [ ] Implement error handling
- [ ] Add logging

**Testing Phase:**
- [ ] Test all navigation paths
- [ ] Verify data queries
- [ ] Check error handling
- [ ] Test with different user roles
- [ ] Validate performance

**Deployment Phase:**
- [ ] Document architecture decisions
- [ ] Create deployment checklist
- [ ] Set up monitoring
- [ ] Plan for maintenance

---

**Next Steps:**
- [JSP Development](03-JSP-DEVELOPMENT.md) - Implement frontend
- [JSSP API](04-JSSP-API.md) - Build backend APIs
- [Database Queries](05-DATABASE-QUERIES.md) - Data access patterns
