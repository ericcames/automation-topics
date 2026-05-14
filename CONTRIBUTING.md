# Contributing

This repository is a public collection of conversation prep sessions around automation topics. Contributions — corrections, new sessions, template improvements — are welcome.

## Content Policy

**Never include:**
- Customer or prospect names, company names, or identifying details
- Internal Red Hat pricing, deal terms, or confidential strategy
- Personal contact information of any kind
- Credentials, tokens, or API keys

Sessions are identified by audience type and topic only. If something was said in a meeting, it belongs in your private notes — not here.

## Adding a Session

1. Copy `_template/` into `sessions/` using the naming convention:

   ```
   YYYY-MM-DD_[audience-type]_[topic-slug]
   ```

2. Fill in each file. Leave `notes.md` blank until after the conversation.

3. Update the session index table in the root `README.md`.

4. Add an entry under `[Unreleased]` in `CHANGELOG.md`.

### Audience Type Labels

| Label | Audience |
|-------|----------|
| `customer-sse` | Senior Systems Engineer |
| `customer-architect` | Solution / Enterprise Architect |
| `customer-exec` | Executive (CTO, VP, Director) |
| `sales-ae` | Account Executive |
| `sales-se` | Sales Engineer |
| `internal` | Red Hat teammates |

## AI Agent Workflow

For a short, agent-oriented checklist (naming, files, content policy), see [AGENTS.md](AGENTS.md).

Sessions are designed for multi-agent collaboration. Each file in a session folder is atomic — Claude, Cursor, or any other agent can work on separate files without conflict. When an agent contributes, note it in the session `README.md` under **Contributors**.

## Pull Requests

- One concern per PR
- Update `CHANGELOG.md` in every PR
- PR title should be descriptive: `Add session: customer-sse AAP 2.6 CI/CD pipelines`
