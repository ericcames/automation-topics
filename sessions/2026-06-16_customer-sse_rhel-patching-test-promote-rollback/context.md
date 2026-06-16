# Context

## Audience Profile

A **mixed room**: the **Red Hat account team** plus the **customer**. On the customer side the active
voices are **systems engineers / operators** who own patching day-to-day — they ask concrete,
mechanical questions (rollback steps, batch sizes, schedule counts), so the technical altitude needs
to be real. The account team needs the conversation to also **frame a target state** they can carry
forward commercially (notably the **Satellite** opportunity).

Plan accordingly: **open with the plan/architecture** so the account team and any leadership get the
shape of the solution, then **go deep** on the operator questions.

## Estate Snapshot (as described — keep generic, no identifying detail)

| Element | State |
|---------|-------|
| AAP — production | **2.5**, on **OpenShift** |
| AAP — test | **2.6**, on **OpenShift** |
| Red Hat Satellite | **Not yet a user** — interested in adopting (this is part of the plan) |
| ServiceNow | **Existing customer** — ITSM + **CMDB** available |
| Primary OS | RHEL (the focus), with a notable **SUSE** footprint |
| Architectures | Mostly x86_64, with **a couple of RHEL-on-Power (ppc64le)** hosts |
| Vuln/patch tooling | **Qualys** in use ("Qualys repos" — meaning to be clarified) |
| Scale signal | On the order of **hundreds of servers**; they **do not** patch all on one day |

## Topic Background

The customer wants to **modernize RHEL patching**. The core friction point they named: they want to
**test patches against test systems before applying them to production**. Everything else they asked
(rollback, staggering, grouping, ServiceNow tasks) hangs off that same need for a **controlled,
promotable, reversible** patch flow.

The clean way to deliver "test before prod" is a **content lifecycle**: **Satellite Content Views +
Lifecycle Environments** let you publish a patch set **once** and **promote that exact frozen version**
through rings (Library → Dev/Test → Prod). AAP orchestrates *when* and *to whom*; Satellite controls
*what content* each ring sees. This pairing is what makes rollback ("promote to a lower version"),
staggering (ring schedules), and grouping (Satellite inventory) all work coherently.

## The distinction that must not get blurred

The headline question mixes two operations with **opposite** rollback realities:

| | **Routine patching** (`dnf update` + reboot) | **Major-version upgrade** (RHEL 7 → 8, Leapp) |
|---|---|---|
| What it is | Updates within a release | In-place OS upgrade across major versions |
| Rollback | CV revert / snapshot / `dnf history undo` | **No clean post-commit rollback** — snapshot-before / restore-on-failure |
| "Set 1 host down a version" | Move host to a **prior CV version** in Satellite | **Restore that host's pre-upgrade snapshot** |
| Cadence | Recurring (their "every 2 weeks", and others) | Project-based, infrequent |

## Likely Assumptions They're Walking In With

- *"Rollback is a single button / a version downgrade like any app."* — True-ish for routine patching
  via Satellite CV revert and snapshots; **not** true for a completed Leapp major upgrade.
- *"RHEL 7 → 8 is just a bigger patch."* — It's a different operation (Leapp) with a different safety net.
- *"We'll need a separate job template for every schedule."* — No: **one template, many schedules**.
- *"Satellite can manage all our Linux, including SUSE."* — Satellite manages **Red Hat** content;
  **SUSE content** is SUSE Manager / Uyuni territory. AAP still **patches** SUSE via `zypper`.

## Potential Concerns or Objections

- **Leapp has no auto-rollback.** Address head-on; lead with the snapshot-before pattern so it reads as
  a designed safety net, not a gap.
- **Satellite adoption cost/effort.** They're new to it — frame CVs/lifecycle environments as the
  enabler for the very things they asked for, not as extra overhead.
- **Mixed estate coverage.** Make clear AAP is the **single patch orchestrator** across RHEL + SUSE +
  Power even where the **content-management** tooling differs by OS.
- **Snapshot capability.** Rollback robustness depends on whether hosts can be snapshotted
  (hypervisor/LVM); confirm rather than assume.
- **Qualys overlap.** Be ready to position Red Hat **Insights** vs Qualys without making it a
  rip-and-replace fight — AAP is the remediation engine either way.
