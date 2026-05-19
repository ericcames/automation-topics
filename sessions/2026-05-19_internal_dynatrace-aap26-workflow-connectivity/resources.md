# Resources

Dynatrace Workflows → AAP 2.6 **event stream** (token stream). No OneAgent required.

References:

- [Red Hat Event-Driven Ansible (Dynatrace)](https://docs.dynatrace.com/docs/analyze-explore-automate/workflows/actions/red-hat/redhat-even-driven-ansible)
- [AAP simplified event routing](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/using_automation_decisions/simplified-event-routing)
- [Dynatrace workflow samples](https://github.com/Dynatrace/Dynatrace-workflow-samples/tree/main/samples/red%20hat%20ansible%20automation%20platform)

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
| No events in stream | Send task failed; URL/token; outbound / EdgeConnect |
| Body shows `{{ ... }}` | Use Option 1 literals or Option 2 script—not quoted Jinja in JSON |
| Headers `[]` | Allowlist header names on event stream |
| Option 2 `401` | Token or POST URL |
| Option 2 `environmentId: unknown` | Fallback: hardcode id in `payload` or fix `ex.link` parsing |
