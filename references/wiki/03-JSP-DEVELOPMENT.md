# JSP Development Guide

Complete guide to building frontend web applications with JSP in Adobe Campaign Classic.

## Table of Contents
1. [JSP Fundamentals](#jsp-fundamentals)
2. [Page Structure](#page-structure)
3. [Styling Patterns](#styling-patterns)
4. [Data Retrieval](#data-retrieval)
5. [UI Components](#ui-components)
6. [Forms & Filters](#forms--filters)
7. [Tables & Grids](#tables--grids)
8. [Charts & Visualization](#charts--visualization)
9. [Performance Optimization](#performance-optimization)

---

## JSP Fundamentals

### Basic Syntax

```jsp
<!DOCTYPE html>
<html>
<head>
  <!-- Metadata -->
</head>
<body>
  <!-- Static HTML -->
  <h1>Welcome</h1>
  
  <%
  // Server-side JavaScript block
  var data = getData();
  %>
  
  <!-- Inline interpolation -->
  <p>Value: <%= data %></p>
  
  <% if (condition) { %>
    <div>Conditional content</div>
  <% } %>
  
  <% for each(var item in items) { %>
    <div><%= item %></div>
  <% } %>
</body>
</html>
```

### Server-Side vs Client-Side

```jsp
<%
// SERVER-SIDE: Executes on Adobe Campaign server
var serverData = xtk.queryDef.create(...).ExecuteQuery();
var userName = ctx.userInfo.@login;
%>

<script>
// CLIENT-SIDE: Executes in browser
var clientData = <%= JSON.stringify(serverData) %>;
console.log('User: ', '<%= userName %>');
</script>
```

---

## Page Structure

### Complete Production Template

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <!-- Disable caching for dynamic content -->
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="0">
  
  <title>Application Name - Organization</title>
  
  <!-- External Resources -->
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:400,500,600,700&display=swap">
  <link rel="shortcut icon" type="image/x-icon" href="https://your-logo-url.png">
  
  <!-- Optional: Chart.js for visualizations -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  
  <style>
    /* CSS Variables for theming */
    :root {
      --primary: #005aa0;
      --primary-light: #4495d1;
      --primary-dark: #004880;
      --gray-light: #f5f7fa;
      --gray: #eaeef2;
      --gray-dark: #98a6b3;
      --text: #000000;
      --red: #e30613;
      --green: #2ecc71;
      --white: #fff;
      --radius: 8px;
      --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    
    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }
    
    body {
      font-family: 'Roboto', Arial, sans-serif;
      color: var(--text);
      background-color: var(--gray-light);
      line-height: 1.6;
    }
    
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
    
    /* More styles... */
  </style>
</head>
<body>
  <div class="container">
    <!-- Logo -->
    <div class="logo-box">
      <img src="https://your-logo.svg" alt="Organization Logo">
    </div>
    
    <!-- Header -->
    <header>
      <h1>Application Title</h1>
      <p>Description or subtitle</p>
    </header>
    
    <%
    // Server-side logic
    var currentUser = ctx.userInfo.@login.toString();
    logInfo("User " + currentUser + " accessed webapp");
    %>
    
    <!-- Main Content -->
    <main>
      <!-- Content here -->
    </main>
    
    <!-- Footer -->
    <footer>
      <p>Last updated: <%= new Date().toLocaleDateString() %></p>
    </footer>
  </div>
  
  <script>
    // Client-side JavaScript
  </script>
</body>
</html>
```

---

## Styling Patterns

### CSS Architecture

```css
/* 1. CSS Variables (Root Level) */
:root {
  --primary: #005aa0;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
}

/* 2. Reset/Base Styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* 3. Typography */
body {
  font-family: 'Roboto', Arial, sans-serif;
  font-size: 16px;
  line-height: 1.6;
}

h1 { font-size: 2em; font-weight: 600; }
h2 { font-size: 1.5em; font-weight: 600; }

/* 4. Layout Components */
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* 5. UI Components */
.card {
  background: var(--white);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: 20px;
}

/* 6. Interactive States */
button:hover {
  background: var(--primary-dark);
  transform: translateY(-2px);
}

/* 7. Responsive Design */
@media (max-width: 768px) {
  .container {
    padding: 10px;
  }
}
```

### Card Grid Pattern

```css
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.card {
  background: var(--white);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  overflow: hidden;
  transition: transform 0.2s, box-shadow 0.2s;
  cursor: pointer;
  text-decoration: none;
  color: var(--text);
  display: flex;
  flex-direction: column;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
}

.card-image {
  height: 140px;
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--white);
  font-size: 48px;
  font-weight: 600;
}

.card-content {
  padding: 15px;
  flex: 1;
}

.card-title {
  font-size: 18px;
  font-weight: 600;
  color: var(--primary);
  margin-bottom: 8px;
}
```

---

## Data Retrieval

### Basic Query Pattern

```jsp
<%
// Helper function for logging
function logInfo(message) {
  try {
    var logMsg = "WEBAPP [" + new Date().toISOString() + "] " + message;
    <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3552554d44524675595d4746544758415c5b5a">logInfo</a>(logMsg);
  } catch(e) {}
}

// Query deliveries
logInfo("=== FETCHING DELIVERIES ===");
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@lastModified"/>
      <node expr="@state"/>
    </select>
    <where>
      <condition expr="@lastModified >= GetDate() - 30"/>
    </where>
    <orderBy>
      <node expr="@lastModified" sortDesc="true"/>
    </orderBy>
  </queryDef>
);

var deliveries = query.ExecuteQuery();
logInfo("Found " + deliveries.@count + " deliveries");

// Convert to array for easier handling
var deliveryList = [];
for each(var delivery in deliveries.delivery) {
  deliveryList.push({
    id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4803263b2d083a">[email&#160;protected]</a>(),
    label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="542132213e25143831">[email&#160;protected]</a>(),
    lastModified: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="85e4e3ebe2edc5e9edeeede0e9acfaecebe4e9ace9e5">[email&#160;protected]</a>(),
    state: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f9959a9596b99f909c">[email&#160;protected]</a>()
  });
}
%>
```

### Dynamic Filters with Query

```jsp
<%
// Get filter parameters
var nameFilter = request.getParameter('nameFilter') || '';
var stateFilter = request.getParameter('stateFilter') || '';
var dateFrom = request.getParameter('dateFrom') || '';

// Build where conditions
var conditions = [];
if (nameFilter) {
  conditions.push("@label LIKE '%" + nameFilter + "%'");
}
if (stateFilter) {
  conditions.push("@state = " + stateFilter);
}
if (dateFrom) {
  conditions.push("@lastModified >= '" + dateFrom + "'");
}

// Default condition if no filters
var whereExpr = conditions.length > 0 ? 
  conditions.join(' AND ') : 
  "1=1";

logInfo("Filter applied: " + whereExpr);

// Execute query with filters
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@state"/>
    </select>
    <where>
      <condition expr={whereExpr}/>
    </where>
  </queryDef>
);

var results = query.ExecuteQuery();
%>
```

### Multiple Related Queries

```jsp
<%
// Query deliveries
var deliveryQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <where>
      <condition expr="@id IN (SELECT iDeliveryId FROM nmsTrackingLogRcp WHERE iDeliveryId > 0 GROUP BY iDeliveryId LIMIT 10)"/>
    </where>
  </queryDef>
);
var deliveries = deliveryQuery.ExecuteQuery();

// For each delivery, get stats
var deliveryStats = [];
for each(var delivery in deliveries.delivery) {
  var deliveryId = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1f71504f53484d5f6d">[email&#160;protected]</a>();
  
  // Query tracking logs
  var trackingQuery = xtk.queryDef.create(
    <queryDef schema="nms:trackingLogRcp" operation="select">
      <select>
        <node expr="Count(@id)" alias="opens"/>
      </select>
      <where>
        <condition expr={"@delivery-id = " + deliveryId}/>
      </where>
    </queryDef>
  );
  var tracking = trackingQuery.ExecuteQuery();
  
  deliveryStats.push({
    id: deliveryId,
    label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="017563606264417c64">[email&#160;protected]</a>(),
    opens: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f69e849a9595829783b685998897">[email&#160;protected]</a>() || 0
  });
}
%>
```

---

## UI Components

### Card Component

```jsp
<%
// Render cards from data
for (var i = 0; i < deliveryList.length; i++) {
  var item = deliveryList[i];
  
  // Generate initials for card
  var initials = '';
  var words = item.label.split(' ');
  if (words.length >= 2) {
    initials = words[0].charAt(0).toUpperCase() + 
               words[1].charAt(0).toUpperCase();
  } else if (words.length === 1 && words[0].length > 0) {
    initials = words[0].charAt(0).toUpperCase();
    if (words[0].length > 1) {
      initials += words[0].charAt(1).toUpperCase();
    }
  } else {
    initials = 'DL';
  }
%>
  <a href="/view/<%= item.id %>" class="card">
    <div class="card-image">
      <%= initials %>
    </div>
    <div class="card-content">
      <div class="card-title"><%= item.label %></div>
      <div class="card-meta">
        Updated: <%= item.lastModified %>
      </div>
    </div>
  </a>
<%
}

// Show empty message if no results
if (deliveryList.length === 0) {
%>
  <div class="empty-message">
    No deliveries found matching your criteria.
  </div>
<%
}
%>
```

### Tab Navigation

```jsp
<!-- Tab navigation -->
<div class="nav-tabs">
  <button class="nav-tab active" onclick="switchTab('overview')">
    Overview
  </button>
  <button class="nav-tab" onclick="switchTab('details')">
    Details
  </button>
  <button class="nav-tab" onclick="switchTab('analytics')">
    Analytics
  </button>
</div>

<!-- Tab content -->
<div id="overview-tab" class="tab-content active">
  <!-- Overview content -->
</div>

<div id="details-tab" class="tab-content">
  <!-- Details content -->
</div>

<div id="analytics-tab" class="tab-content">
  <!-- Analytics content -->
</div>

<style>
.nav-tabs {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  border-bottom: 2px solid var(--gray);
}

.nav-tab {
  padding: 12px 24px;
  background: var(--white);
  border: none;
  cursor: pointer;
  font-weight: 500;
  border-radius: var(--radius) var(--radius) 0 0;
}

.nav-tab.active {
  background: var(--primary);
  color: var(--white);
}

.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
}
</style>

<script>
function switchTab(tabName) {
  // Hide all tabs
  var tabs = document.querySelectorAll('.tab-content');
  tabs.forEach(function(tab) {
    tab.classList.remove('active');
  });
  
  // Remove active from all buttons
  var buttons = document.querySelectorAll('.nav-tab');
  buttons.forEach(function(btn) {
    btn.classList.remove('active');
  });
  
  // Show selected tab
  document.getElementById(tabName + '-tab').classList.add('active');
  event.target.classList.add('active');
}
</script>
```

---

## Forms & Filters

### Complete Filter Form

```jsp
<form method="get" id="filterForm">
  <div class="filter-section">
    <h2>Filters</h2>
    
    <div class="filter-row">
      <!-- Text input -->
      <div class="filter-group">
        <label for="nameFilter">Search Name</label>
        <input type="text" 
               id="nameFilter" 
               name="nameFilter" 
               value="<%= request.getParameter('nameFilter') || '' %>" 
               placeholder="Enter name...">
      </div>
      
      <!-- Date input -->
      <div class="filter-group">
        <label for="dateFrom">Date From</label>
        <input type="date" 
               id="dateFrom" 
               name="dateFrom" 
               value="<%= request.getParameter('dateFrom') || '' %>">
      </div>
      
      <!-- Select dropdown -->
      <div class="filter-group">
        <label for="stateFilter">State</label>
        <select id="stateFilter" name="stateFilter">
          <option value="">All States</option>
          <%
          var selectedState = request.getParameter('stateFilter') || '';
          var states = [
            {value: '0', label: 'Draft'},
            {value: '1', label: 'Sent'},
            {value: '2', label: 'Failed'}
          ];
          for (var i = 0; i < states.length; i++) {
            var selected = (states[i].value == selectedState) ? 'selected' : '';
          %>
            <option value="<%= states[i].value %>" <%= selected %>>
              <%= states[i].label %>
            </option>
          <% } %>
        </select>
      </div>
    </div>
    
    <!-- Action buttons -->
    <div class="filter-actions">
      <button type="submit">Apply Filters</button>
      <button type="button" class="secondary" onclick="resetFilters()">
        Reset
      </button>
    </div>
  </div>
</form>

<script>
function resetFilters() {
  // Clear all form inputs
  document.getElementById('filterForm').reset();
  // Submit to reload without parameters
  window.location.href = window.location.pathname;
}
</script>

<style>
.filter-section {
  background: var(--white);
  padding: 20px;
  border-radius: var(--radius);
  margin-bottom: 20px;
  box-shadow: var(--shadow);
}

.filter-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 15px;
}

.filter-group {
  display: flex;
  flex-direction: column;
}

label {
  font-weight: 500;
  margin-bottom: 8px;
}

input, select {
  padding: 10px;
  border: 1px solid var(--gray);
  border-radius: calc(var(--radius) / 2);
  font-size: 14px;
}

input:focus, select:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(0, 90, 160, 0.2);
}

.filter-actions {
  display: flex;
  gap: 10px;
}

button {
  padding: 12px 24px;
  background: var(--primary);
  color: var(--white);
  border: none;
  border-radius: calc(var(--radius) / 2);
  cursor: pointer;
  font-weight: 500;
}

button.secondary {
  background: var(--gray-dark);
}
</style>
```

---

## Tables & Grids

### Responsive Data Table

```jsp
<div class="table-container">
  <table class="data-table">
    <thead>
      <tr>
        <th>ID</th>
        <th>Label</th>
        <th>State</th>
        <th>Last Modified</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% 
      for (var i = 0; i < deliveryList.length; i++) {
        var item = deliveryList[i];
      %>
        <tr>
          <td><%= item.id %></td>
          <td><%= item.label %></td>
          <td>
            <span class="badge state-<%= item.state %>">
              <%= getStateLabel(item.state) %>
            </span>
          </td>
          <td><%= formatDate(item.lastModified) %></td>
          <td>
            <button onclick="viewItem(<%= item.id %>)" class="btn-small">
              View
            </button>
          </td>
        </tr>
      <% } %>
    </tbody>
  </table>
</div>

<%
// Helper function to format state
function getStateLabel(state) {
  var states = {
    '0': 'Draft',
    '1': 'Sent',
    '2': 'Failed'
  };
  return states[state] || 'Unknown';
}

// Helper function to format date
function formatDate(dateStr) {
  try {
    var date = new Date(dateStr);
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    return year + '-' + 
           (month < 10 ? '0' : '') + month + '-' + 
           (day < 10 ? '0' : '') + day;
  } catch(e) {
    return dateStr;
  }
}
%>

<style>
.table-container {
  background: var(--white);
  border-radius: var(--radius);
  overflow-x: auto;
  box-shadow: var(--shadow);
}

.data-table {
  width: 100%;
  border-collapse: collapse;
}

.data-table thead {
  background: var(--gray-light);
}

.data-table th {
  padding: 12px;
  text-align: left;
  font-weight: 600;
  border-bottom: 2px solid var(--gray);
}

.data-table td {
  padding: 12px;
  border-bottom: 1px solid var(--gray);
}

.data-table tbody tr:hover {
  background: var(--gray-light);
}

.badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 600;
}

.state-0 { background: #ffeaa7; color: #d63031; }
.state-1 { background: #55efc4; color: #00b894; }
.state-2 { background: #fab1a0; color: #d63031; }

.btn-small {
  padding: 6px 12px;
  font-size: 12px;
}
</style>
```

---

## Charts & Visualization

### Chart.js Integration

```jsp
<%
// Query data for chart
var monthlyQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="Month(@lastModified)" alias="month"/>
      <node expr="Count(@id)" alias="count"/>
    </select>
    <where>
      <condition expr="@lastModified >= GetDate() - 365"/>
    </where>
    <groupBy>
      <node expr="Month(@lastModified)"/>
    </groupBy>
    <orderBy>
      <node expr="Month(@lastModified)"/>
    </orderBy>
  </queryDef>
);

var monthlyData = monthlyQuery.ExecuteQuery();

// Convert to arrays for Chart.js
var months = [];
var counts = [];
for each(var row in monthlyData) {
  months.push(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0f637e7c6e6b7a4f6263">[email&#160;protected]</a>());
  counts.push(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b4c5d5d0d8dbd8ddde91f4d0">[email&#160;protected]</a>());
}
%>

<div class="chart-container">
  <canvas id="monthlyChart"></canvas>
</div>

<script>
// Pass server data to client
var chartData = {
  labels: <%= JSON.stringify(months) %>,
  counts: <%= JSON.stringify(counts) %>
};

// Create chart
var ctx = document.getElementById('monthlyChart').getContext('2d');
new Chart(ctx, {
  type: 'bar',
  data: {
    labels: chartData.labels,
    datasets: [{
      label: 'Deliveries per Month',
      data: chartData.counts,
      backgroundColor: 'rgba(0, 90, 160, 0.7)',
      borderColor: 'rgba(0, 90, 160, 1)',
      borderWidth: 1
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false,
    scales: {
      y: {
        beginAtZero: true
      }
    }
  }
});
</script>

<style>
.chart-container {
  background: var(--white);
  padding: 20px;
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  height: 400px;
}
</style>
```

---

## Performance Optimization

### Efficient Queries

```jsp
<%
// BAD: Multiple queries in loop
for each(var delivery in deliveries.delivery) {
  var statsQuery = xtk.queryDef.create(...); // Query inside loop!
  var stats = statsQuery.ExecuteQuery();
}

// GOOD: Single query with aggregation
var statsQuery = xtk.queryDef.create(
  <queryDef schema="nms:trackingLogRcp" operation="select">
    <select>
      <node expr="@delivery-id" alias="deliveryId"/>
      <node expr="Count(@id)" alias="opens"/>
    </select>
    <where>
      <condition expr="@delivery-id IN (1,2,3,4,5)"/>
    </where>
    <groupBy>
      <node expr="@delivery-id"/>
    </groupBy>
  </queryDef>
);
var allStats = statsQuery.ExecuteQuery();
%>
```

### Data Pagination

```jsp
<%
var page = parseInt(request.getParameter('page') || '1');
var pageSize = 50;
var offset = (page - 1) * pageSize;

var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" lineCount={pageSize} startLine={offset}>
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
  </queryDef>
);

var results = query.ExecuteQuery();
var totalCount = results.@count;
var totalPages = Math.ceil(totalCount / pageSize);
%>

<!-- Pagination controls -->
<div class="pagination">
  <% if (page > 1) { %>
    <a href="?page=<%= page - 1 %>">Previous</a>
  <% } %>
  
  <span>Page <%= page %> of <%= totalPages %></span>
  
  <% if (page < totalPages) { %>
    <a href="?page=<%= page + 1 %>">Next</a>
  <% } %>
</div>
```

---

**Next Steps:**
- [JSSP API Development](04-JSSP-API.md) - Build backend APIs
- [Database & Queries](05-DATABASE-QUERIES.md) - Advanced query patterns
- [Code Templates](08-CODE-TEMPLATES.md) - Ready-to-use templates
