# Objectives

## Done (Option 1)

- [x] AAP **Token Event Stream** credential and **event stream** configured; POST URL in Dynatrace **Red Hat Ansible** connection.
- [x] Dynatrace workflow **Send event to Event-Driven Ansible** delivers events (**Events received** increments).
- [x] **Event data** with **static JSON** (literal values) shows correct fields in AAP **Body** under `eventData`.
- [x] Confirmed quoted Jinja in JSON (`"{{ environment().id }}"`) is **not** evaluated—arrives as literal text.

## Deferred (Option 2)

- [ ] **Run JavaScript** task POSTs dynamic payload (environment id, execution id) via `fetch` to the event stream URL.
- [ ] Token stored outside script (workflow secret / credential pattern).
- [ ] Rulebook activation with **Forward events** enabled and condition matched to AAP Body shape.

## Learn (ongoing)

- Whether **Event data** gains expression / `result()` support in a future Hub app version.
- Headers visibility after allowlisting on the event stream.
