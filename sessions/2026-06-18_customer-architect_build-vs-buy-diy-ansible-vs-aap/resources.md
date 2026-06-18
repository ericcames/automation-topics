# Resources

## Documentation

- **Ansible Automation Platform** product overview and architecture — what the platform includes beyond Core.
- **Workflow job templates** — chaining jobs with **success/failure/always** branches (this is his 4-phase framework).
- **Event-Driven Ansible (EDA)** — rulebooks: condition → action; the supported home for his **auto-rollback trigger**.
- **Execution Environments** — versioned, reproducible container runtimes (vs. "works on my control node").
- **Automation mesh** — scaling execution across sites/segments to thousands of devices.
- **RBAC & activity stream / audit** — who-changed-what-when by default.
- **Certified Content / Ansible automation hub** — signed, supported collections and the CVE/security pipeline.

## Network automation collections (config generation + the 4 phases)

> All certified/supported — config generation and push are solved content, not hand-rolled scripts.

- `ansible.netcommon` — shared network plumbing, `cli_config`, backup/restore, `assert`-style validation.
- `cisco.ios`, `cisco.nxos` — Cisco IOS / NX-OS resource modules (idempotent config + diff).
- `arista.eos` — Arista EOS.
- `junipernetworks.junos` — Juniper Junos (native commit/rollback semantics pair well with phase 4).
- `paloaltonetworks.panos` — Palo Alto.
- **Resource modules + Jinja2 templates** — the actual "generate configurations" engine; runs identically on Core or AAP.

## Demos / proof-of-value to offer

- **The headline demo:** build *his* 4-phase flow as an **AAP workflow** —
  `pre-validate (gather facts + assert)` → `push (resource module)` → `post-validate (diff + assert)` →
  **on failure → EDA-triggered rollback job (restore prior config)** + open a ticket; on success → proceed.
  Goal: he watches **his own design** run, supported, and says "that's what I was about to build."
- **Config-generation demo:** Jinja2 + resource modules generating and pushing a device config from inventory/vars —
  shows the high-value work is the *content*, which is his on either platform.
- **Audit/RBAC walk-through:** show the activity stream answering "who changed what, when" with zero extra code —
  the evidence execs need.

## Framing aids (for the room)

- **The iceberg / capability map** in [talking-points.md](talking-points.md) — make the hidden maintenance visible.
- **The RHEL analogy** — Fedora/CentOS Stream → RHEL :: Ansible Core → AAP. He's already chosen "buy" once.
- **TCO worksheet** — list the homegrown platform's real costs (his time, maintenance, CVE ownership, on-call,
  bus-factor, cost-of-outage) next to a bounded subscription. Win framing; route exact numbers to the account team.

## Internal References

- Loop in the **account team** for subscription model and pricing specifics — **do not quote figures in the room.**
- Red Hat **public-safety / life-safety** customer references (anonymized) where available — supportability and
  continuity stories land harder than feature lists with this audience.
