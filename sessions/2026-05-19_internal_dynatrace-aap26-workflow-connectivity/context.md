# Context

Integration under test: **Dynatrace Workflows** → **AAP 2.6** → **Automation Decisions → Event streams** (token event stream), not Automation Controller job launch.

No OneAgent or Davis problems are required for connectivity testing.

## What we learned about the Dynatrace UI

- **Event data** on **Send event to Event-Driven Ansible** accepts **plain static JSON** only (in our tenant).
- JSON with `"{{ environment().id }}"` is sent **literally** to AAP inside `eventData`.
- Multiline Jinja (`{{ { ... } | to_json }}`) is **rejected** or not supported in that field.
- **Run workflow → Event** is the trigger simulation (`event()`); it is **not** the POST body to AAP unless the send action is wired to use it.
- AAP wraps the payload under **`eventData:`** in the stream **Body** view.
- **Headers** in AAP show `[]` until header names are allowlisted on the event stream (see resources.md).

## Chosen path for now

**Option 1:** static **Event data** with real tenant id and URL literals. Revisit **Option 2** (JavaScript `fetch`) when there is time for dynamic fields and outbound/secret hardening.
