# Automation Topics

A public collection of conversation prep sessions on automation — covering CI/CD pipelines, infrastructure as code, platform engineering, and related topics.

Sessions are prepared for various audiences: customers, sales teams, and internal teammates. No customer names, company names, or identifying information is ever included.

## How Sessions Are Organized

```
sessions/
  YYYY-MM-DD_[audience-type]_[topic-slug]/
```

Each session folder contains:

| File | Purpose |
|------|---------|
| `README.md` | Session overview — date, audience type, goal |
| `context.md` | Audience profile and topic background |
| `objectives.md` | What success looks like and what we want to learn |
| `talking-points.md` | Key messages and framing |
| `questions.md` | Discovery and qualification questions |
| `resources.md` | Docs, demos, and reference links |
| `notes.md` | Post-conversation capture |

## Audience Types

| Label | Audience |
|-------|----------|
| `customer-sse` | Senior Systems Engineer |
| `customer-architect` | Solution / Enterprise Architect |
| `customer-exec` | Executive (CTO, VP, Director) |
| `sales-ae` | Account Executive |
| `sales-se` | Sales Engineer |
| `internal` | Red Hat teammates |

## Session Index

| Date | Audience | Topic | Folder |
|------|----------|-------|--------|
| 2026-05-14 | `customer-sse` | AAP 2.6 and CI/CD pipelines | [sessions/2026-05-14_customer-sse_aap26-cicd-pipelines](sessions/2026-05-14_customer-sse_aap26-cicd-pipelines/) |
| 2026-05-19 | `internal` | Dynatrace → AAP 2.6 EDA event stream (Option 1 static JSON) | [sessions/2026-05-19_internal_dynatrace-aap26-workflow-connectivity](sessions/2026-05-19_internal_dynatrace-aap26-workflow-connectivity/) |
| 2026-05-19 | `customer-sse` | AAP 2.6 container enterprise — PostgreSQL vs DBaaS vs Crunchy external DB | [sessions/2026-05-19_customer-sse_aap26-container-enterprise-database](sessions/2026-05-19_customer-sse_aap26-container-enterprise-database/) |
| 2026-05-28 | `customer-sse` | Dynatrace SaaS → AAP EDA pull model (EDA polls Dynatrace; no EdgeConnect); build 2.6 test → promote 2.5 prod | [sessions/2026-05-28_customer-sse_dynatrace-aap-eda-pull-integration](sessions/2026-05-28_customer-sse_dynatrace-aap-eda-pull-integration/) |
| 2026-06-16 | `customer-sse` | RHEL patching modernization — test → promote (Satellite Content Views/lifecycle), rollback (CV revert / snapshot / Leapp snapshot-before), staggered rings, ServiceNow change-gate, Insights push-button; SUSE/Power/Qualys noted | [sessions/2026-06-16_customer-sse_rhel-patching-test-promote-rollback](sessions/2026-06-16_customer-sse_rhel-patching-test-promote-rollback/) |

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The blank session template lives in [_template/](_template/).

## License

[MIT](LICENSE)
