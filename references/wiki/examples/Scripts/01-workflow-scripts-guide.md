# Workflow Scripts Guide

**Fundamentals of JavaScript scripting in Adobe Campaign Classic workflows**

---

## Overview

This guide covers the essential concepts for writing JavaScript code in ACC workflow activities. You'll learn about logging, variables, error handling, and the basic patterns used in all workflow scripts.

---

## Table of Contents

1. [JavaScript Activity Basics](#javascript-activity-basics)
2. [Logging](#logging)
3. [Variables](#variables)
4. [Options](#options)
5. [Error Handling](#error-handling)
6. [Date and Time Operations](#date-and-time-operations)
7. [Working with Files](#working-with-files)
8. [Best Practices](#best-practices)

---

## JavaScript Activity Basics

### Adding a JavaScript Activity

1. Open your workflow in edit mode
2. From the palette, drag **JavaScript code** into the workflow
3. Double-click to open the editor
4. Write your code in the script area
5. Save and close

### Activity Types

| Activity | Description |
|----------|-------------|
| **JavaScript code** | Single script with one transition out |
| **Advanced JavaScript code** | Multiple named transitions based on conditions |
| **Test** | Conditional branching with expressions |

### Basic Script Structure

```javascript
// Always log the start of your script
logInfo('---START OF RUN---');

// Your main code here
var count = 0;
// ... processing logic

// Log completion
logInfo('Processed ' + count + ' records');
logInfo('---END OF RUN---');
```

---

## Logging

Logging is essential for debugging and monitoring workflow execution.

### Log Functions

```javascript
// Information - general progress messages
logInfo('Processing started');
logInfo('Found ' + count + ' records');

// Warnings - non-critical issues
logWarning('No records found, skipping step');
logWarning('Using default value for missing parameter');

// Errors - critical issues
logError('Failed to load delivery: ' + ex.message);
logError('Invalid data format in file');
```

### Log Output Location

Logs appear in:
- **Workflow journal** - Right-click workflow > Display logs
- **Audit trail** - Administration > Audit > Workflow logs
- **Server logs** - For debugging during development

### Logging Best Practices

```javascript
// Include context in messages
logInfo('Processing delivery ID: ' + deliveryId);
logInfo('Updated ' + count + ' of ' + total + ' records');

// Log before and after important operations
logInfo('Starting batch update...');
// ... update code
logInfo('Batch update complete');

// Use separators for clarity
logInfo('---START OF RUN---');
// ... code
logInfo('---END OF RUN---');
```

---

## Variables

### Workflow Variables (vars)

Variables that persist across activities within a single workflow execution:

```javascript
// Set a variable
vars.myVariable = 'some value';
vars.recordCount = 42;
vars.isProcessed = true;

// Read a variable
var value = vars.myVariable;
logInfo('Record count: ' + vars.recordCount);

// Variables from Query activity
// After a Query activity, vars.targetSchema contains the result schema
var schema = vars.targetSchema;
```

### Instance Variables (instance.vars)

Variables shared across the entire workflow instance:

```javascript
// Set instance variable
instance.vars.fileMask = "LFProvaPa_";
instance.vars.loadPath = "/path/to/files";
instance.vars.fileList = "";

// Read instance variable
var mask = instance.vars.fileMask;
```

### Variable Scope Comparison

| Scope | Syntax | Lifetime | Use Case |
|-------|--------|----------|----------|
| Local | `var x = 1;` | Current script only | Temporary calculations |
| Workflow | `vars.x = 1;` | Current execution | Pass data between activities |
| Instance | `instance.vars.x = 1;` | Workflow instance | Configuration, shared state |

### Example: Passing Data Between Activities

**Activity 1 (JavaScript):**
```javascript
// Query and store results
var count = 0;
// ... query logic
vars.recordCount = count;
vars.processDate = new Date().toISOString();
logInfo('Stored count: ' + vars.recordCount);
```

**Activity 2 (JavaScript):**
```javascript
// Use data from previous activity
logInfo('Records from previous step: ' + vars.recordCount);
logInfo('Process date: ' + vars.processDate);
```

---

## Options

Options are persistent key-value settings stored in the database.

### Reading Options

```javascript
// Get option value
var value = getOption('optionName');

// With default value handling
var fileDate = getOption('LfWkfBvLFPPFileReceivedToday');
vars.fileReceivedToday = fileDate || null;

// Convert to appropriate type
var isEnabled = getOption('myBooleanOption') === 'true';
var maxCount = parseInt(getOption('myNumberOption'), 10);
```

### Setting Options

```javascript
// Set option value
setOption('LfWkfBvLFPPFileReceivedToday', currentDate);
setOption('LfWkfBvLFPPFileReceivedLastRun', 'true');

// Reset option
setOption('LfWkfBvLFPPFileReceivedLastRun', false);
```

### Common Use Cases

```javascript
// Track last run date
var lastRun = getOption('myWorkflow_lastRunDate');
// ... process
setOption('myWorkflow_lastRunDate', new Date().toISOString());

// Environment-specific paths
var envName = getOption("gisFolderEnvironmentName");
var parentPath = getOption("gisParentPath");
var fullPath = parentPath + envName + "\\Inbox\\";

// Feature flags
var isFeatureEnabled = getOption('featureX_enabled') === 'true';
if (isFeatureEnabled) {
    // ... feature code
}
```

---

## Error Handling

Always wrap operations that might fail in try/catch blocks.

### Basic Try/Catch

```javascript
try {
    var delivery = NLWS.nmsDelivery.load(deliveryId);
    delivery.someProperty = 'newValue';
    delivery.save();
    logInfo('Successfully updated delivery: ' + deliveryId);
} catch (ex) {
    logError('Error updating delivery ' + deliveryId + ': ' + ex.message);
}
```

### With Cleanup

```javascript
var file = null;
try {
    file = new File('/path/to/file.txt');
    file.open('r');
    // ... read file
    logInfo('File processed successfully');
} catch (ex) {
    logError('File error: ' + ex.message);
} finally {
    if (file && file.isOpen) {
        file.close();
    }
}
```

### Error Handling in Loops

```javascript
logInfo('---START OF RUN---');
var successCount = 0;
var errorCount = 0;

for each (var record in records) {
    try {
        // Process record
        updateRecord(record);
        successCount++;
    } catch (ex) {
        logError('Failed on record ' + record.id + ': ' + ex.message);
        errorCount++;
        // Continue with next record
    }
}

logInfo('Completed: ' + successCount + ' success, ' + errorCount + ' errors');
logInfo('---END OF RUN---');
```

---

## Date and Time Operations

### Getting Current Date

```javascript
// Current date object
var date = new Date();

// Day of week (0 = Sunday, 1 = Monday, ... 6 = Saturday)
var dayOfWeek = date.getDay();

// Format as YYYY-MM-DD
var currentDate = date.toISOString().split('T')[0];
logInfo('Current date is: ' + currentDate);

// Check if weekday
var isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;
vars.isWeekday = isWeekday;
logInfo('Today is a weekday: ' + vars.isWeekday);
```

### Date Formatting

```javascript
var date = new Date();

// ISO format: 2024-01-15T10:30:00.000Z
var isoDate = date.toISOString();

// Date only: 2024-01-15
var dateOnly = date.toISOString().split('T')[0];

// Custom format
var year = date.getFullYear();
var month = ('0' + (date.getMonth() + 1)).slice(-2);
var day = ('0' + date.getDate()).slice(-2);
var formatted = year + '-' + month + '-' + day;
```

### Date Comparison

```javascript
// Compare dates
var storedDate = getOption('lastProcessDate');
var currentDate = new Date().toISOString().split('T')[0];

if (storedDate === currentDate) {
    logInfo('Already processed today');
} else {
    logInfo('New day, proceeding with process');
    // ... process
    setOption('lastProcessDate', currentDate);
}
```

---

## Working with Files

### File Object Basics

```javascript
// Create file reference
var dir = new File('/path/to/directory/');

// List files matching pattern
var files = dir.list('*pattern*');

// Log found files
for each (var fileName in files) {
    logInfo('Found file: ' + fileName);
}
```

### Building File Paths

```javascript
// Build paths from options
instance.vars.envVariable = getOption("gisFolderEnvironmentName");
instance.vars.parentPath = getOption("gisParentPath");
instance.vars.loadPath = instance.vars.parentPath + instance.vars.envVariable + "\\Inbox\\Bilvision";
instance.vars.histPath = instance.vars.parentPath + instance.vars.envVariable + "\\Inbox\\Bilvision\\History";

// Create directory object
var dir = new File(instance.vars.loadPath + "\\");

// List files with mask
instance.vars.fileMask = "LFProvaPa_";
var files = dir.list("*" + instance.vars.fileMask + "*");
```

### Extracting File Information

```javascript
// From filename, extract parts
logInfo("Input full file name: " + vars.filename);

var ix = vars.filename.indexOf(instance.vars.fileMask);
var endOfFileName = ix;
var fname = vars.filename.substring(endOfFileName);
var len = fname.length;

// Get file name without extension
vars.inputfile = fname.substring(0, len - 20);
logInfo("Input file name: " + vars.inputfile);

// Extract date from filename (assuming format)
instance.vars.fileRecvDate = fname.substring(len - 19, len - 11);
```

---

## Best Practices

### 1. Always Log Start and End

```javascript
logInfo('---START OF RUN---');
// ... your code
logInfo('---END OF RUN---');
```

### 2. Validate Before Processing

```javascript
// Check if we should process
if (!isWeekday) {
    logInfo("Today is not a weekday. No file processing will occur.");
    return; // or skip to next activity
}

// Check if already processed
if (vars.fileReceivedToday === vars.currentDate && vars.fileReceivedLastRun === true) {
    logInfo("File has been received today.");
} else {
    logInfo("No file received today. Proceeding with the rest of the logic.");
    vars.fileReceived = true;
}
```

### 3. Use Descriptive Variable Names

```javascript
// Good
var deliveryCount = 0;
var isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;
var fileReceivedToday = getOption('LfWkfBvLFPPFileReceivedToday');

// Avoid
var d = 0;
var x = dayOfWeek >= 1 && dayOfWeek <= 5;
var opt = getOption('LfWkfBvLFPPFileReceivedToday');
```

### 4. Comment Complex Logic

```javascript
// Check if today is a weekday (Monday=1 through Friday=5)
// Weekend days (Saturday=6, Sunday=0) should not trigger processing
var isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;

// Extract date from filename format: PREFIX_YYYYMMDD_HHMMSS.csv
// Position len-19 to len-11 gives us the YYYYMMDD part
instance.vars.fileRecvDate = fname.substring(len - 19, len - 11);
```

### 5. Initialize Variables

```javascript
// Always initialize before use
vars.fileReceived = false;
instance.vars.fileList = "";
var count = 0;
var list = "";
```

---

## Complete Example: ETL Step 1

This example from production demonstrates many concepts:

```javascript
// Get current date and day
var date = new Date();
var dayOfWeek = date.getDay();
var currentDate = date.toISOString().split('T')[0];
logInfo('Current date is: ' + currentDate);

// Check if weekday (Monday-Friday)
var isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;
vars.isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;
logInfo('Today is a weekday: ' + vars.isWeekday);

// Get last file received date from options
var fileReceivedToday = getOption('LfWkfBvLFPPFileReceivedToday');
vars.fileReceivedToday = fileReceivedToday || null;
logInfo('Last file received date: ' + vars.fileReceivedToday);

// Get status from last run
var fileReceivedLastRun = getOption('LfWkfBvLFPPFileReceivedLastRun');
vars.fileReceivedLastRun = fileReceivedLastRun === 'true';
logInfo('File received last run: ' + vars.fileReceivedLastRun);

// Initialize file received flag
vars.fileReceived = false;

if (isWeekday) {
    // Set up file paths from options
    instance.vars.fileMask = "LFProvaPa_";
    instance.vars.envVariable = getOption("gisFolderEnvironmentName");
    instance.vars.parentPath = getOption("gisParentPath");
    instance.vars.loadPath = instance.vars.parentPath + instance.vars.envVariable + "\\Inbox\\Bilvision";
    instance.vars.histPath = instance.vars.parentPath + instance.vars.envVariable + "\\Inbox\\Bilvision\\History";
    instance.vars.fileList = "";

    // List matching files
    var dir = new File(instance.vars.loadPath + "\\");
    var files = dir.list("*" + instance.vars.fileMask + "*");

    vars.currentDate = currentDate;
    logInfo("Value of LfWkfBvLFPPFileReceivedToday after processing: " + vars.fileReceivedToday);

    // Check if file already received today
    if (vars.fileReceivedToday === vars.currentDate && vars.fileReceivedLastRun === true) {
        logInfo("File has been received today.");
    } else {
        logInfo("No file received today. Proceeding with the rest of the logic.");
        vars.fileReceived = true;
    }
} else {
    logInfo("Today is not a weekday. No file processing will occur.");
}
```

---

## Next Steps

- [Query and Update Patterns](02-query-and-update-patterns.md) - Learn to read and modify data
- [ETL Processing](03-etl-processing.md) - File handling and transformations
- [Delivery Management](04-delivery-management.md) - Work with deliveries

---

**Related:** [Scripts README](README.md) | [Database Queries](../../05-DATABASE-QUERIES.md)
