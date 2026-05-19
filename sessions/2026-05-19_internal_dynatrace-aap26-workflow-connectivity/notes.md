# Notes (2026-05-19)

## Outcome

- **Option 1** validated: static **Event data** JSON reaches AAP event stream; **Events received** and **Body** (`eventData`) confirmed (lab / reachable AAP).
- **Option 2** (Run JavaScript + `fetch`) documented in resources.md; not implemented yet.

## Pitfalls hit (Dynatrace UI)

- Pasting `{{ environment().id }}` inside JSON → literal strings in AAP.
- Putting payload in **Run workflow → Event** instead of **Send event → Event data**.
- Jinja dict / `to_json` in **Event data** → UI validation errors; only minimal static JSON accepted in that field.

## On-prem OpenShift + SaaS (later same day)

- Target: **Dynatrace SaaS** → **AAP 2.6 on OpenShift on-prem**.
- Error: `client error (Connect): dns error: Device or resource busy (os error 16)`.
- **EdgeConnect** is required for this topology (Dynatrace-owned component, deployed customer-side).
- Connection URL must be the **OpenShift Route** hostname (not in-cluster service DNS).
- Align EdgeConnect **host pattern** with the AAP route host; verify DNS/HTTPS from the EdgeConnect pod.

## Crib sheet incorporated

- Personal PDF *Dynatrace cribnotes - Ames* merged into [cribnotes.md](cribnotes.md) (names and tenant IDs redacted for public repo).
- Captures: Hub **Red Hat Ansible** app vs Ansible Tower catalog entry; EDA vs Controller connection tabs; allowlist host patterns; EdgeConnect UI guidance.

## Next session

- Deploy/configure **EdgeConnect** on OpenShift; confirm healthy in Dynatrace settings.
- Confirm **Allowlist** includes AAP route host (see cribnotes.md).
- Re-test Option 1 send after EdgeConnect + allowlisted outbound host.
- Implement Option 2; move token to secrets.
- Enable **Forward events** + rulebook on `event.payload.eventData.*`.
