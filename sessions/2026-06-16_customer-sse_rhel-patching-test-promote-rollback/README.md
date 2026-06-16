# Session: RHEL patching modernization — test → promote, rollback, Satellite, ServiceNow

| Field | Value |
|-------|-------|
| Date | 2026-06-16 |
| Audience type | `customer-sse` |
| Topic | Modernize RHEL patching on **AAP** — test patches in a **test ring** before production, with a credible **rollback** story, **staggered** rollout, **Satellite**-driven inventory/content, and **ServiceNow** integration |
| Format | Account-team + customer working session — **open with the plan, then go deep** on the operational questions |
| Contributors | Claude (Claude Code) |

## Goal

Agree on a **phased target architecture** for RHEL patching on AAP — **build/validate in a test ring, then promote the *same* content to production** — and give the customer correct, demonstrable answers to every operational question they raised (rollback, staggered rings, Satellite grouping, ServiceNow tasks, schedule sprawl, push-button remediation), while flagging where their mixed estate (SUSE, RHEL-on-Power, Qualys) fits.

## Two questions hide in one

The customer's headline question — *"if we go RHEL 7 → 8 and one server breaks, how do we roll back?"* — actually contains **two very different operations**:

- **Major-version upgrade** (RHEL 7 → 8 via **Leapp**): there is **no clean post-commit auto-rollback**. The supported pattern is **snapshot before, restore on failure**.
- **Routine in-release patching** (`dnf`/`yum` update + reboot): rollback via **Satellite content-view revert**, **LVM/`boom` snapshot**, or **`dnf history undo`**.

Keep these separate on the whiteboard — conflating them is the fastest way to over-promise. See [talking-points.md](talking-points.md).

## Files

| File | Purpose |
|------|---------|
| [context.md](context.md) | Audience, estate snapshot, the major-upgrade-vs-patching distinction |
| [objectives.md](objectives.md) | What we want to achieve and how to measure it |
| [talking-points.md](talking-points.md) | Key messages + a per-question answer map + the phased architecture |
| [questions.md](questions.md) | Discovery, depth probes, and qualification questions |
| [resources.md](resources.md) | Collections, docs, and demo hooks to reference |
| [notes.md](notes.md) | Post-conversation capture (fill in after) |
