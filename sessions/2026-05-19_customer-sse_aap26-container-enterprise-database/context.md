# Context

## Reference topology

Red Hat’s **container enterprise** model (~12 application VMs + external dependencies) is documented here:

[Container enterprise topology — infrastructure](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a#cont-b-env-a___infrastructure_topology)

Components include (among others): 2× platform gateway, 2× automation controller, 2× automation hub, 2× Event-Driven Ansible, mesh hop + execution nodes, colocated **Redis** on six VMs, **one externally managed database**, and an external **HAProxy** in front of the gateway.

**Important:** In this tested enterprise design, PostgreSQL is already **external** to the AAP component VMs. The architectural choice is not “embedded DB vs external DB” but **who builds, runs, and supports** that external PostgreSQL service.

## The two paths being compared

| Label | What it means |
|-------|----------------|
| **Red Hat–aligned external PostgreSQL** | Customer-provided database host(s) meeting Red Hat requirements (PostgreSQL **15** for the RH-managed-database case; installer can create DBs/users with `postgresql_admin_*` or you pre-create them). Operations follow [Configure an external (customer provided) PostgreSQL database](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-con_configuring-an-external-postgresql-database). RHEL + PostgreSQL subscriptions and platform support follow normal Red Hat channels for those layers. |
| **Customer-operated external PostgreSQL (Crunchy / PGO)** | Same *external* pattern from AAP’s perspective (`*_pg_host`, separate databases per component), but the database tier is operated by the customer using **Crunchy Data PostgreSQL Operator** (or similar) — often on OpenShift. Red Hat supports **AAP** when the database meets documented requirements; **Crunchy cluster lifecycle** (backup, HA, upgrade, tuning) is customer responsibility unless separately contracted. |

Crunchy is **not** a third “Red Hat managed database” product in the container installer; it is one way to implement **customer-provided external** PostgreSQL.

## Customer decision (recorded)

- **Platform:** AAP **2.6 containerized enterprise** on **Red Hat Enterprise Linux 10** VMs (not OpenShift Operator as the primary AAP install path).
- **Install/runtime:** RHEL 10 uses `ansible-core` **2.16** for both the installation program and AAP operation (per container enterprise topology tested configurations).

This favors **Red Hat–aligned external PostgreSQL** on RHEL (dedicated DB VM or existing Postgres service) over adopting **Crunchy on OpenShift** solely to support AAP — unless the customer already has a mandatory enterprise standard for Crunchy and accepts cross-platform **5432** connectivity from the RHEL 10 AAP fleet.

## Not in scope here

- **Operator-based AAP on OpenShift** (different install doc tree; external DB via secrets — see [Configure an external database for AAP Operator](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-configure_an_external_database_for_ansible_automation_platform)).
- **Growth topology** (smaller footprint; may differ in DB placement).
- **Managed PostgreSQL pod** created by the AAP Operator on OCP (contrast only where relevant).
