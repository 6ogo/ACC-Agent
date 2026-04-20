# Frontend Patterns Guide

Complete guide to styling, components, and user experience patterns for Adobe Campaign Classic web applications.

## Table of Contents
1. [CSS Architecture](#css-architecture)
2. [Component Library](#component-library)
3. [Layout Patterns](#layout-patterns)
4. [Responsive Design](#responsive-design)
5. [Interactive Elements](#interactive-elements)
6. [Data Visualization](#data-visualization)
7. [UX Best Practices](#ux-best-practices)

---

## CSS Architecture

### CSS Variables System

```css
:root {
  /* Colors - Primary */
  --primary: #005aa0;
  --primary-light: #4495d1;
  --primary-dark: #004880;
  
  /* Colors - Neutrals */
  --gray-light: #f5f7fa;
  --gray: #eaeef2;
  --gray-dark: #98a6b3;
  --white: #fff;
  --black: #000;
  
  /* Colors - Semantic */
  --success: #2ecc71;
  --warning: #f39c12;
  --danger: #e30613;
  --info: #3498db;
  
  /* Spacing */
  --spacing-xs: 4px;
  --spacing-sm: 8px;
  --spacing-md: 16px;
  --spacing-lg: 24px;
  --spacing-xl: 32px;
  
  /* Typography */
  --font-family: 'Roboto', Arial, sans-serif;
  --font-size-sm: 12px;
  --font-size-base: 14px;
  --font-size-lg: 16px;
  --font-size-xl: 20px;
  
  /* Effects */
  --radius: 8px;
  --shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 4px 16px rgba(0, 0, 0, 0.15);
  --transition: 0.2s ease;
}
```

### Base Styles

```css
/* Reset & Box Model */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

/* Typography */
body {
  font-family: var(--font-family);
  font-size: var(--font-size-base);
  color: var(--black);
  line-height: 1.6;
  background-color: var(--gray-light);
}

h1, h2, h3, h4, h5, h6 {
  font-weight: 600;
  margin-bottom: var(--spacing-md);
  color: var(--primary);
}

h1 { font-size: 2em; }
h2 { font-size: 1.5em; }
h3 { font-size: 1.25em; }

p {
  margin-bottom: var(--spacing-md);
}

/* Links */
a {
  color: var(--primary);
  text-decoration: none;
  transition: color var(--transition);
}

a:hover {
  color: var(--primary-dark);
  text-decoration: underline;
}
```

---

## Component Library

### Card Component

```css
.card {
  background: var(--white);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  padding: var(--spacing-lg);
  transition: transform var(--transition), box-shadow var(--transition);
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.card-header {
  border-bottom: 1px solid var(--gray);
  padding-bottom: var(--spacing-md);
  margin-bottom: var(--spacing-md);
}

.card-title {
  font-size: var(--font-size-xl);
  font-weight: 600;
  color: var(--primary);
  margin: 0;
}

.card-subtitle {
  font-size: var(--font-size-sm);
  color: var(--gray-dark);
  margin-top: var(--spacing-sm);
}

.card-content {
  /* Main content area */
}

.card-footer {
  border-top: 1px solid var(--gray);
  padding-top: var(--spacing-md);
  margin-top: var(--spacing-md);
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

**Usage Example:**
```html
<div class="card">
  <div class="card-header">
    <h3 class="card-title">Card Title</h3>
    <p class="card-subtitle">Optional subtitle</p>
  </div>
  <div class="card-content">
    <p>Card content goes here</p>
  </div>
  <div class="card-footer">
    <span>Last updated: 2024-12-16</span>
    <button class="btn btn-primary">Action</button>
  </div>
</div>
```

### Button Styles

```css
.btn {
  padding: 10px 20px;
  border: none;
  border-radius: calc(var(--radius) / 2);
  font-weight: 500;
  font-size: var(--font-size-base);
  cursor: pointer;
  transition: all var(--transition);
  display: inline-flex;
  align-items: center;
  gap: var(--spacing-sm);
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Primary Button */
.btn-primary {
  background: var(--primary);
  color: var(--white);
}

.btn-primary:hover:not(:disabled) {
  background: var(--primary-dark);
  transform: translateY(-2px);
  box-shadow: var(--shadow);
}

/* Secondary Button */
.btn-secondary {
  background: var(--gray);
  color: var(--black);
}

.btn-secondary:hover:not(:disabled) {
  background: var(--gray-dark);
}

/* Danger Button */
.btn-danger {
  background: var(--danger);
  color: var(--white);
}

.btn-danger:hover:not(:disabled) {
  background: #c60511;
}

/* Success Button */
.btn-success {
  background: var(--success);
  color: var(--white);
}

/* Outline Buttons */
.btn-outline {
  background: transparent;
  border: 2px solid var(--primary);
  color: var(--primary);
}

.btn-outline:hover:not(:disabled) {
  background: var(--primary);
  color: var(--white);
}

/* Size Variants */
.btn-sm {
  padding: 6px 12px;
  font-size: var(--font-size-sm);
}

.btn-lg {
  padding: 14px 28px;
  font-size: var(--font-size-lg);
}

/* Icon Button */
.btn-icon {
  padding: 8px;
  width: 36px;
  height: 36px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}
```

### Badge Component

```css
.badge {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: var(--font-size-sm);
  font-weight: 600;
  line-height: 1;
}

.badge-primary {
  background: var(--primary-light);
  color: var(--white);
}

.badge-success {
  background: #55efc4;
  color: #00b894;
}

.badge-warning {
  background: #ffeaa7;
  color: #d63031;
}

.badge-danger {
  background: #fab1a0;
  color: #d63031;
}

.badge-info {
  background: #74b9ff;
  color: #0984e3;
}
```

### Input Styles

```css
.form-group {
  margin-bottom: var(--spacing-lg);
}

label {
  display: block;
  margin-bottom: var(--spacing-sm);
  font-weight: 500;
  color: var(--black);
}

input[type="text"],
input[type="email"],
input[type="password"],
input[type="number"],
input[type="date"],
input[type="time"],
select,
textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid var(--gray);
  border-radius: calc(var(--radius) / 2);
  font-size: var(--font-size-base);
  font-family: var(--font-family);
  transition: border-color var(--transition), box-shadow var(--transition);
}

input:focus,
select:focus,
textarea:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(0, 90, 160, 0.2);
}

input:disabled,
select:disabled,
textarea:disabled {
  background: var(--gray-light);
  cursor: not-allowed;
}

/* Input with icon */
.input-group {
  position: relative;
  display: flex;
  align-items: center;
}

.input-group input {
  padding-left: 40px;
}

.input-icon {
  position: absolute;
  left: 12px;
  color: var(--gray-dark);
  pointer-events: none;
}
```

### Alert Component

```css
.alert {
  padding: var(--spacing-md);
  border-radius: var(--radius);
  margin-bottom: var(--spacing-md);
  border-left: 4px solid;
}

.alert-success {
  background: #d4edda;
  color: #155724;
  border-left-color: var(--success);
}

.alert-warning {
  background: #fff3cd;
  color: #856404;
  border-left-color: var(--warning);
}

.alert-danger {
  background: #f8d7da;
  color: #721c24;
  border-left-color: var(--danger);
}

.alert-info {
  background: #d1ecf1;
  color: #0c5460;
  border-left-color: var(--info);
}

.alert-title {
  font-weight: 600;
  margin-bottom: var(--spacing-sm);
}
```

---

## Layout Patterns

### Container

```css
.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: var(--spacing-lg);
}

.container-fluid {
  width: 100%;
  padding: var(--spacing-lg);
}

.container-narrow {
  max-width: 800px;
  margin: 0 auto;
  padding: var(--spacing-lg);
}
```

### Grid System

```css
/* Card Grid */
.cards-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: var(--spacing-lg);
}

/* Two Column Layout */
.two-column {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: var(--spacing-lg);
}

/* Three Column Layout */
.three-column {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: var(--spacing-lg);
}

/* Responsive Grid */
.responsive-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: var(--spacing-lg);
}

/* Sidebar Layout */
.sidebar-layout {
  display: grid;
  grid-template-columns: 250px 1fr;
  gap: var(--spacing-lg);
}

.sidebar {
  background: var(--white);
  padding: var(--spacing-lg);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
}

.main-content {
  /* Main content area */
}
```

### Flexbox Utilities

```css
.flex {
  display: flex;
}

.flex-column {
  display: flex;
  flex-direction: column;
}

.flex-center {
  display: flex;
  align-items: center;
  justify-content: center;
}

.flex-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.flex-wrap {
  flex-wrap: wrap;
}

.flex-gap-sm { gap: var(--spacing-sm); }
.flex-gap-md { gap: var(--spacing-md); }
.flex-gap-lg { gap: var(--spacing-lg); }
```

### Header Layout

```css
.header {
  background: var(--white);
  padding: var(--spacing-lg);
  border-radius: var(--radius);
  margin-bottom: var(--spacing-lg);
  box-shadow: var(--shadow);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-title {
  margin: 0;
}

.header-actions {
  display: flex;
  gap: var(--spacing-md);
}
```

---

## Responsive Design

### Breakpoints

```css
/* Mobile First Approach */

/* Extra Small (default) */
/* < 576px */

/* Small Devices (tablets) */
@media (min-width: 576px) {
  .container {
    max-width: 540px;
  }
}

/* Medium Devices (small laptops) */
@media (min-width: 768px) {
  .container {
    max-width: 720px;
  }
  
  .cards-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

/* Large Devices (desktops) */
@media (min-width: 992px) {
  .container {
    max-width: 960px;
  }
  
  .cards-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

/* Extra Large Devices (large desktops) */
@media (min-width: 1200px) {
  .container {
    max-width: 1140px;
  }
}
```

### Mobile Adaptations

```css
/* Hide on mobile */
@media (max-width: 768px) {
  .hide-mobile {
    display: none !important;
  }
  
  /* Stack cards */
  .cards-grid {
    grid-template-columns: 1fr;
  }
  
  /* Full width buttons */
  .btn {
    width: 100%;
    justify-content: center;
  }
  
  /* Smaller padding */
  .container {
    padding: var(--spacing-md);
  }
  
  /* Sidebar becomes full width */
  .sidebar-layout {
    grid-template-columns: 1fr;
  }
}

/* Show only on mobile */
@media (min-width: 769px) {
  .show-mobile {
    display: none !important;
  }
}
```

---

## Interactive Elements

### Loading Spinner

```css
.spinner {
  border: 3px solid var(--gray);
  border-top: 3px solid var(--primary);
  border-radius: 50%;
  width: 40px;
  height: 40px;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.spinner-sm {
  width: 20px;
  height: 20px;
  border-width: 2px;
}

/* Loading Overlay */
.loading-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
}
```

**Usage:**
```html
<div class="loading-overlay">
  <div class="spinner"></div>
</div>
```

### Modal Dialog

```css
.modal {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  z-index: 1000;
  align-items: center;
  justify-content: center;
}

.modal.active {
  display: flex;
}

.modal-content {
  background: var(--white);
  border-radius: var(--radius);
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.modal-header {
  padding: var(--spacing-lg);
  border-bottom: 1px solid var(--gray);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  margin: 0;
  font-size: var(--font-size-xl);
}

.modal-close {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: var(--gray-dark);
  padding: 0;
  width: 32px;
  height: 32px;
}

.modal-body {
  padding: var(--spacing-lg);
}

.modal-footer {
  padding: var(--spacing-lg);
  border-top: 1px solid var(--gray);
  display: flex;
  justify-content: flex-end;
  gap: var(--spacing-md);
}
```

**JavaScript:**
```javascript
function openModal(modalId) {
  document.getElementById(modalId).classList.add('active');
}

function closeModal(modalId) {
  document.getElementById(modalId).classList.remove('active');
}
```

### Dropdown Menu

```css
.dropdown {
  position: relative;
  display: inline-block;
}

.dropdown-toggle {
  cursor: pointer;
}

.dropdown-menu {
  position: absolute;
  top: 100%;
  left: 0;
  background: var(--white);
  border: 1px solid var(--gray);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  min-width: 200px;
  z-index: 100;
  display: none;
}

.dropdown.active .dropdown-menu {
  display: block;
}

.dropdown-item {
  padding: var(--spacing-md);
  cursor: pointer;
  transition: background var(--transition);
}

.dropdown-item:hover {
  background: var(--gray-light);
}

.dropdown-divider {
  height: 1px;
  background: var(--gray);
  margin: var(--spacing-sm) 0;
}
```

### Tabs

```css
.tabs {
  display: flex;
  gap: var(--spacing-sm);
  border-bottom: 2px solid var(--gray);
  margin-bottom: var(--spacing-lg);
}

.tab {
  padding: var(--spacing-md) var(--spacing-lg);
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  font-weight: 500;
  color: var(--gray-dark);
  transition: all var(--transition);
}

.tab:hover {
  background: var(--gray-light);
  color: var(--black);
}

.tab.active {
  color: var(--primary);
  border-bottom-color: var(--primary);
}

.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
}
```

### Tooltip

```css
.tooltip {
  position: relative;
  display: inline-block;
}

.tooltip-text {
  visibility: hidden;
  background: var(--black);
  color: var(--white);
  text-align: center;
  padding: 8px 12px;
  border-radius: 4px;
  position: absolute;
  z-index: 100;
  bottom: 125%;
  left: 50%;
  transform: translateX(-50%);
  white-space: nowrap;
  font-size: var(--font-size-sm);
  opacity: 0;
  transition: opacity var(--transition);
}

.tooltip-text::after {
  content: "";
  position: absolute;
  top: 100%;
  left: 50%;
  margin-left: -5px;
  border-width: 5px;
  border-style: solid;
  border-color: var(--black) transparent transparent transparent;
}

.tooltip:hover .tooltip-text {
  visibility: visible;
  opacity: 1;
}
```

---

## Data Visualization

### Progress Bar

```css
.progress {
  height: 24px;
  background: var(--gray);
  border-radius: 12px;
  overflow: hidden;
}

.progress-bar {
  height: 100%;
  background: var(--primary);
  transition: width 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--white);
  font-size: var(--font-size-sm);
  font-weight: 600;
}

.progress-bar-success { background: var(--success); }
.progress-bar-warning { background: var(--warning); }
.progress-bar-danger { background: var(--danger); }
```

### Stat Card

```css
.stat-card {
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
  color: var(--white);
  padding: var(--spacing-xl);
  border-radius: var(--radius);
  box-shadow: var(--shadow);
  transition: transform var(--transition);
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.stat-label {
  font-size: var(--font-size-sm);
  opacity: 0.9;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  margin-bottom: var(--spacing-sm);
}

.stat-value {
  font-size: 48px;
  font-weight: 700;
  line-height: 1;
}

.stat-change {
  font-size: var(--font-size-sm);
  margin-top: var(--spacing-sm);
  opacity: 0.9;
}

.stat-change.positive { color: #55efc4; }
.stat-change.negative { color: #fab1a0; }
```

### Table Styles

```css
.table-container {
  background: var(--white);
  border-radius: var(--radius);
  overflow-x: auto;
  box-shadow: var(--shadow);
}

.table {
  width: 100%;
  border-collapse: collapse;
}

.table thead {
  background: var(--gray-light);
}

.table th {
  padding: var(--spacing-md);
  text-align: left;
  font-weight: 600;
  border-bottom: 2px solid var(--gray);
  white-space: nowrap;
}

.table td {
  padding: var(--spacing-md);
  border-bottom: 1px solid var(--gray);
}

.table tbody tr:hover {
  background: var(--gray-light);
}

.table tbody tr:last-child td {
  border-bottom: none;
}

/* Sortable columns */
.table th.sortable {
  cursor: pointer;
  user-select: none;
}

.table th.sortable:hover {
  background: var(--gray);
}

/* Zebra striping */
.table-striped tbody tr:nth-child(even) {
  background: var(--gray-light);
}
```

---

## UX Best Practices

### Loading States

```html
<!-- Button loading state -->
<button class="btn btn-primary" disabled>
  <span class="spinner spinner-sm"></span>
  Loading...
</button>

<!-- Content loading state -->
<div class="card">
  <div class="flex-center" style="padding: 40px;">
    <div class="spinner"></div>
  </div>
</div>
```

### Empty States

```css
.empty-state {
  text-align: center;
  padding: 60px 20px;
  color: var(--gray-dark);
}

.empty-state-icon {
  font-size: 64px;
  margin-bottom: var(--spacing-lg);
  opacity: 0.5;
}

.empty-state-title {
  font-size: var(--font-size-xl);
  margin-bottom: var(--spacing-sm);
  color: var(--black);
}

.empty-state-text {
  margin-bottom: var(--spacing-lg);
}
```

### Error States

```html
<div class="alert alert-danger">
  <div class="alert-title">Error</div>
  <p>Unable to load data. Please try again.</p>
  <button class="btn btn-sm btn-danger" onclick="retry()">
    Retry
  </button>
</div>
```

### Success Feedback

```javascript
// Show temporary success message
function showSuccess(message) {
  var alert = document.createElement('div');
  alert.className = 'alert alert-success';
  alert.textContent = message;
  document.body.appendChild(alert);
  
  setTimeout(function() {
    alert.style.opacity = '0';
    setTimeout(function() {
      document.body.removeChild(alert);
    }, 300);
  }, 3000);
}
```

### Keyboard Navigation

```css
/* Focus styles */
*:focus {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}

button:focus,
a:focus,
input:focus,
select:focus {
  outline: 2px solid var(--primary);
  outline-offset: 2px;
}
```

---

## Animation & Transitions

### Fade In Animation

```css
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in {
  animation: fadeIn 0.3s ease;
}
```

### Slide In Animation

```css
@keyframes slideIn {
  from {
    transform: translateX(-100%);
  }
  to {
    transform: translateX(0);
  }
}

.slide-in {
  animation: slideIn 0.3s ease;
}
```

### Hover Effects

```css
/* Lift Effect */
.lift:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

/* Grow Effect */
.grow:hover {
  transform: scale(1.05);
}

/* Glow Effect */
.glow:hover {
  box-shadow: 0 0 20px rgba(0, 90, 160, 0.5);
}
```

---

**Next Steps:**
- [Code Templates](08-CODE-TEMPLATES.md) - Use these patterns in templates
- [JSP Development](03-JSP-DEVELOPMENT.md) - Apply to your pages
- [Security & Performance](07-SECURITY-PERFORMANCE.md) - Optimize your frontend
