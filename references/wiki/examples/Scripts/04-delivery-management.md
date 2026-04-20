# Delivery Management

**Modifying deliveries, waves, typology rules, and sender settings in Adobe Campaign Classic**

---

## Overview

This guide covers patterns for programmatically modifying deliveries in ACC. You'll learn to update sender information, configure wave scheduling, manage control groups, and change typology rules across multiple deliveries.

---

## Table of Contents

1. [Loading and Saving Deliveries](#loading-and-saving-deliveries)
2. [Updating Sender Information](#updating-sender-information)
3. [Wave Scheduling](#wave-scheduling)
4. [Control Groups](#control-groups)
5. [Typology Rules](#typology-rules)
6. [Custom Fields](#custom-fields)
7. [Bulk Update Pattern](#bulk-update-pattern)
8. [Best Practices](#best-practices)

---

## Loading and Saving Deliveries

### Loading a Delivery

```javascript
// Load by ID (returns modifiable object)
var deliveryId = 537077963;
var delivery = NLWS.nmsDelivery.load(deliveryId);

// Get by ID (returns XML representation)
var deliveryXml = NLWS.nmsDelivery.get(deliveryId);
```

### Saving Changes

```javascript
// After modifying properties
delivery.someProperty = 'newValue';
delivery.save();
logInfo('Delivery saved successfully');
```

### Load from Query Results

```javascript
// Query deliveries
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

// Load each delivery
for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    var delivery = NLWS.nmsDelivery.load(deliveryId);

    // ... modify and save
}
```

---

## Updating Sender Information

### Change Sender Name (From Field)

Update the sender name to use a dynamic expression:

```javascript
logInfo('---START OF RUN---');

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

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    var delivery = NLWS.nmsDelivery.load(deliveryId);

    try {
        // Check current value before updating
        if (delivery.mailParameters.senderName != "<![CDATA[<%= recipient.companySignaturesLink.companyName %>]]>") {
            logInfo('Changing senderName for Delivery ID: ' + deliveryId);

            // Set new sender name with personalization
            delivery.mailParameters.senderName = new XML("<![CDATA[<%= recipient.companySignaturesLink.companyName %>]]>");

            delivery.save();
            logInfo('senderName update complete for delivery: ' + deliveryId);
        }
    } catch (ex) {
        logError('Error updating ' + deliveryId + ': ' + ex.message);
    }
}

logInfo('---END OF RUN---');
```

### Common Sender Name Patterns

```javascript
// Static sender name
delivery.mailParameters.senderName = "Company Name";

// Dynamic from recipient field
delivery.mailParameters.senderName = new XML("<![CDATA[<%= recipient.companySignaturesLink.companyName %>]]>");

// Dynamic from delivery field
delivery.mailParameters.senderName = new XML("<![CDATA[<%= delivery.@senderName %>]]>");
```

---

## Wave Scheduling

### Disable Waves

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

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    logInfo('Delivery ID: ' + deliveryId);

    var delivery = NLWS.nmsDelivery.load(deliveryId);

    // Check if waves are enabled
    if (delivery.scheduling.waves.enabled == true) {
        delivery.scheduling.waves.enabled = false;
        delivery.save();
        logInfo('Waves disabled for Delivery: ' + deliveryId);
    }
}
```

### Enable and Configure Waves

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

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    logInfo('Delivery ID: ' + deliveryId);

    var delivery = NLWS.nmsDelivery.load(deliveryId);

    // Enable waves if disabled
    if (delivery.scheduling.waves.enabled == false) {
        delivery.scheduling.waves.enabled = true;

        // Wave mode: 0 = by size, 1 = by calendar
        delivery.scheduling.waves.mode = 0;

        // Split size as percentage
        delivery.scheduling.waves.splitSize = "5 %";

        // Delay between waves in seconds (360 = 6 minutes)
        delivery.scheduling.waves.splitDelay = "360";

        delivery.save();
        logInfo('Waves enabled for Delivery: ' + deliveryId);
    }
}
```

### Wave Configuration Options

| Property | Description | Example Values |
|----------|-------------|----------------|
| `enabled` | Enable/disable waves | `true`, `false` |
| `mode` | Wave split mode | `0` (by size), `1` (by calendar) |
| `splitSize` | Size per wave | `"5 %"`, `"1000"` (count) |
| `splitDelay` | Delay in seconds | `"360"` (6 min), `"3600"` (1 hour) |

---

## Control Groups

### Disable Control Group

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
logInfo('Results: ' + results);

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    logInfo('Delivery ID: ' + deliveryId);

    var delivery = NLWS.nmsDelivery.load(deliveryId);

    // Disable control group
    delivery.execution.controlGroup.enabled = false;

    delivery.save();
    logInfo('Control group disabled for Delivery: ' + deliveryId);
}
```

### Enable Control Group

```javascript
var delivery = NLWS.nmsDelivery.load(deliveryId);

// Enable control group
delivery.execution.controlGroup.enabled = true;

// Configure control group size (optional)
// delivery.execution.controlGroup.size = "5 %";

delivery.save();
```

### Explore Control Group Properties

```javascript
var sourceDeliveryId = 537077963;
var sourceDelivery = NLWS.nmsDelivery.get(sourceDeliveryId);

var conditions = sourceDelivery.execution.controlGroup;

logInfo("---------------NEW SCAN---------------");

for each (var condition in conditions) {
    for (var property in condition) {
        logInfo("Name: " + property + " Value: " + condition[property]);
    }
}
```

---

## Typology Rules

### Change Typology

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

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    var delivery = NLWS.nmsDelivery.load(deliveryId);

    try {
        // Set typology by name
        delivery.typology.name = 'defaultTypology';

        delivery.save();
        logInfo(deliveryId + ' typology updated!');

    } catch (ex) {
        logError('Error updating ' + deliveryId + ': ' + ex.message);
    }
}
```

### Common Typology Operations

```javascript
// Set typology by name
delivery.typology.name = 'defaultTypology';

// Set typology by ID
delivery.typology.id = 12345;

// Clear typology (use default)
delivery.typology.name = '';
```

---

## Custom Fields

### Update Custom Field via XML

For custom fields that require XML-based updates:

```javascript
var query = NLWS.xtkQueryDef.create({
    queryDef: {
        schema: vars.targetSchema,
        operation: 'select',
        select: {
            node: [
                { expr: '@id' },
                { expr: '@label' },
                { expr: '@internalCompanyCode' }
            ]
        }
    }
});
var results = query.ExecuteQuery();

for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');

    try {
        // Step 1: Clear the field first
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
}
```

### Why Two-Step Update?

Some fields require clearing before setting a new value because:
- ACC caches certain field values
- Direct overwrites may not trigger validation
- Two-step ensures the new value is properly registered

---

## Bulk Update Pattern

### Complete Template

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

// Counters
var totalCount = 0;
var successCount = 0;
var skipCount = 0;
var errorCount = 0;

// Count total
for each (var res in results.getElements("query")) {
    totalCount++;
}
logInfo('Found ' + totalCount + ' deliveries to process');

// Process each delivery
for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    var deliveryLabel = res.getAttribute('label');

    try {
        var delivery = NLWS.nmsDelivery.load(deliveryId);

        // ========================================
        // YOUR UPDATE LOGIC HERE
        // ========================================

        // Example: Check before update
        if (delivery.scheduling.waves.enabled == true) {
            delivery.scheduling.waves.enabled = false;
            delivery.save();
            logInfo('Updated: ' + deliveryLabel + ' (' + deliveryId + ')');
            successCount++;
        } else {
            logInfo('Skipped (already disabled): ' + deliveryLabel);
            skipCount++;
        }

        // ========================================

    } catch (ex) {
        logError('Error on ' + deliveryId + ': ' + ex.message);
        errorCount++;
    }
}

// Summary
logInfo('========================================');
logInfo('SUMMARY:');
logInfo('  Total:   ' + totalCount);
logInfo('  Success: ' + successCount);
logInfo('  Skipped: ' + skipCount);
logInfo('  Errors:  ' + errorCount);
logInfo('========================================');
logInfo('---END OF RUN---');
```

---

## Common Delivery Properties

### Mail Parameters

```javascript
delivery.mailParameters.senderName     // From name
delivery.mailParameters.senderAddress  // From email
delivery.mailParameters.replyAddress   // Reply-to email
delivery.mailParameters.subject        // Email subject
```

### Scheduling

```javascript
delivery.scheduling.waves.enabled       // Wave scheduling on/off
delivery.scheduling.waves.mode          // 0=by size, 1=by calendar
delivery.scheduling.waves.splitSize     // e.g., "5 %"
delivery.scheduling.waves.splitDelay    // seconds between waves
delivery.scheduling.contactDate         // Scheduled send date
```

### Execution

```javascript
delivery.execution.controlGroup.enabled   // Control group on/off
delivery.execution.controlGroup.size      // Control group size
```

### Typology

```javascript
delivery.typology.name    // Typology name
delivery.typology.id      // Typology ID
```

### State

```javascript
delivery.state            // Delivery state (0=draft, 1=ready, etc.)
delivery.status           // Execution status
```

---

## Best Practices

### 1. Always Check Before Updating

```javascript
// Only update if needed
if (delivery.scheduling.waves.enabled == true) {
    delivery.scheduling.waves.enabled = false;
    delivery.save();
    logInfo('Updated');
} else {
    logInfo('Already in desired state, skipping');
}
```

### 2. Use Try/Catch for Each Record

```javascript
for each (var res in results.getElements("query")) {
    var deliveryId = res.getAttribute('id');
    try {
        // Update logic
    } catch (ex) {
        logError('Failed: ' + deliveryId + ' - ' + ex.message);
        // Continue with next record
    }
}
```

### 3. Log Progress and Summary

```javascript
logInfo('---START OF RUN---');
// ... process with logging
logInfo('Summary: ' + successCount + ' success, ' + errorCount + ' errors');
logInfo('---END OF RUN---');
```

### 4. Validate State Changes

```javascript
// After save, optionally reload and verify
delivery.save();
var reloaded = NLWS.nmsDelivery.load(deliveryId);
if (reloaded.typology.name === 'defaultTypology') {
    logInfo('Verified: typology correctly set');
}
```

### 5. Use XML for Complex Updates

```javascript
// For fields that don't update via object properties
var deliveryXml = delivery.toXML();
deliveryXml.@customField = 'value';
deliveryXml.@_operation = "update";
xtk.session.Write(deliveryXml);
```

---

## Related Scripts

| Script | Description |
|--------|-------------|
| `Change from field in deliveries from query.js` | Update sender name |
| `Disable waves in deliveries from query.js` | Disable wave scheduling |
| `Update delivery waves on deliveries in query.js` | Configure wave settings |
| `Update typology rules for deliveries in query.js` | Change typology |
| `Update userPreference in deliveries from query.js` | Update custom fields |
| `Update controlgroup from query.js` | Manage control groups |

---

**Related:** [Scripts README](README.md) | [Query and Update Patterns](02-query-and-update-patterns.md)
