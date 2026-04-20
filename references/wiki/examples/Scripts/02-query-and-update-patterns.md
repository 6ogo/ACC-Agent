# Query and Update Patterns

**Reading data with QueryDef and updating records in Adobe Campaign Classic**

---

## Overview

This guide covers the essential patterns for querying and updating data in ACC workflow scripts. You'll learn to use the QueryDef API, iterate over results, and safely update records.

---

## Table of Contents

1. [QueryDef Basics](#querydef-basics)
2. [Querying from Previous Activities](#querying-from-previous-activities)
3. [Loading Individual Records](#loading-individual-records)
4. [Exploring Record Properties](#exploring-record-properties)
5. [Updating Records](#updating-records)
6. [XML-Based Updates](#xml-based-updates)
7. [Bulk Update Patterns](#bulk-update-patterns)

---

## QueryDef Basics

QueryDef is the primary API for reading data from the ACC database.

### Simple Query

```javascript
var query = xtk.queryDef.create({
    queryDef: {
        schema: "nms:recipient",
        operation: "select",
        select: {
            node: [
                { expr: "@id" },
                { expr: "@firstName" },
                { expr: "@lastName" },
                { expr: "@email" }
            ]
        }
    }
});
var results = query.ExecuteQuery();

// Iterate results
for each (var recipient in results.recipient) {
    logInfo('Found: ' + recipient.@firstName + ' ' + recipient.@lastName);
}
```

### Query with Conditions

```javascript
var query = xtk.queryDef.create({
    queryDef: {
        schema: "nms:delivery",
        operation: "select",
        select: {
            node: [
                { expr: "@id" },
                { expr: "@label" },
                { expr: "@state" }
            ]
        },
        where: {
            condition: [
                { expr: "@state = 1" }  // Filter by state
            ]
        },
        orderBy: {
            node: [
                { expr: "@created", sortDesc: "true" }
            ]
        }
    }
});
var results = query.ExecuteQuery();
```

### Using NLWS.xtkQueryDef

Alternative syntax often used in workflow scripts:

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
```

---

## Querying from Previous Activities

When a JavaScript activity follows a Query activity, you can access the query results using `vars.targetSchema`.

### Pattern: Query Results from Previous Activity

```javascript
logInfo('---START OF RUN---');

// Query using the schema from previous Query activity
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

// Process each result
for each (var res in results.getElements("query")) {
    var id = res.getAttribute('id');
    var label = res.getAttribute('label');
    logInfo('Processing: ' + label + ' (ID: ' + id + ')');
}

logInfo('---END OF RUN---');
```

### Accessing Attributes

Two ways to access result attributes:

```javascript
for each (var res in results.getElements("query")) {
    // Method 1: getAttribute
    var id = res.getAttribute('id');

    // Method 2: E4X syntax
    var label = res.@label;

    logInfo('ID: ' + id + ', Label: ' + label);
}
```

---

## Loading Individual Records

To modify a record, first load it using the appropriate NLWS method.

### Loading Deliveries

```javascript
// Load by ID
var deliveryId = 537077963;
var delivery = NLWS.nmsDelivery.load(deliveryId);

// Or using get (returns XML)
var deliveryXml = NLWS.nmsDelivery.get(deliveryId);
```

### Loading Workflows

```javascript
var wfId = parseInt(res.@id.toString(), 10);
var workflow = NLWS.xtkWorkflow.load(wfId);
```

### Loading Other Entity Types

```javascript
// Recipients
var recipient = NLWS.nmsRecipient.load(recipientId);

// Operators
var operator = NLWS.xtkOperator.load(operatorId);

// Folders
var folder = NLWS.xtkFolder.load(folderId);
```

---

## Exploring Record Properties

These patterns help you discover what fields are available on a record.

### List All Fields

```javascript
var deliveryId = "533987282";
var delivery = NLWS.nmsDelivery.get(deliveryId);

// Log all fields
for (var field in delivery) {
    if (delivery.hasOwnProperty(field)) {
        logInfo("Field: " + field + ", Value: " + delivery[field]);
    }
}
```

### Explore Nested Properties

```javascript
var sourceDeliveryId = 235573908;
var sourceDelivery = NLWS.nmsDelivery.get(sourceDeliveryId);

logInfo("---------------NEW SCAN---------------");

// Explore content properties
for (var property in sourceDelivery.content) {
    logInfo("Name: " + property + " Value: " + sourceDelivery.content[property]);
}
```

### Find Entity Objects

```javascript
var sourceDeliveryId = 537077963;
var sourceDelivery = NLWS.nmsDelivery.get(sourceDeliveryId);

// Access specific nested elements
var conditions = sourceDelivery.execution.controlGroup;

logInfo("---------------NEW SCAN---------------");

for each (var condition in conditions) {
    for (var property in condition) {
        logInfo("Name: " + property + " Value: " + condition[property]);
    }
}
```

### Navigate XML Structure

```javascript
var sourceDeliveryId = 537077963;
var sourceDelivery = NLWS.nmsDelivery.get(sourceDeliveryId);

// Convert to XML
var deliveryXml = sourceDelivery.toXML();

// Try to access nested node directly
var newsletterNode = deliveryXml.content.Newsletter2019;

// If not found, search anywhere in XML (E4X descendant selector)
if (!newsletterNode || newsletterNode.length() == 0) {
    newsletterNode = deliveryXml..Newsletter2019;
}

// Extract attribute from found node
if (newsletterNode && newsletterNode.length() > 0) {
    var preheader = newsletterNode.@preheader.toString();
    logInfo("Preheader: " + preheader);
} else {
    logInfo("Error: Newsletter2019 node not found in the XML.");
}
```

---

## Updating Records

### Simple Property Update

```javascript
var deliveryId = res.getAttribute('id');
var delivery = NLWS.nmsDelivery.load(deliveryId);

// Modify property
delivery.typology.name = 'defaultTypology';

// Save changes
delivery.save();
logInfo(deliveryId + ' updated!');
```

### Conditional Update

```javascript
var deliveryId = res.getAttribute('id');
var delivery = NLWS.nmsDelivery.load(deliveryId);

// Check before updating
if (delivery.scheduling.waves.enabled == true) {
    delivery.scheduling.waves.enabled = false;
    delivery.save();
    logInfo('Waves disabled for Delivery: ' + deliveryId);
}
```

### Update with Error Handling

```javascript
var deliveryId = res.getAttribute('id');
var delivery = NLWS.nmsDelivery.load(deliveryId);

try {
    delivery.typology.name = 'defaultTypology';
    delivery.save();
    logInfo(deliveryId + ' updated!');
} catch (ex) {
    logError('Error updating ' + deliveryId + ': ' + ex.message);
}
```

---

## XML-Based Updates

For complex updates or when you need to modify attributes, use XML-based updates with `xtk.session.Write`.

### Two-Step Update Pattern

Sometimes you need to clear a value before setting a new one:

```javascript
var deliveryId = res.getAttribute('id');

try {
    // Step 1: Clear the field
    var delivery = NLWS.nmsDelivery.load(deliveryId);
    var deliveryXml = delivery.toXML();

    deliveryXml.@internalCompanyCode = '';
    deliveryXml.@_operation = "update";
    xtk.session.Write(deliveryXml);
    logInfo('Cleared internalCompanyCode for delivery: ' + deliveryId);

    // Step 2: Set new value
    delivery = NLWS.nmsDelivery.load(deliveryId);
    deliveryXml = delivery.toXML();

    deliveryXml.@internalCompanyCode = 'BXX';
    deliveryXml.@_operation = "update";
    xtk.session.Write(deliveryXml);
    logInfo('Updated internalCompanyCode to BXX for delivery: ' + deliveryId);

} catch (ex) {
    logError('Error updating ' + deliveryId + ': ' + ex.message);
}
```

### Setting XML Content

For complex values like CDATA content:

```javascript
var deliveryId = res.getAttribute('id');
var delivery = NLWS.nmsDelivery.load(deliveryId);

try {
    // Check current value
    if (delivery.mailParameters.senderName != "<![CDATA[<%= recipient.companySignaturesLink.companyName %>]]>") {
        logInfo('Changing senderName for Delivery ID: ' + deliveryId);

        // Set XML content
        delivery.mailParameters.senderName = new XML("<![CDATA[<%= recipient.companySignaturesLink.companyName %>]]>");

        delivery.save();
        logInfo('senderName update complete for delivery: ' + deliveryId);
    }
} catch (ex) {
    logError('Error during update of ' + deliveryId + ': ' + ex.message);
}
```

---

## Bulk Update Patterns

### Complete Bulk Update Example

```javascript
logInfo('---START OF RUN---');

// Query deliveries from previous Query activity
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

// Count for logging
var count = 0;
for each (var res in results.getElements("query")) {
    count++;
}
logInfo('Found ' + count + ' records to process');

// Process each record
var successCount = 0;
var errorCount = 0;

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    var label = res.getAttribute('label');

    try {
        var delivery = NLWS.nmsDelivery.load(deliveryId);

        // Your update logic here
        delivery.execution.controlGroup.enabled = false;

        delivery.save();
        logInfo('Updated: ' + label + ' (' + deliveryId + ')');
        successCount++;

    } catch (ex) {
        logError('Error on ' + deliveryId + ': ' + ex.message);
        errorCount++;
    }
}

logInfo('Completed: ' + successCount + ' success, ' + errorCount + ' errors');
logInfo('---END OF RUN---');
```

### Workflow Bulk Update (Find/Replace)

```javascript
logInfo('---START OF RUN---');

// Query workflows
var query = xtk.queryDef.create(
    <queryDef schema={vars.targetSchema} operation="select">
        <select>
            <node expr="@id"/>
            <node expr="@internalName"/>
        </select>
    </queryDef>
);
var results = query.ExecuteQuery();

// Process each workflow
for each (var res in results.query) {
    var wfId = parseInt(res.@id.toString(), 10);
    var wfName = res.@internalName.toString();

    try {
        logInfo('Processing: ' + wfName + ' (' + wfId + ')');

        // Load workflow and convert to XML string
        var wf = NLWS.xtkWorkflow.load(wfId);
        var wfXml = wf.toXML();
        var xmlString = wfXml.toXMLString();

        // Define old and new field values
        var oldField = '[agreementLink/physicalObjectLink/@physicalObjectRegistrationNumber]';
        var newField = '[agreementLink/RallySpecific/@vehicleRegistrationNumber]';

        // Check if old field exists
        if (xmlString.indexOf(oldField) === -1) {
            continue; // Skip if not found
        }

        // Count occurrences
        var pattern = oldField.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        var count = (xmlString.match(new RegExp(pattern, 'g')) || []).length;

        // Replace all occurrences
        var newXmlString = xmlString.split(oldField).join(newField);

        if (newXmlString === xmlString) {
            logInfo('No replacements needed for ' + wfName);
            continue;
        }

        // Parse back to XML and save
        var modifiedXml = new XML(newXmlString);
        modifiedXml.@['xtkschema'] = 'xtk:workflow';
        xtk.session.Write(modifiedXml);
        logInfo('Saved: ' + wfName + ' (' + count + ' fields replaced)');

    } catch (ex) {
        logError('ERROR on ' + wfName + ': ' + (ex.message || ex));
    }
}

logInfo('---END OF RUN---');
```

---

## Common Schemas

| Schema | Entity | NLWS Method |
|--------|--------|-------------|
| `nms:recipient` | Recipients | `NLWS.nmsRecipient` |
| `nms:delivery` | Deliveries | `NLWS.nmsDelivery` |
| `xtk:workflow` | Workflows | `NLWS.xtkWorkflow` |
| `xtk:operator` | Operators | `NLWS.xtkOperator` |
| `xtk:folder` | Folders | `NLWS.xtkFolder` |
| `nms:webApp` | Web apps | `NLWS.nmsWebApp` |

---

## Best Practices

1. **Always log the record ID** when processing in loops
2. **Use try/catch** around each record operation
3. **Check values before updating** to avoid unnecessary saves
4. **Load fresh** after modifying via XML write
5. **Count successes and errors** for summary logging

---

## Next Steps

- [ETL Processing](03-etl-processing.md) - File handling patterns
- [Delivery Management](04-delivery-management.md) - Delivery-specific updates

---

**Related:** [Scripts README](README.md) | [Database Queries](../../05-DATABASE-QUERIES.md)
