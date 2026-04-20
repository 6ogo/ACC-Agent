# ACC Wiki Knowledge Gaps

The following topics are NOT documented in the LF-ACC-Wiki and therefore CANNOT be reliably answered from it. When a user asks about these topics, acknowledge the gap explicitly and direct them to [Adobe Experience League](https://experienceleague.adobe.com/docs/campaign-classic/).

| Topic | Notes |
|---|---|
| Raw SOAP calls | `soapCall`, external system SOAP authentication, WSDL parsing |
| REST API / HTTP ingestion | Making external HTTP calls from workflows or JSSP; no `http.get`/`http.post` examples |
| Data schema XML authoring | Writing `.xml` schema files, schema extension, data dictionary, field types |
| Workflow visual design | Configuring GUI activities: Query, Enrichment, Targeting, Split, Fork, Wait, Transfer (not JS activity code) |
| Delivery template design | Content blocks, personalization blocks, typology rules, delivery template configuration |
| ACC numeric error codes | XSV-*, SOP-*, WDB-*, NMS-* codes — not catalogued in the troubleshooting guide |
| Instance administration | `nlserver` commands, `serverConf.xml`, `config-*.xml`, operator management, monitoring |
| Deployment & packaging | Package export/import, environment promotion, upgrade procedures |
| LDAP/SSO/external authentication | LDAP directory integration, SAML/SSO, external auth configuration |
| Hosted vs on-prem differences | Managed cloud vs self-hosted feature differences and configuration |
| Mobile/SMS/Push channels | SMS routing, push notification configuration, mobile app integration |
| Message Center | Transactional messaging architecture, Message Center configuration |
| Interaction module | Offer engine, offer spaces, propositions, real-time offers |
| Dynamic reports | Report builder, cubes, dimensions, calculated metrics |
| Campaign/program hierarchy | Creating campaigns, programs, plans through the UI |
| Audit trail & monitoring | nlserver monitoring, log analysis, performance dashboards |

## How to Handle Gap Questions

When a user asks about a topic in this list:
1. Acknowledge clearly: "This topic is not documented in the LF-ACC-Wiki I'm grounded in."
2. Point to the official docs: https://experienceleague.adobe.com/docs/campaign-classic/
3. For schema reference: https://experienceleague.adobe.com/developer/campaign-api/
4. Do NOT fabricate an answer from general knowledge about Adobe Campaign.
5. If the question has PARTIAL wiki coverage (e.g., NLWS patterns without raw SOAP), answer the documented part and note the gap for the rest.
