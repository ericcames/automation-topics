# Resources

## Documentation

- **Satellite — Content Views & Lifecycle Environments** (the test→promote backbone; promoting and
  reverting content versions): Red Hat Satellite "Managing Content" guide.
- **Leapp / in-place upgrade** (RHEL 7→8→9): Red Hat "Upgrading from RHEL 7 to RHEL 8" — note the
  **pre-upgrade snapshot** guidance and that there is **no supported post-commit rollback**.
- **`boom` boot manager + LVM snapshots** — boot into a pre-patch snapshot to roll back kernel-level
  changes (`boom` is shipped in RHEL).
- **`dnf history` / `dnf history undo`** — package-level transaction rollback for simple cases.
- **Red Hat Insights** — Advisor, **Vulnerability**, **Patch**, **Tasks**, and **"Remediate with
  Ansible"** (push-button remediation; included with the RHEL subscription).
- **Image-mode RHEL (bootc)** — *future-state* note: atomic update + **rollback by rebooting to the
  previous image**; worth naming because rollback is their pain point.

## Collections (AAP)

- **`redhat.satellite`** / **`theforeman.foreman`** — Satellite **dynamic inventory** (hosts, facts,
  host groups, host collections, content-view / lifecycle-environment membership) and content modules.
- **`servicenow.itsm`** — change requests, incident/CMDB modules, and ServiceNow **inventory** source.
- **`community.general.zypper`** (and `zypper_repository`) — **SUSE** patch orchestration from AAP.
- **`ansible.builtin.dnf`** / **`dnf` + reboot** — core RHEL patch tasks (prefer **`ansible.platform`**
  over legacy `ansible.controller` when expressing AAP-as-code).

## Demos / runbooks to reference

- **AAP patch workflow with a rollback branch:** patch ring → validation → on-failure (CV revert /
  snapshot restore / `dnf history undo`) + ServiceNow ticket; on-success → promote next ring.
- **Ring-based staggered rollout:** one job template + survey + multiple schedules scoped to Satellite
  host groups; `serial` / job slicing for batch size.
- **ServiceNow-gated patching:** open change → approval gate → patch tasks → update CMDB CI → close.

## Concepts (quick reference)

- **Content View (CV) version** — a frozen snapshot of repository content; you **promote** a version
  across lifecycle environments and can **move a host back** to an earlier version (= "promote to a
  lower version").
- **Lifecycle Environment** — an ordered stage (Library → Dev/Test → Prod) a host is registered to;
  the host only sees content promoted to its stage. This is what gives you **test-before-prod** for free.
- **Host collection / host group** — Satellite groupings that surface in AAP inventory as the **rings**
  operators pick from.
- **Routine patching vs major upgrade** — reversible (`dnf history` / snapshot / CV revert) vs
  snapshot-before-restore-on-failure (Leapp). Keep them separate.

## Internal References

- (Add Red Hat Solution Briefs / battle cards on **AAP + Satellite patch management** and **Insights
  remediation** here — do not link login-gated material in this public repo.)
