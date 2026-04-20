# Getting Started with Adobe Campaign Classic Web Applications

## Overview

Web applications in Adobe Campaign Classic enable you to create custom interfaces for:
- Campaign dashboards and analytics
- Administrative tools and configuration interfaces
- Data visualization and reporting
- Integration endpoints and APIs

## System Architecture

```
┌─────────────────────────────────────────┐
│   Adobe Campaign Classic Instance      │
├─────────────────────────────────────────┤
│                                         │
│  ┌───────────┐        ┌──────────────┐ │
│  │  Web App  │◄───────┤   Database   │ │
│  │  (JSP)    │        │  (Postgres)  │ │
│  └─────┬─────┘        └──────────────┘ │
│        │                                │
│  ┌─────▼─────┐                         │
│  │  API      │                         │
│  │  (JSSP)   │                         │
│  └───────────┘                         │
└─────────────────────────────────────────┘
         ▲
         │ HTTPS
         │
    ┌────▼────┐
    │ Browser │
    └─────────┘
```

## File Types

### JSP (JavaScript Server Pages)
- **Purpose**: Frontend pages with HTML, CSS, and server-side JavaScript
- **Location**: Web application pages
- **Extension**: `.jsp`
- **Rendering**: Server-side, outputs HTML to browser
- **Use Cases**: Dashboards, forms, reports

### JSSP (JavaScript Server Pages - API)
- **Purpose**: Backend APIs returning JSON/XML
- **Location**: Web application pages
- **Extension**: `.jssp`
- **Rendering**: Server-side, outputs JSON/XML
- **Use Cases**: AJAX endpoints, data APIs, integrations

## Core Concepts

### 1. Server-Side JavaScript (E4X)
Adobe Campaign uses JavaScript with E4X (ECMAScript for XML):

```javascript
// E4X syntax for XML manipulation
var delivery = <delivery id="123" label="Newsletter">
  <target>
    <recipient id="456"/>
  </target>
</delivery>;

// Access attributes with @
var deliveryId = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c2afaba6a6fbfaabbdbda7aeafa3a7b6abadac82">[email&#160;protected]</a>;

// Access child elements
var recipient = delivery.target.recipient;
```

### 2. QueryDef API
Standard way to query ACC database:

```javascript
// Create query
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@lastModified"/>
    </select>
    <where>
      <condition expr="@label LIKE '%Newsletter%'"/>
    </where>
  </queryDef>
);

// Execute and get results
var results = query.ExecuteQuery();
```

### 3. Request/Response Cycle

```javascript
// JSP Page
<%
// Get parameters from URL
var filter = request.getParameter('filter');
var page = request.getParameter('page') || '1';

// Query database
var data = fetchData(filter);

// Render HTML
for each(var item in data) {
  document.write("<div>" + <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f1b69c87949594bb">[email&#160;protected]</a>() + "</div>");
}
%>
```

## Creating Your First Web Application

### Step 1: Create Web Application in ACC Interface

1. Navigate to **Resources > Web > Web Applications**
2. Click **New**
3. Choose **Empty web application**
4. Set internal name (e.g., `myFirstApp`)
5. Set label (e.g., "My First Application")
6. Click **Save**

### Step 2: Add a JSP Page

1. Open your web application
2. Go to **Edit > Page**
3. Click **Add** 
4. Choose **Page (JSP)**
5. Name it `index.jsp`
6. Click **OK**

