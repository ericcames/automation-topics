# Resources

Dynatrace SaaS → AAP **Event-Driven Ansible**, **pull** model. EDA polls the Dynatrace problems API; **no EdgeConnect**.

## Architecture (pull)

```text
AAP Event-Driven Ansible  (rulebook activation, on-prem OpenShift / AAP host)
   source: dynatrace.event_driven_ansible.dt_esa_api
        │  outbound HTTPS 443  (polls problems API on an interval)
        ▼
Dynatrace SaaS  (Davis problems API,  https://<env-id>.live.dynatrace.com)
        │  problem matches rulebook condition
        ▼
Action:  run_job_template (Automation Controller)  |  run_playbook
        │  (optional closed loop)
        ▼
Comment / status back to the Dynatrace problem via API  (also outbound)
```

Connection is **outbound only**. The cluster needs egress to the tenant host; Dynatrace needs **no** path back into your network.

## Push vs pull — what decides EdgeConnect

| | **Pull (this session)** | **Push (companion session)** |
|---|---|---|
| Direction | AAP → Dynatrace (outbound) | Dynatrace → AAP (inbound) |
| EDA source / mechanism | `dt_esa_api` (poll problems API) | Event stream / `dt_webhook` (Workflows *Send event to EDA*) |
| Connectivity to arrange | Outbound 443 from AAP/OpenShift (+ proxy if any) | SaaS must reach the **private AAP route** |
| **EdgeConnect** | **Not needed** | **Required** for private on-prem AAP |
| Orchestration/decisioning | In **AAP/EDA** (rulebooks) | In **Dynatrace Workflows** |
| Latency | Poll interval (near-real-time-ish) | Near-real-time |

**EdgeConnect** is an *inbound* connector: it runs in your network and lets Dynatrace SaaS reach private endpoints. Per the Dynatrace docs it is **not required** when an external system calls Dynatrace APIs — which is the pull model. So for this design, EdgeConnect is out of scope.

## EDA source plugin: `dt_esa_api`

From the certified `dynatrace.event_driven_ansible` collection.

| Plugin | Role |
|--------|------|
| `dt_esa_api` | **Poll** the Dynatrace problems API; emit events into the rulebook (pull — used here) |
| `dt_webhook` | **Receive** events from a Dynatrace Workflow *Send event to EDA* action (push) |

The decision environment running the activation must include this collection.

### `dt_esa_api` parameters (verified against the upstream example)

| Param | Value |
|-------|-------|
| `dt_api_host` | Tenant URL, e.g. `https://<env-id>.live.dynatrace.com` |
| `dt_api_token` | Dynatrace API token (reference an AAP credential, not inline) |
| `delay` | Poll interval in **seconds** (default **60**) |
| `proxy` | Optional egress proxy URL, e.g. `http://my-proxy:3128` |

### Rulebook skeleton

Modeled on the collection's own example rulebook. **Events are flat** — match on `event.title` and `event.status`, not a nested `event.problem.*`.

```yaml
- name: React to Dynatrace problems
  hosts: all
  sources:
    - dynatrace.event_driven_ansible.dt_esa_api:
        dt_api_host: "https://<env-id>.live.dynatrace.com"   # tenant URL
        dt_api_token: "{{ DT_API_TOKEN }}"                   # from AAP credential, not inline
        delay: 60                                            # poll interval (seconds); default 60
        proxy: "http://my-proxy:3128"                        # optional — drop if no egress proxy
  rules:
    - name: Launch remediation on CPU saturation
      condition: event.status == "OPEN" and event.title is match("CPU saturation")
      action:
        run_job_template:
          name: "Remediate - <service>"
          organization: "Default"
```

Still inspect a real event in **Automation Decisions** before hardening conditions — `title`/`status` are confirmed, but the full payload depth isn't documented upstream.

## Dynatrace access token

- **Settings → Access tokens** → create a token.
- Scopes (per the collection README): **Read problems** *and* **Write problems**. Write supports the closed-loop step (commenting on / closing the problem); the collection asks for both.
- Store as an **AAP credential** referenced by the rulebook activation — never in the rulebook or project.

## OpenShift / network egress

- Activation pod needs **outbound 443** to `https://<env-id>.live.dynatrace.com` (and `<env-id>.apps.dynatrace.com` if used).
- If the cluster uses an **egress proxy**, set the plugin's native **`proxy`** parameter (above) — no reliance on env vars.
- No inbound rules, no route exposure, no EdgeConnect.

## Build → promote checklist (2.6 test → 2.5 production)

| Step | 2.6 test | 2.5 production |
|------|----------|----------------|
| Dynatrace token (scoped) | ☐ | ☐ (re-issue/scope per prod policy) |
| AAP credential for token | ☐ | ☐ |
| Decision environment w/ collection | ☐ | ☐ (same version; registry reachable) |
| Rulebook in a project | ☐ | ☐ (project sync) |
| Rulebook activation started | ☐ | ☐ |
| Egress to tenant verified | ☐ | ☐ |
| Synthetic problem fires a job | ☐ | ☐ |

> Confirm the **EDA controller** is enabled in 2.5 and feature/version parity with 2.6 rather than assuming it.

## References

- Dynatrace EdgeConnect (inbound-only; not needed for outbound/pull) — https://docs.dynatrace.com/docs/ingest-from/edgeconnect
- Red Hat certified collection `dynatrace.event_driven_ansible` — https://catalog.redhat.com/en/software/collection/dynatrace/event_driven_ansible
- Dynatrace EventDrivenAnsible (GitHub) — https://github.com/Dynatrace/Dynatrace-EventDrivenAnsible
- Dynatrace — Red Hat Event-Driven Ansible (Workflows action; the push side) — https://docs.dynatrace.com/docs/analyze-explore-automate/workflows/actions/red-hat/redhat-even-driven-ansible
- AAP simplified event routing (event streams; push) — https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/using_automation_decisions/simplified-event-routing
- Companion push session — [../2026-05-19_internal_dynatrace-aap26-workflow-connectivity/](../2026-05-19_internal_dynatrace-aap26-workflow-connectivity/)
