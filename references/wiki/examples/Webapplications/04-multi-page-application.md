# Walkthrough 04: Multi-Page Application - Delivery Workflow Wizard

**Build a multi-step wizard with navigation, sessions, and context variables**

---

## What You'll Build

A delivery configuration wizard that:
- Guides users through multiple steps
- Maintains state across pages
- Uses context variables for data passing
- Implements session storage for persistence
- Shows progress indication
- Supports back/forward navigation

**Final Result Preview:**

```
┌─────────────────────────────────────────────────────────────────┐
│  Delivery Configuration Wizard                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Step: [1. Select] ─ [2. Configure] ─ [3. Review] ─ [4. Done]  │
│              ●            ○              ○             ○        │
│                                                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Select Delivery Type                                           │
│  ─────────────────────                                          │
│                                                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Email     │  │    SMS      │  │   Letter    │             │
│  │    📧       │  │    📱       │  │    ✉️       │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│                                          [Cancel]  [Next →]     │
└─────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- Completed previous walkthroughs
- Understanding of ctx.vars and sessions
- Familiarity with page transitions in ACC

**Time to complete:** ~60 minutes

---

## Key Concepts

### Context Variables (ctx.vars)
Pass data between pages in the same request flow.

### Sessions (session.addValue/getValue)
Persist data across multiple requests/page loads.

### Page Transitions
Control navigation flow between webapp pages.

---

## Part 1: Application Architecture

### 1.1 Page Structure

```
Web Application: deliveryWizard
├── Pages
│   ├── step1-type.jsp       # Step 1: Select delivery type
│   ├── step2-config.jsp     # Step 2: Configure details
│   ├── step3-review.jsp     # Step 3: Review settings
│   ├── step4-complete.jsp   # Step 4: Confirmation
│   └── api/
│       └── wizard.jssp      # API for saving/loading
├── Transitions
│   ├── step1 → step2
│   ├── step2 → step3
│   ├── step3 → step4
│   └── Back transitions for each
```

### 1.2 Data Flow

```
User Input → ctx.vars (page-to-page) → session (persistence)
                                           ↓
                                    Final Submit
                                           ↓
                                    xtk.session.Write
```

---

## Part 2: Create Shared Components

### 2.1 Shared Styles and Scripts

Create a file `_shared.jsp` with common elements:

```jsp
<%
/**
 * Shared styles and functions for wizard
 * Include this in each page
 */
