# Resources

Dynatrace Workflows → AAP 2.6 **event stream** (token stream). No OneAgent required.

References:

- [Red Hat Event-Driven Ansible (Dynatrace)](https://docs.dynatrace.com/docs/analyze-explore-automate/workflows/actions/red-hat/redhat-even-driven-ansible)
- [AAP simplified event routing](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/using_automation_decisions/simplified-event-routing)
- [Configure and deploy EdgeConnect](https://docs.dynatrace.com/docs/ingest-from/edgeconnect)
- [Troubleshoot app functions — DNS errors](https://developer.dynatrace.com/develop/troubleshoot/troubleshoot-app-functions/)
- [Dynatrace workflow samples](https://github.com/Dynatrace/Dynatrace-workflow-samples/tree/main/samples/red%20hat%20ansible%20automation%20platform)
- [Session crib notes (Hub, allowlist, links)](cribnotes.md)

---

## EdgeConnect: Dynatrace SaaS → AAP on OpenShift (on-prem)

**EdgeConnect is a Dynatrace component** (not part of AAP). For **Dynatrace SaaS** calling **AAP on private OpenShift**, deploy EdgeConnect in your environment so HTTP to the AAP **Route** runs inside your network.

```text
Dynatrace SaaS (Workflows / Send event to EDA)
        ↓
EdgeConnect (pod on OpenShift — outbound WSS to Dynatrace)
        ↓
AAP Route URL → …/eda-event-streams/.../post
```

### Configure in Dynatrace

1. **Settings → General → External Requests → EdgeConnect** → **New EdgeConnect**.
2. **Name**: e.g. `aap-openshift`.
3. **Host pattern**: must match the hostname in the AAP connection URL, e.g. `aap-aap.apps.<cluster>.<domain>` (not an in-cluster service name).
4. Download **edgeConnect.yaml** and deploy on OpenShift.
5. **Settings → General → External Requests → Allowed outbound connections** — add the same hostname if required by your tenant.

### Verify from OpenShift

```bash
oc exec -it <edgeconnect-pod> -n <namespace> -- sh
# nslookup <aap-route-hostname>
# curl -sS -o /dev/null -w "%{http_code}" "https://<aap-route-hostname>/"
```

### Connection URL rules

| Use | Do not use |
|-----|------------|
| `https://<aap-route>/eda-event-streams/api/eda/v1/external_event_stream/<id>/post` | `https://*.svc.cluster.local/...` |
| Hostname that resolves from EdgeConnect pod | Internal-only DNS names |

Community: [EdgeConnect and firewall rules](https://community.dynatrace.com/t5/Automations/Dynatrace-EdgeConnect-and-firewall-rules/m-p/210701).

**Allowlist (in addition to EdgeConnect):** **Settings → General → External requests → Allowlist** — add the AAP route hostname (and any other hosts workflows call). UI states: *Use EdgeConnect for private network endpoints.* See [cribnotes.md § External requests](cribnotes.md#dynatrace-settings--external-requests).

---

## DNS / Connect errors (os error 16)

Observed when SaaS/workflows target on-prem AAP without correct path:

```text
client error (Connect): dns error: Device or resource busy (os error 16)
```

Per [Dynatrace developer docs](https://developer.dynatrace.com/develop/troubleshoot/troubleshoot-app-functions/), common causes:

1. **Bad or unresolvable hostname** — typo, internal OpenShift DNS used in the connection URL, host pattern not matching EdgeConnect config.
2. **Resolver overload** — too many concurrent HTTP/DNS requests from workflows (parallel `fetch` / send actions without batching).

| Action | Purpose |
|--------|---------|
| Deploy EdgeConnect; match **host pattern** to AAP route | Route SaaS traffic into your network |
| Use **Route URL** in Red Hat Ansible connection | Resolvable from EdgeConnect |
| Test DNS/HTTPS from EdgeConnect pod | Isolate platform vs Dynatrace |
| Single manual workflow run | Rule out transient EBUSY |
| Reduce parallel outbound tasks | If error only under load |

---

## Option 1: static Event data (in use)

Use on **Send event to Event-Driven Ansible** → **Event data**. Replace placeholders with your tenant (from the browser URL: `https://<environment-id>.apps.dynatrace.com`).

### Minimal (connectivity only)

```json
{
  "source": "dynatrace-workflow",
  "connectivityTest": true
}
```

### Recommended (full static tenant context)

```json
{
  "source": "dynatrace-workflow",
  "connectivityTest": true,
  "environmentId": "<environment-id>",
  "environmentUrl": "https://<environment-id>.apps.dynatrace.com"
}
```

Optional keys to add manually when useful:

```json
{
  "workflowExecutionId": "<paste-after-run-from-execution-url>",
  "workflowTitle": "Hello World"
}
```

### What AAP shows

Under **Body** (YAML view), expect a wrapper:

```yaml
eventData:
  source: dynatrace-workflow
  connectivityTest: true
  environmentId: <environment-id>
  environmentUrl: https://<environment-id>.apps.dynatrace.com
```

Rulebook conditions (when forwarding is on) — match the Body you see:

```yaml
condition: event.payload.eventData.connectivityTest == true
```

### What does not work in Event data (this tenant)

| Attempt | Result |
|---------|--------|
| `"environmentId": "{{ environment().id }}"` | Literal `{{ environment().id }}` in AAP |
| `{{ { ... } \| to_json }}` | UI validation error |
| `{{ result("build_eda_payload") }}` | Not tested / likely rejected if field is JSON-only |

---

## Option 2 (deferred): Run JavaScript + `fetch` POST

Use when Option 1 is not enough (dynamic `environmentId`, execution id on every run without editing JSON).

### Prerequisites

- AAP event stream **POST URL** and **token** (same as Option 1).
- Dynatrace **outbound** access to AAP host (**Settings → External Requests**) or **EdgeConnect**.

### Workflow shape

```text
[Trigger] → [Run JavaScript: send_to_aap_event_stream]
```

Remove or disconnect **Send event to Event-Driven Ansible** for this path.

### Script (paste into Run JavaScript)

Replace `PASTE_EVENT_STREAM_POST_URL_HERE` and `PASTE_TOKEN_HERE`.

```javascript
import { executionsClient } from '@dynatrace-sdk/client-automation';

export default async function ({ execution_id }) {
  const ex = await executionsClient.getExecution({ id: execution_id });
  const link = ex.link ?? '';
  const match = link.match(/https:\/\/([^.]+)\.apps\.dynatrace\.com/);
  const environmentId = match ? match[1] : 'unknown';

  const payload = {
    source: 'dynatrace-workflow',
    connectivityTest: true,
    environmentId,
    environmentUrl: `https://${environmentId}.apps.dynatrace.com`,
    workflowExecutionId: execution_id,
    workflowId: ex.workflow?.id,
    workflowTitle: ex.workflow?.title,
  };

  const eventStreamUrl = 'PASTE_EVENT_STREAM_POST_URL_HERE';
  const token = 'PASTE_TOKEN_HERE';

  const response = await fetch(eventStreamUrl, {
    method: 'POST',
    headers: {
      Authorization: token,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(payload),
  });

  const responseText = await response.text();

  return {
    ok: response.ok,
    status: response.status,
    sent: payload,
    response: responseText,
  };
}
```

### Verify

- Dynatrace execution: task output `"ok": true`, `"status": 200`.
- AAP event stream: **Body** with real `environmentId` and `workflowExecutionId`.

### Hardening before production

- Do not commit tokens; use workflow secrets when available.
- Restrict outbound hosts to the AAP event stream URL only.

---

## Dynatrace connection

- URL: `https://<aap-host>/eda-event-streams/api/eda/v1/external_event_stream/<id>/post`
- Token: **Token Event Stream** credential in AAP; header `Authorization`.

---

## AAP: HTTP headers in stream Details

1. **Edit** event stream → **Headers** → `Content-Type,Authorization,User-Agent`
2. Re-run workflow; refresh **Details** (Authorization value may show as redacted).

---

## Manual Run dialog

- **Event** field: optional `{}` for Option 1; does not replace **Event data** on the send action.
- Do not put Jinja in **Run → Event** expecting it in AAP unless the send action references `event()`.

---

## curl smoke test (AAP only)

```bash
curl -sS -X POST "https://<aap-host>/eda-event-streams/api/eda/v1/external_event_stream/<id>/post" \
  -H "Authorization: <token>" \
  -H "Content-Type: application/json" \
  -d '{"source":"curl-smoke","connectivityTest":true,"environmentId":"manual-test"}'
```

---

## Troubleshooting

| Symptom | Check |
|---------|--------|
| `dns error: Device or resource busy (os error 16)` | EdgeConnect; Route hostname; host pattern; DNS from EdgeConnect pod; reduce concurrent requests |
| No events in stream | Send task failed; URL/token; EdgeConnect healthy; outbound allowlist |
| Body shows `{{ ... }}` | Use Option 1 literals or Option 2 script—not quoted Jinja in JSON |
| Headers `[]` | Allowlist header names on event stream |
| Option 2 `401` | Token or POST URL |
| Option 2 `environmentId: unknown` | Fallback: hardcode id in `payload` or fix `ex.link` parsing |
