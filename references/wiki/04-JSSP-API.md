# JSSP API Development Guide

Complete guide to building backend APIs with JSSP (JavaScript Server Pages) in Adobe Campaign Classic.

## Table of Contents
1. [JSSP Fundamentals](#jssp-fundamentals)
2. [API Structure](#api-structure)
3. [Request Handling](#request-handling)
4. [Data Operations](#data-operations)
5. [Response Patterns](#response-patterns)
6. [Error Handling](#error-handling)
7. [Security](#security)
8. [AJAX Integration](#ajax-integration)

---

## JSSP Fundamentals

### JSSP vs JSP

| Feature | JSSP (.jssp) | JSP (.jsp) |
|---------|--------------|------------|
| Purpose | Backend API | Frontend page |
| Output | JSON/XML | HTML |
| Use Case | AJAX endpoints | User interfaces |
| Authentication | logonEscalation() | Automatic |

### Basic JSSP Structure

```javascript
<%
// 1. Set authentication (REQUIRED for JSSP)
logonEscalation("webapp");

// 2. Set response type
response.contentType = "application/json";

// 3. Initialize response object
var result = {
  success: false,
  message: "",
  data: null
};

try {
  // 4. Business logic here
  result.success = true;
  result.data = { /* your data */ };
  
} catch(e) {
  result.message = e.message || e.toString();
}

// 5. Send JSON response
document.write(JSON.stringify(result));
%>
```

---

## API Structure

### Complete Production Template

```javascript
<%
/**
 * API Endpoint: optionUpdate.jssp
 * Purpose: Update option values via AJAX
 * Method: GET/POST
 * Returns: JSON response
 */

// Required: Set authentication context
logonEscalation("webapp");

// Set response type to JSON
response.contentType = "application/json";

// Initialize response object
var result = {
  success: false,
  error: "",
  data: null,
  metadata: {
    timestamp: new Date().toISOString(),
    version: "1.0"
  }
};

try {
  // Log request
  logInfo("API Request: optionUpdate.jssp");
  
  // Get and validate parameters
  var action = request.getParameter("action");
  var optionName = request.getParameter("optionName");
  
  if (!action) {
    throw new Error("Parameter 'action' is required");
  }
  
  if (!optionName) {
    throw new Error("Parameter 'optionName' is required");
  }
  
  logInfo("Action: " + action + ", Option: " + optionName);
  
  // Route to appropriate handler
  switch(action) {
    case "get":
      result.data = getOption(optionName);
      break;
      
    case "update":
      var newValue = request.getParameter("value");
      result.data = updateOption(optionName, newValue);
      break;
      
    default:
      throw new Error("Invalid action: " + action);
  }
  
  result.success = true;
  result.message = "Operation completed successfully";
  
} catch(e) {
  result.error = e.message || e.toString();
  logError("API Error: " + result.error + (e.stack ? " Stack: " + e.stack : ""));
}

// Output JSON response
var jsonResponse = JSON.stringify(result);
logInfo("API Response: " + jsonResponse);
document.write(jsonResponse);

// Helper functions
function getOption(name) {
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:option" operation="get">
      <select>
        <node expr="@name"/>
        <node expr="@stringValue"/>
        <node expr="@type"/>
      </select>
      <where>
        <condition expr={"@name = '" + name + "'"}/>
      </where>
    </queryDef>
  );
  
  var option = query.ExecuteQuery();
  
  if (!option || !option.@name) {
    throw new Error("Option '" + name + "' not found");
  }
  
  return {
    name: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a8cac9d8cce895cae899c499c4cdc98ac5">[email&#160;protected]</a>(),
    value: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4a233b2f283e6e382f242338290a6f24">[email&#160;protected]</a>(),
    type: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8ce1efffe9e5cce9e2">[email&#160;protected]</a>()
  };
}

function updateOption(name, value) {
  var optionXml = <option _key={"@name"} name={name} stringValue={value} xtkschema="xtk:option"/>;
  xtk.session.Write(optionXml);
  
  logInfo("Updated option '" + name + "' to value: " + value);
  
  return {
    name: name,
    value: value,
    updated: true
  };
}
%>
```

---

## Request Handling

### Parameter Extraction

```javascript
<%
// Get parameters with defaults
var id = request.getParameter("id") || null;
var name = request.getParameter("name") || "";
var page = parseInt(request.getParameter("page") || "1");
var includeDetails = request.getParameter("details") === "true";

// Array parameters (multi-select)
var ids = request.getParameter("ids");
if (ids) {
  ids = ids.split(',').map(function(id) { 
    return id.trim(); 
  });
}

// Validate required parameters
if (!id) {
  throw new Error("Parameter 'id' is required");
}

// Validate parameter format
if (!/^\d+$/.test(id)) {
  throw new Error("Parameter 'id' must be numeric");
}
%>
```

### Request Method Detection

```javascript
<%
var method = request.method || "GET";

if (method === "POST") {
  // Handle POST data
  var postData = request.getParameter("data");
} else if (method === "GET") {
  // Handle GET parameters
  var getData = request.getParameter("query");
}
%>
```

---

## Data Operations

### Read Operations (GET)

```javascript
<%
function getDelivery(deliveryId) {
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="get">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
        <node expr="@state"/>
        <node expr="@lastModified"/>
      </select>
      <where>
        <condition expr={"@id = " + deliveryId}/>
      </where>
    </queryDef>
  );
  
  var delivery = query.ExecuteQuery();
  
  if (!delivery || !<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f5959b9890b58c">[email&#160;protected]</a>) {
    throw new Error("Delivery not found: " + deliveryId);
  }
  
  return {
    id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a4cac2e4dd">[email&#160;protected]</a>(),
    label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a5c7c0d6d0e5c8cc">[email&#160;protected]</a>(),
    state: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2354425556634a4e">[email&#160;protected]</a>(),
    lastModified: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fd9d9a929b94bd919592919c95d0869095">[email&#160;protected]</a>()
  };
}

// List operation with filtering
function listDeliveries(filters) {
  var conditions = [];
  
  if (filters.label) {
    conditions.push("@label LIKE '%" + filters.label + "%'");
  }
  
  if (filters.stateFilter) {
    conditions.push("@state = " + filters.stateFilter);
  }
  
  var whereExpr = conditions.length > 0 ? 
    conditions.join(' AND ') : 
    "1=1";
  
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="select" lineCount="50">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
        <node expr="@state"/>
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
  var deliveries = [];
  
  for each(var delivery in results.delivery) {
    deliveries.push({
      id: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2f416c6f56">[email&#160;protected]</a>(),
      label: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="92f1f6e0e6d2fffb">[email&#160;protected]</a>(),
      state: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d890bbaabf98b1b5">[email&#160;protected]</a>()
    });
  }
  
  return {
    count: deliveries.length,
    total: results.@count,
    items: deliveries
  };
}
%>
```

### Write Operations (POST/PUT)

```javascript
<%
function updateDeliveryLabel(deliveryId, newLabel) {
  // Validate input
  if (!newLabel || newLabel.length === 0) {
    throw new Error("Label cannot be empty");
  }
  
  if (newLabel.length > 255) {
    throw new Error("Label too long (max 255 characters)");
  }
  
  // Update using xtk.session.Write
  var deliveryXml = <delivery 
    _key={"@id"} 
    id={deliveryId} 
    label={newLabel} 
    xtkschema="nms:delivery"/>;
  
  xtk.session.Write(deliveryXml);
  
  logInfo("Updated delivery " + deliveryId + " label to: " + newLabel);
  
  return {
    id: deliveryId,
    label: newLabel,
    updated: true,
    timestamp: new Date().toISOString()
  };
}

function createOption(name, value) {
  // Check if option already exists
  var checkQuery = xtk.queryDef.create(
    <queryDef schema="xtk:option" operation="get">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@name = '" + name + "'"}/>
      </where>
    </queryDef>
  );
  
  var existing = checkQuery.ExecuteQuery();
  if (existing && existing.@name) {
    throw new Error("Option '" + name + "' already exists");
  }
  
  // Create new option
  var optionXml = <option 
    name={name} 
    stringValue={value}
    dataType="6"
    xtkschema="xtk:option"/>;
  
  xtk.session.Write(optionXml);
  
  return {
    name: name,
    value: value,
    created: true
  };
}
%>
```

### Delete Operations

```javascript
<%
function deleteOption(optionName) {
  // Verify option exists
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:option" operation="get">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@name = '" + optionName + "'"}/>
      </where>
    </queryDef>
  );
  
  var option = query.ExecuteQuery();
  if (!option || !option.@name) {
    throw new Error("Option '" + optionName + "' not found");
  }
  
  // Delete using _operation
  var deleteXml = <option 
    _operation="delete"
    _key={"@name"}
    name={optionName}
    xtkschema="xtk:option"/>;
  
  xtk.session.Write(deleteXml);
  
  logInfo("Deleted option: " + optionName);
  
  return {
    name: optionName,
    deleted: true
  };
}
%>
```

---

## Response Patterns

### Standard Success Response

```javascript
<%
var result = {
  success: true,
  message: "Operation completed successfully",
  data: {
    id: 123,
    name: "Example",
    status: "active"
  },
  metadata: {
    timestamp: new Date().toISOString(),
    requestId: generateRequestId()
  }
};

document.write(JSON.stringify(result));
%>
```

### Paginated Response

```javascript
<%
var page = parseInt(request.getParameter('page') || '1');
var pageSize = parseInt(request.getParameter('pageSize') || '50');

var result = {
  success: true,
  data: {
    items: [...], // Your items array
    pagination: {
      page: page,
      pageSize: pageSize,
      totalItems: totalCount,
      totalPages: Math.ceil(totalCount / pageSize),
      hasNext: page < Math.ceil(totalCount / pageSize),
      hasPrev: page > 1
    }
  }
};

document.write(JSON.stringify(result));
%>
```

### List with Metadata

```javascript
<%
var result = {
  success: true,
  data: {
    items: [
      {id: 1, label: "Item 1"},
      {id: 2, label: "Item 2"}
    ],
    count: 2,
    filters: {
      applied: {
        name: nameFilter,
        state: stateFilter
      },
      available: {
        states: ["Draft", "Sent", "Failed"],
        categories: ["A", "B", "C"]
      }
    }
  }
};

document.write(JSON.stringify(result));
%>
```

---

## Error Handling

### Comprehensive Error Handling

```javascript
<%
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  error: {
    code: null,
    message: "",
    details: null
  },
  data: null
};

try {
  // Validate parameters
  var id = request.getParameter("id");
  if (!id) {
    result.error.code = "MISSING_PARAMETER";
    result.error.message = "Parameter 'id' is required";
    throw new Error(result.error.message);
  }
  
  // Validate format
  if (!/^\d+$/.test(id)) {
    result.error.code = "INVALID_FORMAT";
    result.error.message = "Parameter 'id' must be numeric";
    throw new Error(result.error.message);
  }
  
  // Business logic
  var data = processRequest(id);
  
  if (!data) {
    result.error.code = "NOT_FOUND";
    result.error.message = "Resource not found with id: " + id;
    throw new Error(result.error.message);
  }
  
  result.success = true;
  result.data = data;
  result.error = null;
  
} catch(e) {
  // Set error code if not already set
  if (!result.error.code) {
    result.error.code = "INTERNAL_ERROR";
  }
  
  // Set error message
  result.error.message = e.message || e.toString();
  
  // Add stack trace in development
  if (isDevelopment()) {
    result.error.details = {
      stack: e.stack || "No stack trace available",
      line: e.lineNumber || null
    };
  }
  
  // Log error
  logError("API Error [" + result.error.code + "]: " + result.error.message);
}

document.write(JSON.stringify(result));

function isDevelopment() {
  // Check environment
  return getOption("environment") === "development";
}
%>
```

### Error Code Standards

```javascript
// Define error codes
var ERROR_CODES = {
  // Client errors (400-499)
  MISSING_PARAMETER: "MISSING_PARAMETER",
  INVALID_FORMAT: "INVALID_FORMAT",
  INVALID_VALUE: "INVALID_VALUE",
  UNAUTHORIZED: "UNAUTHORIZED",
  FORBIDDEN: "FORBIDDEN",
  NOT_FOUND: "NOT_FOUND",
  CONFLICT: "CONFLICT",
  
  // Server errors (500-599)
  INTERNAL_ERROR: "INTERNAL_ERROR",
  DATABASE_ERROR: "DATABASE_ERROR",
  QUERY_FAILED: "QUERY_FAILED",
  WRITE_FAILED: "WRITE_FAILED"
};
```

---

## Security

### Authentication Check

```javascript
<%
// Required for all JSSP
logonEscalation("webapp");

// Additional auth checks
var currentUser = ctx.userInfo.@login.toString();
var currentUserId = ctx.userInfo.@id.toString();

// Verify user has required permissions
if (!hasPermission(currentUserId, "admin")) {
  result.error.code = "FORBIDDEN";
  result.error.message = "User lacks required permissions";
  throw new Error(result.error.message);
}

function hasPermission(userId, permission) {
  // Check user rights
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:operatorGroup" operation="select">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@operator-id = " + userId}/>
        <condition expr={"@name = '" + permission + "'"}/>
      </where>
    </queryDef>
  );
  
  var group = query.ExecuteQuery();
  return (group && group.@name);
}
%>
```

### Input Sanitization

```javascript
<%
function sanitizeInput(input) {
  if (!input) return "";
  
  // Remove potentially dangerous characters
  input = input.replace(/[<>'"]/g, '');
  
  // Trim whitespace
  input = input.trim();
  
  return input;
}

function sanitizeSQLInput(input) {
  if (!input) return "";
  
  // Escape single quotes for SQL
  input = input.replace(/'/g, "''");
  
  return input;
}

// Usage
var userInput = request.getParameter("search");
var safeName = sanitizeInput(userInput);
var safeSQLName = sanitizeSQLInput(userInput);
%>
```

### Rate Limiting

```javascript
<%
var rateLimitKey = "api_calls_" + ctx.userInfo.@id;
var maxCallsPerMinute = 60;

function checkRateLimit() {
  // Get current call count from option
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:option" operation="get">
      <select>
        <node expr="@stringValue"/>
      </select>
      <where>
        <condition expr={"@name = '" + rateLimitKey + "'"}/>
      </where>
    </queryDef>
  );
  
  var option = query.ExecuteQuery();
  var callCount = option && <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="345b40575a51745d565a">[email&#160;protected]</a> ? 
    parseInt(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5e31382e2b2e1e373c30">[email&#160;protected]</a>()) : 0;
  
  if (callCount >= maxCallsPerMinute) {
    throw new Error("Rate limit exceeded. Try again later.");
  }
  
  // Increment counter
  var optionXml = <option 
    _key={"@name"} 
    name={rateLimitKey} 
    stringValue={String(callCount + 1)} 
    xtkschema="xtk:option"/>;
  xtk.session.Write(optionXml);
  
  return true;
}

checkRateLimit();
%>
```

---

## AJAX Integration

### Frontend AJAX Call

```javascript
// From JSP page
<script>
function updateOption(optionName, newValue) {
  fetch('/jssp/optionUpdate.jssp?action=update&optionName=' + 
        encodeURIComponent(optionName) + 
        '&value=' + encodeURIComponent(newValue))
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        console.log('Update successful:', data.data);
        alert('Updated successfully!');
      } else {
        console.error('Update failed:', data.error);
        alert('Error: ' + data.error.message);
      }
    })
    .catch(error => {
      console.error('Request failed:', error);
      alert('Request failed: ' + error.message);
    });
}

// POST request example
function createResource(resourceData) {
  fetch('/jssp/resourceCreate.jssp', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      action: 'create',
      data: JSON.stringify(resourceData)
    })
  })
  .then(response => response.json())
  .then(data => {
    if (data.success) {
      console.log('Created:', data.data);
    }
  });
}
</script>
```

### CORS Handling

```javascript
<%
// Add CORS headers if needed
response.addHeader("Access-Control-Allow-Origin", "*");
response.addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
response.addHeader("Access-Control-Allow-Headers", "Content-Type");

// Handle OPTIONS preflight
if (request.method === "OPTIONS") {
  document.write("");
  return;
}
%>
```

---

## Best Practices

### 1. Always Use Try-Catch
```javascript
<%
try {
  // Your code
  result.success = true;
} catch(e) {
  result.error = e.message;
  logError(e.toString());
}
%>
```

### 2. Log All Operations
```javascript
logInfo("API: " + apiName + " - User: " + currentUser + " - Action: " + action);
```

### 3. Validate All Inputs
```javascript
if (!param || param === "") {
  throw new Error("Invalid parameter");
}
```

### 4. Use Consistent Response Format
```javascript
{
  success: boolean,
  message: string,
  data: object|array|null,
  error: object|null
}
```

### 5. Handle Database Errors
```javascript
try {
  var result = query.ExecuteQuery();
} catch(e) {
  logError("Query failed: " + e.toString());
  throw new Error("Database error occurred");
}
```

---

**Next Steps:**
- [Database & Queries](05-DATABASE-QUERIES.md) - Advanced query patterns
- [Security & Performance](07-SECURITY-PERFORMANCE.md) - Security best practices
- [Code Templates](08-CODE-TEMPLATES.md) - Ready-to-use JSSP templates
