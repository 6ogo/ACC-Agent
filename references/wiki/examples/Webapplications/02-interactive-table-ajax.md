# Walkthrough 02: Interactive Table with AJAX

**Build a data table with real-time updates using AJAX**

---

## What You'll Build

An interactive table that:
- Displays data with filtering options
- Updates records without page reload using AJAX
- Shows status indicators
- Includes action buttons for each row

This walkthrough is based on the production files `code examples/Web.jsp` and `code examples/optionUpdated.jssp`.

---

## Application Structure

```
Web Application: interactiveTable
├── Pages
│   ├── main.jsp         # Table display page
│   └── api/
│       └── update.jssp  # AJAX endpoint for updates
```

---

## Step 1: Create the Web Application

1. Go to **Resources > Online > Web applications**
2. Create a new empty web application
3. Set Internal name: `interactiveTable`
4. Set Label: `Interactive Table`
5. Save the application

---

## Step 2: Build the AJAX API First

Start with the backend API. Create `api/update.jssp`:

### 2.1 Basic Structure

```javascript
<%
// Enable webapp authentication - REQUIRED for all JSSP endpoints
logonEscalation("webapp");

// Set JSON response type
response.contentType = "application/json";

// Initialize result object
var result = {
  success: false,
  error: "",
  recordId: "",
  newStatus: ""
};
%>
```

**What this does:**
- `logonEscalation("webapp")` - Grants necessary permissions
- `response.contentType` - Tells browser to expect JSON
- `result` object - Standard response structure

### 2.2 Get Request Parameters

```javascript
<%
try {
  // Get parameters from the request
  var recordId = request.getParameter("recordId");
  var newStatus = request.getParameter("newStatus");
  var userLogin = request.getParameter("userLogin") || "Unknown";

  // Store in result for debugging
  result.recordId = recordId;
  result.newStatus = newStatus;

  // Log the request
  logInfo("update.jssp: Request - recordId: " + recordId +
          ", newStatus: " + newStatus + ", user: " + userLogin);

  // Validate parameters
  if (!recordId) {
    throw new Error("Parameter 'recordId' is required.");
  }
  if (!newStatus) {
    throw new Error("Parameter 'newStatus' is required.");
  }
%>
```

**What this does:**
- `request.getParameter()` - Reads POST/GET parameters
- `logInfo()` - Writes to ACC server logs for debugging
- Validation ensures required data is present

### 2.3 Query Existing Data

```javascript
<%
  // Query the current record
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="get">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
        <node expr="@state"/>
      </select>
      <where>
        <condition expr={"@id = " + recordId}/>
      </where>
    </queryDef>
  );

  var record = query.ExecuteQuery();

  if (!record || !record.@id) {
    throw new Error("Record with ID '" + recordId + "' not found.");
  }

  var currentState = record.@state.toString();
  result.previousStatus = currentState;
  logInfo("update.jssp: Current state: " + currentState);
%>
```

**What this does:**
- Uses `operation="get"` for single record retrieval
- Checks if record exists before updating
- Stores previous state for logging

### 2.4 Perform the Update

```javascript
<%
  // Perform the update using xtk.session.Write
  var updateXml = <delivery xtkschema="nms:delivery"
                            _key="@id"
                            id={recordId}
                            state={newStatus}/>;

  xtk.session.Write(updateXml);

  logInfo("update.jssp: Successfully updated record " + recordId +
          " from state " + currentState + " to " + newStatus);

  result.success = true;
%>
```

**What this does:**
- Creates XML with the update data
- `_key="@id"` tells ACC which field identifies the record
- `xtk.session.Write()` performs the database update

### 2.5 Error Handling and Response

```javascript
<%
} catch (e) {
  result.error = e.message || e.toString();
  logError("update.jssp: ERROR - " + result.error);
}

// Output JSON response
document.write(JSON.stringify(result));
%>
```

### Complete API File

Here's the complete `api/update.jssp`:

```javascript
<%
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  error: "",
  recordId: "",
  newStatus: "",
  previousStatus: ""
};

try {
  var recordId = request.getParameter("recordId");
  var newStatus = request.getParameter("newStatus");
  var userLogin = request.getParameter("userLogin") || "Unknown";

  result.recordId = recordId;
  result.newStatus = newStatus;

  logInfo("update.jssp: Request - recordId: " + recordId +
          ", newStatus: " + newStatus + ", user: " + userLogin);

  if (!recordId) throw new Error("Parameter 'recordId' is required.");
  if (!newStatus) throw new Error("Parameter 'newStatus' is required.");

  // Query current record
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="get">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
        <node expr="@state"/>
      </select>
      <where>
        <condition expr={"@id = " + recordId}/>
      </where>
    </queryDef>
  );

  var record = query.ExecuteQuery();

  if (!record || !record.@id) {
    throw new Error("Record with ID '" + recordId + "' not found.");
  }

  result.previousStatus = record.@state.toString();

  // Update the record
  var updateXml = <delivery xtkschema="nms:delivery"
                            _key="@id"
                            id={recordId}
                            state={newStatus}/>;
  xtk.session.Write(updateXml);

  logInfo("update.jssp: Updated record " + recordId);
  result.success = true;

} catch (e) {
  result.error = e.message || e.toString();
  logError("update.jssp: ERROR - " + result.error);
}

document.write(JSON.stringify(result));
%>
```

