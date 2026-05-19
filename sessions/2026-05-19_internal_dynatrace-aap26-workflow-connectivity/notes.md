# Notes (2026-05-19)

## Outcome

- **Option 1** validated: static **Event data** JSON reaches AAP event stream; **Events received** and **Body** (`eventData`) confirmed.
- **Option 2** (Run JavaScript + `fetch`) documented in resources.md; not implemented yet.

## Pitfalls hit

- Pasting `{{ environment().id }}` inside JSON → literal strings in AAP.
- Putting payload in **Run workflow → Event** instead of **Send event → Event data**.
- Jinja dict / `to_json` in **Event data** → UI validation errors.

## Next session

- Implement Option 2; move token to secrets.
- Enable **Forward events** + rulebook condition on `event.payload.eventData.*`.
- Optional: Controller **Launch job template** path for remediation jobs.
