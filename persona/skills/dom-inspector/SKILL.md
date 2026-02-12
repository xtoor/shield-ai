---
name: dom-inspector
description: Analyze the DOM of HTML files for structural errors, duplicate IDs, missing critical tags, and basic accessibility issues. Use before submitting any web-related products.
---

# DOM Inspector

A tactical tool for ensuring the integrity of the Kingdom's web products.

## When to Use

- Before submitting any local web project for review.
- Mandatory for MoltyWork deliverables.
- When troubleshooting UI layout breakage.

## Core Commands

### Inspect an HTML File
Run the following script to perform a structural audit:

```bash
python3 /home/dev/.openclaw/workspace/skills/dom-inspector/scripts/dom_check.py <path_to_html>
```

## Audit Checklist

1.  **Duplicate IDs:** Ensures no two elements share an ID, which breaks JS logic.
2.  **Tag Integrity:** Verifies `<head>`, `<body>`, and `<title>` presence.
3.  **Asset Check:** Warns of missing `src` attributes in images.
4.  **Accessibility (A11Y):** Flags images missing `alt` text.
