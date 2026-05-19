# Context

Integration under test: **Dynatrace SaaS Workflows** → **AAP 2.6 on OpenShift (on-prem)** → **Automation Decisions → Event streams** (token event stream), not Automation Controller job launch.

No OneAgent or Davis problems are required for connectivity testing.

## Deployment topologies

| AAP location | Dynatrace → AAP path |
|--------------|----------------------|
| **Public or lab route** (reachable from internet) | Dynatrace connection + **allowed outbound** host may be enough for a smoke test. |
| **On-prem OpenShift** (private route) | **EdgeConnect** (Dynatrace component) deployed in your cluster/network is the normal pattern. SaaS cannot resolve or reach `*.svc.cluster.local` or internal-only DNS. |

**EdgeConnect** is a **Dynatrace** product (not Red Hat). You run its container on OpenShift; it maintains outbound connectivity to Dynatrace and performs HTTP(S) to internal URLs (for example the AAP route) on behalf of SaaS workflows.

## What we learned about the Dynatrace UI

- **Event data** on **Send event to Event-Driven Ansible** accepts **plain static JSON** only (in our tenant).
- JSON with `"{{ environment().id }}"` is sent **literally** to AAP inside `eventData`.
- Multiline Jinja (`{{ { ... } | to_json }}`) is **rejected** or not supported in that field.
- **Run workflow → Event** is the trigger simulation (`event()`); it is **not** the POST body to AAP unless the send action is wired to use it.
- AAP wraps the payload under **`eventData:`** in the stream **Body** view.
- **Headers** in AAP show `[]` until header names are allowlisted on the event stream (see resources.md).

## On-prem connectivity error (seen in testing)

When targeting on-prem AAP from SaaS without correct routing:

```text
client error (Connect): dns error: Device or resource busy (os error 16)
```

Typical causes: missing or misconfigured **EdgeConnect**, wrong hostname (internal DNS / typo), or too many concurrent outbound requests from the workflow runtime. See [resources.md § DNS / Connect errors](resources.md#dns--connect-errors-os-error-16).

## Chosen path for now

**Option 1:** static **Event data** with real tenant id and URL literals (validated against a reachable AAP). **EdgeConnect** must be in place for on-prem OpenShift before that path works from SaaS. **Option 2** (JavaScript `fetch`) deferred.
