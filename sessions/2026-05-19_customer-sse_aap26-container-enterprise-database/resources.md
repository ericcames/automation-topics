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

### Deep dive — when EDB is on the table

(Moved from talking-points.md so the main side-by-side stays focused on the three customer-operated paths in scope.)

- **Pros:** Multi-DC HA/DR patterns, EFM failover hooks, AAP scale scripts during failover, documented RTO/RPO targets, DR test framework. Strongest HA/DR story of any path in this brief.
- **Cons:** **EnterpriseDB subscription** required (extra cost vs RHEL PostgreSQL); repo targets **RHEL 9.4+** / **OpenShift 4.12+** — validate **RHEL 10** + **containerized enterprise on VMs** against this repo (may differ from repo's Operator/TPA-first layouts); **split support** (EDB + Red Hat AAP).
- **Cost:** Typically **higher** than RH-aligned community PostgreSQL on RHEL because of **EDB licensing** plus HA/DR scope (S3 WAL archive, multi-DC).
- **Do not** treat EDB_Testing as replacing the [container enterprise topology](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a) or the [external PostgreSQL install guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-con_configuring-an-external-postgresql-database) until architecture is mapped explicitly to the customer's RHEL 10 + containerized enterprise topology.

## Concepts — quick reference

Background for the technical terms used across [talking-points.md](talking-points.md), particularly Appendix A (HA) and Appendix C (sizing / pooling).

### Patroni + etcd / Consul (PostgreSQL HA)

- **Patroni** is an open-source HA orchestrator for PostgreSQL. A Patroni daemon runs alongside each PG node, monitors health, and automates failover — promote a standby when the primary dies, demote the old primary when it returns, run `pg_rewind` if needed.
- PostgreSQL has streaming replication built in, but **no automatic failover** — promotion is `pg_ctl promote` until something orchestrates it. Patroni is that orchestrator.
- **etcd or Consul** is a distributed key-value store (typically 3 or 5 nodes for quorum) that Patroni uses as its **consensus layer**. Patroni instances ask etcd "who currently holds the leader lock?" to prevent split-brain (two primaries both accepting writes → corruption). etcd holds a short leader lease; whichever node can renew it is primary.
- **Why use it:** if RPO ≈ 0 and RTO < ~5 min are real requirements, manual failover does not meet them. Patroni + etcd is the most common community pattern for sub-minute automatic failover on RHEL VMs without a vendor product.
- **Operational cost:** three layers to operate instead of one — Postgres, the Patroni daemon on each PG node, and the etcd cluster (which itself wants 3 or 5 nodes for quorum).
- **Alternatives:**
  - **RH HA Add-on (Pacemaker + Corosync)** — OS-level cluster manager with a Postgres resource agent. RHEL-native; less Postgres-specific tooling than Patroni; requires fencing.
  - **DBaaS (RDS / Azure DB)** — hides all of this behind a managed multi-AZ flip.
  - **Crunchy PGO** — bakes HA into the Kubernetes operator.
  - **EDB EFM** — EnterpriseDB's failover manager; what the EDB_Testing repo uses.

### PgBouncer (PostgreSQL connection pooler)

- **PgBouncer** is a lightweight connection pooler that sits between clients (AAP components) and Postgres. Clients connect to PgBouncer; PgBouncer maintains a small pool of real connections to Postgres and multiplexes client traffic onto them.
- **Why use it:** each PostgreSQL backend connection costs ~10 MB of RAM and has setup overhead. AAP enterprise has gateway + controller + hub + EDA, each with multiple workers — easily hundreds of would-be connections at peak. PgBouncer lets you serve 500 client "connections" through, say, 50 real Postgres backends.
- **Three pooling modes:**
  - **Session pooling** — client gets a real backend for the life of its connection. Safest; smallest gain.
  - **Transaction pooling** — client borrows a backend per transaction. Big efficiency gain, but **breaks** prepared statements, session-level GUCs (`SET`), and `LISTEN` / `NOTIFY`.
  - **Statement pooling** — per-statement. Rarely usable.
- **The AAP gotcha:** EDA uses `LISTEN` / `NOTIFY` heavily, and some controller code paths rely on session state. **Transaction pooling can break those.** AAP 2.6 does not ship an opinionated pooler for external DB — you cannot drop in PgBouncer in transaction mode and walk away.
- **Decisions to make:**
  - **Placement** — PgBouncer per AAP component host (each AAP node has its own bouncer) or centralized (one bouncer host between clients and DB).
  - **Mode** — start with **session pooling** for AAP safety; only move to transaction pooling after testing each component end-to-end.
  - **Or skip pooling** and size Postgres `max_connections` higher (simpler, less efficient).