---

## Step 3: Build the Table Page

Now create `main.jsp` for the frontend.

### 3.1 Head Section with Styles

```jsp
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Interactive Data Table</title>
  <style>
    :root {
      --primary: #005aa0;
      --primary-dark: #004880;
      --gray-light: #f5f7fa;
      --gray: #eaeef2;
      --white: #fff;
      --green: #28a745;
      --red: #dc3545;
      --radius: 8px;
      --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background-color: var(--gray-light); color: #333; line-height: 1.6; }
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    header { background-color: var(--white); padding: 20px; border-radius: var(--radius); margin-bottom: 20px; box-shadow: var(--shadow); }
    h1 { color: var(--primary); font-weight: 600; }

    /* Filter styles */
    .filter { background-color: var(--white); border-radius: var(--radius); padding: 20px; margin-bottom: 20px; box-shadow: var(--shadow); }
    .filter-row { display: flex; flex-wrap: wrap; gap: 15px; align-items: flex-end; }
    .filter-group { flex: 1; min-width: 200px; }
    label { display: block; margin-bottom: 5px; font-weight: 500; }
    input, select { width: 100%; padding: 10px; border: 1px solid var(--gray); border-radius: 4px; font-size: 14px; }
    input:focus, select:focus { outline: none; border-color: var(--primary); }

    /* Button styles */
    button { padding: 10px 15px; background: var(--primary); color: var(--white); border: none; border-radius: 4px; cursor: pointer; font-weight: 500; transition: background 0.2s; }
    button:hover:not(:disabled) { background: var(--primary-dark); }
    button:disabled { opacity: 0.6; cursor: not-allowed; background: #ccc; }
    .btn-success { background: var(--green); }
    .btn-success:hover:not(:disabled) { background: #218838; }
    .btn-danger { background: var(--red); }
    .btn-danger:hover:not(:disabled) { background: #c82333; }

    /* Table styles */
    .table-container { background: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); overflow: hidden; }
    table { width: 100%; border-collapse: collapse; }
    th { background: var(--primary); color: white; padding: 12px 15px; text-align: left; font-weight: 500; }
    td { padding: 12px 15px; border-bottom: 1px solid var(--gray); }
    tr:last-child td { border-bottom: none; }
    tr:nth-child(even) { background: var(--gray-light); }
    tr:hover { background-color: rgba(0, 90, 160, 0.1); }

    /* Status badge */
    .status-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; }
    .status-active { background: var(--green); color: white; }
    .status-inactive { background: var(--red); color: white; }
    .status-pending { background: #ffc107; color: #333; }

    /* Action buttons */
    .action-buttons { display: flex; gap: 8px; }
    .action-buttons button { padding: 6px 12px; font-size: 13px; }

    /* Loading spinner */
    .spinner { display: inline-block; width: 14px; height: 14px; border: 2px solid rgba(0,0,0,0.2); border-radius: 50%; border-top-color: var(--primary); animation: spin 1s linear infinite; margin-right: 5px; vertical-align: middle; }
    @keyframes spin { to { transform: rotate(360deg); } }

    /* Footer */
    .footer { margin-top: 20px; padding: 15px 20px; background-color: var(--white); border-radius: var(--radius); box-shadow: var(--shadow); }
    .empty-message { text-align: center; padding: 40px; color: #888; }
  </style>
</head>
```

### 3.2 Body Structure

```jsp
<body>
  <div class="container">
    <header>
      <h1>Interactive Data Table</h1>
    </header>

    <!-- Filter Form -->
    <form method="GET" id="filterForm">
      <div class="filter">
        <div class="filter-row">
          <div class="filter-group">
            <label for="nameFilter">Search</label>
            <input type="text" id="nameFilter" name="nameFilter"
                   value="<%= request.getParameter('nameFilter') || '' %>"
                   placeholder="Search by name...">
          </div>
          <div class="filter-group">
            <label for="statusFilter">Status</label>
            <select id="statusFilter" name="statusFilter">
              <option value="">All</option>
              <option value="active" <%= request.getParameter('statusFilter') == 'active' ? 'selected' : '' %>>Active</option>
              <option value="inactive" <%= request.getParameter('statusFilter') == 'inactive' ? 'selected' : '' %>>Inactive</option>
            </select>
          </div>
          <div style="display: flex; gap: 10px;">
            <button type="submit">Filter</button>
            <button type="button" onclick="resetFilters()">Reset</button>
          </div>
        </div>
      </div>
    </form>
```

