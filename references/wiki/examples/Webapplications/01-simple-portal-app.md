# Walkthrough 01: Simple Portal Application

**Build a card-based portal that displays web applications with search functionality**

---

## What You'll Build

A portal page that:
- Queries web applications from the ACC database
- Displays them as visual cards with initials
- Includes a search filter
- Links to each application

This walkthrough is based on the production file `code examples/app.jsp`.

---

## Step 1: Create the Web Application

1. Go to **Resources > Online > Web applications**
2. Create a new empty web application
3. Set Internal name: `simplePortal`
4. Set Label: `Simple Portal`
5. Save the application

---

## Step 2: Set Up the Page Structure

Create a new page called `main.jsp`. We'll build it section by section.

### 2.1 HTML Head and Styles

Start with the document structure and CSS variables for easy theming:

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Web Applications</title>
  <style>
    :root {
      --primary: #005aa0;
      --primary-light: #4495d1;
      --primary-dark: #004880;
      --gray-light: #f5f7fa;
      --gray: #eaeef2;
      --white: #fff;
      --radius: 8px;
      --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: Arial, sans-serif;
      background-color: var(--gray-light);
      color: #333;
      line-height: 1.6;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
```

**What this does:**
- CSS variables (`:root`) let you change colors in one place
- The container centers content and adds padding

### 2.2 Header Styles

```jsp
    header {
      background-color: var(--white);
      padding: 20px;
      border-radius: var(--radius);
      margin-bottom: 20px;
      box-shadow: var(--shadow);
    }

    h1 {
      color: var(--primary);
      font-weight: 600;
    }
```

### 2.3 Filter Box Styles

```jsp
    .filter {
      background-color: var(--white);
      border-radius: var(--radius);
      padding: 20px;
      margin-bottom: 20px;
      box-shadow: var(--shadow);
    }

    .filter-row {
      display: flex;
      flex-wrap: wrap;
      gap: 15px;
      align-items: center;
    }

    .filter-group {
      flex: 1;
      min-width: 200px;
    }

    label {
      display: block;
      margin-bottom: 5px;
      font-weight: 500;
    }

    input {
      width: 100%;
      padding: 10px;
      border: 1px solid var(--gray);
      border-radius: 4px;
      font-size: 14px;
    }

    input:focus {
      outline: none;
      border-color: var(--primary);
    }

    button {
      padding: 10px 15px;
      background: var(--primary);
      color: var(--white);
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 500;
    }

    button:hover {
      background: var(--primary-dark);
    }
```

### 2.4 Card Grid Styles

```jsp
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
      color: #333;
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
    }

    .card-title {
      font-size: 18px;
      font-weight: 600;
      color: var(--primary);
      margin-bottom: 8px;
    }

    .card-meta {
      font-size: 13px;
      color: #888;
    }
