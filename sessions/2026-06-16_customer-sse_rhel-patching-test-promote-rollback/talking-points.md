# Talking Points

## Opening Frame

"You want to test patches before they hit production, and you want to know you can get out of trouble
if one host misbehaves. Both of those are really one thing: a **promotable, reversible patch pipeline**
— validate on a test ring, promote the *same* content to prod, and keep an escape hatch at every step.
Let's draw that target state first, then walk straight through each of your questions against it."

## Key Messages

1. **Test → promote is a content lifecycle, not a re-run.** With **Satellite Content Views +
   Lifecycle Environments**, you publish a patch set **once** and **promote that exact frozen version**
   through rings (Library → Dev/Test → Prod). The test ring proves the *same bits* prod will get — not
   "a patch run that hopefully matches."
2. **AAP orchestrates the *when* and *who*; Satellite controls the *what*.** That division is what makes
   rollback, staggering, and grouping all fall out of one design instead of bespoke scripts.
3. **Rollback has two honest answers** — routine patching is reversible several ways; a *completed*
   major-version upgrade is not, so you design the safety net **before** it (snapshot-restore).
4. **One template, many schedules.** Schedule sprawl is a symptom of modeling rings as templates.
   Model rings as **inventory groups + schedules + surveys** against a single template.
5. **AAP is the single patch orchestrator across the whole estate** — RHEL, SUSE, Power — even where
   the *content-management* tooling differs by OS.

---

## Per-question answer map

> Use this as the "go deep" section. Each row is a customer question → the answer to land.

### Q1 — "If we update 20 systems (RHEL 7→8) and 1 breaks, how do we roll back? Can AAP show it?"

**Split the question first** (major upgrade vs routine patching), then:

- **Routine in-release patching** — rollback options, most→least robust:
  - **Satellite content-view revert** — move the broken host back to a **prior published CV version**
    (the older patch set). This *is* their phrase **"promote it to a lower version via Satellite."** ✅
  - **LVM snapshot + `boom`** — snapshot before patching; reboot into the snapshot to undo, including
    **kernel** changes that package-level undo can't handle.
  - **`dnf history undo <id>`** — fast, package-level; good for simple transactions, not guaranteed for
    kernel/scriptlet-heavy ones.
  - **VM / hypervisor snapshot** — heavy but dead simple; revert the whole disk.
- **Major-version upgrade (RHEL 7→8 via Leapp)** — be honest: **no clean post-commit auto-rollback.**
  Supported pattern: **snapshot the host *before* Leapp**, run the upgrade, **validate**, and if it
  breaks, **restore the snapshot**. "Set that 1 host down a version until we resolve it" =
  **restore its pre-upgrade snapshot** (major) or **CV revert** (routine).
- **Yes, AAP shows this as a workflow.** On the canvas: **patch ring → validation job → on-failure
  branch** that (a) runs the **rollback job** (CV revert / snapshot restore / `dnf history undo`) and
  (b) **opens a ServiceNow ticket**; the **success branch promotes the next ring**. This is the demo to
  offer.

### Q2 — "500 servers, we don't patch all at once. Can we patch 10 today, 5 tomorrow, staggered?"

- **Yes — rings.** **One job template**, multiple **schedules**, each scoped to a different **host group
  / `limit` / inventory slice** with its own recurrence. Batch size within a run via **`serial`** or
  **job slicing**.
- The "10 today, 5 tomorrow" cadence is just **two schedules** (or a survey-driven group pick), not two
  templates.

### Q3 — "We pull facts/inventory from Satellite. Can we use Satellite via AAP to pick groups and patch?"

- **Yes.** The **Satellite dynamic inventory** (`redhat.satellite` / `theforeman.foreman` plugin) syncs
  hosts, **facts**, **host groups**, **host collections**, and **content-view / lifecycle-environment**
  membership into AAP as **inventory groups**. A **survey** lets the operator **pick a group and patch
  it**. Facts from Satellite drive conditional logic (e.g. only reboot if a kernel changed).

### Q4 — "Lots of schedules — 1 template, many schedules. We don't always patch every 2 weeks."

- **Exactly the right instinct.** Keep **one template**; attach **N schedules**, each with its own
  `rrule` (weekly, monthly, ad-hoc maintenance windows). Use **survey variables** for the bits that
  change per run (target group, reboot yes/no, dry-run). Avoids template sprawl and keeps logic in one
  place.

### Q5 — "Should we discuss push-button remediation for AAP + Satellite customers?"

