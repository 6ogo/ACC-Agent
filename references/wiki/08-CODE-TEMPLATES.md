# Code Templates - Ready to Use

Production-ready code templates for Adobe Campaign Classic web applications.

## Table of Contents
1. [Complete Application Templates](#complete-application-templates)
2. [Portal/Dashboard Templates](#portaldashboard-templates)
3. [Data Table Templates](#data-table-templates)
4. [Filter Form Templates](#filter-form-templates)
5. [API Templates (JSSP)](#api-templates-jssp)
6. [Chart Templates](#chart-templates)
7. [Utility Functions](#utility-functions)

---

## Complete Application Templates

### Template 1: Simple Dashboard

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - ACC</title>
  <style>
    :root {
      --primary: #005aa0;
      --gray-light: #f5f7fa;
      --white: #fff;
      --radius: 8px;
      --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: Arial, sans-serif;
      background: var(--gray-light);
      padding: 20px;
    }
    .container { max-width: 1200px; margin: 0 auto; }
    .header {
      background: var(--white);
      padding: 20px;
      border-radius: var(--radius);
      margin-bottom: 20px;
      box-shadow: var(--shadow);
    }
    h1 { color: var(--primary); }
    .cards-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 20px;
    }
    .card {
      background: var(--white);
      padding: 20px;
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      text-decoration: none;
      color: #000;
      transition: transform 0.2s;
    }
    .card:hover { transform: translateY(-4px); }
    .card-title { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Application Dashboard</h1>
      <p>Welcome, <%= ctx.userInfo.@login %></p>
    </div>
    
    <%
    // Query for web applications
    var query = xtk.queryDef.create(
      <queryDef schema="nms:webApp" operation="select">
        <select>
          <node expr="@internalName"/>
          <node expr="@label"/>
          <node expr="@lastModified"/>
        </select>
        <where>
          <condition expr="@state = 1"/>
        </where>
        <orderBy>
          <node expr="@label"/>
        </orderBy>
      </queryDef>
    );
    var apps = query.ExecuteQuery();
    %>
    
    <div class="cards-grid">
      <% for each(var app in apps.webApp) { %>
        <a href="/webApp/<%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6a06180b0e031b1b452a070309">[email&#160;protected]</a>() %>" class="card">
          <div class="card-title"><%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ddb2a8b9bcb1f89d">[email&#160;protected]</a>() %></div>
          <div>Updated: <%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8fe9e6eee7e8cfe3e7e4e7eae3a6f0e1">[email&#160;protected]</a>() %></div>
        </a>
      <% } %>
    </div>
  </div>
</body>
</html>
```

---

## Portal/Dashboard Templates

### Template 2: Advanced Portal with Search

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Portal</title>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:400,500,600&display=swap">
  <style>
    :root {
      --primary: #005aa0;
      --primary-light: #4495d1;
      --gray-light: #f5f7fa;
      --gray: #eaeef2;
      --white: #fff;
      --radius: 8px;
      --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Roboto', Arial, sans-serif;
      background: var(--gray-light);
      padding: 20px;
    }
    .container { max-width: 1200px; margin: 0 auto; }
    .header {
      background: var(--white);
      padding: 30px;
      border-radius: var(--radius);
      margin-bottom: 20px;
      box-shadow: var(--shadow);
    }
    h1 { color: var(--primary); margin-bottom: 10px; }
    .search-box {
      background: var(--white);
      padding: 20px;
      border-radius: var(--radius);
      margin-bottom: 20px;
      box-shadow: var(--shadow);
    }
    .search-box input {
      width: 100%;
      padding: 12px;
      border: 1px solid var(--gray);
      border-radius: calc(var(--radius) / 2);
      font-size: 16px;
    }
    .search-box input:focus {
      outline: none;
      border-color: var(--primary);
    }
    .cards-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 20px;
    }
    .card {
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
      overflow: hidden;
      transition: transform 0.2s, box-shadow 0.2s;
      cursor: pointer;
      text-decoration: none;
      color: #000;
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
    .card-content { padding: 15px; }
    .card-title {
      font-size: 18px;
      font-weight: 600;
      color: var(--primary);
      margin-bottom: 8px;
    }
    .card-meta {
      font-size: 13px;
      color: #999;
    }
    .empty-message {
      text-align: center;
      padding: 60px 20px;
      color: #999;
      background: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Application Portal</h1>
      <p>Select an application to continue</p>
    </div>
    
    <form method="get" class="search-box">
      <input type="text" 
             name="search" 
             value="<%= request.getParameter('search') || '' %>" 
             placeholder="Search applications...">
    </form>
    
    <%
    // Get search parameter
    var searchTerm = request.getParameter('search') || '';
    
    // Query with search filter
    var conditions = ["@state = 1"];
    if (searchTerm) {
      conditions.push("(@label LIKE '%" + searchTerm + "%' OR @internalName LIKE '%" + searchTerm + "%')");
    }
    var whereExpr = conditions.join(' AND ');
    
    var query = xtk.queryDef.create(
      <queryDef schema="nms:webApp" operation="select">
        <select>
          <node expr="@internalName"/>
          <node expr="@label"/>
          <node expr="@lastModified"/>
        </select>
        <where>
          <condition expr={whereExpr}/>
        </where>
        <orderBy>
          <node expr="@label"/>
        </orderBy>
      </queryDef>
    );
    
    var apps = query.ExecuteQuery();
    var appList = [];
    
    // Build array and generate initials
    for each(var app in apps.webApp) {
      var label = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a9c7c4d8dce9c4c0">[email&#160;protected]</a>();
      var words = label.split(' ');
      var initials = '';
      
      if (words.length >= 2) {
        initials = words[0].charAt(0).toUpperCase() + words[1].charAt(0).toUpperCase();
      } else if (words.length === 1 && words[0].length > 0) {
        initials = words[0].charAt(0).toUpperCase();
        if (words[0].length > 1) {
          initials += words[0].charAt(1).toUpperCase();
        }
      } else {
        initials = 'WA';
      }
      
      appList.push({
        internalName: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6c0003190e0306021e1e402c01050f">[email&#160;protected]</a>(),
        label: label,
        lastModified: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5c3c3b333a351c303437343930753830">[email&#160;protected]</a>(),
        initials: initials
      });
    }
    %>
    
    <div class="cards-grid">
      <% 
      if (appList.length > 0) {
        for (var i = 0; i < appList.length; i++) {
          var app = appList[i];
      %>
        <a href="/webApp/<%= app.internalName %>" class="card">
          <div class="card-image"><%= app.initials %></div>
          <div class="card-content">
            <div class="card-title"><%= app.label %></div>
            <div class="card-meta">Updated: <%= app.lastModified %></div>
          </div>
        </a>
      <%
        }
      } else {
      %>
        <div class="empty-message" style="grid-column: 1 / -1;">
          No applications found matching "<%= searchTerm %>"
        </div>
      <%
      }
      %>
    </div>
  </div>
</body>
</html>
```

---

## Data Table Templates

### Template 3: Sortable Data Table

```jsp
<%
// Query data
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" lineCount="100">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@state"/>
      <node expr="@lastModified"/>
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
var deliveryList = [];

for each(var delivery in deliveries.delivery) {
  deliveryList.push({
    id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="20626b20">[email&#160;protected]</a>(),
    label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bb94d8fbd6d2">[email&#160;protected]</a>(),
    state: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="54223023143d39">[email&#160;protected]</a>(),
    lastModified: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fa9a9d959c93ba96929192">[email&#160;protected]</a>()
  });
}
%>

<style>
.table-container {
  background: #fff;
  border-radius: 8px;
  overflow-x: auto;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
table {
  width: 100%;
  border-collapse: collapse;
}
thead {
  background: #f5f7fa;
}
th {
  padding: 12px;
  text-align: left;
  font-weight: 600;
  border-bottom: 2px solid #eaeef2;
  cursor: pointer;
}
th:hover {
  background: #eaeef2;
}
td {
  padding: 12px;
  border-bottom: 1px solid #eaeef2;
}
tbody tr:hover {
  background: #f5f7fa;
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
</style>

<div class="table-container">
  <table id="dataTable">
    <thead>
      <tr>
        <th onclick="sortTable(0)">ID ▼</th>
        <th onclick="sortTable(1)">Label ▼</th>
        <th onclick="sortTable(2)">State ▼</th>
        <th onclick="sortTable(3)">Last Modified ▼</th>
      </tr>
    </thead>
    <tbody>
      <% for (var i = 0; i < deliveryList.length; i++) {
        var item = deliveryList[i];
        var stateLabel = item.state == 1 ? 'Sent' : item.state == 2 ? 'Failed' : 'Draft';
      %>
        <tr>
          <td><%= item.id %></td>
          <td><%= item.label %></td>
          <td><span class="badge state-<%= item.state %>"><%= stateLabel %></span></td>
          <td><%= item.lastModified %></td>
        </tr>
      <% } %>
    </tbody>
  </table>
</div>

<script>
function sortTable(column) {
  var table = document.getElementById('dataTable');
  var rows = Array.from(table.tBodies[0].rows);
  
  rows.sort(function(a, b) {
    var aVal = a.cells[column].textContent.trim();
    var bVal = b.cells[column].textContent.trim();
    
    // Try numeric comparison
    if (!isNaN(aVal) && !isNaN(bVal)) {
      return parseFloat(aVal) - parseFloat(bVal);
    }
    
    // String comparison
    return aVal.localeCompare(bVal);
  });
  
  // Re-append rows
  rows.forEach(function(row) {
    table.tBodies[0].appendChild(row);
  });
}
</script>
```

---

## Filter Form Templates

### Template 4: Multi-Field Filter Form

```jsp
<%
// Get filter parameters
var nameFilter = request.getParameter('name') || '';
var stateFilter = request.getParameter('state') || '';
var dateFrom = request.getParameter('dateFrom') || '';
var dateTo = request.getParameter('dateTo') || '';

// Get available states for dropdown
var stateQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" distinct="true">
    <select>
      <node expr="@state"/>
    </select>
    <where>
      <condition expr="@state IS NOT NULL"/>
    </where>
    <orderBy>
      <node expr="@state"/>
    </orderBy>
  </queryDef>
);
var states = stateQuery.ExecuteQuery();

// Build where conditions
var conditions = ["1=1"];
if (nameFilter) {
  conditions.push("@label LIKE '%" + nameFilter + "%'");
}
if (stateFilter) {
  conditions.push("@state = " + stateFilter);
}
if (dateFrom) {
  conditions.push("@lastModified >= '" + dateFrom + "'");
}
if (dateTo) {
  conditions.push("@lastModified <= '" + dateTo + "'");
}
var whereExpr = conditions.join(' AND ');

// Query with filters
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@state"/>
      <node expr="@lastModified"/>
    </select>
    <where>
      <condition expr={whereExpr}/>
    </where>
    <orderBy>
      <node expr="@lastModified" sortDesc="true"/>
    </orderBy>
  </queryDef>
);
var results = query.ExecuteQuery();
%>

<style>
.filter-section {
  background: #fff;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}
.filter-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
  margin-bottom: 15px;
}
.filter-group {
  display: flex;
  flex-direction: column;
}
label {
  font-weight: 500;
  margin-bottom: 5px;
}
input, select {
  padding: 10px;
  border: 1px solid #eaeef2;
  border-radius: 4px;
  font-size: 14px;
}
input:focus, select:focus {
  outline: none;
  border-color: #005aa0;
}
.filter-actions {
  display: flex;
  gap: 10px;
}
button {
  padding: 10px 20px;
  background: #005aa0;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-weight: 500;
}
button:hover {
  background: #004880;
}
button.secondary {
  background: #98a6b3;
}
</style>

<form method="get" id="filterForm" class="filter-section">
  <h2 style="margin-bottom: 15px;">Filters</h2>
  
  <div class="filter-row">
    <div class="filter-group">
      <label for="name">Name</label>
      <input type="text" 
             id="name" 
             name="name" 
             value="<%= nameFilter %>" 
             placeholder="Search by name...">
    </div>
    
    <div class="filter-group">
      <label for="state">State</label>
      <select id="state" name="state">
        <option value="">All States</option>
        <% for each(var row in states) {
          var stateVal = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fa989e9bba93">[email&#160;protected]</a>();
          var selected = (stateVal == stateFilter) ? 'selected' : '';
        %>
          <option value="<%= stateVal %>" <%= selected %>>
            State <%= stateVal %>
          </option>
        <% } %>
      </select>
    </div>
    
    <div class="filter-group">
      <label for="dateFrom">Date From</label>
      <input type="date" 
             id="dateFrom" 
             name="dateFrom" 
             value="<%= dateFrom %>">
    </div>
    
    <div class="filter-group">
      <label for="dateTo">Date To</label>
      <input type="date" 
             id="dateTo" 
             name="dateTo" 
             value="<%= dateTo %>">
    </div>
  </div>
  
  <div class="filter-actions">
    <button type="submit">Apply Filters</button>
    <button type="button" class="secondary" onclick="resetFilters()">
      Reset
    </button>
  </div>
</form>

<!-- Results display -->
<div>
  <p>Found <%= results.@count %> results</p>
  <!-- Display results here -->
</div>

<script>
function resetFilters() {
  window.location.href = window.location.pathname;
}
</script>
```

---

## API Templates (JSSP)

### Template 5: Complete JSSP API

```javascript
<%
/**
 * Generic API Template
 * Methods: GET, POST
 */

// Required authentication
logonEscalation("webapp");

// Set response type
response.contentType = "application/json";

// Initialize response
var result = {
  success: false,
  error: {
    code: null,
    message: ""
  },
  data: null,
  metadata: {
    timestamp: new Date().toISOString(),
    user: ctx.userInfo.@login.toString()
  }
};

try {
  // Get parameters
  var action = request.getParameter("action");
  var id = request.getParameter("id");
  
  // Validate
  if (!action) {
    result.error.code = "MISSING_PARAMETER";
    throw new Error("Parameter 'action' is required");
  }
  
  // Log request
  logInfo("API Request - Action: " + action + ", User: " + result.metadata.user);
  
  // Route action
  switch(action) {
    case "get":
      if (!id) {
        result.error.code = "MISSING_PARAMETER";
        throw new Error("Parameter 'id' is required for get action");
      }
      result.data = getRecord(id);
      break;
      
    case "list":
      var filters = {
        search: request.getParameter("search") || "",
        limit: parseInt(request.getParameter("limit") || "50")
      };
      result.data = listRecords(filters);
      break;
      
    case "update":
      if (!id) {
        result.error.code = "MISSING_PARAMETER";
        throw new Error("Parameter 'id' is required for update action");
      }
      var newValue = request.getParameter("value");
      result.data = updateRecord(id, newValue);
      break;
      
    case "delete":
      if (!id) {
        result.error.code = "MISSING_PARAMETER";
        throw new Error("Parameter 'id' is required for delete action");
      }
      result.data = deleteRecord(id);
      break;
      
    default:
      result.error.code = "INVALID_ACTION";
      throw new Error("Invalid action: " + action);
  }
  
  result.success = true;
  result.error = null;
  logInfo("API Success - Action: " + action);
  
} catch(e) {
  if (!result.error.code) {
    result.error.code = "INTERNAL_ERROR";
  }
  result.error.message = e.message || e.toString();
  logError("API Error: " + result.error.message);
}

// Send response
document.write(JSON.stringify(result));

// Helper functions
function getRecord(id) {
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
  
  var record = query.ExecuteQuery();
  if (!record || !<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e3a8a3">[email&#160;protected]</a>) {
    throw new Error("Record not found: " + id);
  }
  
  return {
    id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0e484b0e37">[email&#160;protected]</a>(),
    label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bfd3d0cccaff">[email&#160;protected]</a>()
  };
}

function listRecords(filters) {
  var conditions = ["1=1"];
  if (filters.search) {
    conditions.push("@label LIKE '%" + filters.search + "%'");
  }
  
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="select" lineCount={filters.limit}>
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
      </select>
      <where>
        <condition expr={conditions.join(' AND ')}/>
      </where>
      <orderBy>
        <node expr="@label"/>
      </orderBy>
    </queryDef>
  );
  
  var results = query.ExecuteQuery();
  var items = [];
  for each(var record in results.delivery) {
    items.push({
      id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1e58595e27">[email&#160;protected]</a>(),
      label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ad81cfed">[email&#160;protected]</a>()
    });
  }
  
  return {
    items: items,
    count: items.length,
    total: results.@count
  };
}

function updateRecord(id, value) {
  var xml = <delivery _key={"@id"} id={id} label={value} xtkschema="nms:delivery"/>;
  xtk.session.Write(xml);
  return { id: id, updated: true };
}

function deleteRecord(id) {
  var xml = <delivery _operation="delete" _key={"@id"} id={id} xtkschema="nms:delivery"/>;
  xtk.session.Write(xml);
  return { id: id, deleted: true };
}
%>
```

---

## Chart Templates

### Template 6: Chart.js Integration

```jsp
<%
// Query monthly data
var query = xtk.queryDef.create(
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

var results = query.ExecuteQuery();
var months = [];
var counts = [];

for each(var row in results) {
  months.push("Month " + <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e78d8995a78e">[email&#160;protected]</a>());
  counts.push(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6f01071a01182f06">[email&#160;protected]</a>());
}
%>

<!DOCTYPE html>
<html>
<head>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    .chart-container {
      background: #fff;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      height: 400px;
    }
  </style>
</head>
<body>
  <div class="chart-container">
    <canvas id="myChart"></canvas>
  </div>
  
  <script>
  var ctx = document.getElementById('myChart').getContext('2d');
  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: <%= JSON.stringify(months) %>,
      datasets: [{
        label: 'Deliveries per Month',
        data: <%= JSON.stringify(counts) %>,
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
</body>
</html>
```

---

## Utility Functions

### Template 7: Common Helper Functions

```javascript
<%
// ===== DATE FUNCTIONS =====

function formatDate(dateString) {
  try {
    var date = new Date(dateString);
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    
    return year + '-' + 
           (month < 10 ? '0' : '') + month + '-' + 
           (day < 10 ? '0' : '') + day;
  } catch(e) {
    return dateString;
  }
}

function formatDateTime(dateString) {
  try {
    var date = new Date(dateString);
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    var hours = date.getHours();
    var minutes = date.getMinutes();
    
    return year + '-' + 
           (month < 10 ? '0' : '') + month + '-' + 
           (day < 10 ? '0' : '') + day + ' ' + 
           (hours < 10 ? '0' : '') + hours + ':' + 
           (minutes < 10 ? '0' : '') + minutes;
  } catch(e) {
    return dateString;
  }
}

// ===== STRING FUNCTIONS =====

function sanitizeString(str) {
  if (!str) return "";
  str = str.replace(/[<>'"]/g, '');
  return str.trim();
}

function truncate(str, length) {
  if (!str || str.length <= length) return str;
  return str.substring(0, length) + '...';
}

function getInitials(str) {
  if (!str) return 'NA';
  var words = str.split(' ');
  if (words.length >= 2) {
    return words[0].charAt(0).toUpperCase() + 
           words[1].charAt(0).toUpperCase();
  } else if (words.length === 1 && words[0].length > 0) {
    var initials = words[0].charAt(0).toUpperCase();
    if (words[0].length > 1) {
      initials += words[0].charAt(1).toUpperCase();
    }
    return initials;
  }
  return 'NA';
}

// ===== LOGGING FUNCTIONS =====

function logInfo(message) {
  try {
    var timestamp = new Date().toISOString();
    var logMsg = "[INFO] [" + timestamp + "] " + message;
    <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2242425b5c4a4f624e4a415a5151">logInfo</a>(logMsg);
  } catch(e) {}
}

function logError(message) {
  try {
    var timestamp = new Date().toISOString();
    var logMsg = "[ERROR] [" + timestamp + "] " + message;
    <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8de9eeeae3cde1e5eef5fcfc">logError</a>(logMsg);
  } catch(e) {}
}

// ===== QUERY HELPERS =====

function recordExists(schema, id) {
  var query = xtk.queryDef.create(
    <queryDef schema={schema} operation="getIfExists">
      <select>
        <node expr="@id"/>
      </select>
      <where>
        <condition expr={"@id = " + id}/>
      </where>
    </queryDef>
  );
  var result = query.ExecuteQuery();
  return (result && <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="89c7c0c9">[email&#160;protected]</a>);
}

function getDistinctValues(schema, fieldName) {
  var query = xtk.queryDef.create(
    <queryDef schema={schema} operation="select" distinct="true">
      <select>
        <node expr={"@" + fieldName}/>
      </select>
      <where>
        <condition expr={"@" + fieldName + " IS NOT NULL"}/>
        <condition expr={"@" + fieldName + " != ''"}/>
      </where>
      <orderBy>
        <node expr={"@" + fieldName}/>
      </orderBy>
    </queryDef>
  );
  
  var results = query.ExecuteQuery();
  var values = [];
  
  for each(var row in results) {
    var value = row['@' + fieldName].toString();
    if (value) {
      values.push(value);
    }
  }
  
  return values;
}

// ===== DATA CONVERSION =====

function xmlToArray(xmlCollection, schemaName) {
  var array = [];
  for each(var item in xmlCollection[schemaName]) {
    array.push(item);
  }
  return array;
}

function resultToJson(xmlResult) {
  var json = {};
  for each(var attr in xmlResult.@*) {
    json[attr.name().toString()] = attr.toString();
  }
  return json;
}

// ===== VALIDATION =====

function isValidEmail(email) {
  var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

function isNumeric(value) {
  return !isNaN(value) && !isNaN(parseFloat(value));
}

%>
```

---

**Usage Notes:**

1. **Copy the template you need** into your JSP/JSSP file
2. **Customize the schema and fields** to match your requirements
3. **Adjust styling** to match your brand
4. **Test thoroughly** before deploying to production
5. **Add error handling** as needed for your specific use case

**Next Steps:**
- [Troubleshooting](09-TROUBLESHOOTING.md) - Common issues and solutions
- [Security & Performance](07-SECURITY-PERFORMANCE.md) - Best practices
