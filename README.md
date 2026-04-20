# ACC-Agent

Adobe Campaign Classic agents for Claude Code and Copilot CLI — develop, troubleshoot, and walk through ACC, grounded in the LF-ACC-Wiki.

## Agents

| Agent | Trigger | What it does |
|---|---|---|
| `acc-developer` | ACC coding questions (JSSP, JSP, QueryDef, NLWS) | Writes and explains ACC code grounded in the wiki |
| `acc-troubleshooter` | ACC errors, blank responses, debug help | Symptom→diagnosis→fix using 09-TROUBLESHOOTING.md |
| `acc-walkthrough-guide` | "Walk me through building X" | Step-by-step tutorials from the 8 example walkthroughs |
| `acc-wiki-librarian` | "Where is X documented?" | Returns wiki file paths and section anchors |

## Commands

| Command | Purpose |
|---|---|
| `/acc-develop <request>` | Dispatches to acc-developer |
| `/acc-fix <issue>` | Dispatches to acc-troubleshooter |
| `/acc-walkthrough <goal>` | Dispatches to acc-walkthrough-guide |
| `/acc-find <topic>` | Dispatches to acc-wiki-librarian |

## Install

### Claude Code

```bash
# Option 1: Install from marketplace (once repo is published on GitHub)
/plugin marketplace add 6ogo/ACC-Agent
/plugin install acc-agent@acc-agent-marketplace

# Option 2: Install from local directory (for development)
cc --plugin-dir C:/path/to/ACC-Agent
```

### GitHub Copilot CLI

```bash
# Install from marketplace (once repo is published on GitHub)
copilot plugin marketplace add 6ogo/ACC-Agent
copilot plugin install acc-agent@acc-agent-marketplace
```

## Grounded in LF-ACC-Wiki

The agents answer from a bundled snapshot of the [LF-ACC-Wiki](https://github.com/6ogo/LF-ACC-Wiki) — a curated knowledge base covering:
- JSP frontend development
- JSSP backend APIs (logonEscalation, QueryDef, NLWS)
- Database queries (xtk.queryDef, E4X XML)
- Security & performance patterns
- Troubleshooting guide (symptom→diagnosis→fix)
- 4 webapp build walkthroughs + 4 workflow script guides

### What's NOT covered

The wiki (and therefore these agents) does not cover: raw SOAP calls, REST API ingestion, schema XML authoring, workflow visual design, delivery template configuration, ACC numeric error codes, instance administration, or mobile channels. For these, see [Adobe Experience League](https://experienceleague.adobe.com/docs/campaign-classic/).

## Update wiki snapshot

To refresh the bundled wiki content from the latest upstream:

```bash
# Using the skill
/refresh-wiki

# Or run the script directly
bash skills/refresh-wiki/scripts/refresh.sh
```

## About

Built by George Yakoub. Wiki source: [LF-ACC-Wiki](https://github.com/6ogo/LF-ACC-Wiki).