```

### 2.5 Footer and Responsive Styles

```jsp
    .footer {
      padding: 15px 20px;
      background-color: var(--white);
      border-radius: var(--radius);
      box-shadow: var(--shadow);
    }

    .empty-message {
      text-align: center;
      padding: 60px 20px;
      color: #888;
      background: var(--white);
      border-radius: var(--radius);
      grid-column: 1 / -1;
    }

    @media (max-width: 768px) {
      .filter-row { flex-direction: column; }
      .filter-group { min-width: 100%; }
      .cards-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
```

---

## Step 3: Build the HTML Body

### 3.1 Header and Filter Form

```jsp
<body>
  <div class="container">
    <header>
      <h1>My Web Applications</h1>
    </header>

    <form method="get">
      <div class="filter">
        <div class="filter-row">
          <div class="filter-group">
            <label for="nameFilter">Search applications</label>
            <input type="text"
                   id="nameFilter"
                   name="nameFilter"
                   value="<%= request.getParameter('nameFilter') || '' %>"
                   placeholder="Search by name...">
          </div>
          <div style="display: flex; gap: 10px;">
            <button type="submit">Search</button>
            <button type="button" onclick="resetFilters()">Reset</button>
          </div>
        </div>
      </div>
    </form>
```

**What this does:**
- Creates a search form using GET method
- `request.getParameter('nameFilter')` retrieves the current filter value
- The `|| ''` provides an empty string default if no parameter exists

---

## Step 4: Query Data from the Database

This is where we fetch web applications using QueryDef:

```jsp
    <div class="cards-grid">
<%
// Step 4.1: Create the query
var query = xtk.queryDef.create(
  <queryDef schema="nms:webApp" operation="select">
    <select>
      <node expr="@internalName"/>
      <node expr="@label"/>
      <node expr="@lastModified"/>
    </select>
    <where>
      <condition expr="@internalName IS NOT NULL"/>
    </where>
    <orderBy>
      <node expr="@label"/>
    </orderBy>
  </queryDef>
);

// Step 4.2: Execute the query
var webApps = query.ExecuteQuery();

// Step 4.3: Get the filter value
var nameFilter = request.getParameter('nameFilter') || '';

// Step 4.4: Process and filter results
var filteredWebapps = [];

for each (var webapp in webApps.webApp) {
  var internalName = webapp.@internalName.toString();
  var label = webapp.@label.toString();
  var lastModified = webapp.@lastModified.toString();

  // Apply search filter
  var nameMatch = !nameFilter ||
                  label.toLowerCase().indexOf(nameFilter.toLowerCase()) >= 0 ||
                  internalName.toLowerCase().indexOf(nameFilter.toLowerCase()) >= 0;

  if (nameMatch) {
    // Create initials for the card image
    var initials = '';
    var words = label.split(' ');
    if (words.length >= 2) {
      initials = words[0].charAt(0).toUpperCase() + words[1].charAt(0).toUpperCase();
    } else if (words.length === 1) {
      initials = words[0].substring(0, 2).toUpperCase();
    } else {
      initials = 'WA';
    }

    // Format the date
    var formattedDate = '';
    if (lastModified) {
      try {
        var date = new Date(lastModified);
        if (!isNaN(date.getTime())) {
          formattedDate = date.getFullYear() + '-' +
                          String(date.getMonth() + 1).padStart(2, '0') + '-' +
                          String(date.getDate()).padStart(2, '0');
        }
      } catch (e) {
        formattedDate = lastModified;
      }
    }

    filteredWebapps.push({
      internalName: internalName,
      label: label,
      lastModified: formattedDate,
      initials: initials
    });
  }
}

var displayCount = filteredWebapps.length;
%>
```

**What this does:**

1. **Create query** - Uses E4X XML syntax to define a QueryDef
2. **Execute query** - Runs against the database
3. **Get filter** - Reads the search parameter from the URL
4. **Process results** - Loops through results, applies filter, creates initials

---

## Step 5: Display the Cards

Now render each webapp as a card:

```jsp
<%
// Step 5: Loop through filtered results and display cards
for (var i = 0; i < filteredWebapps.length; i++) {
  var webapp = filteredWebapps[i];
  var webappUrl = '/webApp/' + webapp.internalName;
%>
      <a href="<%= webappUrl %>" class="card" target="_blank">
        <div class="card-image">
          <%= webapp.initials %>
        </div>
        <div class="card-content">
          <div class="card-title"><%= webapp.label %></div>
          <div class="card-meta">
            <% if (webapp.lastModified) { %>
              Last updated: <%= webapp.lastModified %>
            <% } %>
          </div>
        </div>
      </a>
<%
}

// Show message if no results
if (displayCount === 0) {
%>
      <div class="empty-message">
        No web applications found.
      </div>
<%
}
%>
    </div>
```

**What this does:**
- Loops through filtered results
- Creates a card link for each webapp
- Shows initials in the colored header area
- Displays label and last modified date
- Shows empty message if no results match the filter

---

## Step 6: Add Footer and JavaScript

```jsp
    <div class="footer">
      <strong>Total applications: <%= displayCount %></strong>
    </div>
  </div>

  <script>
    function resetFilters() {
      // Clear the filter and reload without parameters
      var baseUrl = window.location.protocol + '//' +
                    window.location.host +
                    window.location.pathname;
      window.location.href = baseUrl;
    }
  </script>
</body>
</html>
```

---

## Complete Code

Here's the complete `main.jsp` file:

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Web Applications</title>
  <style>
    :root {
      --primary: #005aa0;
      --primary-light: #4495d1;
      --primary-dark: #004880;
      --gray-light: #f5f7fa;
      --gray: #eaeef2;
      --white: #fff;
      --radius: 8px;
      --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background-color: var(--gray-light); color: #333; line-height: 1.6; }
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    header { background-color: var(--white); padding: 20px; border-radius: var(--radius); margin-bottom: 20px; box-shadow: var(--shadow); }
    h1 { color: var(--primary); font-weight: 600; }
    .filter { background-color: var(--white); border-radius: var(--radius); padding: 20px; margin-bottom: 20px; box-shadow: var(--shadow); }
    .filter-row { display: flex; flex-wrap: wrap; gap: 15px; align-items: center; }
    .filter-group { flex: 1; min-width: 200px; }
    label { display: block; margin-bottom: 5px; font-weight: 500; }
    input { width: 100%; padding: 10px; border: 1px solid var(--gray); border-radius: 4px; font-size: 14px; }
    input:focus { outline: none; border-color: var(--primary); }
    button { padding: 10px 15px; background: var(--primary); color: var(--white); border: none; border-radius: 4px; cursor: pointer; font-weight: 500; }
    button:hover { background: var(--primary-dark); }
    .cards-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; margin-bottom: 20px; }
    .card { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); overflow: hidden; transition: transform 0.2s; cursor: pointer; text-decoration: none; color: #333; display: flex; flex-direction: column; }
    .card:hover { transform: translateY(-4px); box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15); }
    .card-image { height: 140px; background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%); display: flex; align-items: center; justify-content: center; color: var(--white); font-size: 48px; font-weight: 600; }
    .card-content { padding: 15px; }
    .card-title { font-size: 18px; font-weight: 600; color: var(--primary); margin-bottom: 8px; }
    .card-meta { font-size: 13px; color: #888; }
    .footer { padding: 15px 20px; background-color: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); }
    .empty-message { text-align: center; padding: 60px 20px; color: #888; background: var(--white); border-radius: var(--radius); grid-column: 1 / -1; }
    @media (max-width: 768px) { .filter-row { flex-direction: column; } .filter-group { min-width: 100%; } .cards-grid { grid-template-columns: 1fr; } }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>My Web Applications</h1>
    </header>

    <form method="get">
      <div class="filter">
        <div class="filter-row">
          <div class="filter-group">
            <label for="nameFilter">Search applications</label>
            <input type="text" id="nameFilter" name="nameFilter"
                   value="<%= request.getParameter('nameFilter') || '' %>"
                   placeholder="Search by name...">
          </div>
          <div style="display: flex; gap: 10px;">
            <button type="submit">Search</button>
            <button type="button" onclick="resetFilters()">Reset</button>
          </div>
        </div>
      </div>
    </form>

    <div class="cards-grid">
<%
var query = xtk.queryDef.create(
  <queryDef schema="nms:webApp" operation="select">
    <select>
      <node expr="@internalName"/>
      <node expr="@label"/>
      <node expr="@lastModified"/>
    </select>
    <where>
      <condition expr="@internalName IS NOT NULL"/>
    </where>
    <orderBy>
      <node expr="@label"/>
    </orderBy>
  </queryDef>
);

var webApps = query.ExecuteQuery();
var nameFilter = request.getParameter('nameFilter') || '';
var filteredWebapps = [];

for each (var webapp in webApps.webApp) {
  var internalName = webapp.@internalName.toString();
  var label = webapp.@label.toString();
  var lastModified = webapp.@lastModified.toString();

  var nameMatch = !nameFilter ||
                  label.toLowerCase().indexOf(nameFilter.toLowerCase()) >= 0 ||
                  internalName.toLowerCase().indexOf(nameFilter.toLowerCase()) >= 0;

  if (nameMatch) {
    var initials = '';
    var words = label.split(' ');
    if (words.length >= 2) {
      initials = words[0].charAt(0).toUpperCase() + words[1].charAt(0).toUpperCase();
    } else if (words.length === 1) {
      initials = words[0].substring(0, 2).toUpperCase();
    } else {
      initials = 'WA';
    }

    var formattedDate = '';
    if (lastModified) {
      try {
        var date = new Date(lastModified);
        if (!isNaN(date.getTime())) {
          var month = date.getMonth() + 1;
          var day = date.getDate();
          formattedDate = date.getFullYear() + '-' +
                          (month < 10 ? '0' + month : month) + '-' +
                          (day < 10 ? '0' + day : day);
        }
      } catch (e) {
        formattedDate = lastModified;
      }
    }

    filteredWebapps.push({
      internalName: internalName,
      label: label,
      lastModified: formattedDate,
      initials: initials
    });
  }
}

var displayCount = filteredWebapps.length;

for (var i = 0; i < filteredWebapps.length; i++) {
  var webapp = filteredWebapps[i];
  var webappUrl = '/webApp/' + webapp.internalName;
%>
      <a href="<%= webappUrl %>" class="card" target="_blank">
        <div class="card-image"><%= webapp.initials %></div>
        <div class="card-content">
          <div class="card-title"><%= webapp.label %></div>
          <div class="card-meta">
            <% if (webapp.lastModified) { %>Last updated: <%= webapp.lastModified %><% } %>
          </div>
        </div>
      </a>
<%
}

if (displayCount === 0) {
%>
      <div class="empty-message">No web applications found.</div>
<%
}
%>
    </div>

    <div class="footer">
      <strong>Total applications: <%= displayCount %></strong>
    </div>
  </div>

  <script>
    function resetFilters() {
      var baseUrl = window.location.protocol + '//' + window.location.host + window.location.pathname;
      window.location.href = baseUrl;
    }
  </script>
</body>
</html>
```

---

## Key Concepts Learned

1. **QueryDef with E4X** - Using XML syntax directly in JavaScript
2. **Request parameters** - Reading URL parameters with `request.getParameter()`
3. **Server-side filtering** - Processing data before display
4. **CSS Grid layout** - Creating responsive card grids
5. **JSP template syntax** - Mixing `<% %>` server code with HTML

---

## Next Steps

- [Walkthrough 02: Interactive Table with AJAX](02-interactive-table-ajax.md) - Add real-time updates
- [03-Dashboard with Charts](03-dashboard-with-charts.md) - Build analytics dashboards
- [Database Queries Guide](../05-DATABASE-QUERIES.md) - More query patterns
