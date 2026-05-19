# Objectives

## Done (Option 1 — reachable AAP)

- [x] AAP **Token Event Stream** credential and **event stream** configured; POST URL in Dynatrace **Red Hat Ansible** connection.
- [x] Dynatrace workflow **Send event to Event-Driven Ansible** delivers events (**Events received** increments).
- [x] **Event data** with **static JSON** (literal values) shows correct fields in AAP **Body** under `eventData`.
- [x] Confirmed quoted Jinja in JSON (`"{{ environment().id }}"`) is **not** evaluated—arrives as literal text.
- [x] Documented **EdgeConnect** requirement and DNS/connect error for SaaS → on-prem OpenShift.

## In progress (on-prem OpenShift)

- [ ] **EdgeConnect** deployed on OpenShift; host pattern matches AAP route hostname.
- [ ] EdgeConnect status healthy in **Settings → External Requests → EdgeConnect**.
- [ ] DNS/HTTPS from EdgeConnect pod to AAP route succeeds (`nslookup`, `curl`).
- [ ] Workflow send succeeds without `dns error: Device or resource busy (os error 16)`.

## Deferred (Option 2)

- [ ] **Run JavaScript** task POSTs dynamic payload via `fetch` to the event stream URL.
- [ ] Token stored outside script (workflow secret / credential pattern).
- [ ] Rulebook activation with **Forward events** enabled and condition matched to AAP Body shape.

## Learn (ongoing)

- Whether **Event data** gains expression / `result()` support in a future Hub app version.
- Headers visibility after allowlisting on the event stream.
- CoreDNS / concurrent workflow load if os error 16 persists after EdgeConnect is correct.
