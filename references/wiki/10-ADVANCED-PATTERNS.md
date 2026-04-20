# Advanced Patterns Guide

Advanced development patterns for Adobe Campaign Classic web applications. This guide covers topics for experienced developers building complex applications.

## Table of Contents
1. [Custom Schemas](#custom-schemas)
2. [xtk.session.Write Operations](#xtksessionwrite-operations)
3. [Context Variables](#context-variables)
4. [User Context (ctx.userInfo)](#user-context-ctxuserinfo)
5. [Session Management](#session-management)
6. [Custom JavaScript Libraries](#custom-javascript-libraries)
7. [Admin Panel Patterns](#admin-panel-patterns)
8. [Date Handling Best Practices](#date-handling-best-practices)
9. [E4X XML Operations](#e4x-xml-operations)
10. [Multi-Page Applications](#multi-page-applications)

---

## Custom Schemas

### Understanding Custom Namespaces

Adobe Campaign uses namespaces to organize schemas:

| Namespace | Purpose | Examples |
|-----------|---------|----------|
| `nms:` | Core marketing schemas | delivery, recipient, webApp |
| `xtk:` | Technical/system schemas | option, session, operator |
| `cus:` | Custom extensions | Custom recipient fields |
| `lf:` | Organization-specific | Custom business logic |

### Creating Custom Schemas

Custom schemas allow you to store application-specific data. Here's how to create one:

**Step 1: Define the Schema in ACC**

```xml
<!-- Navigate to: Administration > Configuration > Data schemas -->
<srcSchema namespace="lf" name="optionLog" label="Option Change Log"
           xtkschema="xtk:srcSchema">

  <element name="optionLog" autopk="true">
    <!-- Primary key is auto-generated -->

    <!-- Action tracking -->
    <attribute name="action" type="string" length="50"
               label="Action Type" desc="subscribe or unsubscribe"/>

    <!-- User information -->
    <attribute name="changedBy" type="string" length="100"
               label="Changed By" desc="User login who made change"/>
    <attribute name="changedById" type="string" length="50"
               label="Changed By ID" desc="User ID"/>
    <attribute name="changedDate" type="datetime"
               label="Changed Date" desc="Timestamp of change"/>

    <!-- Change details -->
    <attribute name="oldValue" type="memo"
               label="Old Value" desc="Previous value"/>
    <attribute name="newValue" type="memo"
               label="New Value" desc="New value after change"/>
    <attribute name="comment" type="memo"
               label="Comment" desc="Description of change"/>

    <!-- Reference to related option -->
    <attribute name="optionName" type="string" length="255"
               label="Option Name" desc="Name of option changed"/>

  </element>
</srcSchema>
```

**Step 2: Write to Custom Schema**

```javascript
<%
// Write a new record to custom schema
var logEntry = <optionLog xtkschema="lf:optionLog"/>;
logEntry.@action = "subscribe";
logEntry.@changedBy = ctx.userInfo.@login.toString();
logEntry.@changedById = ctx.userInfo.@loginId.toString();
logEntry.@changedDate = formatDateForACC(new Date());
logEntry.@oldValue = previousValue;
logEntry.@newValue = newValue;
logEntry.@comment = "User changed subscription status";
logEntry.@optionName = optionName;

xtk.session.Write(logEntry);
logInfo("Successfully logged change to lf:optionLog");
%>
```

**Step 3: Query Custom Schema**

```javascript
<%
// Query custom schema data
var query = xtk.queryDef.create(
  <queryDef schema="lf:optionLog" operation="select" lineCount="100">
    <select>
      <node expr="@id"/>
      <node expr="@action"/>
      <node expr="@changedBy"/>
      <node expr="@changedDate"/>
      <node expr="@comment"/>
    </select>
    <where>
      <condition expr="@optionName = 'myOption'"/>
    </where>
    <orderBy>
      <node expr="@changedDate" sortDesc="true"/>
    </orderBy>
  </queryDef>
);

var logs = query.ExecuteQuery();
for each(var log in logs.optionLog) {
  logInfo("Action: " + log.@action + " by " + log.@changedBy);
}
%>
```

### Common Custom Schema Patterns

**Audit/Change Log Schema:**
```xml
<srcSchema namespace="lf" name="auditLog" label="Audit Log">
  <element name="auditLog" autopk="true">
    <attribute name="entityType" type="string" length="100"/>
    <attribute name="entityId" type="long"/>
    <attribute name="action" type="string" length="50"/>
    <attribute name="userId" type="long"/>
    <attribute name="userLogin" type="string" length="100"/>
    <attribute name="timestamp" type="datetime"/>
    <attribute name="oldValues" type="memo"/>
    <attribute name="newValues" type="memo"/>
    <attribute name="ipAddress" type="string" length="50"/>
  </element>
</srcSchema>
```

**Configuration/Settings Schema:**
```xml
<srcSchema namespace="lf" name="appConfig" label="Application Configuration">
  <element name="appConfig" autopk="true">
    <attribute name="configKey" type="string" length="100"/>
    <attribute name="configValue" type="memo"/>
    <attribute name="configType" type="string" length="50"/>
    <attribute name="description" type="memo"/>
    <attribute name="lastModified" type="datetime"/>
    <attribute name="modifiedBy" type="string" length="100"/>
  </element>
</srcSchema>
```

---

## xtk.session.Write Operations

### Basic Write Operations

`xtk.session.Write()` is the primary method for creating and updating records in ACC.

**Creating a New Record:**
```javascript
<%
// Create new record - no _key needed for new records
var newRecord = <delivery xtkschema="nms:delivery"/>;
newRecord.@label = "My New Delivery";
newRecord.@internalName = "DLV_" + new Date().getTime();
newRecord.@state = 0;

xtk.session.Write(newRecord);
logInfo("Created new delivery");
%>
```

**Updating an Existing Record:**
```javascript
<%
// Update existing record - _key specifies which record to update
var updateXml = <option
  _key={"@name"}                   // Key field for lookup
  name="myOptionName"               // Value to match
  stringValue="new value"           // Field to update
  xtkschema="xtk:option"/>;

xtk.session.Write(updateXml);
logInfo("Updated option value");
%>
```

**Deleting a Record:**
```javascript
<%
// Delete a record
var deleteXml = <option
  _operation="delete"               // Delete operation
  _key={"@name"}                    // Key field
  name="optionToDelete"             // Record to delete
  xtkschema="xtk:option"/>;

xtk.session.Write(deleteXml);
logInfo("Deleted option");
%>
```

### Advanced Write Patterns

**Upsert (Insert or Update):**
```javascript
<%
// Check if record exists first
var existingQuery = xtk.queryDef.create(
  <queryDef schema="xtk:option" operation="getIfExists">
    <select><node expr="@name"/></select>
    <where>
      <condition expr={"@name = '" + optionName + "'"}/>
    </where>
  </queryDef>
);

var existing = existingQuery.ExecuteQuery();

// Build XML - same structure for insert or update
var optionXml = <option
  _key={"@name"}
  name={optionName}
  stringValue={newValue}
  xtkschema="xtk:option"/>;

xtk.session.Write(optionXml);

if (existing && existing.@name) {
  logInfo("Updated existing option: " + optionName);
} else {
  logInfo("Created new option: " + optionName);
}
%>
```

**Batch Write with Error Handling:**
```javascript
<%
var records = [
  { name: "opt1", value: "value1" },
  { name: "opt2", value: "value2" },
  { name: "opt3", value: "value3" }
];

var successCount = 0;
var errorCount = 0;
var errors = [];

for (var i = 0; i < records.length; i++) {
  try {
    var record = records[i];
    var xml = <option
      _key={"@name"}
      name={record.name}
      stringValue={record.value}
      xtkschema="xtk:option"/>;

    xtk.session.Write(xml);
    successCount++;

  } catch(e) {
    errorCount++;
    errors.push({
      record: records[i].name,
      error: e.message
    });
    logError("Failed to write record " + records[i].name + ": " + e.message);
  }
}

logInfo("Batch write complete: " + successCount + " success, " + errorCount + " errors");
%>
```

**Write with Related Records:**
```javascript
<%
// Write record with linked data
// Note: For complex relationships, may need multiple writes

// First write the parent
var deliveryXml = <delivery
  _key={"@internalName"}
  internalName="DLV_TEST"
  label="Test Delivery"
  xtkschema="nms:delivery"/>;

xtk.session.Write(deliveryXml);

// Then query to get the ID
var idQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="get">
    <select><node expr="@id"/></select>
    <where>
      <condition expr="@internalName = 'DLV_TEST'"/>
    </where>
  </queryDef>
);

var delivery = idQuery.ExecuteQuery();
var deliveryId = delivery.@id.toString();

// Now use the ID for related records
logInfo("Created delivery with ID: " + deliveryId);
%>
```

### Write Operation Attributes Reference

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `_key` | Specifies field(s) used to identify record | `_key={"@name"}` |
| `_operation` | Operation type (delete, insertOrUpdate) | `_operation="delete"` |
| `xtkschema` | Target schema for the write | `xtkschema="xtk:option"` |

---

## Context Variables

### Understanding ctx.vars

`ctx.vars` is used to pass variables between pages in a multi-page web application.

**Setting Variables (e.g., in fetchData.js):**
```javascript
<%
// In a JavaScript activity or initialization script
ctx.vars.externalId = "EXT123";
ctx.vars.bolagKod = "28";
ctx.vars.isLFABAdmin = true;
ctx.vars.userRoles = JSON.stringify(["admin", "editor"]);
ctx.vars.configData = JSON.stringify({
  theme: "dark",
  language: "sv"
});

logInfo("Set context variables for user");
%>
```

**Accessing Variables in JSP:**
```javascript
<%
// Read context variables with type conversion
var externalId = String(ctx.vars.externalId || "");
var bolagKod = String(ctx.vars.bolagKod || "");
var isAdmin = (String(ctx.vars.isLFABAdmin || "false") === "true");

// Parse JSON stored in variables
var userRoles = [];
var rolesStr = String(ctx.vars.userRoles || "[]");
try {
  userRoles = JSON.parse(rolesStr);
} catch(e) {
  logWarning("Could not parse userRoles: " + e.message);
}

var configData = {};
var configStr = String(ctx.vars.configData || "{}");
try {
  configData = JSON.parse(configStr);
} catch(e) {
  logWarning("Could not parse configData: " + e.message);
}

logInfo("User bolagKod: " + bolagKod + ", isAdmin: " + isAdmin);
%>
```

### Variable Persistence Scope

| Variable Type | Scope | Use Case |
|---------------|-------|----------|
| `ctx.vars` | Current web app session | User preferences, page state |
| `request.getParameter()` | Single request | Form submissions, URL params |
| `xtk:option` | Global/persistent | App configuration, feature flags |

**Best Practice Pattern:**
```javascript
<%
// Initialize with ctx.vars, fallback to request parameter, then default
function getVariable(varName, defaultValue) {
  // First check ctx.vars (session level)
  if (ctx.vars && typeof ctx.vars[varName] !== 'undefined') {
    return String(ctx.vars[varName]);
  }

  // Then check request parameters (URL/form)
  var param = request.getParameter(varName);
  if (param) {
    return param;
  }

  // Finally return default
  return defaultValue;
}

var bolagKod = getVariable("bolagKod", "");
var theme = getVariable("theme", "light");
%>
```

---

## User Context (ctx.userInfo)

### Available User Properties

The `ctx.userInfo` object contains information about the currently logged-in user.

```javascript
<%
// Access user information
var userLogin = ctx.userInfo.@login.toString();       // "john.doe"
var userId = ctx.userInfo.@id.toString();             // "12345"
var loginId = ctx.userInfo.@loginId.toString();       // "12345"
var orgUnitId = ctx.userInfo.@orgUnitId.toString();   // "1"
var timezone = ctx.userInfo.@timezone.toString();     // "Europe/Stockholm"

logInfo("Current user: " + userLogin + " (ID: " + userId + ")");
%>
```

### User Role Verification

```javascript
<%
// Check if user belongs to a specific group
function userInGroup(userId, groupName) {
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:operatorGroup" operation="select">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@operator-id = " + userId}/>
        <condition expr={"@name = '" + groupName + "'"}/>
      </where>
    </queryDef>
  );

  var result = query.ExecuteQuery();
  return (result && result.operatorGroup && result.operatorGroup.length() > 0);
}

// Get all user groups
function getUserGroups(userId) {
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:operatorGroup" operation="select">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@operator-id = " + userId}/>
      </where>
    </queryDef>
  );

  var results = query.ExecuteQuery();
  var groups = [];

  for each(var group in results.operatorGroup) {
    groups.push(group.@name.toString());
  }

  return groups;
}

// Usage
var currentUserId = ctx.userInfo.@id.toString();
var isAdmin = userInGroup(currentUserId, "Administrators");
var allGroups = getUserGroups(currentUserId);

logInfo("User is admin: " + isAdmin);
logInfo("User groups: " + allGroups.join(", "));
%>
```

### Building User-Aware Applications

```javascript
<%
// Comprehensive user context setup
var UserContext = {
  login: ctx.userInfo.@login.toString(),
  id: ctx.userInfo.@id.toString(),
  timezone: ctx.userInfo.@timezone.toString(),
  groups: [],
  isAdmin: false,
  canEdit: false,
  canDelete: false
};

// Load user groups
var groupQuery = xtk.queryDef.create(
  <queryDef schema="xtk:operatorGroup" operation="select">
    <select><node expr="@name"/></select>
    <where>
      <condition expr={"@operator-id = " + UserContext.id}/>
    </where>
  </queryDef>
);

var groupResults = groupQuery.ExecuteQuery();
for each(var g in groupResults.operatorGroup) {
  UserContext.groups.push(g.@name.toString());
}

// Set permissions based on groups
UserContext.isAdmin = (UserContext.groups.indexOf("Administrators") !== -1);
UserContext.canEdit = UserContext.isAdmin || (UserContext.groups.indexOf("Content Editors") !== -1);
UserContext.canDelete = UserContext.isAdmin;

logInfo("User context initialized: " + JSON.stringify(UserContext));
%>

<!-- Use in HTML -->
<% if (UserContext.canEdit) { %>
  <button onclick="editRecord()">Edit</button>
<% } %>

<% if (UserContext.canDelete) { %>
  <button onclick="deleteRecord()" class="danger">Delete</button>
<% } %>
```

---

## Session Management

### Session Values

```javascript
<%
// Store values in session (persists across pages within webapp)
session.addValue("lastPage", "dashboard");
session.addValue("filterState", JSON.stringify({
  search: "test",
  category: "all"
}));
session.addValue("viewCount", "5");

// Retrieve session values
var lastPage = session.getValue("lastPage") || "home";
var filterStateStr = session.getValue("filterState") || "{}";
var filterState = JSON.parse(filterStateStr);
var viewCount = parseInt(session.getValue("viewCount") || "0");

logInfo("Last page: " + lastPage + ", View count: " + viewCount);
%>
```

### Session Timeout Configuration

```javascript
<%
// Set session timeout (in seconds)
session.setTimeOut(1800); // 30 minutes

// Get remaining session time
var remainingTime = session.getTimeOut();
logInfo("Session expires in " + remainingTime + " seconds");
%>
```

### Session State Management Pattern

```javascript
<%
// Session state manager utility
var SessionManager = {
  // Get value with default
  get: function(key, defaultValue) {
    var value = session.getValue(key);
    return value !== null ? value : defaultValue;
  },

  // Set value
  set: function(key, value) {
    session.addValue(key, String(value));
  },

  // Get JSON object
  getObject: function(key, defaultObj) {
    var str = session.getValue(key);
    if (!str) return defaultObj || {};
    try {
      return JSON.parse(str);
    } catch(e) {
      return defaultObj || {};
    }
  },

  // Set JSON object
  setObject: function(key, obj) {
    session.addValue(key, JSON.stringify(obj));
  },

  // Increment counter
  increment: function(key) {
    var current = parseInt(this.get(key, "0"));
    this.set(key, current + 1);
    return current + 1;
  },

  // Clear a value
  clear: function(key) {
    session.addValue(key, "");
  }
};

// Usage examples
SessionManager.set("theme", "dark");
var theme = SessionManager.get("theme", "light");

SessionManager.setObject("filters", { status: "active", page: 1 });
var filters = SessionManager.getObject("filters");

var pageViews = SessionManager.increment("pageViews");
%>
```

---

## Custom JavaScript Libraries

### Using loadLibrary()

`loadLibrary()` loads reusable JavaScript code from the ACC resource library.

```javascript
<%
// Load a custom library at the start of your JSP
loadLibrary("lf:eventCoupon.js");
loadLibrary("lf:utilities.js");
loadLibrary("cus:validationHelpers.js");

// Now you can use functions defined in those libraries
var result = validateInput(userInput);
var formatted = formatCurrency(amount);
%>
```

### Creating Custom Libraries

**Step 1: Create the Library in ACC**

Navigate to: Administration > Configuration > JavaScript codes

```javascript
/**
 * lf:utilities.js - Common utility functions
 */

// Date formatting utilities
function formatDateForACC(date) {
  if (!date) return "";

  var d = new Date(date);
  if (isNaN(d.getTime())) return "";

  var year = d.getFullYear();
  var month = d.getMonth() + 1;
  var day = d.getDate();
  var hours = d.getHours();
  var minutes = d.getMinutes();
  var seconds = d.getSeconds();

  return year + "-" +
         (month < 10 ? "0" : "") + month + "-" +
         (day < 10 ? "0" : "") + day + " " +
         (hours < 10 ? "0" : "") + hours + ":" +
         (minutes < 10 ? "0" : "") + minutes + ":" +
         (seconds < 10 ? "0" : "") + seconds;
}

function formatDateDisplay(dateString) {
  if (!dateString) return "N/A";

  try {
    var d = new Date(dateString);
    if (isNaN(d.getTime())) return dateString;

    var year = d.getFullYear();
    var month = d.getMonth() + 1;
    var day = d.getDate();

    return year + "-" +
           (month < 10 ? "0" : "") + month + "-" +
           (day < 10 ? "0" : "") + day;
  } catch(e) {
    return dateString;
  }
}

// String utilities
function sanitizeString(str) {
  if (!str) return "";
  str = str.replace(/[<>'"]/g, '');
  return str.trim();
}

function escapeSql(str) {
  if (!str) return "";
  return str.replace(/'/g, "''");
}

function truncateString(str, maxLength) {
  if (!str || str.length <= maxLength) return str;
  return str.substring(0, maxLength) + "...";
}

function getInitials(str) {
  if (!str) return "NA";
  var words = str.trim().split(/\s+/);

  if (words.length >= 2) {
    return words[0].charAt(0).toUpperCase() + words[1].charAt(0).toUpperCase();
  } else if (words.length === 1 && words[0].length > 0) {
    var initials = words[0].charAt(0).toUpperCase();
    if (words[0].length > 1) {
      initials += words[0].charAt(1).toUpperCase();
    }
    return initials;
  }
  return "NA";
}

// Validation utilities
function isValidEmail(email) {
  var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
}

function isNumeric(value) {
  return !isNaN(value) && !isNaN(parseFloat(value));
}

function isPositiveInteger(value) {
  var num = parseInt(value);
  return !isNaN(num) && num > 0;
}

// Array utilities (ES5 compatible)
function arrayContains(arr, value) {
  for (var i = 0; i < arr.length; i++) {
    if (arr[i] === value) return true;
  }
  return false;
}

function arrayIndexOf(arr, value) {
  for (var i = 0; i < arr.length; i++) {
    if (arr[i] === value) return i;
  }
  return -1;
}

// Logging with context
function logWithContext(level, message, context) {
  var timestamp = new Date().toISOString();
  var contextStr = context ? " " + JSON.stringify(context) : "";
  var fullMessage = "[" + level + "] [" + timestamp + "]" + contextStr + " " + message;

  if (level === "ERROR") {
    logError(fullMessage);
  } else if (level === "WARN") {
    logWarning(fullMessage);
  } else {
    logInfo(fullMessage);
  }
}
```

**Step 2: Use the Library**

```javascript
<%
loadLibrary("lf:utilities.js");

// Now use the functions
var cleanInput = sanitizeString(request.getParameter("search"));
var safeSql = escapeSql(cleanInput);
var dateFormatted = formatDateDisplay(record.@lastModified);
var initials = getInitials(record.@label.toString());

logWithContext("INFO", "Processing record", { id: record.@id });
%>
```

---

## Admin Panel Patterns

### Role-Based Admin UI

```javascript
<%
// Determine admin status
var pageIsLFABAdmin = (String(ctx.vars.isLFABAdmin || "false") === "true");
var pageUserBolag = String(ctx.vars.bolagKod || "");

// If admin, check for admin-selected bolag parameter
var adminSelectedBolag = request.getParameter('adminBolag');
if (pageIsLFABAdmin && adminSelectedBolag) {
  pageUserBolag = adminSelectedBolag;
}
%>

<!-- Admin Panel - Only shown to admins -->
<% if (pageIsLFABAdmin) { %>
<div class="admin-panel">
  <h3>Admin Panel</h3>
  <p>Select organization to manage:</p>

  <form method="GET" id="adminForm">
    <div class="form-group">
      <label for="adminBolag">Organization:</label>
      <select id="adminBolag" name="adminBolag" onchange="this.form.submit()">
        <option value="">Select organization...</option>
        <% for (var code in organizationMap) { %>
          <option value="<%= code %>" <%= pageUserBolag == code ? 'selected' : '' %>>
            <%= organizationMap[code] %> (<%= code %>)
          </option>
        <% } %>
      </select>
    </div>

    <!-- Preserve existing filter parameters -->
    <% if (request.getParameter('nameFilter')) { %>
      <input type="hidden" name="nameFilter" value="<%= request.getParameter('nameFilter') %>">
    <% } %>
  </form>

  <p>Currently viewing: <strong><%= pageUserBolagName %></strong></p>
</div>
<% } %>

<!-- User info display -->
<div class="user-info">
  <span>Logged in as: <%= ctx.userInfo.@login %></span>
  <% if (pageIsLFABAdmin) { %>
    <span class="badge admin">Admin</span>
  <% } %>
</div>

<style>
.admin-panel {
  background: #fff3cd;
  border: 1px solid #ffc107;
  border-radius: 8px;
  padding: 20px;
  margin-bottom: 20px;
}
.admin-panel h3 {
  color: #856404;
  margin-bottom: 10px;
}
.badge.admin {
  background: #dc3545;
  color: white;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  margin-left: 8px;
}
</style>
```

### Admin Action Buttons with Confirmation

```javascript
<%
var canModify = pageUserBolag && organizationMap[pageUserBolag];
%>

<div class="action-buttons">
  <% if (canModify) { %>
    <button class="include-button"
            onclick="updateStatus('<%= optionName %>', '<%= bolagKod %>', 'included')"
            <%= currentStatus === 'included' ? 'disabled' : '' %>>
      Include
    </button>
    <button class="exclude-button"
            onclick="confirmExclude('<%= optionName %>', '<%= bolagKod %>')"
            <%= currentStatus === 'excluded' ? 'disabled' : '' %>>
      Exclude
    </button>
  <% } else { %>
    <span class="no-permission">Select an organization to modify status</span>
  <% } %>
</div>

<script>
function confirmExclude(optionName, bolagKod) {
  if (confirm('Are you sure you want to exclude this organization?')) {
    updateStatus(optionName, bolagKod, 'excluded');
  }
}

function updateStatus(optionName, bolagKod, newStatus) {
  var button = event.target;
  var originalText = button.textContent;
  button.disabled = true;
  button.innerHTML = '<span class="spinner"></span> Updating...';

  var params = 'optionName=' + encodeURIComponent(optionName) +
               '&bolagKod=' + encodeURIComponent(bolagKod) +
               '&newStatus=' + encodeURIComponent(newStatus) +
               '&userLogin=' + encodeURIComponent('<%= ctx.userInfo.@login %>') +
               '&userLoginId=' + encodeURIComponent('<%= ctx.userInfo.@loginId %>');

  fetch('/jssp/lf/optionUpdated.jssp?' + params)
    .then(function(response) { return response.json(); })
    .then(function(data) {
      if (data.success) {
        location.reload();
      } else {
        alert('Error: ' + (data.error || 'Unknown error'));
        button.disabled = false;
        button.textContent = originalText;
      }
    })
    .catch(function(error) {
      alert('Network error: ' + error.message);
      button.disabled = false;
      button.textContent = originalText;
    });
}
</script>

<style>
.action-buttons {
  display: flex;
  gap: 10px;
}
.include-button {
  background-color: #28a745;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}
.include-button:hover:not(:disabled) {
  background-color: #218838;
}
.exclude-button {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 4px;
  cursor: pointer;
}
.exclude-button:hover:not(:disabled) {
  background-color: #c82333;
}
button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  background-color: #ccc !important;
}
.spinner {
  display: inline-block;
  width: 14px;
  height: 14px;
  border: 2px solid #fff;
  border-radius: 50%;
  border-top-color: transparent;
  animation: spin 1s linear infinite;
  vertical-align: middle;
  margin-right: 5px;
}
@keyframes spin {
  to { transform: rotate(360deg); }
}
.no-permission {
  color: #666;
  font-style: italic;
}
</style>
```

---

## Date Handling Best Practices

### Adobe Campaign Date Formats

ACC uses specific date formats. Understanding them is crucial for correct data handling.

**Date Format Reference:**
| Context | Format | Example |
|---------|--------|---------|
| ACC Database | ISO 8601 | `2024-12-15 14:30:00` |
| Display (Swedish) | YYYY-MM-DD | `2024-12-15` |
| Display with time | YYYY-MM-DD HH:MM | `2024-12-15 14:30` |
| QueryDef dates | ISO string | `'2024-12-15'` |

### Date Formatting Functions

```javascript
<%
// Format date for ACC database storage
function formatDateForACC(date) {
  if (!date) return "";

  var d = (date instanceof Date) ? date : new Date(date);
  if (isNaN(d.getTime())) return "";

  var year = d.getFullYear();
  var month = d.getMonth() + 1;
  var day = d.getDate();
  var hours = d.getHours();
  var minutes = d.getMinutes();
  var seconds = d.getSeconds();

  // ACC format: YYYY-MM-DD HH:MM:SS
  return year + "-" +
         (month < 10 ? "0" : "") + month + "-" +
         (day < 10 ? "0" : "") + day + " " +
         (hours < 10 ? "0" : "") + hours + ":" +
         (minutes < 10 ? "0" : "") + minutes + ":" +
         (seconds < 10 ? "0" : "") + seconds;
}

// Format date for display (date only)
function formatDateDisplay(dateInput) {
  if (!dateInput) return "N/A";

  try {
    var dateStr = String(dateInput);

    // Handle ISO format with T separator
    if (dateStr.indexOf('T') > -1) {
      dateStr = dateStr.split('T')[0];
      return dateStr; // Already YYYY-MM-DD
    }

    // Handle ISO format with space separator
    if (dateStr.indexOf(' ') > -1) {
      dateStr = dateStr.split(' ')[0];
      return dateStr; // Already YYYY-MM-DD
    }

    // Try to parse and format
    var d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;

    var year = d.getFullYear();
    var month = d.getMonth() + 1;
    var day = d.getDate();

    return year + "-" +
           (month < 10 ? "0" : "") + month + "-" +
           (day < 10 ? "0" : "") + day;

  } catch(e) {
    return String(dateInput);
  }
}

// Format datetime for display
function formatDateTimeDisplay(dateInput) {
  if (!dateInput) return "N/A";

  try {
    var d = new Date(dateInput);
    if (isNaN(d.getTime())) return String(dateInput);

    var year = d.getFullYear();
    var month = d.getMonth() + 1;
    var day = d.getDate();
    var hours = d.getHours();
    var minutes = d.getMinutes();

    return year + "-" +
           (month < 10 ? "0" : "") + month + "-" +
           (day < 10 ? "0" : "") + day + " " +
           (hours < 10 ? "0" : "") + hours + ":" +
           (minutes < 10 ? "0" : "") + minutes;

  } catch(e) {
    return String(dateInput);
  }
}

// Get relative time (e.g., "2 days ago")
function getRelativeTime(dateInput) {
  if (!dateInput) return "Unknown";

  var d = new Date(dateInput);
  if (isNaN(d.getTime())) return "Unknown";

  var now = new Date();
  var diffMs = now - d;
  var diffMins = Math.floor(diffMs / 60000);
  var diffHours = Math.floor(diffMs / 3600000);
  var diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return "Just now";
  if (diffMins < 60) return diffMins + " min ago";
  if (diffHours < 24) return diffHours + " hours ago";
  if (diffDays < 7) return diffDays + " days ago";
  if (diffDays < 30) return Math.floor(diffDays / 7) + " weeks ago";

  return formatDateDisplay(dateInput);
}
%>
```

### Date Operations in Queries

```javascript
<%
// Get today's date for queries
var today = new Date();
var todayStr = formatDateForACC(today).split(' ')[0]; // YYYY-MM-DD

// Date range queries
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@lastModified"/>
    </select>
    <where>
      <!-- Last 30 days using GetDate() function -->
      <condition expr="@lastModified >= GetDate() - 30"/>

      <!-- Or with explicit date -->
      <condition expr={"@created >= '" + todayStr + "'"}/>

      <!-- Date range -->
      <condition expr="@lastModified >= '2024-01-01' AND @lastModified < '2024-02-01'"/>
    </where>
  </queryDef>
);

// Year/Month queries
var yearQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="Year(@created)" alias="year"/>
      <node expr="Month(@created)" alias="month"/>
      <node expr="Count(@id)" alias="count"/>
    </select>
    <groupBy>
      <node expr="Year(@created)"/>
      <node expr="Month(@created)"/>
    </groupBy>
    <orderBy>
      <node expr="Year(@created)"/>
      <node expr="Month(@created)"/>
    </orderBy>
  </queryDef>
);
%>
```

---

## E4X XML Operations

### Understanding E4X in ACC

Adobe Campaign Classic uses E4X (ECMAScript for XML) for XML manipulation.

**Creating XML:**
```javascript
<%
// Create XML literal
var xml = <delivery>
  <label>My Delivery</label>
  <state>0</state>
</delivery>;

// Create with dynamic values
var label = "Dynamic Label";
var state = 1;
var xml2 = <delivery>
  <label>{label}</label>
  <state>{state}</state>
</delivery>;

// Create with attributes
var xml3 = <delivery id="123" label="Test"/>;
%>
```

**Accessing XML Data:**
```javascript
<%
var result = query.ExecuteQuery();

// Access attributes with @
var id = result.@id;
var label = result.@label.toString();

// Access elements (no @)
var content = result.content.toString();

// Iterate over collections
for each(var delivery in result.delivery) {
  var dlvId = delivery.@id.toString();
  var dlvLabel = delivery.@label.toString();
  logInfo("Delivery: " + dlvId + " - " + dlvLabel);
}

// Check if attribute exists
if (result.@optionalField) {
  var value = result.@optionalField.toString();
}

// Get count of children
var count = result.delivery.length();
%>
```

**Modifying XML:**
```javascript
<%
// Add/modify attributes
var xml = <option/>;
xml.@name = "myOption";
xml.@stringValue = "myValue";
xml.@xtkschema = "xtk:option";

// Add child elements
xml.appendChild(<description>My description</description>);

// Set attribute with dynamic name
var attrName = "customAttr";
xml['@' + attrName] = "customValue";
%>
```

**XML to Array Conversion:**
```javascript
<%
// Convert XML collection to JavaScript array for easier manipulation
function xmlToArray(xmlCollection, elementName) {
  var arr = [];

  for each(var item in xmlCollection[elementName]) {
    var obj = {};

    // Copy all attributes
    for each(var attr in item.@*) {
      obj[attr.name().toString()] = attr.toString();
    }

    arr.push(obj);
  }

  return arr;
}

// Usage
var results = query.ExecuteQuery();
var deliveries = xmlToArray(results, "delivery");

// Now you can use standard array methods
deliveries.sort(function(a, b) {
  return a.label.localeCompare(b.label);
});

for (var i = 0; i < deliveries.length; i++) {
  logInfo("Delivery: " + deliveries[i].label);
}
%>
```

---

## Multi-Page Applications

### Page Flow with Context Variables

**Page 1 (fetchData.js - Initialization Activity):**
```javascript
<%
// This runs when webapp loads, before first page displays

// Query user data
var userQuery = xtk.queryDef.create(
  <queryDef schema="cus:userProfile" operation="get">
    <select>
      <node expr="@externalId"/>
      <node expr="@organizationCode"/>
      <node expr="@role"/>
    </select>
    <where>
      <condition expr={"@operatorId = " + ctx.userInfo.@id}/>
    </where>
  </queryDef>
);

var userProfile = userQuery.ExecuteQuery();

// Set context variables for all pages
if (userProfile && userProfile.@externalId) {
  ctx.vars.externalId = userProfile.@externalId.toString();
  ctx.vars.organizationCode = userProfile.@organizationCode.toString();
  ctx.vars.userRole = userProfile.@role.toString();
  ctx.vars.isAdmin = (userProfile.@role.toString() === "admin");
}

// Load organization lookup map
var orgQuery = xtk.queryDef.create(
  <queryDef schema="cus:organization" operation="select">
    <select>
      <node expr="@code"/>
      <node expr="@name"/>
    </select>
  </queryDef>
);

var orgs = orgQuery.ExecuteQuery();
var orgMap = {};
for each(var org in orgs.organization) {
  orgMap[org.@code.toString()] = org.@name.toString();
}

ctx.vars.organizationMap = JSON.stringify(orgMap);

logInfo("Context initialized for user: " + ctx.userInfo.@login);
%>
```

**Page 2 (dashboard.jsp - Main Page):**
```javascript
<%
// Read context variables set by initialization
var userRole = String(ctx.vars.userRole || "viewer");
var isAdmin = (String(ctx.vars.isAdmin || "false") === "true");
var orgCode = String(ctx.vars.organizationCode || "");

// Parse organization map
var orgMap = {};
try {
  orgMap = JSON.parse(String(ctx.vars.organizationMap || "{}"));
} catch(e) {
  logWarning("Could not parse organization map");
}

var orgName = orgMap[orgCode] || "Unknown Organization";
%>

<!DOCTYPE html>
<html>
<head>
  <title>Dashboard - <%= orgName %></title>
</head>
<body>
  <header>
    <h1>Dashboard</h1>
    <div class="user-bar">
      <span>Organization: <%= orgName %></span>
      <span>Role: <%= userRole %></span>
      <% if (isAdmin) { %>
        <span class="badge">Admin</span>
      <% } %>
    </div>
  </header>

  <!-- Page content based on role -->
  <% if (isAdmin) { %>
    <section class="admin-tools">
      <h2>Admin Tools</h2>
      <!-- Admin-only features -->
    </section>
  <% } %>

  <section class="main-content">
    <!-- Main content available to all users -->
  </section>
</body>
</html>
```

### Passing Data Between Pages via URL

```javascript
<%
// Build URL with parameters
function buildUrl(basePath, params) {
  var queryParts = [];
  for (var key in params) {
    if (params[key]) {
      queryParts.push(encodeURIComponent(key) + '=' + encodeURIComponent(params[key]));
    }
  }
  return basePath + (queryParts.length > 0 ? '?' + queryParts.join('&') : '');
}

// Example: Link to detail page
var detailUrl = buildUrl('/webApp/itemDetail', {
  id: item.@id.toString(),
  tab: 'overview',
  returnUrl: currentPageUrl
});
%>

<a href="<%= detailUrl %>">View Details</a>
```

---

## Best Practices Summary

### Schema Design
- Use meaningful namespace prefixes (lf:, cus:)
- Include audit fields (createdBy, createdDate, modifiedBy, modifiedDate)
- Define appropriate field lengths
- Use autopk for simple primary keys

### Data Operations
- Always validate before write operations
- Use try-catch around all database operations
- Log all modifications for audit purposes
- Check record existence before updates

### Context Variables
- Initialize all context vars in a single place
- Use JSON.stringify for complex objects
- Always provide defaults when reading
- Document what context vars are expected

### User Context
- Cache user permissions at page load
- Build permission checks as reusable functions
- Never trust client-side permission checks alone
- Log security-sensitive operations

### Date Handling
- Always use consistent date formats
- Handle timezone differences appropriately
- Use ACC's GetDate() for date arithmetic
- Format dates appropriately for display vs storage

---

**Next Steps:**
- [Getting Started](01-GETTING-STARTED.md) - Return to basics
- [Code Templates](08-CODE-TEMPLATES.md) - Production-ready code
- [Troubleshooting](09-TROUBLESHOOTING.md) - Debug issues
