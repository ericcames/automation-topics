# Talking points — Option 1 (today)

Beginner-oriented steps for Dynatrace → AAP event stream using **static Event data**.

## 1. AAP: event stream (one-time)

1. **Automation Decisions → Infrastructure → Credentials** → create **Token Event Stream** (header `Authorization`, set a token).
2. **Automation Decisions → Event streams** → **Create** → type **Token Event Stream** → attach credential.
3. Copy the **POST URL** from stream **Details**.
4. For testing: turn **off** **Forward events to rulebook activation**.
5. Optional: **Edit** stream → **Headers** → `Content-Type,Authorization,User-Agent` to populate the Headers panel (values may be redacted).

## 2. Dynatrace: connection (one-time)

1. Dynatrace Hub → install **Red Hat Ansible for Workflows**.
2. **Settings → Connections → Red Hat Ansible** → Event-Driven Ansible / EDA connection.
3. URL = AAP event stream **POST URL** (ends with `/post`).
4. Token = same value as AAP credential.

## 3. Dynatrace: workflow

1. App launcher → **Workflows** → open or create a workflow.
2. Trigger: **On demand** or **Schedule** (avoid **Problem** trigger until you have Davis events).
3. Add **Send event to Event-Driven Ansible** → select connection.
4. **Event data** — paste static JSON from [resources.md § Option 1](resources.md#option-1-static-event-data-in-use). Replace `<environment-id>` and URL with your tenant.
5. **Save** workflow.

## 4. Run and verify

1. **Run** workflow. If prompted for **Event**, use `{}` or minimal JSON (not required for Option 1 body).
2. Dynatrace: open **Executions** → send task **OK**.
3. AAP: **Event streams → &lt;stream&gt; → Details** → **Events received** increases; **Body** shows `eventData` with your literals.

## 5. Later — Option 2

When ready for dynamic payloads without editing JSON each time, follow [resources.md § Option 2](resources.md#option-2-deferred-run-javascript--fetch-post) (Run JavaScript + `fetch`).

## Not used in this path

- **Launch job template** (Automation Controller) — different action and **ExtraVars** field.
- **Run workflow → Event** with Jinja — does not populate AAP **Event data** unless explicitly mapped.