%>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background: #f0f2f5;
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 20px;
    }

    .wizard-container {
        background: white;
        border-radius: 16px;
        box-shadow: 0 10px 40px rgba(0,0,0,0.1);
        width: 100%;
        max-width: 700px;
        overflow: hidden;
    }

    /* Header */
    .wizard-header {
        background: linear-gradient(135deg, #1a237e 0%, #283593 100%);
        color: white;
        padding: 25px 30px;
    }

    .wizard-header h1 {
        font-size: 22px;
        font-weight: 600;
        margin-bottom: 5px;
    }

    .wizard-header p {
        opacity: 0.8;
        font-size: 14px;
    }

    /* Progress Steps */
    .progress-steps {
        display: flex;
        justify-content: space-between;
        padding: 25px 30px;
        background: #f8f9fa;
        border-bottom: 1px solid #e0e0e0;
    }

    .step {
        display: flex;
        flex-direction: column;
        align-items: center;
        flex: 1;
        position: relative;
    }

    .step:not(:last-child)::after {
        content: '';
        position: absolute;
        top: 15px;
        left: 60%;
        width: 80%;
        height: 2px;
        background: #e0e0e0;
    }

    .step.completed:not(:last-child)::after {
        background: #4CAF50;
    }

    .step-number {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: #e0e0e0;
        color: #666;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: 600;
        font-size: 14px;
        margin-bottom: 8px;
        position: relative;
        z-index: 1;
    }

    .step.active .step-number {
        background: #1a237e;
        color: white;
    }

    .step.completed .step-number {
        background: #4CAF50;
        color: white;
    }

    .step-label {
        font-size: 12px;
        color: #666;
        text-align: center;
    }

    .step.active .step-label {
        color: #1a237e;
        font-weight: 600;
    }

    /* Content */
    .wizard-content {
        padding: 30px;
        min-height: 300px;
    }

    .wizard-content h2 {
        font-size: 20px;
        margin-bottom: 20px;
        color: #333;
    }

    /* Type Selection Cards */
    .type-cards {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-bottom: 20px;
    }

    .type-card {
        border: 2px solid #e0e0e0;
        border-radius: 12px;
        padding: 25px 15px;
        text-align: center;
        cursor: pointer;
        transition: all 0.2s;
    }

    .type-card:hover {
        border-color: #1a237e;
        background: #f5f5ff;
    }

    .type-card.selected {
        border-color: #1a237e;
        background: #e8eaf6;
    }

    .type-card .icon {
        font-size: 36px;
        margin-bottom: 10px;
    }

    .type-card .label {
        font-weight: 600;
        color: #333;
    }

    .type-card .description {
        font-size: 12px;
        color: #666;
        margin-top: 5px;
    }

    /* Form Fields */
    .form-group {
        margin-bottom: 20px;
    }

    .form-group label {
        display: block;
        font-weight: 500;
        margin-bottom: 8px;
        color: #333;
    }

    .form-group input,
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 12px 15px;
        border: 1px solid #ddd;
        border-radius: 8px;
        font-size: 15px;
        transition: border-color 0.2s;
    }

    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
        outline: none;
        border-color: #1a237e;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    /* Review Summary */
    .review-section {
        background: #f8f9fa;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 15px;
    }

    .review-section h3 {
        font-size: 14px;
        color: #666;
        text-transform: uppercase;
        margin-bottom: 10px;
    }

    .review-item {
        display: flex;
        justify-content: space-between;
        padding: 8px 0;
        border-bottom: 1px solid #e0e0e0;
    }

    .review-item:last-child {
        border-bottom: none;
    }

    .review-item .label {
        color: #666;
    }

    .review-item .value {
        font-weight: 500;
        color: #333;
    }

    /* Footer */
    .wizard-footer {
        padding: 20px 30px;
        border-top: 1px solid #e0e0e0;
        display: flex;
        justify-content: space-between;
        background: #fafafa;
    }

    .btn {
        padding: 12px 25px;
        border: none;
        border-radius: 8px;
        font-size: 15px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s;
    }

    .btn-primary {
        background: #1a237e;
        color: white;
    }

    .btn-primary:hover {
        background: #283593;
    }

    .btn-secondary {
        background: #e0e0e0;
        color: #333;
    }

    .btn-secondary:hover {
        background: #d0d0d0;
    }

    .btn-success {
        background: #4CAF50;
        color: white;
    }

    .btn-success:hover {
        background: #43a047;
    }

    .btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    /* Success State */
    .success-container {
        text-align: center;
        padding: 40px 20px;
    }

    .success-icon {
        width: 80px;
        height: 80px;
        background: #e8f5e9;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        font-size: 40px;
    }

    .success-container h2 {
        color: #2e7d32;
        margin-bottom: 10px;
    }

    /* Error State */
    .error-message {
        background: #ffebee;
        color: #c62828;
        padding: 12px 15px;
        border-radius: 8px;
        margin-bottom: 20px;
    }
</style>

