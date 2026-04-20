# Workflow Scripts in Adobe Campaign Classic

**JavaScript scripting for workflow automation and batch operations**

---

## Overview

Workflow scripts in Adobe Campaign Classic enable you to automate complex operations, manipulate data, update records in bulk, and integrate with external systems. Scripts run within workflow activities and have access to the full ACC JavaScript API.

This section contains guides and production-tested examples for common scripting patterns.

---

## When to Use Workflow Scripts

| Use Case | Best Approach |
|----------|---------------|
| Bulk update records | JavaScript activity with loop |
| Conditional logic | JavaScript activity or Test activity |
| ETL processing | JavaScript activity with File API |
| Custom validation | JavaScript activity before targeting |
| External integrations | JavaScript activity with HTTP calls |
| Simple field mapping | Enrichment activity (no script needed) |
| Basic filtering | Query activity (no script needed) |

---

## Documentation

| # | Guide | Description |
|---|-------|-------------|
| 01 | [Workflow Scripts Guide](01-workflow-scripts-guide.md) | Fundamentals, logging, variables, error handling |
| 02 | [Query and Update Patterns](02-query-and-update-patterns.md) | QueryDef API, reading data, updating records |
| 03 | [ETL Processing](03-etl-processing.md) | File handling, date operations, transformations |
| 04 | [Delivery Management](04-delivery-management.md) | Modifying deliveries, waves, typology rules |

---

## Quick Reference

### Essential Functions

```javascript
// Logging
logInfo('Information message');    // Info level
logWarning('Warning message');     // Warning level
logError('Error message');         // Error level

// Options (persistent settings)
var value = getOption('optionName');
setOption('optionName', 'newValue');

// Variables (workflow scope)
vars.myVariable = 'value';          // Set variable
var x = vars.myVariable;            // Get variable
instance.vars.shared = 'value';     // Instance-level variable
```

### Query Pattern

```javascript
var query = NLWS.xtkQueryDef.create({
    queryDef: {
        schema: vars.targetSchema,
        operation: 'select',
        select: {
            node: [
                { expr: '@id' },
                { expr: '@label' }
            ]
        }
    }
});
var results = query.ExecuteQuery();

for each (var row in results.getElements("query")) {
    var id = row.getAttribute('id');
    logInfo('Found: ' + id);
}
```

### Update Pattern

```javascript
var record = NLWS.nmsDelivery.load(deliveryId);
record.someProperty = 'newValue';
record.save();
```

### Error Handling

```javascript
try {
    // Your code here
    record.save();
    logInfo('Success');
} catch (ex) {
    logError('Error: ' + ex.message);
}
```

---

## Workflow Activity Types

Scripts can be used in these workflow activities:

| Activity | Icon | Use Case |
|----------|------|----------|
| **JavaScript code** | `</>` | General scripting, complex logic |
| **Advanced JavaScript code** | `</>+` | Multiple input/output transitions |
| **External signal** | Signal icon | Trigger workflows externally |
| **SQL code** | SQL icon | Direct SQL execution |
| **Test** | Diamond | Conditional branching |
| **Enrichment** | Enrichment icon | Can include computed fields |

---

## Best Practices

### Do's

- **Log extensively** - Use `logInfo()` to track progress
- **Use try/catch** - Wrap operations that might fail
- **Check before update** - Verify values before saving
- **Use vars.targetSchema** - Access query results from previous activities
- **Test with small datasets** - Verify logic before bulk operations

### Don'ts

- **Don't hardcode IDs** - Use queries to find records dynamically
- **Don't skip error handling** - Always catch and log errors
- **Don't forget to save** - Call `.save()` after modifications
- **Don't ignore performance** - Limit queries, use indexes
- **Don't run untested scripts** - Test in development first

---

## Related Documentation

- [Database Queries](../../05-DATABASE-QUERIES.md) - QueryDef reference
- [Advanced Patterns](../../10-ADVANCED-PATTERNS.md) - Complex scenarios
- [Troubleshooting](../../09-TROUBLESHOOTING.md) - Common issues

---

**Ready to start?** Begin with [01 - Workflow Scripts Guide](01-workflow-scripts-guide.md)
