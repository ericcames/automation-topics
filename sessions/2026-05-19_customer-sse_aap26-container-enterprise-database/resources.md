# Resources

## Primary references

| Topic | Link |
|-------|------|
| Container enterprise topology | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a |
| External PostgreSQL (containerized install) | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-con_configuring-an-external-postgresql-database |
| Database inventory variables | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/install-ref_database_variables |
| Back up / restore containerized AAP | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/administer-back_up_and_restore_your_containerized_deployment |
| Tune PostgreSQL | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/optimize-tuning-postgresql |
| External DB (Operator / OCP) | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-configure_an_external_database_for_ansible_automation_platform |

## RHEL 10 (customer platform)

Per [tested system configurations](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a#cont-b-env-a___tested_system_configurations):

- **RHEL 10** (and later 10.x minors) is supported for containerized AAP.
- **ansible-core 2.16** for both installation program and AAP operation on RHEL 10.
- Apply the same per-VM minimums (16 GB RAM, 4 vCPU, 60 GB disk, 3000 IOPS) to each enterprise node group.

Database VM should run a **supported PostgreSQL** version with ICU; aligning the DB host to **RHEL 10** keeps patching and support consistent with the AAP fleet.

## Requirements cheat sheet (from topology doc)

| Item | AAP-managed database | Customer-provided external |
|------|----------------------|----------------------------|
| PostgreSQL versions | **15** | **15, 16, 17** |
| ICU | — | **Required** |
| Backup/restore via AAP containerized utilities | Tied to PG **15** tooling per RH note | **PG 16/17:** use **external** backup/restore processes |
| Enterprise topology DB VM | N/A (external service in diagram) | **1 × externally managed database** (customer operates) |

## Inventory pattern (external — all components)

From [example enterprise inventory](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a#example-inventory-file):

- Omit `[database]` group.
- Set per component: `gateway_pg_host`, `controller_pg_host`, `hub_pg_host`, `eda_pg_host` (and matching database, username, password).
- Optional: `postgresql_admin_username` / `postgresql_admin_password` (superuser) for installer-driven object creation.

## Network (firewall)

Allow **TCP 5432** from each component class to the database host:

- Platform gateway → external database  
- Automation controller → external database  
- Automation hub → external database  
- Event-Driven Ansible → external database  

(Source: network ports table in container enterprise topology doc.)

## Crunchy (customer operator)

- Crunchy Data **PostgreSQL Operator** is a **customer** implementation of “external PostgreSQL,” not a Red Hat substitute for the database VM in the topology diagram.
- Validate: PostgreSQL version, ICU, connectivity from **all** AAP enterprise hosts, backup/restore runbooks, and extensions required by AAP.
- Crunchy documentation: https://access.crunchydata.com/documentation/

## Red Hat EnterpriseDB testing with AAP (not referenced before 2026-05-19)

Public Red Hat testing/validation repo (not a substitute for official AAP install docs):

| Resource | Link |
|----------|------|
| **EDB_Testing** (main) | https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing |
| Quick start (15–30 min paths) | https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing/blob/main/docs/quick-start-guide.md |
| Architecture | https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing/blob/main/docs/architecture.md |
| RHEL with TPA install | https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing/blob/main/docs/install-tpa.md |

**What it is:** Reference implementation for **AAP + EnterpriseDB Postgres Advanced Server** (multi-DC active/passive, EFM, WAL to S3, DR test framework). Prerequisites include an **EnterpriseDB subscription** and **RHEL 9.4+** or **OpenShift 4.12+** (confirm **RHEL 10** alignment with customer platform choice before promising parity).

**How it fits the customer decision:**

| Path | Relation to EDB repo |
|------|---------------------|
| **RH-aligned PostgreSQL** (RHEL Postgres / AAP external PG guide) | Standard [external PostgreSQL](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-con_configuring-an-external-postgresql-database) path — **not** EDB Advanced Server |
| **Red Hat tested EnterpriseDB** | Use **EDB_Testing** patterns; adds **EDB license** + TPA/EFM ops; strongest HA/DR story in repo |
| **Non–RH (e.g. Crunchy only)** | Different from EDB; repo’s OpenShift path uses **CloudNativePG** manifests under `db-deploy/operator/` for EDB clusters — do not conflate “Crunchy” and “EDB” without architecture review |

**Support boundary (important for SSE):** The GitHub org describes **testing and validation**. **EnterpriseDB** commercial support is with EDB; **AAP** with Red Hat; this repo is engineering reference, not a single support contract.

## Related session

Dynatrace → AAP integration (separate topic): [2026-05-19_internal_dynatrace-aap26-workflow-connectivity](../2026-05-19_internal_dynatrace-aap26-workflow-connectivity/).