### 3.3 Server-Side Data Processing

```jsp
<%
// Query deliveries from database
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" lineCount="50">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@state"/>
      <node expr="@created"/>
    </select>
    <where>
      <condition expr="@label IS NOT NULL"/>
    </where>
    <orderBy>
      <node expr="@created" sortDesc="true"/>
    </orderBy>
  </queryDef>
);

var deliveries = query.ExecuteQuery();

// Get filter values
var nameFilter = request.getParameter('nameFilter') || '';
var statusFilter = request.getParameter('statusFilter') || '';

// Process and filter results
var filteredItems = [];

for each (var delivery in deliveries.delivery) {
  var id = delivery.@id.toString();
  var label = delivery.@label.toString();
  var state = parseInt(delivery.@state);
  var created = delivery.@created.toString();

  // Determine status
  var statusLabel = 'Pending';
  var statusClass = 'pending';
  if (state === 95) {
    statusLabel = 'Active';
    statusClass = 'active';
  } else if (state === 0 || state === 87) {
    statusLabel = 'Inactive';
    statusClass = 'inactive';
  }

  // Apply filters
  var nameMatch = !nameFilter ||
                  label.toLowerCase().indexOf(nameFilter.toLowerCase()) >= 0;

  var statusMatch = !statusFilter ||
                    (statusFilter === 'active' && state === 95) ||
                    (statusFilter === 'inactive' && (state === 0 || state === 87));

  if (nameMatch && statusMatch) {
    // Format date
    var formattedDate = '';
    if (created) {
      try {
        var date = new Date(created);
        if (!isNaN(date.getTime())) {
          var month = date.getMonth() + 1;
          var day = date.getDate();
          formattedDate = date.getFullYear() + '-' +
                          (month < 10 ? '0' + month : month) + '-' +
                          (day < 10 ? '0' + day : day);
        }
      } catch (e) {
        formattedDate = created;
      }
    }

    filteredItems.push({
      id: id,
      label: label,
      state: state,
      statusLabel: statusLabel,
      statusClass: statusClass,
      created: formattedDate
    });
  }
}

var displayCount = filteredItems.length;
%>
```

### 3.4 Render the Table

```jsp
    <!-- Data Table -->
    <div class="table-container">
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Status</th>
            <th>Created</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody id="tableBody">
          <% if (displayCount > 0) {
               for (var i = 0; i < filteredItems.length; i++) {
                 var item = filteredItems[i];
          %>
            <tr id="row-<%= item.id %>">
              <td><strong><%= item.label %></strong></td>
              <td>
                <span id="status-<%= item.id %>"
                      class="status-badge status-<%= item.statusClass %>">
                  <%= item.statusLabel %>
                </span>
              </td>
              <td><%= item.created %></td>
              <td class="action-buttons">
                <button id="btn-activate-<%= item.id %>"
                        class="btn-success"
                        onclick="updateStatus('<%= item.id %>', 95)"
                        <%= item.state === 95 ? 'disabled' : '' %>>
                  Activate
                </button>
                <button id="btn-deactivate-<%= item.id %>"
                        class="btn-danger"
                        onclick="updateStatus('<%= item.id %>', 0)"
                        <%= item.state === 0 ? 'disabled' : '' %>>
                  Deactivate
                </button>
              </td>
            </tr>
          <% }
             } else { %>
            <tr>
              <td colspan="4" class="empty-message">
                No records match your filters.
              </td>
            </tr>
          <% } %>
        </tbody>
      </table>
    </div>

    <div class="footer">
      <strong>Showing <%= displayCount %> records</strong>
    </div>
  </div>
```

### 3.5 JavaScript for AJAX Updates