<script>
    /**
     * Select delivery type card
     */
    function selectType(type) {
        // Remove selection from all cards
        document.querySelectorAll('.type-card').forEach(function(card) {
            card.classList.remove('selected');
        });

        // Select clicked card
        var selectedCard = document.querySelector('[data-type="' + type + '"]');
        if (selectedCard) {
            selectedCard.classList.add('selected');
        }

        // Update hidden input
        var input = document.getElementById('deliveryType');
        if (input) {
            input.value = type;
        }

        // Enable next button
        var nextBtn = document.getElementById('nextBtn');
        if (nextBtn) {
            nextBtn.disabled = false;
        }
    }

    /**
     * Validate form before proceeding
     */
    function validateForm() {
        var form = document.getElementById('wizardForm');
        if (form && form.checkValidity) {
            return form.checkValidity();
        }
        return true;
    }

    /**
     * Show validation error
     */
    function showError(message) {
        var errorDiv = document.getElementById('errorMessage');
        if (errorDiv) {
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
        }
    }
</script>
```

---

## Part 3: Step 1 - Select Delivery Type

### 3.1 Create step1-type.jsp

```jsp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Wizard - Step 1</title>
    <%@ include file="_shared.jsp" %>
</head>
<body>
    <%
    // Initialize or get existing session data
    var wizardData = {};
    try {
        var stored = session.getValue("wizardData");
        if (stored) {
            wizardData = JSON.parse(stored);
        }
    } catch (e) {
        // Start fresh
    }

    var selectedType = wizardData.deliveryType || "";
    var errorMessage = "";

    // Handle form submission
    if (request.getParameter("action") === "next") {
        var type = request.getParameter("deliveryType");

        if (!type) {
            errorMessage = "Please select a delivery type";
        } else {
            // Save to session
            wizardData.deliveryType = type;
            session.addValue("wizardData", JSON.stringify(wizardData));

            // Pass to next page via ctx.vars
            ctx.vars.deliveryType = type;

            // Trigger transition to step 2
            // In ACC, this would be: document.controller.setEnableTransition("step2", true);
        }
    }
    %>

    <div class="wizard-container">
        <div class="wizard-header">
            <h1>Create New Delivery</h1>
            <p>Configure your delivery settings in a few simple steps</p>
        </div>

        <!-- Progress Steps -->
        <div class="progress-steps">
            <div class="step active">
                <div class="step-number">1</div>
                <div class="step-label">Select Type</div>
            </div>
            <div class="step">
                <div class="step-number">2</div>
                <div class="step-label">Configure</div>
            </div>
            <div class="step">
                <div class="step-number">3</div>
                <div class="step-label">Review</div>
            </div>
            <div class="step">
                <div class="step-number">4</div>
                <div class="step-label">Complete</div>
            </div>
        </div>

        <!-- Content -->
        <div class="wizard-content">
            <h2>Select Delivery Type</h2>

            <% if (errorMessage) { %>
            <div class="error-message" id="errorMessage"><%= errorMessage %></div>
            <% } %>

            <form id="wizardForm" method="post">
                <input type="hidden" name="action" value="next">
                <input type="hidden" name="deliveryType" id="deliveryType"
                       value="<%= selectedType %>">

                <div class="type-cards">
                    <div class="type-card <%= selectedType === 'email' ? 'selected' : '' %>"
                         data-type="email"
                         onclick="selectType('email')">
                        <div class="icon">📧</div>
                        <div class="label">Email</div>
                        <div class="description">Send HTML or text emails</div>
                    </div>

                    <div class="type-card <%= selectedType === 'sms' ? 'selected' : '' %>"
                         data-type="sms"
                         onclick="selectType('sms')">
                        <div class="icon">📱</div>
                        <div class="label">SMS</div>
                        <div class="description">Send text messages</div>
                    </div>

                    <div class="type-card <%= selectedType === 'push' ? 'selected' : '' %>"
                         data-type="push"
                         onclick="selectType('push')">
                        <div class="icon">🔔</div>
                        <div class="label">Push</div>
                        <div class="description">Mobile push notifications</div>
                    </div>
                </div>
            </form>
        </div>

        <!-- Footer -->
        <div class="wizard-footer">
            <button type="button" class="btn btn-secondary"
                    onclick="window.location.href='/'">
                Cancel
            </button>
            <button type="submit" form="wizardForm" class="btn btn-primary"
                    id="nextBtn" <%= selectedType ? '' : 'disabled' %>>
                Next →
            </button>
        </div>
    </div>
