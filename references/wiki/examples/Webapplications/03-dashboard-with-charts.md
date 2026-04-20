# Walkthrough 03: Campaign Analytics Dashboard

**Build an analytics dashboard with interactive charts for campaign performance**

---

## What You'll Build

A dashboard application that:
- Displays delivery statistics with visual charts
- Shows campaign performance metrics
- Provides date range filtering
- Includes real-time data from ACC database
- Uses Chart.js for beautiful visualizations

**Final Result Preview:**

```
┌─────────────────────────────────────────────────────────────────────────┐
│  Campaign Analytics Dashboard              [Last 7 Days ▼] [Refresh]    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐│
│  │    1,234     │  │   98.5%      │  │    456       │  │   12.3%      ││
│  │  Deliveries  │  │  Delivery    │  │   Opens      │  │   Click      ││
│  │              │  │  Rate        │  │   (unique)   │  │   Rate       ││
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘│
│                                                                         │
│  ┌─────────────────────────────────┐ ┌─────────────────────────────────┐│
│  │    Deliveries by Status         │ │    Opens Over Time              ││
│  │         [PIE CHART]             │ │        [LINE CHART]             ││
│  │                                 │ │                                 ││
│  └─────────────────────────────────┘ └─────────────────────────────────┘│
│                                                                         │
│  ┌───────────────────────────────────────────────────────────────────┐ │
│  │    Recent Deliveries                                               │ │
│  │    ──────────────────────────────────────────────────────────────  │ │
│  │    Newsletter Q1      | Sent    | 15,234 recipients | 2024-01-15  │ │
│  │    Promo Campaign     | Draft   |      0 recipients | 2024-01-14  │ │
│  └───────────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Prerequisites

- Completed Walkthrough 01 or equivalent knowledge
- Basic understanding of QueryDef and aggregates
- Access to deliveries in your ACC instance

**Time to complete:** ~60 minutes

---

## Part 1: Create the Web Application

### 1.1 Create New Web Application

1. Go to **Resources > Online > Web applications**
2. Create new empty web application
3. Set Internal name: `campaignDashboard`
4. Set Label: `Campaign Analytics Dashboard`

### 1.2 Application Structure

```
Web Application: campaignDashboard
├── Pages
│   ├── main.jsp          # Dashboard page
│   └── api/
│       └── stats.jssp    # Statistics API
```

---

## Part 2: Build the Dashboard Page

### 2.1 Create main.jsp

```jsp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campaign Analytics Dashboard</title>

    <!-- Chart.js from CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f7fa;
            color: #333;
            line-height: 1.6;
        }

        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 20px;
        }

        /* Header */
        .header {
            background: linear-gradient(135deg, #0d47a1 0%, #1565c0 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 12px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
        }

        .header h1 {
            font-size: 26px;
            font-weight: 600;
        }

        .header-controls {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .header select {
            padding: 10px 15px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            background: rgba(255,255,255,0.2);
            color: white;
            cursor: pointer;
        }

        .header select option {
            color: #333;
        }

        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.2s;
        }

        .btn-light {
            background: rgba(255,255,255,0.9);
            color: #0d47a1;
        }

        .btn-light:hover {
            background: white;
        }

        /* Stats Cards */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .stat-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.12);
        }

        .stat-value {
            font-size: 36px;
            font-weight: 700;
            color: #0d47a1;
            margin-bottom: 5px;
        }

        .stat-label {
            font-size: 14px;
            color: #666;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-change {
            font-size: 12px;
            margin-top: 8px;
        }

        .stat-change.positive {
            color: #2e7d32;
        }

        .stat-change.negative {
            color: #c62828;
        }

        /* Charts Grid */
        .charts-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
            margin-bottom: 25px;
        }

        .chart-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        .chart-card h3 {
            font-size: 16px;
            color: #333;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
        }

        .chart-container {
            position: relative;
            height: 280px;
        }

        /* Data Table */
        .data-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
            overflow: hidden;
        }

        .data-card h3 {
            font-size: 16px;
            color: #333;
            padding: 20px;
            border-bottom: 1px solid #eee;
            margin: 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th {
            background: #f8f9fa;
            padding: 12px 15px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
            color: #555;
            border-bottom: 1px solid #eee;
        }

        td {
            padding: 12px 15px;
            border-bottom: 1px solid #f0f0f0;
            font-size: 14px;
        }

        tr:hover {
            background: #f9f9f9;
        }

        tr:last-child td {
            border-bottom: none;
        }

        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }

        .status-sent {
            background: #e8f5e9;
            color: #2e7d32;
        }

        .status-draft {
            background: #fff3e0;
            color: #e65100;
        }

        .status-failed {
            background: #ffebee;
            color: #c62828;
        }

        .status-pending {
            background: #e3f2fd;
            color: #1565c0;
        }

        /* Loading state */
        .loading {
            text-align: center;
            padding: 40px;
            color: #888;
        }

        .loading-spinner {
            width: 40px;
            height: 40px;
            border: 4px solid #f0f0f0;
            border-top-color: #0d47a1;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 15px;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Last updated */
        .last-updated {
            text-align: center;
            color: #888;
            font-size: 12px;
            margin-top: 20px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .charts-grid {
                grid-template-columns: 1fr;
            }

            .header {
                flex-direction: column;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <div class="header">
            <h1>Campaign Analytics Dashboard</h1>
            <div class="header-controls">
                <select id="dateRange" onchange="loadDashboard()">
                    <option value="7">Last 7 Days</option>
                    <option value="30">Last 30 Days</option>
                    <option value="90">Last 90 Days</option>
                    <option value="365">Last Year</option>
                </select>
                <button class="btn btn-light" onclick="loadDashboard()">
                    Refresh
                </button>
            </div>
        </div>

        <!-- Stats Cards -->
        <div class="stats-grid" id="statsCards">
            <div class="stat-card">
                <div class="stat-value" id="totalDeliveries">-</div>
                <div class="stat-label">Total Deliveries</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="successRate">-</div>
                <div class="stat-label">Success Rate</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="totalRecipients">-</div>
                <div class="stat-label">Recipients Reached</div>
            </div>
            <div class="stat-card">
                <div class="stat-value" id="avgOpenRate">-</div>
                <div class="stat-label">Avg. Open Rate</div>
            </div>
        </div>

        <!-- Charts -->
        <div class="charts-grid">
            <div class="chart-card">
                <h3>Deliveries by Status</h3>
                <div class="chart-container">
                    <canvas id="statusChart"></canvas>
                </div>
            </div>
            <div class="chart-card">
                <h3>Deliveries Over Time</h3>
                <div class="chart-container">
                    <canvas id="timelineChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Recent Deliveries Table -->
        <div class="data-card">
            <h3>Recent Deliveries</h3>
            <div id="deliveriesTable">
                <div class="loading">
                    <div class="loading-spinner"></div>
                    Loading deliveries...
                </div>
            </div>
        </div>

        <div class="last-updated" id="lastUpdated"></div>
    </div>

    <script>
        // ============================================
        // Global Variables
        // ============================================
        var API_URL = 'api/stats.jssp';
        var statusChart = null;
        var timelineChart = null;

        // ============================================
        // Initialize Dashboard
        // ============================================
        document.addEventListener('DOMContentLoaded', function() {
            loadDashboard();
        });

        // ============================================
        // Load All Dashboard Data
        // ============================================
        function loadDashboard() {
            var days = document.getElementById('dateRange').value;

            // Load all data in parallel
            Promise.all([
                fetchStats(days),
                fetchDeliveries(days),
                fetchTimeline(days)
            ]).then(function(results) {
                updateStats(results[0]);
                updateDeliveriesTable(results[1]);
                updateCharts(results[0], results[2]);
                updateLastUpdated();
            }).catch(function(error) {
                console.error('Dashboard error:', error);
            });
        }

        // ============================================
        // API Fetch Functions
        // ============================================

        function fetchStats(days) {
            return fetch(API_URL + '?action=stats&days=' + days)
                .then(function(r) { return r.json(); });
        }

        function fetchDeliveries(days) {
            return fetch(API_URL + '?action=deliveries&days=' + days)
                .then(function(r) { return r.json(); });
        }

        function fetchTimeline(days) {
            return fetch(API_URL + '?action=timeline&days=' + days)
                .then(function(r) { return r.json(); });
        }

        // ============================================
        // Update UI Functions
        // ============================================

        function updateStats(data) {
            if (!data.success) return;

            document.getElementById('totalDeliveries').textContent =
                formatNumber(data.totalDeliveries);

            document.getElementById('successRate').textContent =
                data.successRate.toFixed(1) + '%';

            document.getElementById('totalRecipients').textContent =
                formatNumber(data.totalRecipients);

            document.getElementById('avgOpenRate').textContent =
                data.avgOpenRate.toFixed(1) + '%';
        }

        function updateDeliveriesTable(data) {
            if (!data.success) {
                document.getElementById('deliveriesTable').innerHTML =
                    '<div class="loading">Error loading deliveries</div>';
                return;
            }

            if (data.deliveries.length === 0) {
                document.getElementById('deliveriesTable').innerHTML =
                    '<div class="loading">No deliveries found in selected period</div>';
                return;
            }

            var html = '<table><thead><tr>' +
                '<th>Delivery</th>' +
                '<th>Campaign</th>' +
                '<th>Status</th>' +
                '<th>Recipients</th>' +
                '<th>Created</th>' +
                '</tr></thead><tbody>';

            for (var i = 0; i < data.deliveries.length; i++) {
                var d = data.deliveries[i];
                html += '<tr>' +
                    '<td><strong>' + escapeHtml(d.label) + '</strong></td>' +
                    '<td>' + escapeHtml(d.campaignLabel || '-') + '</td>' +
                    '<td><span class="status-badge status-' + d.statusClass + '">' +
                        d.statusLabel + '</span></td>' +
                    '<td>' + formatNumber(d.recipients) + '</td>' +
                    '<td>' + d.created + '</td>' +
                    '</tr>';
            }

            html += '</tbody></table>';
            document.getElementById('deliveriesTable').innerHTML = html;
        }

        function updateCharts(statsData, timelineData) {
            // Destroy existing charts
            if (statusChart) statusChart.destroy();
            if (timelineChart) timelineChart.destroy();

            // Status Pie Chart
            var statusCtx = document.getElementById('statusChart').getContext('2d');
            statusChart = new Chart(statusCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Sent', 'Draft', 'Pending', 'Failed'],
                    datasets: [{
                        data: [
                            statsData.statusCounts.sent || 0,
                            statsData.statusCounts.draft || 0,
                            statsData.statusCounts.pending || 0,
                            statsData.statusCounts.failed || 0
                        ],
                        backgroundColor: [
                            '#4CAF50',
                            '#FF9800',
                            '#2196F3',
                            '#f44336'
                        ],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });

            // Timeline Line Chart
            if (timelineData.success) {
                var timelineCtx = document.getElementById('timelineChart').getContext('2d');
                timelineChart = new Chart(timelineCtx, {
                    type: 'line',
                    data: {
                        labels: timelineData.labels,
                        datasets: [{
                            label: 'Deliveries',
                            data: timelineData.values,
                            borderColor: '#0d47a1',
                            backgroundColor: 'rgba(13, 71, 161, 0.1)',
                            fill: true,
                            tension: 0.4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: false
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    stepSize: 1
                                }
                            }
                        }
                    }
                });
            }
        }

        function updateLastUpdated() {
            var now = new Date();
            var timeStr = now.toLocaleTimeString();
            document.getElementById('lastUpdated').textContent =
                'Last updated: ' + timeStr;
        }

        // ============================================
        // Helper Functions
        // ============================================

        function formatNumber(num) {
            if (num === null || num === undefined) return '0';
            if (num >= 1000000) {
                return (num / 1000000).toFixed(1) + 'M';
            }
            if (num >= 1000) {
                return (num / 1000).toFixed(1) + 'K';
            }
            return num.toString();
        }

        function escapeHtml(str) {
            if (!str) return '';
            var div = document.createElement('div');
            div.textContent = str;
            return div.innerHTML;
        }
    </script>
</body>
</html>
```

---

## Part 3: Build the Statistics API

### 3.1 Create api/stats.jssp

```javascript
<%
/**
 * Campaign Statistics API
 *
 * Actions:
 *   - stats: Get aggregate statistics
 *   - deliveries: Get recent deliveries list
 *   - timeline: Get deliveries over time for chart
 */

// Enable webapp authentication
logonEscalation("webapp");

// Set JSON response
response.setContentType("application/json");

var action = request.getParameter("action") || "stats";
var days = parseInt(request.getParameter("days")) || 30;

// Calculate date range
var endDate = new Date();
var startDate = new Date();
startDate.setDate(startDate.getDate() - days);

// Format dates for SQL
var startDateStr = formatDateForSQL(startDate);
var endDateStr = formatDateForSQL(endDate);

var result = { success: false };

try {
    switch (action) {

        // ============================================
        // STATS - Aggregate Statistics
        // ============================================
        case "stats":
            // Total deliveries count
            var countQuery = xtk.queryDef.create({
                queryDef: {
                    schema: "nms:delivery",
                    operation: "count",
                    where: {
                        condition: [{
                            expr: "@created >= '" + startDateStr + "'"
                        }]
                    }
                }
            });
            var totalDeliveries = countQuery.ExecuteQuery().@count;

            // Deliveries by status
            var statusQuery = xtk.queryDef.create({
                queryDef: {
                    schema: "nms:delivery",
                    operation: "select",
                    select: { node: [
                        { expr: "@state" },
                        { expr: "COUNT(@id)", alias: "@cnt" }
                    ]},
                    where: {
                        condition: [{
                            expr: "@created >= '" + startDateStr + "'"
                        }]
                    },
                    groupBy: { node: [{ expr: "@state" }] }
                }
            });
            var statusRes = statusQuery.ExecuteQuery();

            var statusCounts = {
                draft: 0,    // state = 0
                pending: 0,  // state = 1, 2, 3, 4
                sent: 0,     // state = 95
                failed: 0    // state = 87
            };

            var successCount = 0;
            for each (var row in statusRes.delivery) {
                var state = parseInt(row.@state);
                var cnt = parseInt(row.@cnt);

                if (state === 0) {
                    statusCounts.draft += cnt;
                } else if (state >= 1 && state < 85) {
                    statusCounts.pending += cnt;
                } else if (state === 95) {
                    statusCounts.sent += cnt;
                    successCount += cnt;
                } else if (state === 87) {
                    statusCounts.failed += cnt;
                }
            }

            // Calculate success rate
            var successRate = totalDeliveries > 0 ?
                (successCount / totalDeliveries) * 100 : 0;

            // Total recipients (sum of toDeliver from broadlogs)
            var recipientsQuery = xtk.queryDef.create({
                queryDef: {
                    schema: "nms:delivery",
                    operation: "select",
                    select: { node: [
                        { expr: "SUM(@toDeliver)", alias: "@total" }
                    ]},
                    where: {
                        condition: [{
                            expr: "@created >= '" + startDateStr + "' AND @state = 95"
                        }]
                    }
                }
            });
            var recipientsRes = recipientsQuery.ExecuteQuery();
            var totalRecipients = parseInt(recipientsRes.@total) || 0;

            // Calculate average open rate (simplified)
            // In production, you'd query tracking logs
            var avgOpenRate = statusCounts.sent > 0 ? 23.5 : 0; // Placeholder

            result.success = true;
            result.totalDeliveries = parseInt(totalDeliveries);
            result.successRate = successRate;
            result.totalRecipients = totalRecipients;
            result.avgOpenRate = avgOpenRate;
            result.statusCounts = statusCounts;
            break;

        // ============================================
        // DELIVERIES - Recent Deliveries List
        // ============================================
        case "deliveries":
            var deliveriesQuery = xtk.queryDef.create({
                queryDef: {
                    schema: "nms:delivery",
                    operation: "select",
                    lineCount: 20,
                    select: { node: [
                        { expr: "@id" },
                        { expr: "@label" },
                        { expr: "@state" },
                        { expr: "@created" },
                        { expr: "@toDeliver" },
                        { expr: "[operation/@label]", alias: "@campaignLabel" }
                    ]},
                    where: {
                        condition: [{
                            expr: "@created >= '" + startDateStr + "'"
                        }]
                    },
                    orderBy: { node: [{ expr: "@created", sortDesc: "true" }] }
                }
            });
            var deliveriesRes = deliveriesQuery.ExecuteQuery();

            var deliveries = [];
            for each (var d in deliveriesRes.delivery) {
                var state = parseInt(d.@state);
                var statusInfo = getStatusInfo(state);

                deliveries.push({
                    id: String(d.@id),
                    label: String(d.@label),
                    state: state,
                    statusLabel: statusInfo.label,
                    statusClass: statusInfo.cssClass,
                    recipients: parseInt(d.@toDeliver) || 0,
                    campaignLabel: String(d.@campaignLabel || ""),
                    created: formatDateDisplay(d.@created)
                });
            }

            result.success = true;
            result.deliveries = deliveries;
            break;

        // ============================================
        // TIMELINE - Deliveries Over Time
        // ============================================
        case "timeline":
            // Determine grouping based on date range
            var groupBy = days <= 31 ? "day" : (days <= 90 ? "week" : "month");

            var timelineQuery = xtk.queryDef.create({
                queryDef: {
                    schema: "nms:delivery",
                    operation: "select",
                    select: { node: [
                        { expr: "DATE(@created)", alias: "@dateKey" },
                        { expr: "COUNT(@id)", alias: "@cnt" }
                    ]},
                    where: {
                        condition: [{
                            expr: "@created >= '" + startDateStr + "'"
                        }]
                    },
                    groupBy: { node: [{ expr: "DATE(@created)" }] },
                    orderBy: { node: [{ expr: "DATE(@created)" }] }
                }
            });
            var timelineRes = timelineQuery.ExecuteQuery();

            // Build data arrays for chart
            var labels = [];
            var values = [];

            // Create date map for all days in range
            var dateMap = {};
            var currentDate = new Date(startDate);
            while (currentDate <= endDate) {
                var key = formatDateKey(currentDate);
                dateMap[key] = 0;
                labels.push(formatDateLabel(currentDate));
                currentDate.setDate(currentDate.getDate() + 1);
            }

            // Fill in actual values
            for each (var row in timelineRes.delivery) {
                var dateKey = formatDateKey(new Date(row.@dateKey));
                if (dateMap.hasOwnProperty(dateKey)) {
                    dateMap[dateKey] = parseInt(row.@cnt);
                }
            }

            // Convert map to values array
            currentDate = new Date(startDate);
            while (currentDate <= endDate) {
                var key = formatDateKey(currentDate);
                values.push(dateMap[key] || 0);
                currentDate.setDate(currentDate.getDate() + 1);
            }

            // If too many points, aggregate
            if (labels.length > 30) {
                var aggregated = aggregateData(labels, values, 15);
                labels = aggregated.labels;
                values = aggregated.values;
            }

            result.success = true;
            result.labels = labels;
            result.values = values;
            break;

        default:
            throw new Error("Unknown action: " + action);
    }

} catch (e) {
    result.success = false;
    result.error = e.message || String(e);
    logWarning("Stats API Error: " + result.error);
}

// Output JSON
document.write(JSON.stringify(result));

// ============================================
// Helper Functions
// ============================================

/**
 * Format date for SQL queries
 */
function formatDateForSQL(date) {
    var year = date.getFullYear();
    var month = String(date.getMonth() + 1).padStart(2, '0');
    var day = String(date.getDate()).padStart(2, '0');
    return year + '-' + month + '-' + day;
}

/**
 * Format date for display
 */
function formatDateDisplay(dateVal) {
    if (!dateVal) return '-';
    var d = new Date(dateVal);
    if (isNaN(d.getTime())) return '-';

    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[d.getMonth()] + ' ' + d.getDate() + ', ' + d.getFullYear();
}

/**
 * Format date as key for map
 */
function formatDateKey(date) {
    return date.getFullYear() + '-' +
           String(date.getMonth() + 1).padStart(2, '0') + '-' +
           String(date.getDate()).padStart(2, '0');
}

/**
 * Format date as chart label
 */
function formatDateLabel(date) {
    var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[date.getMonth()] + ' ' + date.getDate();
}

/**
 * Get status info for delivery state
 */
function getStatusInfo(state) {
    // ACC delivery states:
    // 0 = Edition, 1 = Pending, 2 = Connecting, 3 = Targeting, etc.
    // 95 = Finished (sent successfully)
    // 87 = Failed

    if (state === 0) {
        return { label: 'Draft', cssClass: 'draft' };
    } else if (state >= 1 && state < 85) {
        return { label: 'Pending', cssClass: 'pending' };
    } else if (state === 95) {
        return { label: 'Sent', cssClass: 'sent' };
    } else if (state === 87) {
        return { label: 'Failed', cssClass: 'failed' };
    } else {
        return { label: 'Unknown', cssClass: 'draft' };
    }
}

/**
 * Aggregate data points for cleaner charts
 */
function aggregateData(labels, values, targetPoints) {
    var step = Math.ceil(labels.length / targetPoints);
    var newLabels = [];
    var newValues = [];

    for (var i = 0; i < labels.length; i += step) {
        var sum = 0;
        var count = 0;
        for (var j = i; j < Math.min(i + step, labels.length); j++) {
            sum += values[j];
            count++;
        }
        newLabels.push(labels[i]);
        newValues.push(sum);
    }

    return { labels: newLabels, values: newValues };
}

// Polyfill for String.padStart
if (!String.prototype.padStart) {
    String.prototype.padStart = function(targetLength, padString) {
        targetLength = targetLength >> 0;
        padString = String(padString || ' ');
        if (this.length >= targetLength) return String(this);
        targetLength = targetLength - this.length;
        if (targetLength > padString.length) {
            padString += padString.repeat(targetLength / padString.length);
        }
        return padString.slice(0, targetLength) + String(this);
    };
}
%>
```

---

## Part 4: Understanding the Code

### 4.1 Aggregate Queries

**COUNT operation:**
```javascript
var query = xtk.queryDef.create({
    queryDef: {
        schema: "nms:delivery",
        operation: "count",        // Returns single count value
        where: { condition: [...] }
    }
});
var count = query.ExecuteQuery().@count;
```

**GROUP BY with aggregates:**
```javascript
var query = xtk.queryDef.create({
    queryDef: {
        schema: "nms:delivery",
        operation: "select",
        select: { node: [
            { expr: "@state" },                    // Group by field
            { expr: "COUNT(@id)", alias: "@cnt" }  // Aggregate function
        ]},
        groupBy: { node: [{ expr: "@state" }] }   // GROUP BY clause
    }
});
```

**Available aggregate functions:**
- `COUNT(@field)` - Count records
- `SUM(@field)` - Sum values
- `AVG(@field)` - Average value
- `MIN(@field)` - Minimum value
- `MAX(@field)` - Maximum value

### 4.2 Date Filtering

```javascript
// Calculate date range
var endDate = new Date();
var startDate = new Date();
startDate.setDate(startDate.getDate() - 30);  // 30 days ago

// Format for SQL
var dateStr = formatDateForSQL(startDate);  // "2024-01-15"

// Use in query
where: {
    condition: [{
        expr: "@created >= '" + dateStr + "'"
    }]
}
```

### 4.3 Chart.js Integration

```javascript
// Create chart
var chart = new Chart(ctx, {
    type: 'doughnut',  // or 'line', 'bar', 'pie'
    data: {
        labels: ['Label1', 'Label2'],
        datasets: [{
            data: [10, 20],
            backgroundColor: ['#4CAF50', '#f44336']
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false
    }
});

// Update chart data
chart.data.datasets[0].data = [30, 40];
chart.update();

// Destroy before recreating
chart.destroy();
```

### 4.4 Delivery States Reference

| State | Code | Description |
|-------|------|-------------|
| Edition | 0 | Draft, being edited |
| Pending | 1 | Ready for delivery |
| Connecting | 2 | Connecting to server |
| Targeting | 3 | Selecting recipients |
| ... | 4-84 | Various processing states |
| Failed | 87 | Delivery failed |
| Finished | 95 | Successfully sent |

---

## Part 5: Test Your Dashboard

### 5.1 Test Checklist

- [ ] Stats cards show correct values
- [ ] Pie chart displays status distribution
- [ ] Line chart shows timeline data
- [ ] Date range filter works
- [ ] Refresh button updates data
- [ ] Deliveries table shows recent items
- [ ] Status badges display correctly

### 5.2 Performance Considerations

1. **Limit query results** - Use `lineCount` to prevent large datasets
2. **Cache where possible** - Stats don't need real-time updates
3. **Aggregate on server** - Don't send raw data to client
4. **Use indexes** - Ensure date fields are indexed

---

## Part 6: Enhancements

### 6.1 Add Click Rate Chart

Add another chart showing click performance:

```javascript
// In stats.jssp, add tracking query
case "tracking":
    var trackQuery = xtk.queryDef.create({
        queryDef: {
            schema: "nms:trackingLogRcp",
            operation: "select",
            select: { node: [
                { expr: "@urlType" },
                { expr: "COUNT(@id)", alias: "@cnt" }
            ]},
            where: {
                condition: [{
                    expr: "@logDate >= '" + startDateStr + "'"
                }]
            },
            groupBy: { node: [{ expr: "@urlType" }] }
        }
    });
    // Process results...
    break;
```

### 6.2 Add Drill-Down

Make chart elements clickable:

```javascript
options: {
    onClick: function(event, elements) {
        if (elements.length > 0) {
            var index = elements[0].index;
            var status = ['sent', 'draft', 'pending', 'failed'][index];
            showDeliveriesByStatus(status);
        }
    }
}
```

### 6.3 Add Export

```javascript
function exportToCSV() {
    fetch(API_URL + '?action=export&format=csv')
        .then(function(r) { return r.blob(); })
        .then(function(blob) {
            var url = window.URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'campaign-stats.csv';
            a.click();
        });
}
```

---

## What You Learned

1. **Aggregate queries** with COUNT, SUM, GROUP BY
2. **Date range filtering** for time-based analytics
3. **Chart.js integration** for data visualization
4. **Delivery state handling** in Adobe Campaign
5. **Dashboard patterns** with cards, charts, and tables
6. **Performance optimization** for analytics queries

---

## Next Steps

- [Walkthrough 04: Multi-Page Application](04-multi-page-application.md) - Build complex app flows
- [Database & Queries Guide](../05-DATABASE-QUERIES.md) - Advanced query techniques
- [Frontend Patterns](../06-FRONTEND-PATTERNS.md) - More UI components

---

**Excellent work!** You've built a professional analytics dashboard!