- **Yes.** **Red Hat Insights** (Advisor, **Vulnerability**, **Patch**, **Tasks**) → **"Remediate with
  Ansible"** generates remediation playbooks you push through **Satellite/AAP**. **Insights ships with
  the RHEL subscription.** This is the literal "push button → fix" story and a natural bridge to the
  **Qualys** conversation (see Q8).

### Q6 — "Integrate with ServiceNow as part of patching (run tasks: dnf/yum update then reboot)."

- **`servicenow.itsm` collection.** Workflow shape: **open/lookup a Change Request → wait on the
  change-approval gate → run the patch tasks (`dnf`/`yum` update → reboot → validate) → update the
  CMDB CI (new patch level / kernel) → close the change.** That's their "run a number of tasks" plus
  CMDB hygiene in one flow. CMDB can also **enrich inventory** alongside Satellite (Satellite = technical
  truth, CMDB = system of record — reconcile, don't duplicate).

### Q7 — "We have a lot of SUSE."

- **AAP patches SUSE** via **`zypper`** (`community.general.zypper`) — same orchestration, schedules,
  and workflow patterns. **Caveat:** **Satellite does not manage SUSE *content*** (that's SUSE Manager
  / Uyuni). So the **content lifecycle** (CVs) is a RHEL story; the **patch orchestration** is one AAP
  story across both. Position AAP as the unifying layer.

### Q8 — "We use Qualys repos."

- **Clarify the term first:** does "Qualys repos" mean **content mirrors**, or **Qualys Cloud Agent /
  scan data**? Then position: keep Qualys for **scanning/vuln intel** if they like it — **AAP is the
  remediation engine**. Pattern: **Qualys finds → AAP remediates** (Qualys ships Ansible content/APIs;
  **EDA** can trigger automation on a finding). Contrast with **Insights Vulnerability** (Q5) so they
  see the Red Hat-native option without forcing a rip-and-replace.

### Q9 — "A couple of RHEL servers on Power."

- **Non-issue for patching.** AAP patches **ppc64le** RHEL identically (`dnf`); Satellite serves
  **ppc64le** repos in the same CV/lifecycle model. The control node / execution-environment
  architecture is **independent** of the managed-node architecture. Just make sure the Power repos are
  enabled in Satellite. Minor footnote, not a workstream.

---

## Proposed phased architecture (the "open with the plan" picture)

| Phase | Outcome |
|-------|---------|
| **0 — Discovery** | Inventory truth (Satellite ↔ CMDB reconcile), **ring definitions**, maintenance windows, SUSE/Power/Qualys footprint, snapshot capability |
| **1 — Satellite content lifecycle** | Content Views, **Dev/Test/Prod** lifecycle environments, activation keys — the test→promote backbone |
| **2 — AAP inventory** | Satellite dynamic inventory (+ CMDB enrichment) → host groups become patch rings |
| **3 — One patch job template** | Survey-driven; `dnf`/`zypper` update → reboot-if-needed → **validate**; ring schedules |
| **4 — Patch workflow** | Add the **rollback branch** + **ServiceNow change gate** + **CMDB update** |
| **5 — Push-button + major upgrades** | **Insights** remediation; **Leapp** major-upgrade ring with **pre-snapshot** safety net |
| **6 — Extend the estate** | SUSE (`zypper`), Power repos, Qualys integration |

## Supporting Evidence

- **Satellite Content Views + Lifecycle Environments** are the documented mechanism for promoting a
  frozen content version through environments — and for moving a host **back** to a prior version.
- Certified/community collections exist for every integration named here: `redhat.satellite` /
  `theforeman.foreman`, `servicenow.itsm`, `community.general.zypper`, plus Leapp and `boom` tooling.
- **Insights → "Remediate with Ansible"** is a shipping capability included with RHEL — the push-button
  remediation the customer asked about.

## Things to Avoid

- **Don't promise Leapp auto-rollback.** Lead with snapshot-before; it reads as design, not a gap.
- **Don't conflate** major-version upgrade with routine patching — different operation, different safety net.
- **Don't claim Satellite manages SUSE content.** It doesn't; AAP still patches SUSE via `zypper`.
- **Don't model rings as templates.** Rings = inventory groups + schedules + surveys on **one** template.
- **Don't turn Qualys into a fight.** Clarify what they use it for; position AAP as the remediation engine.
- **Don't over-index on Power.** It's a footnote, not a workstream.
- Prefer **`ansible.platform`** modules over legacy `ansible.controller` when describing AAP-as-code.