</body>
</html>
```

---

## Part 4: Step 2 - Configure Details

### 4.1 Create step2-config.jsp

```jsp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Wizard - Step 2</title>
    <%@ include file="_shared.jsp" %>
</head>
<body>
    <%
    // Load wizard data from session
    var wizardData = {};
    try {
        var stored = session.getValue("wizardData");
        if (stored) {
            wizardData = JSON.parse(stored);
        }
    } catch (e) {}

    // Check for data passed via ctx.vars (from previous page)
    if (ctx.vars.deliveryType) {
        wizardData.deliveryType = ctx.vars.deliveryType;
    }

    // Redirect if no type selected
    if (!wizardData.deliveryType) {
        // Redirect back to step 1
        // response.sendRedirect("step1-type.jsp");
    }

    var deliveryType = wizardData.deliveryType || "email";
    var errorMessage = "";

    // Handle form submission
    if (request.getParameter("action") === "next") {
        var name = request.getParameter("deliveryName");
        var subject = request.getParameter("subject");
        var campaignId = request.getParameter("campaignId");
        var scheduledDate = request.getParameter("scheduledDate");

        // Validate
        if (!name || name.trim() === "") {
            errorMessage = "Delivery name is required";
        } else {
            // Save to session
            wizardData.deliveryName = name.trim();
            wizardData.subject = subject || "";
            wizardData.campaignId = campaignId || "";
            wizardData.scheduledDate = scheduledDate || "";

            session.addValue("wizardData", JSON.stringify(wizardData));

            // Pass to next page
            ctx.vars.wizardData = wizardData;

            // Trigger transition to step 3
        }
    }

    // Handle back navigation
    if (request.getParameter("action") === "back") {
        // Trigger transition back to step 1
    }

    // Load campaigns for dropdown
    var campaignQuery = xtk.queryDef.create({
        queryDef: {
            schema: "nms:operation",
            operation: "select",
            lineCount: 50,
            select: { node: [
                { expr: "@id" },
                { expr: "@label" }
            ]},
            orderBy: { node: [{ expr: "@created", sortDesc: "true" }] }
        }
    });
    var campaigns = campaignQuery.ExecuteQuery();

    // Type display names
    var typeLabels = {
        'email': 'Email Delivery',
        'sms': 'SMS Message',
        'push': 'Push Notification'
    };
    %>

    <div class="wizard-container">
        <div class="wizard-header">
            <h1>Create New Delivery</h1>
            <p><%= typeLabels[deliveryType] || 'Delivery' %> Configuration</p>
        </div>

        <!-- Progress Steps -->
        <div class="progress-steps">
            <div class="step completed">
                <div class="step-number">✓</div>
                <div class="step-label">Select Type</div>
            </div>
            <div class="step active">
                <div class="step-number">2</div>
                <div class="step-label">Configure</div>
            </div>
            <div class="step">
                <div class="step-number">3</div>
                <div class="step-label">Review</div>
            </div>
            <div class="step">
                <div class="step-number">4</div>
                <div class="step-label">Complete</div>
            </div>
        </div>

        <!-- Content -->
        <div class="wizard-content">
            <h2>Configure Delivery Details</h2>

            <% if (errorMessage) { %>
            <div class="error-message"><%= errorMessage %></div>
            <% } %>

            <form id="wizardForm" method="post">
                <input type="hidden" name="action" value="next">

                <div class="form-group">
                    <label>Delivery Name *</label>
                    <input type="text" name="deliveryName" required
                           value="<%= wizardData.deliveryName || '' %>"
                           placeholder="Enter a name for this delivery">
                </div>

                <% if (deliveryType === 'email') { %>
                <div class="form-group">
                    <label>Email Subject</label>
                    <input type="text" name="subject"
                           value="<%= wizardData.subject || '' %>"
                           placeholder="Enter email subject line">
                </div>
                <% } %>

                <div class="form-row">
                    <div class="form-group">
                        <label>Campaign (Optional)</label>
                        <select name="campaignId">
                            <option value="">-- No Campaign --</option>
                            <% for each (var c in campaigns.operation) { %>
                            <option value="<%= c.@id %>"
                                    <%= String(wizardData.campaignId) === String(c.@id) ? 'selected' : '' %>>
                                <%= c.@label %>
                            </option>
                            <% } %>
                        </select>
                    </div>

                    <div class="form-group">
                        <label>Scheduled Date</label>
                        <input type="datetime-local" name="scheduledDate"
                               value="<%= wizardData.scheduledDate || '' %>">
                    </div>
                </div>
            </form>
        </div>

        <!-- Footer -->
        <div class="wizard-footer">
            <form method="post" style="display: inline;">
                <input type="hidden" name="action" value="back">
                <button type="submit" class="btn btn-secondary">
                    ← Back
                </button>
            </form>
            <button type="submit" form="wizardForm" class="btn btn-primary">
                Next →
            </button>
        </div>
    </div>
