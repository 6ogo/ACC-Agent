# ETL Processing

**File handling, date operations, and data transformations in Adobe Campaign Classic**

---

## Overview

ETL (Extract, Transform, Load) workflows in ACC handle file-based data imports and exports. This guide covers patterns for file operations, date handling, state management, and common transformation tasks.

---

## Table of Contents

1. [ETL Workflow Structure](#etl-workflow-structure)
2. [File Operations](#file-operations)
3. [State Management with Options](#state-management-with-options)
4. [Date and Weekday Logic](#date-and-weekday-logic)
5. [Filename Parsing](#filename-parsing)
6. [Complete ETL Example](#complete-etl-example)
7. [Value Transformations](#value-transformations)
8. [Best Practices](#best-practices)

---

## ETL Workflow Structure

A typical ETL workflow follows this pattern:

```
[Scheduler] → [Init Variables] → [Check Conditions] → [File Collector]
                                         ↓
              [Process File] ← [Mark Received] ← [Validate]
                    ↓
             [Load Data] → [Transform] → [Update] → [Archive] → [Cleanup]
```

### Key Activities

| Activity | Purpose |
|----------|---------|
| **Scheduler** | Trigger workflow on schedule |
| **JavaScript code** | Initialize variables, check conditions |
| **File collector** | Find files matching pattern |
| **Data loading** | Import file data |
| **JavaScript code** | Transform and validate |
| **Update data** | Write to database |
| **File transfer** | Move to archive |

---

## File Operations

### Building File Paths

```javascript
// Get paths from options (environment-specific)
instance.vars.envVariable = getOption("gisFolderEnvironmentName");
instance.vars.parentPath = getOption("gisParentPath");

// Build full paths
instance.vars.loadPath = instance.vars.parentPath + instance.vars.envVariable + "\\Inbox\\Bilvision";
instance.vars.histPath = instance.vars.parentPath + instance.vars.envVariable + "\\Inbox\\Bilvision\\History";

logInfo('Load path: ' + instance.vars.loadPath);
logInfo('History path: ' + instance.vars.histPath);
```

### Listing Files

```javascript
// Define file mask
instance.vars.fileMask = "LFProvaPa_";

// Create directory object
var dir = new File(instance.vars.loadPath + "\\");

// List files matching pattern
var files = dir.list("*" + instance.vars.fileMask + "*");

// Process found files
instance.vars.fileList = "";
var count = 0;

for each (var fileName in files) {
    logInfo('Found file: ' + fileName);
    instance.vars.fileList += fileName + ";";
    count++;
}

logInfo('Total files found: ' + count);
```

### File Path Patterns

```javascript
// Windows paths (use double backslash)
var winPath = "C:\\Campaign\\Inbox\\";

// Linux paths
var linuxPath = "/opt/campaign/inbox/";

// Build from options for environment independence
var basePath = getOption("gisParentPath");
var envName = getOption("gisFolderEnvironmentName");
var fullPath = basePath + envName + "\\Inbox\\";
```

---

## State Management with Options

Options persist between workflow runs, enabling state tracking.

### Reading State

```javascript
// Get last processed date
var fileReceivedToday = getOption('LfWkfBvLFPPFileReceivedToday');
vars.fileReceivedToday = fileReceivedToday || null;
logInfo('Last file received date: ' + vars.fileReceivedToday);

// Get boolean state (stored as string)
var fileReceivedLastRun = getOption('LfWkfBvLFPPFileReceivedLastRun');
vars.fileReceivedLastRun = fileReceivedLastRun === 'true';
logInfo('File received last run: ' + vars.fileReceivedLastRun);
```

### Updating State

```javascript
// Mark file received today
var date = new Date();
var currentDate = date.toISOString().split('T')[0]; // YYYY-MM-DD

setOption('LfWkfBvLFPPFileReceivedToday', currentDate);
setOption('LfWkfBvLFPPFileReceivedLastRun', 'true');

logInfo("File received for " + currentDate + ". Marked in the system.");
```

### Resetting State

```javascript
// Reset at start of new run or when no file found
setOption('LfWkfBvLFPPFileReceivedLastRun', false);
```

### State Management Pattern

```javascript
// === STEP 1: Check current state ===
var lastDate = getOption('myWorkflow_lastProcessDate');
var lastStatus = getOption('myWorkflow_lastStatus');
logInfo('Last process date: ' + lastDate);
logInfo('Last status: ' + lastStatus);

// === STEP 2: Process ===
var success = false;
try {
    // ... your processing logic
    success = true;
} catch (ex) {
    logError('Processing failed: ' + ex.message);
}

// === STEP 3: Update state ===
var now = new Date().toISOString();
setOption('myWorkflow_lastProcessDate', now);
setOption('myWorkflow_lastStatus', success ? 'success' : 'error');
logInfo('Updated state: ' + now + ' - ' + (success ? 'success' : 'error'));
```

---

## Date and Weekday Logic

### Getting Current Date Information

```javascript
var date = new Date();

// Day of week (0 = Sunday, 1 = Monday, ... 6 = Saturday)
var dayOfWeek = date.getDay();

// Format as YYYY-MM-DD
var currentDate = date.toISOString().split('T')[0];

logInfo('Current date: ' + currentDate);
logInfo('Day of week: ' + dayOfWeek);
```

### Weekday Check

```javascript
// Check if weekday (Monday through Friday)
var dayOfWeek = new Date().getDay();
var isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;
vars.isWeekday = isWeekday;

logInfo('Today is a weekday: ' + vars.isWeekday);

if (isWeekday) {
    logInfo('Proceeding with weekday processing...');
    // ... weekday logic
} else {
    logInfo('Today is not a weekday. No file processing will occur.');
}
```

### Date Comparison

```javascript
var currentDate = new Date().toISOString().split('T')[0];
var storedDate = getOption('lastProcessDate');

if (storedDate === currentDate) {
    logInfo('Already processed today, skipping...');
} else {
    logInfo('New day, proceeding with processing...');
    // ... process
    setOption('lastProcessDate', currentDate);
}
```

### Already Processed Check

```javascript
vars.currentDate = new Date().toISOString().split('T')[0];

if (vars.fileReceivedToday === vars.currentDate && vars.fileReceivedLastRun === true) {
    logInfo("File has been received today. Skipping.");
} else {
    logInfo("No file received today. Proceeding with the rest of the logic.");
    vars.fileReceived = true;
}
```

---

## Filename Parsing

### Extract Parts from Filename

```javascript
// Example filename: LFProvaPa_20240115_143022.csv
logInfo("Input full file name: " + vars.filename);

// Find position of file mask
var ix = vars.filename.indexOf(instance.vars.fileMask);
var endOfFileName = ix;

// Get everything after the mask
var fname = vars.filename.substring(endOfFileName);
var len = fname.length;

// Extract filename without timestamp extension
// Assuming format: PREFIX_YYYYMMDD_HHMMSS.csv (20 chars at end)
vars.inputfile = fname.substring(0, len - 20);
logInfo("Input file name: " + vars.inputfile);

// Extract date from filename
// Positions: len-19 to len-11 gives YYYYMMDD
instance.vars.fileRecvDate = fname.substring(len - 19, len - 11);
logInfo("File receive date: " + instance.vars.fileRecvDate);
```

### Filename Pattern Examples

```javascript
// Pattern: PREFIX_YYYYMMDD_HHMMSS.csv
// Example: LFProvaPa_20240115_143022.csv

var filename = "LFProvaPa_20240115_143022.csv";
var len = filename.length;  // 31

// Extract parts
var prefix = filename.substring(0, 9);           // "LFProvaPa"
var date = filename.substring(10, 18);           // "20240115"
var time = filename.substring(19, 25);           // "143022"
var extension = filename.substring(len - 4);     // ".csv"

logInfo('Prefix: ' + prefix);
logInfo('Date: ' + date);
logInfo('Time: ' + time);
logInfo('Extension: ' + extension);
```

### Safe Filename Extraction

```javascript
function parseFilename(filename, mask) {
    var result = {
        original: filename,
        mask: mask,
        date: null,
        time: null,
        extension: null
    };

    try {
        var maskPos = filename.indexOf(mask);
        if (maskPos === -1) {
            logWarning('Mask not found in filename');
            return result;
        }

        var len = filename.length;
        var dotPos = filename.lastIndexOf('.');

        if (dotPos !== -1) {
            result.extension = filename.substring(dotPos);
        }

        // Assuming format after mask: _YYYYMMDD_HHMMSS.ext
        if (len >= maskPos + mask.length + 16) {
            result.date = filename.substring(maskPos + mask.length + 1, maskPos + mask.length + 9);
            result.time = filename.substring(maskPos + mask.length + 10, maskPos + mask.length + 16);
        }

    } catch (ex) {
        logError('Error parsing filename: ' + ex.message);
    }

    return result;
}

// Usage
var info = parseFilename(vars.filename, instance.vars.fileMask);
logInfo('Extracted date: ' + info.date);
logInfo('Extracted time: ' + info.time);
```

---

## Complete ETL Example

### Step 1: Initialize and Check Conditions

```javascript
// ===== ETL STEP 1: INITIALIZATION =====

// Get current date and day
var date = new Date();
var dayOfWeek = date.getDay();
var currentDate = date.toISOString().split('T')[0];
logInfo('Current date is: ' + currentDate);

// Check if weekday
var isWeekday = dayOfWeek >= 1 && dayOfWeek <= 5;
vars.isWeekday = isWeekday;
logInfo('Today is a weekday: ' + vars.isWeekday);

// Get state from last run
var fileReceivedToday = getOption('LfWkfBvLFPPFileReceivedToday');
vars.fileReceivedToday = fileReceivedToday || null;
logInfo('Last file received date: ' + vars.fileReceivedToday);

var fileReceivedLastRun = getOption('LfWkfBvLFPPFileReceivedLastRun');
vars.fileReceivedLastRun = fileReceivedLastRun === 'true';
logInfo('File received last run: ' + vars.fileReceivedLastRun);

// Initialize flag
vars.fileReceived = false;

if (isWeekday) {
    // Set up file paths
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

    // Check if already processed today
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

### Step 2: Mark File Received

```javascript
// ===== ETL STEP 2: MARK FILE RECEIVED =====

var date = new Date();
var currentDate = date.toISOString().split('T')[0];

// Update options to mark file received
setOption('LfWkfBvLFPPFileReceivedToday', currentDate);
setOption('LfWkfBvLFPPFileReceivedLastRun', 'true');

logInfo("File received for " + currentDate + ". Marked in the system.");

// Log file information
logInfo("Input full file name: " + vars.filename);
var ix = vars.filename.indexOf(instance.vars.fileMask);
var endOfFileName = ix;
var fname = vars.filename.substring(endOfFileName);
var len = fname.length;

vars.inputfile = fname.substring(0, len - 20);
logInfo("Input file name: " + vars.inputfile);

// Extract file receive date
instance.vars.fileRecvDate = fname.substring(len - 19, len - 11);
```

### Step 3: Reset State (No File Branch)

```javascript
// ===== ETL STEP 3: RESET STATE =====
// Run this when no file was found

setOption('LfWkfBvLFPPFileReceivedLastRun', false);
logInfo('Reset file received flag - no file found this run');
```

---

## Value Transformations

### Simple Value Reset

```javascript
// Reset a boolean option
setOption('LfWkfBvLFPPFileReceivedLastRun', false);
```

### String Transformations

```javascript
// Trim whitespace
var cleaned = rawValue.trim();

// Convert case
var upper = value.toUpperCase();
var lower = value.toLowerCase();

// Replace characters
var noSpaces = value.replace(/ /g, '_');
var cleaned = value.replace(/[^a-zA-Z0-9]/g, '');
```

### Date Format Conversion

```javascript
// From YYYYMMDD to YYYY-MM-DD
var rawDate = "20240115";
var formatted = rawDate.substring(0, 4) + '-' +
                rawDate.substring(4, 6) + '-' +
                rawDate.substring(6, 8);
// Result: "2024-01-15"

// From ISO to ACC date format
var isoDate = new Date().toISOString();  // "2024-01-15T14:30:22.000Z"
var accDate = isoDate.split('T')[0];     // "2024-01-15"
```

### Numeric Transformations

```javascript
// String to number
var num = parseInt(stringValue, 10);
var decimal = parseFloat(stringValue);

// Format number
var formatted = num.toFixed(2);  // "42.00"

// Calculate percentage
var pct = (part / total * 100).toFixed(1) + '%';
```

---

## Best Practices

### 1. Always Initialize Variables

```javascript
// At start of workflow
vars.fileReceived = false;
instance.vars.fileList = "";
instance.vars.errorCount = 0;
```

### 2. Use Options for Persistent State

```javascript
// Store state that needs to survive workflow restarts
setOption('myWorkflow_lastRun', new Date().toISOString());
setOption('myWorkflow_status', 'success');
```

### 3. Log Extensively

```javascript
logInfo('=== ETL STEP 1: INITIALIZATION ===');
logInfo('Current date: ' + currentDate);
logInfo('Is weekday: ' + isWeekday);
logInfo('Last file date: ' + vars.fileReceivedToday);
logInfo('Proceeding: ' + vars.fileReceived);
```

### 4. Handle Missing Files Gracefully

```javascript
var dir = new File(instance.vars.loadPath + "\\");
var files = dir.list("*" + instance.vars.fileMask + "*");

if (!files || files.length === 0) {
    logInfo('No files found matching pattern');
    setOption('myWorkflow_lastStatus', 'no_files');
    // Transition to "no file" branch
} else {
    logInfo('Found ' + files.length + ' files');
}
```

### 5. Validate Before Processing

```javascript
// Check required conditions
if (!isWeekday) {
    logInfo('Skipping: not a weekday');
    return;
}

if (vars.fileReceivedToday === currentDate) {
    logInfo('Skipping: already processed today');
    return;
}

// Proceed with processing
logInfo('All conditions met, proceeding...');
```

---

## Next Steps

- [Delivery Management](04-delivery-management.md) - Update deliveries
- [Query and Update Patterns](02-query-and-update-patterns.md) - Database operations

---

**Related:** [Scripts README](README.md) | [Workflow Scripts Guide](01-workflow-scripts-guide.md)
