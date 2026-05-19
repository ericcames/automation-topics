# Dynatrace crib notes (incorporated from personal reference)

Source: personal PDF *Dynatrace cribnotes - Ames* (Downloads). This file is the **public, redacted** copy for the repo. It omits personal names, email-style identifiers, and specific NFR environment IDs. Keep those in your private notes.

---

## Red Hat–provided Dynatrace tenants

- Red Hat NFR / workshop tenants are used for integration testing (assign your own `<environment-id>` from the URL: `https://<environment-id>.apps.dynatrace.com`).
- Tenant access is granted through Red Hat enablement contacts (record names in private notes only).

---

## Internal expertise (private contacts)

| Topic | Who to ask (private crib sheet) |
|-------|----------------------------------|
| EDA + Dynatrace **webhook** source (`dt_webhook`) | Internal SME — webhook / rulebook path |
| EDA + Dynatrace generally | Internal SME — EDA controller / rulebooks |

Do not commit personal names or email to this public repo.

---

## Dynatrace Hub — Ansible integrations

From Hub search **Ansible** (two different entries):

| Hub entry | Type | Use |
|-----------|------|-----|
| **Ansible Tower** | Technology catalog | Reference / legacy naming; not the Workflows connector app |
| **Red Hat Ansible** | App — **Installed** | **Use this** — integrates with EDA, Automation Controller (AAC), AWX; triggers job templates and sends events |

Install path: **Hub → search Ansible → Red Hat Ansible → Install** (if not already installed).

Hub browse (pattern): `https://<environment-id>.apps.dynatrace.com/ui/apps/dynatrace.hub/browse/all?search=Ansible`

---

## Dynatrace Settings — connections

**Settings → Connections → Red Hat Ansible**

| Tab | Purpose |
|-----|---------|
| **Event-Driven Ansible** | EDA event stream POST URL + token (our primary path) |
| **Automation Controller** | Launch job templates on AAC (separate from event stream) |

Example connection (redacted):

| Field | Example pattern |
|-------|-----------------|
| Connection name | `aap-<lab>` |
| API URL | `https://<aap-route-host>/eda-event-streams/api/eda/v1/external_event_stream/<id>/post` |
| Owner | Your Dynatrace user |

Remediation blurb in UI: *Remediate problems and vulnerabilities automatically with the Red Hat Ansible Automation Platform.*

---

## Dynatrace Settings — external requests

**Settings → General → External requests**

UI text (important for on-prem):

> Configure access to public endpoints or disable outgoing requests in-app and ad-hoc functions. **Use EdgeConnect for private network endpoints.**

### Allowlist tab

Host patterns that must be allowlisted for workflow/JS outbound calls (example lab):

- `<aap-route-host>` — e.g. `aap-aap.apps.<cluster>.<domain>` (matches EDA event stream URL host)
- `demo.ansible.show` — additional lab/demo host if used in workflows

Use **+ New host pattern** for each distinct AAP or external host.

**Disable allowlist** — only if policy allows “connect to any external host” (not recommended for production).

### EdgeConnect tab

Required for **Dynatrace SaaS → AAP on private OpenShift**. See [resources.md § EdgeConnect](resources.md#edgeconnect-dynatrace-saas--aap-on-openshift-on-prem).

Allowlist alone is not enough when the UI directs you to EdgeConnect for private endpoints.

---

## Reference links

### Workflows and EDA

| Resource | URL |
|----------|-----|
| Dynatrace — Red Hat Ansible (workflows) | https://docs.dynatrace.com/docs/analyze-explore-automate/workflows/actions/red-hat/redhat-ansible |
| Dynatrace — Red Hat Event-Driven Ansible | https://docs.dynatrace.com/docs/analyze-explore-automate/workflows/actions/red-hat/redhat-even-driven-ansible |
| Example workflow samples (GitHub) | https://github.com/Dynatrace/Dynatrace-workflow-samples/tree/main/samples/red%20hat%20ansible%20automation%20platform |
| Dynatrace EventDrivenAnsible (GitHub) | https://github.com/Dynatrace/Dynatrace-EventDrivenAnsible |
| `dynatrace.event_driven_ansible` collection (Red Hat Catalog) | https://catalog.redhat.com/en/software/collection/dynatrace/event_driven_ansible |

### EDA plugins (collection)

| Plugin | Role |
|--------|------|
| `dt_webhook` | Events from workflow action **Send event to EDA** (webhook-style; custom decision env if not using event streams) |
| `dt_esa_api` | Poll/capture problems from Dynatrace tenant for rulebook-driven remediation |

### OneAgent (out of scope for event-stream smoke test, listed in crib sheet)

| Resource | URL |
|----------|-----|
| Dynatrace OneAgent install | https://docs.dynatrace.com/docs/setup-and-configuration/dynatrace-oneagent |
| Ansible collection for OneAgent | Search **Automation Hub / Galaxy** for Dynatrace OneAgent collection (deploy/monitor agents via Ansible) |

---

## Maps to this session

| Crib sheet item | Session doc |
|-----------------|-------------|
| EDA connection URL | [resources.md](resources.md) — Dynatrace connection |
| Allowlist + EdgeConnect UI note | [resources.md § EdgeConnect](resources.md#edgeconnect-dynatrace-saas--aap-on-openshift-on-prem) |
| Hub Red Hat Ansible app | [talking-points.md](talking-points.md) |
| Example workflow / rulebook | [resources.md](resources.md) — Option 1 / rulebook conditions |
| `os error 16` on-prem | [resources.md § DNS errors](resources.md#dns--connect-errors-os-error-16) |