</body>
</html>
```

---

## Part 5: Step 3 - Review

### 5.1 Create step3-review.jsp

```jsp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Wizard - Step 3</title>
    <%@ include file="_shared.jsp" %>
</head>
<body>
    <%
    // Load wizard data
    var wizardData = {};
    try {
        var stored = session.getValue("wizardData");
        if (stored) {
            wizardData = JSON.parse(stored);
        }
    } catch (e) {}

    // Check for ctx.vars data
    if (ctx.vars.wizardData) {
        wizardData = ctx.vars.wizardData;
    }

    var errorMessage = "";

    // Handle final submission
    if (request.getParameter("action") === "submit") {
        try {
            // Create the delivery in ACC
            // This is a simplified example - real implementation depends on your setup

            var deliveryType = wizardData.deliveryType || 'email';
            var schema = "nms:delivery";

            // Prepare delivery data
            var deliveryData = {
                xtkschema: schema,
                _operation: "insert",
                label: wizardData.deliveryName,
                // Type: 0=email, 1=SMS, 3=mobile
                type: deliveryType === 'email' ? 0 : (deliveryType === 'sms' ? 1 : 3)
            };

            if (wizardData.subject) {
                deliveryData.subject = wizardData.subject;
            }

            if (wizardData.campaignId) {
                deliveryData["operation-id"] = parseInt(wizardData.campaignId);
            }

            // Note: In production, you'd use proper delivery creation APIs
            // xtk.session.Write({ delivery: deliveryData });

            // Log the action
            logInfo("Delivery wizard completed: " + wizardData.deliveryName);

            // Store result for confirmation page
            wizardData.completed = true;
            wizardData.completedAt = new Date().toISOString();
            session.addValue("wizardData", JSON.stringify(wizardData));

            ctx.vars.wizardComplete = true;

            // Transition to step 4
        } catch (e) {
            errorMessage = "Failed to create delivery: " + e.message;
        }
    }

    // Get campaign label
    var campaignLabel = "";
    if (wizardData.campaignId) {
        try {
            var cQuery = xtk.queryDef.create({
                queryDef: {
                    schema: "nms:operation",
                    operation: "get",
                    select: { node: [{ expr: "@label" }] },
                    where: { condition: [{ expr: "@id = " + parseInt(wizardData.campaignId) }] }
                }
            });
            var cResult = cQuery.ExecuteQuery();
            campaignLabel = String(cResult.@label || "");
        } catch (e) {}
    }

    var typeLabels = {
        'email': 'Email',
        'sms': 'SMS',
        'push': 'Push Notification'
    };
    %>

    <div class="wizard-container">
        <div class="wizard-header">
            <h1>Create New Delivery</h1>
            <p>Review your settings before creating</p>
        </div>

        <!-- Progress Steps -->
        <div class="progress-steps">
            <div class="step completed">
                <div class="step-number">✓</div>
                <div class="step-label">Select Type</div>
            </div>
            <div class="step completed">
                <div class="step-number">✓</div>
                <div class="step-label">Configure</div>
            </div>
            <div class="step active">
                <div class="step-number">3</div>
                <div class="step-label">Review</div>
            </div>
            <div class="step">
                <div class="step-number">4</div>
                <div class="step-label">Complete</div>
            </div>
        </div>

        <!-- Content -->
        <div class="wizard-content">
            <h2>Review Configuration</h2>

            <% if (errorMessage) { %>
            <div class="error-message"><%= errorMessage %></div>
            <% } %>

            <div class="review-section">
                <h3>Delivery Type</h3>
                <div class="review-item">
                    <span class="label">Type</span>
                    <span class="value"><%= typeLabels[wizardData.deliveryType] || 'Unknown' %></span>
                </div>
            </div>

            <div class="review-section">
                <h3>Delivery Details</h3>
                <div class="review-item">
                    <span class="label">Name</span>
                    <span class="value"><%= wizardData.deliveryName || '-' %></span>
                </div>
                <% if (wizardData.subject) { %>
                <div class="review-item">
                    <span class="label">Subject</span>
                    <span class="value"><%= wizardData.subject %></span>
                </div>
                <% } %>
                <div class="review-item">
                    <span class="label">Campaign</span>
                    <span class="value"><%= campaignLabel || 'None' %></span>
                </div>
                <div class="review-item">
                    <span class="label">Scheduled</span>
                    <span class="value"><%= wizardData.scheduledDate || 'Immediate' %></span>
                </div>
            </div>

            <form id="wizardForm" method="post">
                <input type="hidden" name="action" value="submit">
            </form>
        </div>

        <!-- Footer -->
        <div class="wizard-footer">
            <form method="post" style="display: inline;">
                <input type="hidden" name="action" value="back">
                <button type="submit" class="btn btn-secondary">
                    ← Back
                </button>
            </form>
            <button type="submit" form="wizardForm" class="btn btn-success">
                Create Delivery ✓
            </button>
        </div>
    </div>
