# Database & Queries Guide

Complete guide to querying data in Adobe Campaign Classic using QueryDef API.

## Table of Contents
1. [QueryDef Fundamentals](#querydef-fundamentals)
2. [Select Operations](#select-operations)
3. [Where Conditions](#where-conditions)
4. [Joins & Relationships](#joins--relationships)
5. [Aggregations](#aggregations)
6. [Ordering & Pagination](#ordering--pagination)
7. [Performance Tips](#performance-tips)
8. [Common Patterns](#common-patterns)

---

## QueryDef Fundamentals

### Basic Structure

```javascript
var query = xtk.queryDef.create(
  <queryDef schema="schemaName" operation="operationType">
    <select>
      <!-- Fields to retrieve -->
    </select>
    <where>
      <!-- Filter conditions -->
    </where>
    <orderBy>
      <!-- Sorting -->
    </orderBy>
  </queryDef>
);

var results = query.ExecuteQuery();
```

### Operations

| Operation | Purpose | Returns |
|-----------|---------|---------|
| `select` | Get multiple records | Collection |
| `get` | Get single record | Single object |
| `count` | Count records | Count attribute |
| `getIfExists` | Get if exists, else null | Single or null |

### Schema Notation

```javascript
// @attribute - Field from current schema
<node expr="@id"/>
<node expr="@label"/>

// [schema/link] - Related schema
<node expr="[recipient/@email]"/>

// [schema/@attribute] - Attribute from link
<node expr="[delivery/@state]"/>
```

---

## Select Operations

### Basic Select

```javascript
// Select specific fields
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="@state"/>
      <node expr="@lastModified"/>
    </select>
  </queryDef>
);

var deliveries = query.ExecuteQuery();

// Access results
for each(var delivery in deliveries.delivery) {
  var id = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6f29202f16">[email&#160;protected]</a>();
  var label = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3e5c5b4d4b7e5351">[email&#160;protected]</a>();
}
```

### Select with Alias

```javascript
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id" alias="deliveryId"/>
      <node expr="@label" alias="deliveryName"/>
      <node expr="Year(@lastModified)" alias="year"/>
    </select>
  </queryDef>
);

var results = query.ExecuteQuery();
for each(var row in results) {
  var id = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bafbdcd5dce8fcfad6d5d4dd">[email&#160;protected]</a>();
  var name = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0a48786b7965697c6f6278794a6b68">[email&#160;protected]</a>();
  var year = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="11726361">[email&#160;protected]</a>();
}
```

### Calculated Fields

```javascript
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@label"/>
      <node expr="@lastModified"/>
      <!-- Calculate days since modified -->
      <node expr="DaysDiff(GetDate(), @lastModified)" alias="daysSince"/>
      <!-- Concatenate fields -->
      <node expr="@label + ' (' + @internalName + ')'" alias="fullName"/>
    </select>
  </queryDef>
);
```

### Distinct Values

```javascript
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" distinct="true">
    <select>
      <node expr="@state"/>
    </select>
  </queryDef>
);

var states = query.ExecuteQuery();
for each(var row in states) {
  var state = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="76061b1c1b3615">[email&#160;protected]</a>();
}
```

---

## Where Conditions

### Basic Conditions

```javascript
// Single condition
<where>
  <condition expr="@id = 12345"/>
</where>

// Multiple conditions (AND)
<where>
  <condition expr="@state = 1"/>
  <condition expr="@lastModified >= GetDate() - 30"/>
</where>

// OR conditions
<where>
  <condition boolOperator="OR" expr="@state = 1"/>
  <condition expr="@state = 2"/>
</where>
```

### Comparison Operators

```javascript
// Equals
<condition expr="@state = 1"/>

// Not equals
<condition expr="@state != 0"/>

// Greater than / Less than
<condition expr="@id > 1000"/>
<condition expr="@created < GetDate()"/>

// Like (pattern matching)
<condition expr="@label LIKE '%Newsletter%'"/>
<condition expr="@email LIKE 'user@%'"/>

// In list
<condition expr="@state IN (1, 2, 3)"/>
<condition expr="@type IN ('email', 'sms')"/>

// Between
<condition expr="@created BETWEEN '2024-01-01' AND '2024-12-31'"/>

// Is null / Is not null
<condition expr="@label IS NULL"/>
<condition expr="@email IS NOT NULL"/>
```

### Dynamic Where Conditions

```javascript
// Build conditions array
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

// Join conditions or use default
var whereExpr = conditions.length > 0 ? 
  conditions.join(' AND ') : 
  "1=1";

// Use in query
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <where>
      <condition expr={whereExpr}/>
    </where>
  </queryDef>
);
```

### Date Functions

```javascript
// Current date
<condition expr="@created >= GetDate()"/>

// Date arithmetic
<condition expr="@lastModified >= GetDate() - 30"/> // Last 30 days
<condition expr="@created <= GetDate() - 365"/> // Older than 1 year

// Extract date parts
<condition expr="Year(@created) = 2024"/>
<condition expr="Month(@lastModified) = 12"/>
<condition expr="DayOfWeek(@created) = 1"/> // Monday

// Date formatting
<node expr="ToString(@created, '%4Y-%2M-%2D')" alias="createdDate"/>
```

---

## Joins & Relationships

### Simple Link

```javascript
// Access recipient from delivery
var query = xtk.queryDef.create(
  <queryDef schema="nms:broadLogRcp" operation="select">
    <select>
      <node expr="@id"/>
      <!-- Link to delivery -->
      <node expr="[delivery/@label]" alias="deliveryLabel"/>
      <!-- Link to recipient -->
      <node expr="[recipient/@email]" alias="recipientEmail"/>
    </select>
  </queryDef>
);
```

### Multiple Joins

```javascript
var query = xtk.queryDef.create(
  <queryDef schema="nms:trackingLogRcp" operation="select">
    <select>
      <node expr="@id"/>
      <!-- Delivery info -->
      <node expr="[delivery/@label]"/>
      <node expr="[delivery/@state]"/>
      <!-- Recipient info -->
      <node expr="[recipient/@email]"/>
      <node expr="[recipient/@firstName]"/>
      <node expr="[recipient/@lastName]"/>
      <!-- URL info -->
      <node expr="[url/@url]"/>
    </select>
    <where>
      <condition expr="[delivery/@id] = 12345"/>
    </where>
  </queryDef>
);
```

### Custom Joins

```javascript
// Query with custom join condition
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <where>
      <condition expr="Exists(SELECT 1 FROM nmsTrackingLogRcp T 
                               WHERE T.iDeliveryId = @id 
                               AND T.tsLog >= GetDate() - 7)"/>
    </where>
  </queryDef>
);
```

---

## Aggregations

### Count

```javascript
// Total count
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="Count(@id)" alias="total"/>
    </select>
  </queryDef>
);

var result = query.ExecuteQuery();
var totalCount = <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="88ede6f9c8e4">[email&#160;protected]</a>();

// Count with grouping
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@state" alias="state"/>
      <node expr="Count(@id)" alias="count"/>
    </select>
    <groupBy>
      <node expr="@state"/>
    </groupBy>
  </queryDef>
);
```

### Sum, Avg, Min, Max

```javascript
var query = xtk.queryDef.create(
  <queryDef schema="nms:broadLogRcp" operation="select">
    <select>
      <node expr="[delivery/@id]" alias="deliveryId"/>
      <!-- Count records -->
      <node expr="Count(@id)" alias="totalSent"/>
      <!-- Count distinct -->
      <node expr="CountDistinct([recipient/@email])" alias="uniqueRecipients"/>
      <!-- Sum -->
      <node expr="Sum(@amount)" alias="totalAmount"/>
      <!-- Average -->
      <node expr="Avg(@score)" alias="avgScore"/>
      <!-- Min / Max -->
      <node expr="Min(@created)" alias="firstSent"/>
      <node expr="Max(@created)" alias="lastSent"/>
    </select>
    <groupBy>
      <node expr="[delivery/@id]"/>
    </groupBy>
  </queryDef>
);
```

### Complex Aggregations

```javascript
// Calculate open rate
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <!-- Total sent -->
      <node expr="Count([broadLogRcp/@id])" alias="totalSent"/>
      <!-- Total opens -->
      <node expr="Count([broadLogRcp/trackingLogRcp/@id])" alias="totalOpens"/>
      <!-- Open rate percentage -->
      <node expr="Case(
        When(Count([broadLogRcp/@id]) > 0,
          Round(Count([broadLogRcp/trackingLogRcp/@id]) * 100.0 / Count([broadLogRcp/@id]), 2),
          0)
      )" alias="openRate"/>
    </select>
    <groupBy>
      <node expr="@id"/>
      <node expr="@label"/>
    </groupBy>
  </queryDef>
);
```

### Having Clause

```javascript
// Filter groups (like WHERE but for aggregated data)
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@state"/>
      <node expr="Count(@id)" alias="count"/>
    </select>
    <groupBy>
      <node expr="@state"/>
    </groupBy>
    <having>
      <condition expr="Count(@id) > 10"/>
    </having>
  </queryDef>
);
```

---

## Ordering & Pagination

### Order By

```javascript
// Single field ascending
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
    </select>
    <orderBy>
      <node expr="@label"/>
    </orderBy>
  </queryDef>
);

// Descending order
<orderBy>
  <node expr="@lastModified" sortDesc="true"/>
</orderBy>

// Multiple fields
<orderBy>
  <node expr="@state"/>
  <node expr="@lastModified" sortDesc="true"/>
</orderBy>

// Order by calculated field
<orderBy>
  <node expr="Count(@id)" sortDesc="true"/>
</orderBy>
```

### Pagination

```javascript
var page = parseInt(request.getParameter('page') || '1');
var pageSize = 50;
var startLine = (page - 1) * pageSize;

var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" 
            lineCount={pageSize} 
            startLine={startLine}>
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
var totalCount = results.@count; // Total records (all pages)
var currentCount = results.delivery.length(); // Records on this page
var totalPages = Math.ceil(totalCount / pageSize);
```

### Top N Results

```javascript
// Get top 10
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select" lineCount="10">
    <select>
      <node expr="@id"/>
      <node expr="@label"/>
      <node expr="Count([broadLogRcp/@id])" alias="sentCount"/>
    </select>
    <groupBy>
      <node expr="@id"/>
      <node expr="@label"/>
    </groupBy>
    <orderBy>
      <node expr="Count([broadLogRcp/@id])" sortDesc="true"/>
    </orderBy>
  </queryDef>
);
```

---

## Performance Tips

### 1. Select Only Needed Fields

```javascript
// BAD: Select everything
<select>
  <node expr="*"/>
</select>

// GOOD: Select specific fields
<select>
  <node expr="@id"/>
  <node expr="@label"/>
</select>
```

### 2. Use Appropriate Operation

```javascript
// BAD: Select when you need count
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    ...
  </queryDef>
);
var count = query.ExecuteQuery().delivery.length();

// GOOD: Use count operation
var query = xtk.queryDef.create(
  <queryDef schema="nms:delivery" operation="select">
    <select>
      <node expr="Count(@id)" alias="count"/>
    </select>
  </queryDef>
);
var count = query.ExecuteQuery().@count;
```

### 3. Limit Results

```javascript
// Always use lineCount when displaying data
<queryDef schema="nms:delivery" operation="select" lineCount="100">
```

### 4. Use Indexes

```javascript
// Query on indexed fields
<condition expr="@id = 12345"/> // id is indexed
<condition expr="@internalName = 'newsletter'"/> // internalName is indexed

// Avoid functions on indexed fields
// BAD
<condition expr="Upper(@email) = 'USER@DOMAIN.COM'"/>
// GOOD
<condition expr="@email = 'user@domain.com'"/>
```

### 5. Avoid Queries in Loops

```javascript
// BAD: Query inside loop
for each(var delivery in deliveries.delivery) {
  var statsQuery = xtk.queryDef.create(...);
  var stats = statsQuery.ExecuteQuery();
}

// GOOD: Single query with GROUP BY
var statsQuery = xtk.queryDef.create(
  <queryDef schema="nms:trackingLogRcp" operation="select">
    <select>
      <node expr="@delivery-id"/>
      <node expr="Count(@id)" alias="opens"/>
    </select>
    <groupBy>
      <node expr="@delivery-id"/>
    </groupBy>
  </queryDef>
);
```

---

## Common Patterns

### Pattern 1: Get Distinct Values for Filters

```javascript
function getDistinctValues(fieldName) {
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="select" distinct="true">
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
    values.push(value);
  }
  
  return values;
}

// Usage
var states = getDistinctValues('state');
var types = getDistinctValues('type');
```

### Pattern 2: Check Record Exists

```javascript
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
  return (result && <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="68260928">[email&#160;protected]</a>);
}

// Usage
if (recordExists("nms:delivery", 12345)) {
  // Record exists
}
```

### Pattern 3: Date Range Query

```javascript
function getDeliveriesInDateRange(dateFrom, dateTo) {
  var conditions = [];
  
  if (dateFrom) {
    conditions.push("@lastModified >= '" + dateFrom + "'");
  }
  
  if (dateTo) {
    conditions.push("@lastModified <= '" + dateTo + "'");
  }
  
  var whereExpr = conditions.length > 0 ? 
    conditions.join(' AND ') : 
    "1=1";
  
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="select">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
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
  
  return query.ExecuteQuery();
}
```

### Pattern 4: Search with Multiple Criteria

```javascript
function searchDeliveries(filters) {
  var conditions = [];
  
  // Text search (partial match)
  if (filters.name) {
    conditions.push("@label LIKE '%" + filters.name + "%'");
  }
  
  // Exact match
  if (filters.state) {
    conditions.push("@state = " + filters.state);
  }
  
  // List match
  if (filters.types && filters.types.length > 0) {
    var typeList = filters.types.map(function(t) { 
      return "'" + t + "'"; 
    }).join(',');
    conditions.push("@deliveryMode IN (" + typeList + ")");
  }
  
  // Date range
  if (filters.dateFrom) {
    conditions.push("@created >= '" + filters.dateFrom + "'");
  }
  if (filters.dateTo) {
    conditions.push("@created <= '" + filters.dateTo + "'");
  }
  
  var whereExpr = conditions.length > 0 ? 
    conditions.join(' AND ') : 
    "1=1";
  
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="select">
      <select>
        <node expr="@id"/>
        <node expr="@label"/>
        <node expr="@state"/>
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
  
  return query.ExecuteQuery();
}
```

### Pattern 5: Aggregation by Month

```javascript
function getMonthlyStats(year) {
  var query = xtk.queryDef.create(
    <queryDef schema="nms:delivery" operation="select">
      <select>
        <node expr="Month(@lastModified)" alias="month"/>
        <node expr="Count(@id)" alias="count"/>
        <node expr="Sum(Case(When(@state=1, 1, 0)))" alias="sent"/>
        <node expr="Sum(Case(When(@state=2, 1, 0)))" alias="failed"/>
      </select>
      <where>
        <condition expr={"Year(@lastModified) = " + year}/>
      </where>
      <groupBy>
        <node expr="Month(@lastModified)"/>
      </groupBy>
      <orderBy>
        <node expr="Month(@lastModified)"/>
      </orderBy>
    </queryDef>
  );
  
  return query.ExecuteQuery();
}
```

---

## Schema Reference

### Common Schemas

| Schema | Description |
|--------|-------------|
| `nms:delivery` | Email/SMS deliveries |
| `nms:recipient` | Recipients |
| `nms:broadLogRcp` | Delivery logs |
| `nms:trackingLogRcp` | Tracking logs (opens/clicks) |
| `nms:webApp` | Web applications |
| `xtk:option` | System options |
| `xtk:operator` | Operators/users |

### Common Fields

```javascript
// Standard fields on most schemas
@id                // Primary key
@created           // Creation date
@lastModified      // Last modified date
@createdBy-id      // Creator ID
@modifiedBy-id     // Last modifier ID

// Delivery specific
@label             // Display name
@internalName      // Internal identifier
@state             // Status
@deliveryMode      // Channel (email, sms, etc.)
```

---

**Next Steps:**
- [Security & Performance](07-SECURITY-PERFORMANCE.md) - Optimization techniques
- [Code Templates](08-CODE-TEMPLATES.md) - Ready-to-use query templates
- [Troubleshooting](09-TROUBLESHOOTING.md) - Common query issues
