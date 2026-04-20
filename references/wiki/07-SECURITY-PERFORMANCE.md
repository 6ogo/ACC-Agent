# Security & Performance Guide

Complete guide to securing and optimizing Adobe Campaign Classic web applications.

## Table of Contents
1. [Security Fundamentals](#security-fundamentals)
2. [Authentication & Authorization](#authentication--authorization)
3. [Input Validation](#input-validation)
4. [SQL Injection Prevention](#sql-injection-prevention)
5. [Performance Optimization](#performance-optimization)
6. [Query Optimization](#query-optimization)
7. [Caching Strategies](#caching-strategies)
8. [Monitoring & Logging](#monitoring--logging)
9. [Real-World Security Considerations](#real-world-security-considerations)
10. [Common Patterns](#common-patterns)

---

## Security Fundamentals

### JSSP Authentication

```javascript
<%
// REQUIRED: Every JSSP must start with this
logonEscalation("webapp");

// This provides:
// - User authentication
// - Session management
// - Permission context
%>
```

### Security Headers

```javascript
<%
// Set security headers
response.addHeader("X-Frame-Options", "SAMEORIGIN");
response.addHeader("X-Content-Type-Options", "nosniff");
response.addHeader("X-XSS-Protection", "1; mode=block");

// Disable caching for sensitive data
response.addHeader("Cache-Control", "no-cache, no-store, must-revalidate");
response.addHeader("Pragma", "no-cache");
response.addHeader("Expires", "0");
%>
```

### Security Checklist

**Before Deployment:**
- [ ] All JSSP files have `logonEscalation("webapp")`
- [ ] User inputs are validated and sanitized
- [ ] SQL queries use proper escaping
- [ ] Sensitive data is not logged
- [ ] Error messages don't expose system details
- [ ] File uploads are validated (if applicable)
- [ ] Session timeouts are configured
- [ ] HTTPS is enforced

---

## Authentication & Authorization

### Check User Permissions

```javascript
<%
// Get current user
var currentUser = ctx.userInfo.@login.toString();
var currentUserId = ctx.userInfo.@id.toString();

// Check if user is in admin group
function isAdmin(userId) {
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:operatorGroup" operation="select">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@operator-id = " + userId}/>
        <condition expr="@name = 'Administrators'"/>
      </where>
    </queryDef>
  );
  
  var result = query.ExecuteQuery();
  return (result && result.@name);
}

// Check specific permission
function hasPermission(userId, permissionName) {
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:operatorGroup" operation="select">
      <select>
        <node expr="@name"/>
      </select>
      <where>
        <condition expr={"@operator-id = " + userId}/>
        <condition expr={"@name = '" + permissionName + "'"}/>
      </where>
    </queryDef>
  );
  
  var result = query.ExecuteQuery();
  return (result && result.@name);
}

// Protect admin-only endpoint
if (!isAdmin(currentUserId)) {
  result.error = {
    code: "FORBIDDEN",
    message: "Insufficient permissions"
  };
  document.write(JSON.stringify(result));
  return;
}
%>
```

### Role-Based Access Control

```javascript
<%
var UserRoles = {
  ADMIN: "Administrators",
  EDITOR: "Content Editors",
  VIEWER: "Viewers"
};

function getUserRoles(userId) {
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
  var roles = [];
  
  for each(var group in results.operatorGroup) {
    roles.push(group.@name.toString());
  }
  
  return roles;
}

function requireRole(userId, roleName) {
  var roles = getUserRoles(userId);
  if (roles.indexOf(roleName) === -1) {
    throw new Error("Access denied: requires role " + roleName);
  }
}

// Usage
try {
  requireRole(currentUserId, UserRoles.ADMIN);
  // Admin-only code here
} catch(e) {
  result.error = {
    code: "FORBIDDEN",
    message: e.message
  };
  document.write(JSON.stringify(result));
  return;
}
%>
```

---

## Input Validation

### Validation Functions

```javascript
<%
// String validation
function validateString(input, maxLength) {
  if (!input || typeof input !== 'string') {
    throw new Error("Invalid string input");
  }
  
  if (maxLength && input.length > maxLength) {
    throw new Error("String too long (max " + maxLength + " characters)");
  }
  
  return true;
}

// Email validation
function validateEmail(email) {
  var regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!regex.test(email)) {
    throw new Error("Invalid email format");
  }
  return true;
}

// Numeric validation
function validateNumeric(value, min, max) {
  var num = parseFloat(value);
  
  if (isNaN(num)) {
    throw new Error("Value must be numeric");
  }
  
  if (min !== undefined && num < min) {
    throw new Error("Value must be at least " + min);
  }
  
  if (max !== undefined && num > max) {
    throw new Error("Value must be at most " + max);
  }
  
  return true;
}

// ID validation (positive integer)
function validateId(id) {
  var num = parseInt(id);
  if (isNaN(num) || num <= 0) {
    throw new Error("Invalid ID");
  }
  return true;
}

// Date validation
function validateDate(dateString) {
  var date = new Date(dateString);
  if (isNaN(date.getTime())) {
    throw new Error("Invalid date format");
  }
  return true;
}

// Enum validation
function validateEnum(value, allowedValues) {
  if (allowedValues.indexOf(value) === -1) {
    throw new Error("Invalid value. Allowed: " + allowedValues.join(", "));
  }
  return true;
}
%>
```

### Input Sanitization

```javascript
<%
// Remove dangerous characters
function sanitizeString(input) {
  if (!input) return "";
  
  // Remove HTML tags
  input = input.replace(/<[^>]*>/g, '');
  
  // Remove potentially dangerous characters
  input = input.replace(/[<>'"]/g, '');
  
  // Trim whitespace
  input = input.trim();
  
  return input;
}

// SQL-safe string (escape single quotes)
function sanitizeSql(input) {
  if (!input) return "";
  
  // Escape single quotes for SQL
  input = input.replace(/'/g, "''");
  
  return input;
}

// Filename sanitization
function sanitizeFilename(filename) {
  if (!filename) return "";
  
  // Remove path separators and dangerous characters
  filename = filename.replace(/[\/\\:*?"<>|]/g, '');
  
  // Limit length
  if (filename.length > 255) {
    filename = filename.substring(0, 255);
  }
  
  return filename;
}

// Usage example
var userInput = request.getParameter("search");
var safeName = sanitizeString(userInput);
var sqlSafeName = sanitizeSql(userInput);
%>
```

### Validation Example

```javascript
<%
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  error: null,
  data: null
};

try {
  // Get parameters
  var id = request.getParameter("id");
  var email = request.getParameter("email");
  var name = request.getParameter("name");
  
  // Validate
  validateId(id);
  validateEmail(email);
  validateString(name, 100);
  
  // Sanitize
  var safeName = sanitizeString(name);
  var safeEmail = sanitizeString(email);
  
  // Process (now safe)
  result.data = processData(id, safeEmail, safeName);
  result.success = true;
  
} catch(e) {
  result.error = {
    code: "VALIDATION_ERROR",
    message: e.message
  };
}

document.write(JSON.stringify(result));
%>
```

---

## SQL Injection Prevention

### Safe Query Building

```javascript
<%
// ❌ DANGEROUS: String concatenation
var userInput = request.getParameter("search");
var whereExpr = "@label LIKE '%" + userInput + "%'"; // SQL injection risk!

// ✅ SAFE: Escape single quotes
var userInput = request.getParameter("search");
var safeName = userInput.replace(/'/g, "''");
var whereExpr = "@label LIKE '%" + safeName + "%'";

// ✅ SAFER: Validate first, then escape
var userInput = request.getParameter("search");
validateString(userInput, 100);
var safeName = sanitizeSql(userInput);
var whereExpr = "@label LIKE '%" + safeName + "%'";
%>
```

### Parameterized Queries

```javascript
<%
// Use variable substitution in QueryDef
var deliveryId = request.getParameter("id");
validateId(deliveryId);

var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="get">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <where>
      <!-- Safe: uses variable binding -->
      <condition expr="@id = $(vars/@deliveryId)"/>
    </where>
  </queryDef>
);

query.setParam("deliveryId", deliveryId);
var delivery = query.ExecuteQuery();
%>
```

### Whitelist Validation

```javascript
<%
// For dynamic sorting/ordering
var sortField = request.getParameter("sort");

// Whitelist allowed fields
var allowedFields = ["@id", "@label", "@created", "@lastModified"];
if (allowedFields.indexOf(sortField) === -1) {
  sortField = "@lastModified"; // Default
}

var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <orderBy>
      <node expr={sortField} sortDesc="true"/>
    </orderBy>
  </queryDef>
);
%>
```

---

## Performance Optimization

### Query Performance

```javascript
<%
// ❌ BAD: Select all fields
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="*"/>
    </select>
  </queryDef>
);

// ✅ GOOD: Select only needed fields
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
  </queryDef>
);

// ❌ BAD: No limit
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select><node expr="@id"/></select>
  </queryDef>
);

// ✅ GOOD: Limit results
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" lineCount="100">
    <select><node expr="@id"/></select>
  </queryDef>
);
%>
```

### Avoid N+1 Queries

```javascript
<%
// ❌ BAD: Query in loop (N+1 problem)
var deliveries = getDeliveries();
for each(var delivery in deliveries.delivery) {
  var statsQuery = xtk.queryDef.create(...);
  var stats = statsQuery.ExecuteQuery(); // Query for each delivery!
}

// ✅ GOOD: Single query with GROUP BY
var query = xtk.queryDef.create(
  <queryDef schema="nms:broadLogRcp" operation="select">
    <select>
      <node expr="@delivery-id"/>
      <node expr="Count(@id)" alias="count"/>
    </select>
    <where>
      <condition expr="@delivery-id IN (1,2,3,4,5)"/>
    </where>
    <groupBy>
      <node expr="@delivery-id"/>
    </groupBy>
  </queryDef>
);

var allStats = query.ExecuteQuery();
// Create lookup map
var statsMap = {};
for each(var stat in allStats) {
  statsMap[<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6624110910131626">[email&#160;protected]</a>()] = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d2b3a5a7a6a792a7">[email&#160;protected]</a>();
}
%>
```

### Pagination

```javascript
<%
// Always paginate large result sets
var page = parseInt(request.getParameter('page') || '1');
var pageSize = 50;
var offset = (page - 1) * pageSize;

var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" 
            operation="select" 
            lineCount={pageSize}
            startLine={offset}>
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <orderBy>
      <node expr="@lastModified" sortDesc="true"/>
    </orderBy>
  </queryDef>
);

var results = query.ExecuteQuery();

// Return pagination info
result.data = {
  items: convertToArray(results),
  pagination: {
    page: page,
    pageSize: pageSize,
    totalItems: results.@count,
    totalPages: Math.ceil(results.@count / pageSize)
  }
};
%>
```

---

## Query Optimization

### Use Indexes

```javascript
<%
// ✅ GOOD: Query on indexed fields
// @id, @internalName are typically indexed
<condition expr="@id = 12345"/>
<condition expr="@internalName = 'newsletter'"/>

// ❌ BAD: Functions on indexed fields
<condition expr="Upper(@email) = 'USER@DOMAIN.COM'"/>

// ✅ GOOD: Don't use functions
<condition expr="@email = 'user@domain.com'"/>
%>
```

### Efficient Joins

```javascript
<%
// ✅ GOOD: Use links instead of subqueries
var query = xtk.queryDef.create(
  <queryDef schema="nms:broadLogRcp" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="[delivery/@label]"/>
      <node expr="[recipient/@email]"/>
    </select>
  </queryDef>
);

// ❌ BAD: Avoid complex subqueries when possible
<condition expr="@id IN (SELECT iId FROM nmsTable WHERE ...)"/>
%>
```

### Count Optimization

```javascript
<%
// ❌ BAD: Select all to count
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select><node expr="@id"/></select>
  </queryDef>
);
var count = query.ExecuteQuery().delivery.length();

// ✅ GOOD: Use COUNT aggregation
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="Count(@id)" alias="total"/>
    </select>
  </queryDef>
);
var count = query.ExecuteQuery().@total;
%>
```

---

## Caching Strategies

### Option-Based Caching

```javascript
<%
// Cache expensive query results in options
function getCachedData(cacheKey, ttlMinutes, fetchFunction) {
  var cacheKeyWithTime = cacheKey + "_timestamp";
  
  // Check if cache exists and is valid
  var cacheQuery = xtk.queryDef.create(
    <queryDef schema="xtk:option" operation="get">
      <select>
        <node expr="@stringValue"/>
      </select>
      <where>
        <condition expr={"@name = '" + cacheKey + "'"}/>
      </where>
    </queryDef>
  );
  
  var cached = cacheQuery.ExecuteQuery();
  
  if (cached && cached.@stringValue) {
    // Check timestamp
    var timestampQuery = xtk.queryDef.create(
      <queryDef schema="xtk:option" operation="get">
        <select>
          <node expr="@stringValue"/>
        </select>
        <where>
          <condition expr={"@name = '" + cacheKeyWithTime + "'"}/>
        </where>
      </queryDef>
    );
    
    var timestamp = timestampQuery.ExecuteQuery();
    
    if (timestamp && timestamp.@stringValue) {
      var cacheTime = new Date(timestamp.@stringValue.toString());
      var now = new Date();
      var diffMinutes = (now - cacheTime) / 1000 / 60;
      
      if (diffMinutes < ttlMinutes) {
        // Cache is valid
        return JSON.parse(cached.@stringValue.toString());
      }
    }
  }
  
  // Cache miss or expired - fetch fresh data
  var freshData = fetchFunction();
  
  // Store in cache
  var cacheXml = <option 
    _key={"@name"} 
    name={cacheKey} 
    stringValue={JSON.stringify(freshData)} 
    xtkschema="xtk:option"/>;
  xtk.session.Write(cacheXml);
  
  var timestampXml = <option 
    _key={"@name"} 
    name={cacheKeyWithTime} 
    stringValue={new Date().toISOString()} 
    xtkschema="xtk:option"/>;
  xtk.session.Write(timestampXml);
  
  return freshData;
}

// Usage
var data = getCachedData(
  "webapp_dashboard_stats",
  15, // 15 minute cache
  function() {
    // Expensive query
    var query = xtk.queryDef.create(...);
    return query.ExecuteQuery();
  }
);
%>
```

### Client-Side Caching

```javascript
<script>
// Cache in localStorage
function getCachedData(key, ttlMinutes, fetchFunction) {
  var cached = localStorage.getItem(key);
  var timestamp = localStorage.getItem(key + '_timestamp');
  
  if (cached && timestamp) {
    var cacheTime = new Date(timestamp);
    var now = new Date();
    var diffMinutes = (now - cacheTime) / 1000 / 60;
    
    if (diffMinutes < ttlMinutes) {
      return JSON.parse(cached);
    }
  }
  
  // Fetch fresh data
  return fetchFunction().then(function(data) {
    localStorage.setItem(key, JSON.stringify(data));
    localStorage.setItem(key + '_timestamp', new Date().toISOString());
    return data;
  });
}

// Usage
getCachedData('dashboard_data', 15, function() {
  return fetch('/jssp/api/data.jssp').then(r => r.json());
}).then(function(data) {
  renderDashboard(data);
});
</script>
```

---

## Monitoring & Logging

### Structured Logging

```javascript
<%
// Logging utility
var Logger = {
  log: function(level, message, context) {
    var timestamp = new Date().toISOString();
    var user = ctx.userInfo.@login.toString();
    
    var logEntry = {
      timestamp: timestamp,
      level: level,
      user: user,
      message: message,
      context: context || {}
    };
    
    var logMessage = "[" + level + "] [" + timestamp + "] [" + user + "] " + 
                     message + 
                     (context ? " " + JSON.stringify(context) : "");
    
    if (level === "ERROR") {
      <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="27525546464667464446">logError</a>(logMessage);
    } else {
      <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="35475c415b404375505c59585b">logInfo</a>(logMessage);
    }
  },
  
  info: function(message, context) {
    this.log("INFO", message, context);
  },
  
  warn: function(message, context) {
    this.log("WARN", message, context);
  },
  
  error: function(message, context) {
    this.log("ERROR", message, context);
  }
};

// Usage
Logger.info("API request started", {
  action: "getData",
  parameters: {id: 123}
});

try {
  var data = fetchData();
  Logger.info("API request completed", {
    recordCount: data.length
  });
} catch(e) {
  Logger.error("API request failed", {
    error: e.message,
    stack: e.stack
  });
}
%>
```

### Performance Monitoring

```javascript
<%
// Performance timer
function Timer(name) {
  this.name = name;
  this.start = new Date().getTime();
}

Timer.prototype.end = function() {
  var end = new Date().getTime();
  var duration = end - this.start;
  logInfo("Performance: " + this.name + " took " + duration + "ms");
  return duration;
};

// Usage
var timer = new Timer("fetchDeliveries");
var deliveries = xtk.queryDef.create(...).ExecuteQuery();
timer.end();

// Log slow queries
var queryTimer = new Timer("complexQuery");
var results = complexQuery();
var duration = queryTimer.end();

if (duration > 1000) { // 1 second threshold
  logWarning("Slow query detected: " + duration + "ms");
}
%>
```

### Error Tracking

```javascript
<%
// Global error handler
function handleError(error, context) {
  var errorDetails = {
    message: error.message || error.toString(),
    stack: error.stack || "No stack trace",
    context: context || {},
    user: ctx.userInfo.@login.toString(),
    timestamp: new Date().toISOString()
  };
  
  // Log error
  logError("Application Error: " + JSON.stringify(errorDetails));
  
  // Could also write to custom error log table
  try {
    var errorLog = <errorLog 
      xtkschema="custom:errorLog"
      message={errorDetails.message}
      context={JSON.stringify(errorDetails.context)}
      user={errorDetails.user}
      timestamp={errorDetails.timestamp}/>;
    xtk.session.Write(errorLog);
  } catch(logErr) {
    // Fallback if error logging fails
    logError("Error logging failed: " + logErr.toString());
  }
  
  return errorDetails;
}

// Usage
try {
  // Your code
} catch(e) {
  var errorDetails = handleError(e, {
    action: "fetchData",
    parameters: {id: 123}
  });
  
  result.error = {
    code: "INTERNAL_ERROR",
    message: "An error occurred",
    reference: errorDetails.timestamp // Give user error reference
  };
}
%>
```

---

## Real-World Security Considerations

### Rate Limiting Limitations

The option-based rate limiting example shown earlier has performance limitations at scale:

```javascript
<%
// ⚠️ LIMITATION: Using xtk:option for rate limiting
// - Creates database writes on every request
// - May cause locking issues under high load
// - Not suitable for high-traffic APIs

// ✅ RECOMMENDED: Simple per-request throttling
// For ACC web apps, focus on:
// 1. Server-side timeouts
// 2. Query result limits
// 3. Session validation

// Practical rate limiting for ACC:
var MAX_RESULTS = 1000;    // Hard limit on query results
var QUERY_TIMEOUT = 30000; // 30 second timeout
var SESSION_MAX_REQUESTS_WARNING = 100; // Log warning after this many

// Track requests in session (lightweight)
var requestCount = parseInt(session.getValue("requestCount") || "0");
requestCount++;
session.addValue("requestCount", String(requestCount));

if (requestCount > SESSION_MAX_REQUESTS_WARNING && requestCount % 100 === 0) {
  logWarning("High request volume from session: " + requestCount + " requests");
}
%>
```

### CSRF Protection

Adobe Campaign Classic doesn't have built-in CSRF tokens. Implement manual protection:

```javascript
<%
// Generate CSRF token on page load
function generateCSRFToken() {
  var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var token = '';
  for (var i = 0; i < 32; i++) {
    token += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return token;
}

// Store in session
var csrfToken = generateCSRFToken();
session.addValue("csrfToken", csrfToken);
%>

<!-- Include in forms -->
<form method="POST" action="/jssp/api/update.jssp">
  <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
  <!-- other fields -->
</form>
```

```javascript
<%
// Validate CSRF in JSSP
logonEscalation("webapp");
response.contentType = "application/json";

var result = { success: false };

// Validate CSRF token for POST requests
if (request.method === "POST") {
  var submittedToken = request.getParameter("csrfToken");
  var sessionToken = session.getValue("csrfToken");

  if (!submittedToken || submittedToken !== sessionToken) {
    result.error = {
      code: "CSRF_ERROR",
      message: "Invalid request token"
    };
    document.write(JSON.stringify(result));
    return;
  }

  // Regenerate token after use (one-time use)
  session.addValue("csrfToken", generateCSRFToken());
}

// Continue with request processing...
%>
```

### XSS Prevention

Always escape output when rendering user data:

```javascript
<%
// Escape HTML entities
function escapeHtml(str) {
  if (!str) return "";
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}

// ❌ DANGEROUS: Unescaped output
var userName = request.getParameter("name");
%>
<h1>Hello, <%= userName %></h1>

<%
// ✅ SAFE: Escaped output
var userName = request.getParameter("name");
var safeUserName = escapeHtml(userName);
%>
<h1>Hello, <%= safeUserName %></h1>
```

### Secure Session Configuration

```javascript
<%
// Set secure session options
session.setTimeOut(1800); // 30 minutes

// Regenerate session after authentication
function regenerateSession() {
  // Store important values
  var userId = ctx.userInfo.@id.toString();
  var userLogin = ctx.userInfo.@login.toString();

  // Clear old session data
  session.addValue("authenticated", "true");
  session.addValue("authTime", new Date().toISOString());
  session.addValue("userId", userId);

  logInfo("Session regenerated for user: " + userLogin);
}

// Call after successful login/authentication
regenerateSession();
%>
```

### Audit Logging for Security Events

```javascript
<%
// Log security-relevant events
function logSecurityEvent(eventType, details) {
  var logEntry = {
    eventType: eventType,
    user: ctx.userInfo.@login.toString(),
    userId: ctx.userInfo.@id.toString(),
    timestamp: new Date().toISOString(),
    ipAddress: request.getHeader("X-Forwarded-For") || "unknown",
    userAgent: request.getHeader("User-Agent") || "unknown",
    details: details
  };

  logInfo("SECURITY_EVENT: " + JSON.stringify(logEntry));

  // Optionally write to audit table
  try {
    var auditXml = <auditLog
      xtkschema="lf:auditLog"
      eventType={eventType}
      userLogin={logEntry.user}
      userId={logEntry.userId}
      ipAddress={logEntry.ipAddress}
      details={JSON.stringify(details)}
      timestamp={logEntry.timestamp}/>;
    xtk.session.Write(auditXml);
  } catch(e) {
    logError("Audit logging failed: " + e.message);
  }
}

// Usage examples
logSecurityEvent("LOGIN_SUCCESS", { method: "webapp" });
logSecurityEvent("PERMISSION_DENIED", { resource: "admin-panel", requiredRole: "Administrators" });
logSecurityEvent("DATA_MODIFIED", { schema: "nms:delivery", recordId: 123, action: "update" });
logSecurityEvent("SUSPICIOUS_ACTIVITY", { reason: "multiple failed attempts", count: 5 });
%>
```

---

## Common Patterns

### Form POST Handling with Validation

Complete pattern for handling form submissions:

```javascript
<%
// form-handler.jssp - Complete POST handling example
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  error: null,
  data: null
};

// Only accept POST
if (request.method !== "POST") {
  result.error = {
    code: "METHOD_NOT_ALLOWED",
    message: "POST method required"
  };
  document.write(JSON.stringify(result));
  return;
}

// CSRF Validation
var submittedToken = request.getParameter("csrfToken");
var sessionToken = session.getValue("csrfToken");

if (!submittedToken || submittedToken !== sessionToken) {
  result.error = {
    code: "CSRF_ERROR",
    message: "Invalid request token. Please refresh and try again."
  };
  document.write(JSON.stringify(result));
  return;
}

try {
  // Get form parameters
  var formData = {
    name: request.getParameter("name"),
    email: request.getParameter("email"),
    phone: request.getParameter("phone"),
    comment: request.getParameter("comment")
  };

  // Validate required fields
  var errors = [];

  if (!formData.name || formData.name.trim() === "") {
    errors.push("Name is required");
  } else if (formData.name.length > 100) {
    errors.push("Name must be 100 characters or less");
  }

  if (!formData.email || formData.email.trim() === "") {
    errors.push("Email is required");
  } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
    errors.push("Invalid email format");
  }

  if (formData.phone && !/^[\d\s\-\+\(\)]{0,20}$/.test(formData.phone)) {
    errors.push("Invalid phone format");
  }

  if (formData.comment && formData.comment.length > 1000) {
    errors.push("Comment must be 1000 characters or less");
  }

  if (errors.length > 0) {
    result.error = {
      code: "VALIDATION_ERROR",
      message: "Please correct the following errors",
      details: errors
    };
    document.write(JSON.stringify(result));
    return;
  }

  // Sanitize data
  var sanitizedData = {
    name: formData.name.replace(/[<>'"]/g, '').trim(),
    email: formData.email.trim().toLowerCase(),
    phone: formData.phone ? formData.phone.replace(/[^\d\s\-\+\(\)]/g, '') : null,
    comment: formData.comment ? formData.comment.replace(/<[^>]*>/g, '').trim() : null
  };

  // Save to database
  var recordXml = <contactRequest
    xtkschema="cus:contactRequest"
    name={sanitizedData.name}
    email={sanitizedData.email}
    phone={sanitizedData.phone || ""}
    comment={sanitizedData.comment || ""}
    submittedBy={ctx.userInfo.@login.toString()}
    submittedDate={new Date().toISOString()}/>;

  xtk.session.Write(recordXml);

  // Regenerate CSRF token
  session.addValue("csrfToken", generateCSRFToken());

  result.success = true;
  result.data = {
    message: "Form submitted successfully",
    newCsrfToken: session.getValue("csrfToken")
  };

  logInfo("Form submitted by " + ctx.userInfo.@login + ": " + sanitizedData.email);

} catch(e) {
  logError("Form submission error: " + e.message);
  result.error = {
    code: "INTERNAL_ERROR",
    message: "An error occurred. Please try again."
  };
}

document.write(JSON.stringify(result));

function generateCSRFToken() {
  var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  var token = '';
  for (var i = 0; i < 32; i++) {
    token += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return token;
}
%>
```

### Bulk Operations with Progress Tracking

Pattern for processing large numbers of records:

```javascript
<%
// bulk-update.jssp - Bulk operation with progress tracking
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  processed: 0,
  succeeded: 0,
  failed: 0,
  errors: []
};

try {
  // Get IDs to process (comma-separated or JSON array)
  var idsParam = request.getParameter("ids");
  var ids = [];

  try {
    ids = JSON.parse(idsParam);
  } catch(e) {
    ids = idsParam ? idsParam.split(",") : [];
  }

  if (ids.length === 0) {
    result.error = { code: "NO_IDS", message: "No IDs provided" };
    document.write(JSON.stringify(result));
    return;
  }

  // Limit batch size to prevent timeouts
  var MAX_BATCH_SIZE = 500;
  if (ids.length > MAX_BATCH_SIZE) {
    result.error = {
      code: "BATCH_TOO_LARGE",
      message: "Maximum " + MAX_BATCH_SIZE + " records per request. Received: " + ids.length
    };
    document.write(JSON.stringify(result));
    return;
  }

  var newStatus = request.getParameter("newStatus");
  var updateComment = request.getParameter("comment") || "Bulk update";

  // Validate status
  var allowedStatuses = ["active", "inactive", "pending", "archived"];
  if (allowedStatuses.indexOf(newStatus) === -1) {
    result.error = { code: "INVALID_STATUS", message: "Invalid status value" };
    document.write(JSON.stringify(result));
    return;
  }

  logInfo("Starting bulk update: " + ids.length + " records to status " + newStatus);

  // Process in smaller chunks to avoid memory issues
  var CHUNK_SIZE = 50;
  var chunks = [];
  for (var i = 0; i < ids.length; i += CHUNK_SIZE) {
    chunks.push(ids.slice(i, i + CHUNK_SIZE));
  }

  for (var chunkIdx = 0; chunkIdx < chunks.length; chunkIdx++) {
    var chunk = chunks[chunkIdx];

    for (var j = 0; j < chunk.length; j++) {
      var recordId = chunk[j];
      result.processed++;

      try {
        // Validate ID
        var numId = parseInt(recordId);
        if (isNaN(numId) || numId <= 0) {
          throw new Error("Invalid ID format");
        }

        // Update record
        var updateXml = <record
          xtkschema="cus:mySchema"
          _key={"@id"}
          id={numId}
          status={newStatus}
          lastModified={new Date().toISOString()}
          modifiedBy={ctx.userInfo.@login.toString()}/>;

        xtk.session.Write(updateXml);
        result.succeeded++;

      } catch(recordError) {
        result.failed++;
        result.errors.push({
          id: recordId,
          error: recordError.message
        });

        // Limit error array size
        if (result.errors.length > 100) {
          result.errors = result.errors.slice(0, 100);
          result.errorsTruncated = true;
        }
      }
    }

    // Log progress for long operations
    if (chunks.length > 1) {
      logInfo("Bulk update progress: chunk " + (chunkIdx + 1) + "/" + chunks.length +
              " (" + result.processed + "/" + ids.length + " records)");
    }
  }

  result.success = (result.failed === 0);

  logInfo("Bulk update completed: " + result.succeeded + " succeeded, " +
          result.failed + " failed out of " + result.processed);

} catch(e) {
  logError("Bulk update error: " + e.message);
  result.error = {
    code: "INTERNAL_ERROR",
    message: e.message
  };
}

document.write(JSON.stringify(result));
%>
```

### Triggering Background Workflows

Pattern for starting long-running operations asynchronously:

```javascript
<%
// trigger-workflow.jssp - Start a workflow and return immediately
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  workflowId: null,
  message: null
};

try {
  var workflowInternalName = request.getParameter("workflow");

  // Whitelist allowed workflows (security)
  var allowedWorkflows = [
    "wkf_export_data",
    "wkf_process_imports",
    "wkf_send_notifications",
    "wkf_cleanup_old_data"
  ];

  if (allowedWorkflows.indexOf(workflowInternalName) === -1) {
    result.error = {
      code: "WORKFLOW_NOT_ALLOWED",
      message: "Workflow not in approved list"
    };
    document.write(JSON.stringify(result));
    return;
  }

  // Find the workflow
  var wkfQuery = xtk.queryDef.create(
    <queryDef schema="xtk:workflow" operation="get">
      <select>
        <node expr="@id"/>
        <node expr="@internalName"/>
        <node expr="@label"/>
        <node expr="@state"/>
      </select>
      <where>
        <condition expr={"@internalName = '" + workflowInternalName + "'"}/>
      </where>
    </queryDef>
  );

  var workflow = wkfQuery.ExecuteQuery();

  if (!workflow || !workflow.@id) {
    result.error = {
      code: "WORKFLOW_NOT_FOUND",
      message: "Workflow not found: " + workflowInternalName
    };
    document.write(JSON.stringify(result));
    return;
  }

  var workflowId = workflow.@id.toString();
  var workflowState = parseInt(workflow.@state.toString());

  // Check if already running (state 2 = running, 11 = being edited)
  if (workflowState === 2) {
    result.error = {
      code: "WORKFLOW_ALREADY_RUNNING",
      message: "Workflow is already running"
    };
    document.write(JSON.stringify(result));
    return;
  }

  // Pass parameters via workflow variables (optional)
  var params = request.getParameter("params");
  if (params) {
    try {
      var paramObj = JSON.parse(params);
      // Store params in an option for the workflow to read
      var optionXml = <option
        _key={"@name"}
        name={"wkf_params_" + workflowInternalName}
        stringValue={params}
        xtkschema="xtk:option"/>;
      xtk.session.Write(optionXml);
    } catch(e) {
      logWarning("Could not parse workflow params: " + e.message);
    }
  }

  // Start the workflow using PostEvent
  xtk.workflow.PostEvent(workflowInternalName, "signal", "", "<ctx/>", 0);

  result.success = true;
  result.workflowId = workflowId;
  result.message = "Workflow " + workflow.@label + " started successfully";

  logInfo("Workflow started by " + ctx.userInfo.@login + ": " + workflowInternalName);

} catch(e) {
  logError("Workflow trigger error: " + e.message);
  result.error = {
    code: "INTERNAL_ERROR",
    message: e.message
  };
}

document.write(JSON.stringify(result));
%>
```

### Polling for Workflow Status

```javascript
<%
// workflow-status.jssp - Check workflow status for polling
logonEscalation("webapp");
response.contentType = "application/json";

var result = {
  success: false,
  status: null,
  isRunning: false,
  lastRun: null
};

try {
  var workflowInternalName = request.getParameter("workflow");

  // Validate input
  if (!workflowInternalName || workflowInternalName.length > 100) {
    result.error = { code: "INVALID_INPUT", message: "Invalid workflow name" };
    document.write(JSON.stringify(result));
    return;
  }

  // Query workflow status
  var query = xtk.queryDef.create(
    <queryDef schema="xtk:workflow" operation="get">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
        <node expr="@state"/>
        <node expr="@lastCompleted"/>
        <node expr="@lastExec"/>
      </select>
      <where>
        <condition expr={"@internalName = '" + workflowInternalName.replace(/'/g, "''") + "'"}/>
      </where>
    </queryDef>
  );

  var workflow = query.ExecuteQuery();

  if (!workflow || !workflow.@id) {
    result.error = { code: "NOT_FOUND", message: "Workflow not found" };
    document.write(JSON.stringify(result));
    return;
  }

  var state = parseInt(workflow.@state.toString());

  // Workflow states:
  // 0 = Being edited
  // 2 = Started/Running
  // 11 = Being edited (locked)
  // 20 = Paused
  // 13 = Stopped
  // 25 = Finished

  var stateNames = {
    0: "editing",
    2: "running",
    11: "locked",
    13: "stopped",
    20: "paused",
    25: "finished"
  };

  result.success = true;
  result.status = stateNames[state] || "unknown";
  result.isRunning = (state === 2);
  result.lastRun = workflow.@lastExec ? workflow.@lastExec.toString() : null;
  result.lastCompleted = workflow.@lastCompleted ? workflow.@lastCompleted.toString() : null;

} catch(e) {
  logError("Workflow status error: " + e.message);
  result.error = { code: "INTERNAL_ERROR", message: e.message };
}

document.write(JSON.stringify(result));
%>
```

### Client-Side Polling Example

```html
<script>
// Poll for workflow completion
function startWorkflowWithPolling(workflowName, params) {
  return new Promise(function(resolve, reject) {
    // Start the workflow
    fetch('/jssp/api/trigger-workflow.jssp?workflow=' + encodeURIComponent(workflowName) +
          '&params=' + encodeURIComponent(JSON.stringify(params)))
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (!data.success) {
          reject(new Error(data.error.message));
          return;
        }

        // Start polling
        var pollInterval = 5000; // 5 seconds
        var maxPolls = 120;      // 10 minutes max
        var pollCount = 0;

        function poll() {
          pollCount++;

          if (pollCount > maxPolls) {
            reject(new Error('Workflow timeout after ' + (maxPolls * pollInterval / 1000) + ' seconds'));
            return;
          }

          fetch('/jssp/api/workflow-status.jssp?workflow=' + encodeURIComponent(workflowName))
            .then(function(r) { return r.json(); })
            .then(function(status) {
              if (status.isRunning) {
                // Still running, poll again
                setTimeout(poll, pollInterval);
              } else if (status.status === 'finished') {
                resolve({ success: true, status: status });
              } else {
                reject(new Error('Workflow ended with status: ' + status.status));
              }
            })
            .catch(function(err) {
              // Retry on network errors
              if (pollCount < maxPolls) {
                setTimeout(poll, pollInterval);
              } else {
                reject(err);
              }
            });
        }

        // Start polling after short delay
        setTimeout(poll, 2000);
      })
      .catch(reject);
  });
}

// Usage
document.getElementById('exportBtn').addEventListener('click', function() {
  var btn = this;
  btn.disabled = true;
  btn.textContent = 'Processing...';

  startWorkflowWithPolling('wkf_export_data', { format: 'csv' })
    .then(function(result) {
      alert('Export completed successfully!');
      // Optionally redirect to download
    })
    .catch(function(error) {
      alert('Export failed: ' + error.message);
    })
    .finally(function() {
      btn.disabled = false;
      btn.textContent = 'Export Data';
    });
});
</script>
```

---

## Security Best Practices Summary

**Authentication:**
- ✅ Always use `logonEscalation("webapp")` in JSSP
- ✅ Check user permissions for sensitive operations
- ✅ Implement role-based access control

**Input Validation:**
- ✅ Validate all user inputs
- ✅ Sanitize strings before use
- ✅ Use whitelist validation for enums

**SQL Security:**
- ✅ Escape single quotes in SQL strings
- ✅ Never use string concatenation for queries
- ✅ Use parameterized queries when possible

**Data Protection:**
- ✅ Don't log sensitive information
- ✅ Use HTTPS for all communications
- ✅ Set appropriate security headers

**Error Handling:**
- ✅ Don't expose system details in errors
- ✅ Log errors securely
- ✅ Return generic error messages to users

---

## Performance Best Practices Summary

**Query Optimization:**
- ✅ Select only needed fields
- ✅ Use appropriate operation types
- ✅ Limit result sets
- ✅ Avoid queries in loops
- ✅ Use indexes effectively

**Caching:**
- ✅ Cache expensive operations
- ✅ Implement appropriate TTL
- ✅ Clear cache when data changes

**Pagination:**
- ✅ Always paginate large datasets
- ✅ Use lineCount and startLine
- ✅ Return pagination metadata

**Monitoring:**
- ✅ Log all operations
- ✅ Track performance metrics
- ✅ Monitor slow queries
- ✅ Implement error tracking

---

**Next Steps:**
- [Code Templates](08-CODE-TEMPLATES.md) - Apply these patterns
- [Troubleshooting](09-TROUBLESHOOTING.md) - Debug security/performance issues
