# Talking Points

## Opening Frame

"You came in expecting to need EdgeConnect — let's settle that first, because the integration *direction* decides it. If AAP calls out to Dynatrace (pull), EdgeConnect isn't in play at all. That's the design we'll build."

## Key Messages

1. **Direction decides EdgeConnect.** EdgeConnect is an *inbound* connector — it lets Dynatrace SaaS reach private endpoints. The **pull** model is **outbound** (AAP → Dynatrace), so EdgeConnect is **not required**. Confirmed in the Dynatrace EdgeConnect docs.
2. **EDA owns the loop.** The certified `dynatrace.event_driven_ansible` collection's **`dt_esa_api`** source polls the Dynatrace problems API; the rulebook evaluates conditions and launches a Controller job template (or runs a playbook). Decisioning lives in AAP, in source control.
3. **Build once, promote.** Prove it in **2.6 test** on OpenShift, then move the same artifacts — credential, decision environment, rulebook/project, activation — to **2.5 production**. EDA exists in both releases; the config is portable.

## Supporting Evidence

- Dynatrace **EdgeConnect** docs: inbound-only, not needed for external-to-Dynatrace API calls. ([resources.md](resources.md#references))
- Red Hat certified collection `dynatrace.event_driven_ansible` with `dt_esa_api` (poll) and `dt_webhook` (push) sources.
- Companion internal session already proved the **push** path end-to-end if they later want Workflows orchestration.

## The build sequence (2.6 test first)

1. **Dynatrace:** create an **access token** with **Read problems** + **Write problems** scopes; note the **tenant URL** (`https://<env-id>.live.dynatrace.com`).
2. **AAP 2.6:** store the token as a **credential**; confirm/extend a **decision environment** that includes `dynatrace.event_driven_ansible`.
3. **Rulebook:** author a rulebook with the `dt_esa_api` **source** + a **condition** (e.g. problem open / severity / tag) + an **action** (`run_job_template` or `run_playbook`). Keep the token out of the rulebook — reference the credential.
4. **Activation:** create the **rulebook activation** in **Automation Decisions** and start it.
5. **Verify:** trigger a synthetic problem in Dynatrace (or wait for a real one); confirm the activation fires and the job runs.
6. **Promote to 2.5:** replicate credential, decision environment (same collection version), rulebook/project, and activation; **confirm egress** to the tenant from the prod network.

## Then promote (2.5 production)

- Confirm the **EDA controller** is enabled and the **decision-environment registry** is reachable in prod.
- Re-issue or scope the **token** per prod security policy; store as a prod credential.
- Validate **outbound 443** to `*.live.dynatrace.com` (direct or via egress proxy) before starting the activation.

## Things to Avoid

- Don't conflate **event streams** (push) with the pull model — different direction, different connectivity story.
- Don't promise **real-time**: polling has an interval; set expectations on detection-to-action latency.
- Don't hardcode the Dynatrace token in the rulebook or project — use an AAP credential.
- Don't assume 2.5 == 2.6 for EDA; verify version/feature parity rather than asserting it.