</body>
</html>
```

---

## Part 6: Step 4 - Completion

### 6.1 Create step4-complete.jsp

```jsp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delivery Wizard - Complete</title>
    <%@ include file="_shared.jsp" %>
</head>
<body>
    <%
    // Load final wizard data
    var wizardData = {};
    try {
        var stored = session.getValue("wizardData");
        if (stored) {
            wizardData = JSON.parse(stored);
        }
    } catch (e) {}

    // Clear session data after completion
    session.addValue("wizardData", "");

    var typeLabels = {
        'email': 'Email delivery',
        'sms': 'SMS message',
        'push': 'Push notification'
    };
    %>

    <div class="wizard-container">
        <div class="wizard-header">
            <h1>Delivery Created</h1>
            <p>Your delivery has been successfully configured</p>
        </div>

        <!-- Progress Steps -->
        <div class="progress-steps">
            <div class="step completed">
                <div class="step-number">✓</div>
                <div class="step-label">Select Type</div>
            </div>
            <div class="step completed">
                <div class="step-number">✓</div>
                <div class="step-label">Configure</div>
            </div>
            <div class="step completed">
                <div class="step-number">✓</div>
                <div class="step-label">Review</div>
            </div>
            <div class="step active">
                <div class="step-number">✓</div>
                <div class="step-label">Complete</div>
            </div>
        </div>

        <!-- Content -->
        <div class="wizard-content">
            <div class="success-container">
                <div class="success-icon">✓</div>
                <h2>Delivery Created Successfully!</h2>
                <p>Your <%= typeLabels[wizardData.deliveryType] || 'delivery' %>
                   "<strong><%= wizardData.deliveryName || 'Untitled' %></strong>"
                   has been created.</p>

                <div class="review-section" style="margin-top: 30px; text-align: left;">
                    <h3>Next Steps</h3>
                    <ul style="margin-top: 10px; padding-left: 20px;">
                        <li>Add recipients or select a target audience</li>
                        <li>Configure the delivery content</li>
                        <li>Preview and test your delivery</li>
                        <li>Schedule or send immediately</li>
                    </ul>
                </div>
            </div>
        </div>

        <!-- Footer -->
        <div class="wizard-footer">
            <a href="/" class="btn btn-secondary">
                Back to Dashboard
            </a>
            <a href="step1-type.jsp" class="btn btn-primary">
                Create Another
            </a>
        </div>
    </div>