### Step 3: Basic Page Template

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My First Webapp</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
      background: #f5f7fa;
    }
    .card {
      background: white;
      padding: 30px;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    h1 {
      color: #005aa0;
      margin-top: 0;
    }
  </style>
</head>
<body>
  <div class="card">
    <h1>Welcome to My First Webapp</h1>
    <%
    // Server-side JavaScript
    var currentDate = new Date();
    var userName = ctx.userInfo.@login.toString();
    %>
    <p>Current time: <%= currentDate.toLocaleString() %></p>
    <p>Logged in as: <%= userName %></p>
    
    <%
    // Query example
    var query = xtk.queryDef.create(
      <queryDef schema="nms:webApp" operation="select">
        <select>
          <node expr="@label"/>
        </select>
        <where>
          <condition expr="@id = [$(id)]"/>
        </where>
      </queryDef>
    );
    var webapp = query.ExecuteQuery();
    %>
    <p>This webapp: <%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="07687463606171772f476a6e63606968296b6475626d626629736871666962">[email&#160;protected]</a>() %></p>
  </div>
</body>
</html>
```

### Step 4: Test Your Application

1. Save the page
2. Click **Preview** or open the URL:
   ```
   https://your-instance.campaign.adobe.com/webApp/yourAppInternalName
   ```

## Common Patterns

### Pattern 1: Portal/Dashboard

```jsp
<%
// Query for multiple web applications
var query = xtk.queryDef.create(
  <queryDef schema="nms:webApp" operation="select">
    <select>
      <node expr="@internalName"/>
      <node expr="@label"/>
      <node expr="@lastModified"/>
    </select>
    <where>
      <condition expr="@internalName IN ('app1', 'app2', 'app3')"/>
    </where>
  </queryDef>
);
var webApps = query.ExecuteQuery();
%>

<div class="cards-grid">
  <% for each(var app in webApps.webApp) { %>
    <a href="/webApp/<%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c7afb2b3eaf8f4f287aaa6a3a0a9e9bea6">[email&#160;protected]</a>() %>" class="card">
      <h3><%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="711c181514023c311c18151614">[email&#160;protected]</a>() %></h3>
      <p>Updated: <%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1265617c717a6f775266607b677d7c7d3c6e7f7c">[email&#160;protected]</a>() %></p>
    </a>
  <% } %>
</div>
```

### Pattern 2: Data Table with Filters

```jsp
<%
// Get filter parameters
var nameFilter = request.getParameter('name') || '';
var dateFrom = request.getParameter('dateFrom') || '';

// Build dynamic where clause
var whereConditions = [];
if (nameFilter) {
  whereConditions.push("@label LIKE '%" + nameFilter + "%'");
}
if (dateFrom) {
  whereConditions.push("@created >= '" + dateFrom + "'");
}
var whereExpr = whereConditions.length > 0 ? 
  whereConditions.join(' AND ') : 
  "1=1";

// Query with filters
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@created"/>
    </select>
    <where>
      <condition expr={whereExpr}/>
    </where>
    <orderBy>
      <node expr="@created" sortDesc="true"/>
    </orderBy>
  </queryDef>
);
var deliveries = query.ExecuteQuery();
%>

<!-- Filter form -->
<form method="get">
  <input type="text" name="name" value="<%= nameFilter %>" 
         placeholder="Search name...">
  <input type="date" name="dateFrom" value="<%= dateFrom %>">
  <button type="submit">Search</button>
</form>

<!-- Results table -->
<table>
  <thead>
    <tr>
      <th>ID</th>
      <th>Label</th>
      <th>Created</th>
    </tr>
  </thead>
  <tbody>
    <% for each(var delivery in deliveries.delivery) { %>
      <tr>
        <td><%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0b666a687e4b6664">[email&#160;protected]</a>() %></td>
        <td><%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="13767c7e7d6a77537e7a777c7e">[email&#160;protected]</a>() %></td>
        <td><%= <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4c2d2a222926610c202d3e39002429262921206823253e2d22292862382b">[email&#160;protected]</a>() %></td>
      </tr>
    <% } %>
  </tbody>
</table>
```

### Pattern 3: JSSP API Endpoint

```javascript
<%
// optionUpdate.jssp
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  message: "",
  data: null
};

try {
  var action = request.getParameter("action");
  var id = request.getParameter("id");
  
  if (!action || !id) {
    throw new Error("Missing parameters");
  }
  
  // Perform action
  if (action === "getData") {
    var query = xtk.queryDef.create(
      <queryDef schema="nms:recipient" operation="get">
        <select>
          <node expr="@id"/>
          <node expr="@email"/>
        </select>
        <where>
          <condition expr={"@id = " + id}/>
        </where>
      </queryDef>
    );
    var recipient = query.ExecuteQuery();
    
    result.success = true;
    result.data = {
      id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8ec0fbebeae9e3ebfacefce1e3">[email&#160;protected]</a>(),
      email: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d0b5bcb4a4a290a2b1b4b1a3a4">[email&#160;protected]</a>()
    };
  }
  
} catch(e) {
  result.message = e.message || e.toString();
}

document.write(JSON.stringify(result));
%>
```

## Development Environment

### Required Permissions
- Web application creation rights
- Schema read access
- Appropriate data access based on use case

### Browser Console
Use browser developer tools for debugging:
```javascript
// Check for JavaScript errors
console.log("Debug info");
console.error("Error details");
```

### Server Logs
Check Adobe Campaign logs for server-side errors:
- Navigate to **Administration > Production > Logs**
- Filter by web application name
- Look for errors and warnings

## Next Steps

1. **Learn JSP Development** → [JSP Development Guide](03-JSP-DEVELOPMENT.md)
2. **Understand Queries** → [Database & Queries](05-DATABASE-QUERIES.md)
3. **Explore Templates** → [Code Templates](08-CODE-TEMPLATES.md)

## Quick Reference

### Essential Variables
```javascript
ctx.userInfo.@login        // Current user login
request.getParameter()     // URL parameters
document.write()           // Output to page
logInfo()                  // Write to log
```

### Common Queries
```javascript
// Count records
var count = xtk.queryDef.create(...).ExecuteQuery().@count;

// Get single record
var record = xtk.queryDef.create(...).ExecuteQuery();

// Get multiple records
var results = xtk.queryDef.create(...).ExecuteQuery();
for each(var item in results.schemaName) { }
```

### HTML Output
```jsp
<% document.write("<p>Server-side output</p>"); %>
<!-- OR -->
<%= variable %> <!-- Direct interpolation -->
<!-- OR -->
<% for each(var item in items) { %>
  <div><%= item %></div>
<% } %>
```

---

**Continue to** → [Architecture Guide](02-ARCHITECTURE.md)
