# Session: Dynatrace SaaS → AAP Event-Driven Ansible (pull model)

| Field | Value |
|-------|-------|
| Date | 2026-05-28 |
| Audience type | `customer-sse` |
| Topic | Integrate Dynatrace SaaS with AAP EDA using the **pull** model (EDA polls Dynatrace problems); build in **2.6 test** on OpenShift, promote to **2.5 production** |
| Format | Solution design / discovery |
| Contributors | Claude (Claude Code) |

## Goal

Stand up a Dynatrace → AAP integration where **EDA polls the Dynatrace problems API** (outbound HTTPS from on-prem OpenShift) and triggers automation — confirming **EdgeConnect is not required** for this direction — then promote the proven configuration from the 2.6 test environment to 2.5 production.

## Why pull (and why this changes the EdgeConnect assumption)

The customer walked in expecting to need **EdgeConnect**. EdgeConnect solves the **inbound** problem only — letting Dynatrace SaaS reach a *private* endpoint. In the **pull** model the connection runs the other way: **AAP reaches out to Dynatrace SaaS** over outbound HTTPS, which on-prem OpenShift almost always already permits. So EdgeConnect drops out of scope. See [resources.md § Push vs pull](resources.md#push-vs-pull--what-decides-edgeconnect).

## Companion session

The earlier hands-on **push** work (Dynatrace Workflows → AAP event stream, with EdgeConnect) lives in [`2026-05-19_internal_dynatrace-aap26-workflow-connectivity`](../2026-05-19_internal_dynatrace-aap26-workflow-connectivity/). Reuse it if the customer later wants Dynatrace Workflows to orchestrate.

## Files

| File | Purpose |
|------|---------|
| [context.md](context.md) | Audience, topology, the push-vs-pull connectivity reality |
| [objectives.md](objectives.md) | Build-in-2.6 / promote-to-2.5 success criteria |
| [talking-points.md](talking-points.md) | Key messages + the build sequence |
| [questions.md](questions.md) | Discovery on egress, tokens, target automation, 2.5 parity |
| [resources.md](resources.md) | Architecture, collection/plugin, rulebook skeleton, promotion checklist |
| [implementation.md](implementation.md) | Phased delivery plan (Phase 0–7) with exit gates and roles |
| [notes.md](notes.md) | Post-conversation capture (fill in after) |
