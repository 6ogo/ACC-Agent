# Troubleshooting Guide

Common issues, solutions, and debugging techniques for Adobe Campaign Classic web applications.

## Table of Contents
1. [Query Issues](#query-issues)
2. [JavaScript Errors](#javascript-errors)
3. [Display Issues](#display-issues)
4. [API Problems](#api-problems)
5. [Performance Issues](#performance-issues)
6. [Authentication Errors](#authentication-errors)
7. [Debugging Techniques](#debugging-techniques)
8. [Common Error Messages](#common-error-messages)

---

## Query Issues

### Issue: Query Returns No Results

**Symptoms:**
- Expected data doesn't appear
- Empty collections
- Zero count

**Diagnosis:**
```javascript
<%
// Add logging to check query
var query = xtk.queryDef.create(...);
logInfo("Executing query...");
var results = query.ExecuteQuery();
logInfo("Query returned " + results.@count + " results");
%>
```

**Common Causes:**

1. **Wrong schema name**
```javascript
// ❌ Wrong
<queryDef schema="delivery" operation="select">

// ✅ Correct
<queryDef schema="nms:delivery" operation="select">
```

2. **Incorrect where clause**
```javascript
// Debug: Remove where clause to see if data exists
<queryDef schema="nms:delivery" operation="select">
  <select><node expr="@id"/></select>
  <!-- <where>...</where> --> <!-- Comment out temporarily -->
</queryDef>
```

3. **Case sensitivity**
```javascript
// ❌ May not match if case differs
<condition expr="@label = 'Newsletter'"/>

// ✅ Case-insensitive
<condition expr="Lower(@label) = Lower('Newsletter')"/>
```

**Solution:**
```javascript
<%
// Step 1: Check if table has data at all
var testQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select><node expr="Count(@id)" alias="total"/></select>
  </queryDef>
);
var testResult = testQuery.ExecuteQuery();
logInfo("Total deliveries in database: " + <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f6949b928f8792b6949b">[email&#160;protected]</a>());

// Step 2: Check with simplified where clause
var simpleQuery = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select><node expr="@id"/><node expr="@label"/></select>
    <where>
      <condition expr="1=1"/> <!-- Always true -->
    </where>
  </queryDef>
);
var simpleResult = simpleQuery.ExecuteQuery();
logInfo("Query with no filters returned: " + simpleResult.@count);

// Step 3: Add filters one by one
%>
```

---

### Issue: Query Takes Too Long

**Symptoms:**
- Page timeout
- Slow response
- High server load

**Diagnosis:**
```javascript
<%
var startTime = new Date().getTime();
var results = query.ExecuteQuery();
var endTime = new Date().getTime();
logInfo("Query took " + (endTime - startTime) + "ms");
%>
```

**Solutions:**

1. **Add lineCount**
```javascript
// Limit results
<queryDef schema="nms:delivery" operation="select" lineCount="100">
```

2. **Select fewer fields**
```javascript
// ❌ Slow
<select><node expr="*"/></select>

// ✅ Fast
<select>
  <node expr="@id"/>
  <node expr="@label"/>
</select>
```

3. **Optimize where clause**
```javascript
// ❌ Slow: Function on indexed field
<condition expr="Year(@created) = 2024"/>

// ✅ Fast: Range query
<condition expr="@created >= '2024-01-01' AND @created < '2025-01-01'"/>
```

---

### Issue: XML Parsing Error

**Symptoms:**
- Error: "XML parsing error"
- Query fails to execute

**Common Causes:**

1. **Missing namespace**
```javascript
// ❌ Wrong
<queryDef schema="delivery">

// ✅ Correct
<queryDef schema="nms:delivery">
```

2. **Invalid expression**
```javascript
// ❌ Wrong: Missing quotes
<condition expr={variable}/>

// ✅ Correct
<condition expr={"@id = " + variable}/>
```

3. **Unescaped special characters**
```javascript
// ❌ Wrong: Breaks XML
<condition expr="@label = 'O'Reilly'"/>

// ✅ Correct: Escaped
<condition expr="@label = 'O''Reilly'"/>
```

---

## JavaScript Errors

### Issue: "Variable is not defined"

**Diagnosis:**
```javascript
// Check browser console (F12)
// Check ACC logs
```

**Common Causes:**

1. **Variable declared in wrong scope**
```javascript
// ❌ Wrong: var declared in server code
<%
var serverVar = "test";
%>
<script>
console.log(serverVar); // Error: not defined
</script>

// ✅ Correct: Pass to client
<%
var serverVar = "test";
%>
<script>
var clientVar = '<%= serverVar %>';
console.log(clientVar);
</script>
```

2. **Typo in variable name**
```javascript
var deliveries = [];
// ...
console.log(deliverys); // Error: typo
```

---

### Issue: "Cannot read property of undefined"

**Common Causes:**

1. **Null/undefined object**
```javascript
// ❌ Doesn't check for null
var label = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="aeedc6cfee">[email&#160;protected]</a>(); // Error if delivery is null

// ✅ Check first
if (delivery && <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="93d1fbf2d3">[email&#160;protected]</a>) {
  var label = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7e3c1623e3">[email&#160;protected]</a>();
}
```

2. **Empty query result**
```javascript
// ❌ No check
var delivery = query.ExecuteQuery();
var label = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4b09222b0b">[email&#160;protected]</a>(); // Error if no results

// ✅ Check result
var result = query.ExecuteQuery();
if (result && <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f1b392b1">[email&#160;protected]</a>) {
  var label = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7830111c5638">[email&#160;protected]</a>();
}
```

---

## Display Issues

### Issue: Styling Not Applied

**Diagnosis:**
```html
<!-- Check browser inspector -->
<!-- Check for CSS specificity issues -->
```

**Common Causes:**

1. **CSS not loaded**
```html
<!-- Check that CSS is in <style> or <link> -->
<style>
.card { background: white; }
</style>
```

2. **Specificity issues**
```css
/* Lower specificity */
.card { color: red; }

/* Higher specificity wins */
div.card { color: blue; }

/* Use !important as last resort */
.card { color: green !important; }
```

3. **Typo in class name**
```html
<!-- ❌ Typo -->
<div class="crad">

<!-- ✅ Correct -->
<div class="card">
```

---

### Issue: Content Not Updating

**Symptoms:**
- Changes don't appear
- Old data still visible

**Solutions:**

1. **Clear browser cache**
```html
<!-- Add cache busting headers -->
<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="0">
```

2. **Hard refresh**
- Chrome/Firefox: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
- Or open DevTools → Network → Disable cache

3. **Clear ACC cache**
```javascript
<%
// Force query re-execution
var query = xtk.queryDef.create(...);
var results = query.ExecuteQuery();

// Log to verify fresh data
logInfo("Query executed at: " + new Date().toISOString());
%>
```

---

### Issue: Layout Broken on Mobile

**Diagnosis:**
```html
<!-- Check viewport meta tag -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

**Solutions:**

1. **Add responsive grid**
```css
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
}

@media (max-width: 768px) {
  .cards-grid {
    grid-template-columns: 1fr;
  }
}
```

2. **Test with DevTools device emulation**
- Open DevTools (F12)
- Click device icon
- Select device or custom dimensions

---

## API Problems

### Issue: JSSP Returns Empty Response

**Diagnosis:**
```javascript
<%
logonEscalation("webapp");
response.contentType = "application/json";

// Add logging
logInfo("JSSP API called");
logInfo("Parameters: " + JSON.stringify(request.parameters));

var result = { success: false };

try {
  // Your code
  logInfo("Processing...");
  result.success = true;
} catch(e) {
  logError("Error: " + e.toString());
}

logInfo("Sending response: " + JSON.stringify(result));
document.write(JSON.stringify(result));
%>
```

**Common Causes:**

1. **Missing logonEscalation**
```javascript
// ❌ JSSP won't execute
<%
response.contentType = "application/json";
// ... rest of code

// ✅ Required for JSSP
<%
logonEscalation("webapp"); // <-- Must be first
response.contentType = "application/json";
```

2. **Exception before document.write**
```javascript
// ❌ Error prevents output
<%
var result = {success: false};
var data = query.ExecuteQuery(); // Throws error
document.write(JSON.stringify(result)); // Never reached

// ✅ Wrap in try-catch
<%
var result = {success: false};
try {
  var data = query.ExecuteQuery();
  result.success = true;
} catch(e) {
  result.error = e.message;
}
document.write(JSON.stringify(result));
%>
```

---

### Issue: CORS Error

**Symptoms:**
- "Access-Control-Allow-Origin" error in console
- AJAX requests fail

**Solution:**
```javascript
<%
// Add CORS headers in JSSP
logonEscalation("webapp");
response.addHeader("Access-Control-Allow-Origin", "*");
response.addHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
response.addHeader("Access-Control-Allow-Headers", "Content-Type");

// Handle OPTIONS preflight
if (request.method === "OPTIONS") {
  document.write("");
  return;
}

response.contentType = "application/json";
// ... rest of code
%>
```

---

### Issue: JSON Parse Error

**Diagnosis:**
```javascript
// Check response in Network tab
fetch('/jssp/api.jssp')
  .then(r => r.text()) // Use text() to see raw response
  .then(text => {
    console.log("Raw response:", text);
    return JSON.parse(text);
  });
```

**Common Causes:**

1. **HTML in JSON response**
```javascript
// ❌ Error message renders as HTML
<%
try {
  // ... code
} catch(e) {
  // This might output HTML error page
  throw e;
}

// ✅ Always return JSON
<%
var result = {success: false};
try {
  // ... code
  result.success = true;
} catch(e) {
  result.error = e.message;
}
document.write(JSON.stringify(result));
%>
```

2. **Extra output before JSON**
```javascript
// ❌ Don't output anything except JSON
<%
logonEscalation("webapp");
response.contentType = "application/json";
document.write("Debug message"); // ❌ Breaks JSON
document.write(JSON.stringify(result));

// ✅ Only JSON
<%
logonEscalation("webapp");
response.contentType = "application/json";
logInfo("Debug message"); // ✅ Use logging instead
document.write(JSON.stringify(result));
%>
```

---

## Performance Issues

### Issue: Page Loads Slowly

**Diagnosis:**
```javascript
<%
// Add timing
var startTime = new Date().getTime();

// ... page code

var endTime = new Date().getTime();
logInfo("Page generation took " + (endTime - startTime) + "ms");
%>
```

**Solutions:**

1. **Optimize queries** (see Query Optimization)
2. **Add pagination**
3. **Lazy load data**

```javascript
// Initial load: minimal data
<%
var recentItems = getRecentItems(10); // Only 10
%>

<div id="recent-items">
  <!-- Show 10 items -->
</div>

<button onclick="loadMore()">Load More</button>

<script>
function loadMore() {
  fetch('/jssp/api/items.jssp?limit=50')
    .then(r => r.json())
    .then(data => {
      // Append more items
    });
}
</script>
```

---

### Issue: High Server Load

**Check logs:**
- ACC logs: Administration > Production > Logs
- Look for repeated errors
- Check for query patterns

**Solutions:**

1. **Add caching** (see Caching Strategies)
2. **Optimize queries**
3. **Add rate limiting**

```javascript
<%
// Simple rate limiting
var rateLimitKey = "api_limit_" + ctx.userInfo.@id;
var maxCalls = 60; // per minute

var query = xtk.queryDef.create(
  <queryDef schema="xtk:option" operation="get">
    <select><node expr="@stringValue"/></select>
    <where><condition expr={"@name = '" + rateLimitKey + "'"}/></where>
  </queryDef>
);

var option = query.ExecuteQuery();
var callCount = option && <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7e1c0f1a1317181b3e171c10">[email&#160;protected]</a> ? 
  parseInt(<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c3a1b2a7a2a6a9aa83aaa1ad">[email&#160;protected]</a>()) : 0;

if (callCount >= maxCalls) {
  result.error = {
    code: "RATE_LIMIT",
    message: "Too many requests"
  };
  document.write(JSON.stringify(result));
  return;
}

// Increment counter
var optionXml = <option 
  _key={"@name"} 
  name={rateLimitKey} 
  stringValue={String(callCount + 1)} 
  xtkschema="xtk:option"/>;
xtk.session.Write(optionXml);
%>
```

---

## Authentication Errors

### Issue: "Access Denied"

**Diagnosis:**
```javascript
<%
logInfo("Current user: " + ctx.userInfo.@login);
logInfo("User ID: " + ctx.userInfo.@id);
%>
```

**Solutions:**

1. **Check permissions**
```javascript
<%
// Check if user has required role
var userId = ctx.userInfo.@id.toString();
var query = xtk.queryDef.create(
  <queryDef schema="xtk:operatorGroup" operation="select">
    <select><node expr="@name"/></select>
    <where>
      <condition expr={"@operator-id = " + userId}/>
    </where>
  </queryDef>
);

var groups = query.ExecuteQuery();
logInfo("User groups:");
for each(var group in groups.operatorGroup) {
  logInfo("  - " + <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="aae5daeac4">[email&#160;protected]</a>());
}
%>
```

2. **Grant permissions**
- Navigate to Administration > Access Management > Operators
- Edit operator
- Add to required group

---

### Issue: Session Timeout

**Symptoms:**
- User logged out unexpectedly
- "Session expired" message

**Solutions:**

1. **Check session timeout settings**
- Administration > Platform > Options
- Look for "SessionTimeOut" option

2. **Extend session**
```javascript
<%
// Refresh session on activity
session.setTimeOut(1800); // 30 minutes in seconds
%>
```

---

## Debugging Techniques

### Server-Side Debugging

```javascript
<%
// 1. Logging
logInfo("=== DEBUG: Function started ===");
logInfo("Parameter value: " + paramValue);

// 2. Variable inspection
logInfo("Variable type: " + typeof myVar);
logInfo("Variable value: " + JSON.stringify(myVar));

// 3. Query debugging
var query = xtk.queryDef.create(...);
logInfo("Query XML: " + query.toXMLString());
var results = query.ExecuteQuery();
logInfo("Result count: " + results.@count);

// 4. Conditional debugging
if (DEBUG_MODE) {
  logInfo("Debug info: " + JSON.stringify(debugData));
}
%>
```

### Client-Side Debugging

```javascript
<script>
// 1. Console logging
console.log("Value:", value);
console.error("Error:", error);
console.table(arrayData); // Nice table view

// 2. Debugger statement
function processData(data) {
  debugger; // Execution pauses here if DevTools open
  // ... processing
}

// 3. Network inspection
// Open DevTools > Network tab
// See all AJAX requests and responses

// 4. Element inspection
// Right-click element > Inspect
// See HTML structure and applied CSS
</script>
```

### Testing Queries in Console

```javascript
// In ACC client console (Tools > JavaScript console):
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select><node expr="@id"/></select>
  </queryDef>
);

var results = query.ExecuteQuery();
logInfo("Count: " + results.@count);

// Inspect results
for each(var delivery in results.delivery) {
  logInfo("ID: " + <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="23626543">[email&#160;protected]</a>());
}
```

---

## Common Error Messages

### "Schema not found"

**Cause:** Wrong schema name
**Solution:** Check schema name with namespace (e.g., `nms:delivery`)

### "Attribute not found"

**Cause:** Wrong field name or field doesn't exist
**Solution:** Check schema definition in ACC

### "Permission denied"

**Cause:** User lacks required permissions
**Solution:** Grant user appropriate rights/groups

### "Query timeout"

**Cause:** Query takes too long
**Solution:** Add lineCount, optimize where clause

### "Out of memory"

**Cause:** Too much data loaded at once
**Solution:** Use pagination, limit results

### "Unable to parse JSON"

**Cause:** Invalid JSON in response
**Solution:** Check JSSP only outputs JSON, no extra content

---

## Quick Debugging Checklist

**Query Not Working:**
- [ ] Schema name correct (with namespace)?
- [ ] Field names correct?
- [ ] Where clause valid?
- [ ] Check logs for errors
- [ ] Test simplified version

**Page Not Loading:**
- [ ] Check ACC logs
- [ ] Check browser console
- [ ] Clear browser cache
- [ ] Test in incognito mode

**Styling Issues:**
- [ ] CSS loaded?
- [ ] Class names correct?
- [ ] Check browser inspector
- [ ] Test in different browser

**API Not Working:**
- [ ] logonEscalation() present?
- [ ] Response format correct?
- [ ] Check Network tab
- [ ] View raw response

**Performance Issues:**
- [ ] Queries optimized?
- [ ] Results limited?
- [ ] Caching implemented?
- [ ] Check timing logs

---

**Need More Help?**
- Check [Adobe Documentation](https://experienceleague.adobe.com/docs/campaign-classic/)
- Review [Deep Wiki](https://deepwiki.com/AdobeDocs/campaign-classic.en)
- Search Stack Overflow: [adobe-campaign] tag
