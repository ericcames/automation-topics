# Implementation plan — phased

Phased delivery for the Dynatrace SaaS → AAP **EDA pull** integration: built in **2.6 test** (OpenShift), promoted to **2.5 production**. Each phase has an **exit gate** — don't start the next phase until the gate is green.

## Phase summary

| Phase | Name | Outcome |
|-------|------|---------|
| 0 | Discovery & prerequisites | Unknowns closed; go/no-go decision |
| 1 | Dynatrace setup | Scoped token, tenant URL, repeatable test-problem method |
| 2 | AAP 2.6 foundation | Decision environment, credential, project, Controller target |
| 3 | Rulebook & activation | Polling loop running — **notify-only** first |
| 4 | End-to-end validation | Synthetic problem → action, plus edge cases |
| 5 | Hardening | Secrets, idempotency, observability, kill switch |
| 6 | Promote to 2.5 production | Replicated artifacts, egress confirmed, canary cutover |
| 7 | Operationalize & scale | More problem→automation pairings, runbook, metrics |

## Roles (RACI-lite)

| Role | Owns |
|------|------|
| Dynatrace admin | Token issuance/scopes, management zone/tag strategy, test problems |
| AAP platform admin | Decision environment, credentials, EDA activations, Controller link |
| Network / cloud team | OpenShift egress + proxy to `*.live.dynatrace.com` |
| Automation / app owner | The remediation playbook/job template and its blast radius |

---

## Phase 0 — Discovery & prerequisites

**Goal:** close the unknowns in [questions.md](questions.md) before building anything.

- Confirm **2.5 production** topology (OpenShift vs VMs, private vs reachable) — affects promotion logistics, not the pull design.
- Confirm **egress**: outbound 443 from 2.6 (and 2.5) to `https://<env-id>.live.dynatrace.com`; capture the **proxy URL** if one is required.
- Confirm **EDA is licensed/enabled** in both 2.5 and 2.6, and that the **decision-environment registry** (private hub / Quay / internal registry) is reachable from each.
- Identify the **token owner** and that **Read problems + Write problems** scopes can be granted.
- Pick **one** first use case: a high-value, **low-blast-radius** problem→remediation pairing (e.g. disk cleanup, log rotation, service restart). Confirm the remediation already exists as a job template/playbook or scope building it.
- Define **success criteria** and a **rollback/kill switch** up front.

**Exit gate:** egress, token feasibility, EDA availability, and the first use case are all confirmed.

---

## Phase 1 — Dynatrace setup

**Goal:** the Dynatrace side is ready and testable on its own.

- Create the **API token** with **Read problems** + **Write problems**; record the **tenant URL**.
- Define a **scoping strategy** — a dedicated **management zone** or **tag** for the pilot — so polling/actions only touch intended problems.
- Establish a **repeatable way to raise a test problem** (synthetic metric event, test entity, or a controlled threshold) so validation isn't dependent on a real incident.
- Smoke-test the token from a workstation/bastion: `GET /api/v2/problems` returns 200.

**Exit gate:** token authenticates against the problems API; tenant URL confirmed; a test problem can be raised on demand.

---

## Phase 2 — AAP 2.6 foundation

**Goal:** the platform plumbing exists before any rulebook runs.

- Build/extend a **decision environment** that includes `dynatrace.event_driven_ansible` (+ deps); push it to the DE registry. *(Usually the trickiest ops step — do it early.)*
- Create the **credential** holding the Dynatrace token so it injects as `DT_API_TOKEN` — never inline in the rulebook.
- Create the **project** (git) for the rulebook and any playbooks.
- If the action is `run_job_template`: ensure the **Controller** job template, its inventory/credentials exist and the **EDA→Controller** link/token is configured.

**Exit gate:** DE pullable in EDA, credential stored, project syncs, Controller target reachable.

---

## Phase 3 — Rulebook & activation (notify-only)

**Goal:** the polling loop runs, but **does nothing destructive yet**.

- Author the rulebook from the verified skeleton in [resources.md](resources.md#rulebook-skeleton): `dt_esa_api` source (`dt_api_host`, `dt_api_token`, `delay`, `proxy` if needed).
- Point the first action at a **benign "notify/log" job**, not remediation — so you can observe the real event payload safely.
- Create and start the **rulebook activation** (DE + project + credential).
- Tune the **condition** against the actual event shape seen in **Automation Decisions** (`event.title`, `event.status`).

**Exit gate:** activation polls cleanly (no auth/proxy/DNS errors); a test problem produces an event with the expected `title`/`status`.

---

## Phase 4 — End-to-end validation

**Goal:** prove the full loop and its edges in 2.6.

- **Happy path:** raise a matching problem → event → condition matches → action fires → (optional) **comment back** on the problem via the Write scope.
- **Negative path:** problems that shouldn't match don't fire.
- **Idempotency / re-trigger (critical):** an **OPEN** problem reappears on every poll. Confirm whether the plugin emits it once or each cycle; if each cycle, guard the rule (e.g. ansible-rulebook **`throttle: once_within`** keyed on the problem id) so remediation doesn't relaunch every `delay` seconds. **Validate this explicitly.**
- **Failure modes:** token expiry, proxy down, Dynatrace **429** rate limit, activation restart (does it replay or resume?).
- Record **detection-to-action latency** vs the `delay` setting.

**Exit gate:** happy + negative + idempotency all behave; latency is acceptable; failure modes understood.

---

## Phase 5 — Hardening

**Goal:** make it safe to run unattended.

- **Secrets:** token in a proper store with a **rotation plan**; least privilege; scoped management zone.
- **Safety ramp:** progress **notify-only → human-gated → full auto**. For the gated stage use an AAP **workflow approval node** before the remediation runs.
- **Observability:** monitor **activation health** (who watches the watcher), forward EDA logs, alert if the activation is down.
- **Rate / load:** tune `delay` to respect Dynatrace API limits.
- **Kill switch:** documented one-step way to disable the activation fast.

**Exit gate:** secrets, idempotency guardrails, monitoring, and kill switch all in place; sign-off on the auto-remediation policy.

---

## Phase 6 — Promote to 2.5 production

**Goal:** move the proven config without surprises.

- **Version parity check first:** confirm 2.5's EDA controller / `ansible-rulebook` / DE base supports the rulebook as written — don't assume 2.5 == 2.6.
- Replicate artifacts: **decision environment** (same collection version), **credential**, **project**, **activation**.
- Issue a **prod-scoped token** (separate from test); confirm **prod egress + proxy**.
- **Canary cutover:** start **notify-only** in prod (or a canary management zone), then enable remediation after confidence.

**Exit gate:** prod activation validated against a controlled problem; remediation enabled per the agreed ramp.

---

## Phase 7 — Operationalize & scale

**Goal:** turn one working loop into a repeatable capability.

- Onboard additional **problem→automation pairings** using a standard rulebook pattern (naming, condition library, throttle defaults).
- Write an **ops runbook** (how to add a pairing, how to disable, how to rotate the token).
- Track **outcome metrics**: MTTR delta, % auto-remediated, false-fire rate.

**Exit gate:** at least one additional pairing onboarded via the documented pattern.

---

## Cross-cutting reminders

- **No EdgeConnect** anywhere in this plan — the loop is outbound only. See [resources.md § Push vs pull](resources.md#push-vs-pull--what-decides-edgeconnect).
- **Notify before you remediate** in every environment, including prod.
- **Blast radius** is controlled in two places: the Dynatrace management zone/tag *and* the rulebook condition.
