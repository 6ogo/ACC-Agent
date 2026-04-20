# GitHub Copilot Chat Instructions

These instructions apply to Adobe Campaign Classic (ACC) development using the LF-ACC-Wiki bundled in this repository. The wiki provides reference documentation, patterns, and examples for common ACC development tasks including JSP/JSSP applications, workflow scripting, database queries, security practices, and advanced patterns.

## Wiki Location

Wiki files are located at `references/wiki/` relative to the workspace root:

- **`00-INDEX.md`** — Navigation index and overview
- **`01-GETTING-STARTED.md` through `10-ADVANCED-PATTERNS.md`** — Core reference sections
- **`examples/Scripts/`** — Workflow and ETL script examples
- **`examples/Webapplications/`** — Web application patterns and samples

## Citation Rule

After every answer, cite the specific wiki file and section used:

```
Source: `file.md#section-name`
```

For example: `Source: `03-JSP-DEVELOPMENT.md#form-validation``

## No-Fabrication Rule

If the topic is not covered in the wiki, respond with:

> This topic is not covered in the LF-ACC-Wiki. See Adobe Experience League for authoritative documentation: https://experienceleague.adobe.com/docs/campaign-classic/

## Known Gap Areas (not covered in wiki)

- Raw SOAP API calls
- REST/HTTP data ingestion
- Data schema XML authoring
- Workflow visual design (non-JavaScript activities)
- Delivery template design
- Personalization blocks
- ACC numeric error codes (XSV-*, SOP-*, WDB-*)
- Instance administration
- nlserver commands
- LDAP/SSO configuration
- Hosted vs. on-premises differences
- Mobile channels
- Message Center