```jsp
  <script>
    // Store the API URL
    var API_URL = 'api/update.jssp';

    /**
     * Update record status via AJAX
     */
    function updateStatus(recordId, newStatus) {
      // Get UI elements
      var statusBadge = document.getElementById('status-' + recordId);
      var activateBtn = document.getElementById('btn-activate-' + recordId);
      var deactivateBtn = document.getElementById('btn-deactivate-' + recordId);

      if (!statusBadge || !activateBtn || !deactivateBtn) {
        alert('UI error: Elements not found. Please reload the page.');
        return;
      }

      // Store original state for rollback
      var originalText = statusBadge.textContent;
      var originalClass = statusBadge.className;
      var originalActivateDisabled = activateBtn.disabled;
      var originalDeactivateDisabled = deactivateBtn.disabled;

      // Show loading state
      activateBtn.disabled = true;
      deactivateBtn.disabled = true;
      statusBadge.innerHTML = '<span class="spinner"></span> Updating...';
      statusBadge.className = 'status-badge';

      // Create AJAX request
      var xhr = new XMLHttpRequest();
      xhr.open('POST', API_URL, true);
      xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

      xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
          try {
            if (xhr.status === 200) {
              var response = JSON.parse(xhr.responseText);

              if (response.success) {
                // Update UI with new status
                var newStatusLabel = newStatus === 95 ? 'Active' : 'Inactive';
                var newStatusClass = newStatus === 95 ? 'active' : 'inactive';

                statusBadge.textContent = newStatusLabel;
                statusBadge.className = 'status-badge status-' + newStatusClass;

                // Update button states
                activateBtn.disabled = (newStatus === 95);
                deactivateBtn.disabled = (newStatus === 0);

              } else {
                // Show error and rollback
                alert('Error: ' + (response.error || 'Unknown error'));
                rollbackUI();
              }

            } else {
              alert('Server error: ' + xhr.status);
              rollbackUI();
            }

          } catch (e) {
            alert('Error processing response: ' + e.message);
            rollbackUI();
          }
        }
      };

      // Rollback function
      function rollbackUI() {
        statusBadge.textContent = originalText;
        statusBadge.className = originalClass;
        activateBtn.disabled = originalActivateDisabled;
        deactivateBtn.disabled = originalDeactivateDisabled;
      }

      // Send the request
      var params = 'recordId=' + encodeURIComponent(recordId) +
                   '&newStatus=' + encodeURIComponent(newStatus) +
                   '&userLogin=' + encodeURIComponent('webuser');
      xhr.send(params);
    }

    /**
     * Reset all filters
     */
    function resetFilters() {
      document.getElementById('nameFilter').value = '';
      document.getElementById('statusFilter').value = '';
      document.getElementById('filterForm').submit();
    }
  </script>
</body>
</html>
```

---

## Complete Files

### api/update.jssp

```javascript
<%
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  error: "",
  recordId: "",
  newStatus: ""
};

try {
  var recordId = request.getParameter("recordId");
  var newStatus = request.getParameter("newStatus");
  var userLogin = request.getParameter("userLogin") || "Unknown";

  result.recordId = recordId;
  result.newStatus = newStatus;

  logInfo("update.jssp: recordId=" + recordId + ", newStatus=" + newStatus);

  if (!recordId) throw new Error("recordId is required");
  if (!newStatus) throw new Error("newStatus is required");

  // Query current record
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="get">
      <select>
        <node expr="@id"/>
        <node expr="@state"/>
      </select>
      <where>
        <condition expr={"@id = " + recordId}/>
      </where>
    </queryDef>
  );

  var record = query.ExecuteQuery();
  if (!record || !record.@id) {
    throw new Error("Record not found: " + recordId);
  }

  // Update the record
  xtk.session.Write(
    <delivery xtkschema="nms:delivery" _key="@id" id={recordId} state={newStatus}/>
  );

  logInfo("update.jssp: Updated successfully");
  result.success = true;

} catch (e) {
  result.error = e.message || String(e);
  logError("update.jssp: " + result.error);
}

document.write(JSON.stringify(result));
%>
```

### main.jsp

See the complete code in the sections above, combined into a single file.

---

## Key Concepts Learned

1. **JSSP API endpoints** - Creating backend APIs for AJAX calls
2. **logonEscalation** - Required authentication for JSSP
3. **XMLHttpRequest** - Making AJAX calls from JavaScript
4. **xtk.session.Write** - Updating records in the database
5. **Error handling** - Both server-side and client-side
6. **UI state management** - Loading states and rollback on error

---

## Common Patterns

### Sending POST data

```javascript
var xhr = new XMLHttpRequest();
xhr.open('POST', '/path/to/api.jssp', true);
xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');

var params = 'param1=' + encodeURIComponent(value1) +
             '&param2=' + encodeURIComponent(value2);
xhr.send(params);
```

### Reading parameters in JSSP

```javascript
var value = request.getParameter("paramName");
```

### JSON response pattern

```javascript
response.contentType = "application/json";

var result = { success: false, error: "" };
try {
  // ... do work ...
  result.success = true;
} catch (e) {
  result.error = e.message;
}
document.write(JSON.stringify(result));
```

---

## Next Steps

- [03-Dashboard with Charts](03-dashboard-with-charts.md) - Build analytics dashboards
- [04-JSSP API Guide](../04-JSSP-API.md) - More API patterns
- [Troubleshooting](../09-TROUBLESHOOTING.md) - Common issues
