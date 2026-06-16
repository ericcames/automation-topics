# Objectives

## Primary Goal

Get agreement on a **phased target architecture** for RHEL patching on AAP where teams **build and
validate in a test ring and then promote the *same* content to production** — with a **credible
rollback story**, **staggered ring-based rollout**, **Satellite-driven inventory/content**, and
**ServiceNow** woven into the patch workflow.

## Secondary Goals

- **Qualify the Satellite opportunity** — position Content Views + Lifecycle Environments as the
  enabler for test→promote, content-version rollback, and host grouping (not as extra overhead).
- **Separate the two rollback conversations** cleanly: routine patching (reversible) vs Leapp
  major-version upgrade (snapshot-before / restore-on-failure).
- **Right-size the schedule model**: one job template + many schedules + surveys, instead of template
  sprawl.
- **Confirm the ServiceNow integration shape**: change-request gate → patch tasks → CMDB update → close.
- **Surface push-button remediation** (Red Hat Insights) and where Qualys fits alongside it.

## What Success Looks Like

- The customer agrees the **ring/promote** model (test ring validated → promote the same CV version to
  prod) is the right backbone.
- They accept the **honest rollback framing** (snapshot-before for Leapp; CV-revert/snapshot/`dnf
  history undo` for routine) and want to see the **AAP workflow with a rollback branch** as a demo.
- A **Satellite proof-of-concept / pilot ring** is on the table as the concrete next step.
- We leave with the **estate facts** needed to size phases (counts per OS/arch, schedule count today,
  change-approval flow, snapshot capability, Insights entitlement, Qualys role).

## What We Want to Learn

- **Scale & shape:** how many RHEL vs SUSE vs Power hosts; how many distinct patch schedules exist today.
- **Cadence reality:** which groups patch on which rhythms (the "not always every 2 weeks" detail).
- **Change management:** is a ServiceNow **change request + approval** a hard gate before patching?
- **Rollback substrate:** can hosts be snapshotted (hypervisor/LVM/`boom`)? On OCP-hosted VMs? Bare metal?
- **Major upgrades:** is RHEL 7→8 (Leapp) actually in scope soon, or was it just the rollback example?
- **Insights & Qualys:** do they have Insights entitlement (it ships with RHEL)? What exactly are the
  "Qualys repos" — content mirrors, or scan/agent data?
- **Source of truth:** who owns CMDB accuracy, and how far does it drift from reality today?