</body>
</html>
```

---

## Part 7: Understanding Multi-Page Concepts

### 7.1 Context Variables (ctx.vars)

```javascript
// Setting ctx.vars (in JSP page)
<%
ctx.vars.myVariable = "someValue";
ctx.vars.userData = { name: "John", id: 123 };
%>

// Reading ctx.vars (in next page in same transition)
<%
var myValue = ctx.vars.myVariable;  // "someValue"
var user = ctx.vars.userData;        // { name: "John", id: 123 }
%>
```

**Important:** ctx.vars only persists within a single page transition. Use session for longer persistence.

### 7.2 Session Storage

```javascript
// Store data in session
<%
var data = { key: "value", items: [1, 2, 3] };
session.addValue("myKey", JSON.stringify(data));
%>

// Retrieve data from session
<%
try {
    var stored = session.getValue("myKey");
    var data = JSON.parse(stored);
} catch (e) {
    // Handle missing/invalid data
}
%>

// Clear session value
<%
session.addValue("myKey", "");  // Set to empty string to clear
%>
```

### 7.3 Page Transitions in ACC

In the ACC web application editor:

1. **Connect pages** with arrows in the workflow
2. **Name transitions** for programmatic control
3. **Control flow** with JavaScript:

```javascript
// Enable a specific transition
document.controller.setEnableTransition("transitionName", true);

// Or use form submission with action parameter
// The webapp interprets action values to choose transitions
```

### 7.4 Best Practices

1. **Always validate on each step** - Don't trust that previous steps completed
2. **Use session for persistence** - ctx.vars don't survive page reloads
3. **Clear session on completion** - Prevent stale data
4. **Provide back navigation** - Let users correct mistakes
5. **Show progress** - Users should know where they are

---

## Part 8: Test Your Wizard

### 8.1 Test Checklist

- [ ] Step 1: Select each delivery type
- [ ] Step 1: Verify Next button enables on selection
- [ ] Step 2: Fill in all fields
- [ ] Step 2: Test validation (empty name)
- [ ] Step 2: Go back to Step 1 and verify type preserved
- [ ] Step 3: Review shows all entered data
- [ ] Step 3: Go back and change data, verify review updates
- [ ] Step 4: Success message shows correct info
- [ ] Step 4: Create Another restarts wizard
- [ ] Session: Refresh page mid-wizard, verify data preserved

### 8.2 Common Issues

| Problem | Solution |
|---------|----------|
| Data lost between pages | Check session.addValue/getValue |
| ctx.vars empty | Ensure proper page transition setup |
| Back button loses data | Save before navigation |
| Validation not working | Check form method and action |

---

## What You Learned

1. **Multi-page architecture** for complex workflows
2. **Context variables (ctx.vars)** for page-to-page data
3. **Session storage** for persistence across requests
4. **Progress indicators** for user guidance
5. **Form validation** at each step
6. **Back/forward navigation** patterns

---

## Next Steps

- [Advanced Patterns Guide](../10-ADVANCED-PATTERNS.md) - Deep dive into sessions and context
- [Code Templates](../08-CODE-TEMPLATES.md) - More ready-to-use patterns
- [Security & Performance](../07-SECURITY-PERFORMANCE.md) - Production considerations

---

**Congratulations!** You've built a complete multi-page wizard application!
