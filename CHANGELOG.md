# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- [AGENTS.md](AGENTS.md) for AI contributor orientation
- Cursor project rule [`.cursor/rules/read-agents.mdc`](.cursor/rules/read-agents.mdc) (`alwaysApply`) so agents load that guidance automatically
- Session [2026-05-19_internal_dynatrace-aap26-workflow-connectivity](sessions/2026-05-19_internal_dynatrace-aap26-workflow-connectivity/) — Dynatrace Workflows to AAP 2.6 EDA event stream: Option 1 static Event data (validated), Option 2 JavaScript `fetch` deferred, UI pitfalls documented
- Same session: EdgeConnect (SaaS → on-prem OpenShift), DNS/connect `os error 16` troubleshooting
- Same session: [cribnotes.md](sessions/2026-05-19_internal_dynatrace-aap26-workflow-connectivity/cribnotes.md) from personal Dynatrace crib sheet (redacted)
- Session [2026-05-19_customer-sse_aap26-container-enterprise-database](sessions/2026-05-19_customer-sse_aap26-container-enterprise-database/) — compare RH-aligned external PostgreSQL vs Crunchy for container enterprise topology (customer: RHEL 10 VMs); add [EDB_Testing](https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing) EnterpriseDB path
- Same session: restructured to discovery-first — recommendation in `talking-points.md §7` is now a conditional decision tree keyed on RPO/RTO, `postgresql_admin_*` superuser availability, and DBaaS allowability; added a Mermaid flowchart for the same three questions
- Same session: added **managed DBaaS** (RDS / Azure Database for PostgreSQL) as a third path in the side-by-side; demoted EDB to a deep-dive in `resources.md` so the main comparison stays focused on the three in-scope paths
- Same session: added Appendices A (HA pattern decision — Patroni+etcd, RH HA Add-on, streaming repl, DBaaS-native), B (preflight checklist — DB stack, access, network, TLS, day-2), and C (sizing inputs + stub resource targets) in `talking-points.md`; each appendix uses a two-column table with opinionated SSE pre-fill defaults alongside blank customer-answer cells
- Same session: added Concepts section to `resources.md` explaining Patroni + etcd / Consul (PostgreSQL HA orchestration) and PgBouncer (connection pooling modes, the AAP `LISTEN` / `NOTIFY` gotcha)
- Session [2026-05-28_customer-sse_dynatrace-aap-eda-pull-integration](sessions/2026-05-28_customer-sse_dynatrace-aap-eda-pull-integration/) — Dynatrace SaaS → AAP EDA via the **pull** model (`dynatrace.event_driven_ansible` `dt_esa_api` polls the problems API); documents that **EdgeConnect is not required** for outbound/pull (it is inbound-only), with a push-vs-pull comparison, rulebook skeleton, token/egress inputs, and a 2.6-test → 2.5-prod promotion checklist
- Same session: `dt_esa_api` rulebook details (args `dt_api_host`/`dt_api_token`/`delay`/`proxy`, flat `event.title`/`event.status` shape, `Read problems` + `Write problems` token scopes) verified against the upstream `Dynatrace/Dynatrace-EventDrivenAnsible` collection
- Same session: [implementation.md](sessions/2026-05-28_customer-sse_dynatrace-aap-eda-pull-integration/implementation.md) — phased delivery plan (Phase 0–7) with per-phase exit gates, RACI-lite roles, and callouts for polling idempotency/re-trigger and a notify-only → human-gated → auto-remediation safety ramp

### Changed
- CI validates session folder naming, requires each session folder in the README Session Index, and checks that index links point at existing directories
- CONTRIBUTING and AGENTS.md note the session-related CI checks

### Removed
- `docs/aap-oidc-vault-identity.md` and its screenshots, plus the README **Reference Docs** section that linked it — pulled from the repo pending an authoritative rewrite. The in-repo draft had drifted: the AAP 2.7 *What's New* doc "OIDC authentication for HashiCorp Vault" confirms the feature is real and the credential types are `HashiCorp Vault Secret Lookup (OIDC)` / `HashiCorp Vault Signed SSH (OIDC)`, but the draft had been mis-corrected to an "announced-only / no OIDC type" framing (based on a build that did not surface the types). Local backup retained; rewrite to follow against the official docs and the 2026-06-16 webinar

## [1.1.0] - 2026-05-14

### Changed
- Linked file names in session README and `_template/README.md` to actual files so they are clickable on GitHub

## [1.0.0] - 2026-05-14

### Added
- Initial repository structure
- Session template (`_template/`)
- `.github` community health files (SECURITY, issue templates, PR template, CI workflow)
- CONTRIBUTING.md and CODE_OF_CONDUCT.md
- First session: `2026-05-14_customer-sse_aap26-cicd-pipelines`
