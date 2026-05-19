# Talking points — database compare/contrast

Audience: **Systems Engineer** planning **AAP 2.6 containerized enterprise** install.

**Customer choice:** AAP on **RHEL 10** VMs (containerized enterprise topology).

Official topology: [Container enterprise topology](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a#cont-b-env-a___infrastructure_topology).

---

## 0. What RHEL 10 changes in the conversation

- Red Hat documents **RHEL 10** (and later 10.x minors) for this deployment model alongside RHEL 9.4+.
- On RHEL 10, install and operation both use **ansible-core 2.16** (RHEL 9 install used 2.14 for install, 2.16 for operation).
- The **enterprise VM count and roles** are unchanged (~12 app/mesh VMs + external DB + external HAProxy).
- **Implication for database:** default recommendation is **external PostgreSQL on RHEL 10** (dedicated VM or shared DB tier), not Crunchy-on-OCP — unless a separate mandate exists.

**Sizing reminder (per VM, each enterprise node):** 16 GB RAM, 4 vCPU, 60 GB disk minimum, 3000 IOPS — plan DB storage separately for four logical databases.

---

## 1. “Red Hat supported database” vs “non–Red Hat supported” — define terms

Red Hat does **not** sell a separate “AAP database SKU.” The customer is really choosing **who deploys and supports PostgreSQL** and **whether the stack matches Red Hat’s documented requirements**.

| Customer language | What it usually means in AAP 2.6 containerized install |
|-------------------|--------------------------------------------------------|
| **Red Hat supported database** | One of **two** RH-oriented paths: **(A)** **PostgreSQL** per official AAP 2.6 container docs (installer `[database]` or **external** PG **15–17** + ICU on RHEL), or **(B)** **EnterpriseDB Postgres Advanced Server** using Red Hat’s public **[EDB_Testing](https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing)** reference (TPA on RHEL, or OpenShift manifests; **EDB subscription** required). |
| **Non–Red Hat supported database** | DB platforms **not** covered by AAP external-DB requirements or EDB testing repo: e.g. **Crunchy-only** mandate without EDB/AAP alignment, unsupported PG versions, missing ICU, or bespoke DBaaS the team will not certify. |

### Third path — EnterpriseDB (Red Hat tested, vendor-licensed)

If the customer says “Red Hat supported” but means **EnterpriseDB**, point them to [Red-Hat-EnterpriseDB-Testing/EDB_Testing](https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing):

- **Pros:** Multi-DC HA/DR patterns, EFM failover hooks, AAP scale scripts during failover, documented RTO/RPO targets, DR test framework.
- **Cons:** **EnterpriseDB subscription** (extra cost vs RHEL PostgreSQL); repo targets **RHEL 9.4+** / **OpenShift 4.12+** — validate **RHEL 10** + **containerized enterprise on VMs** against this repo (may differ from repo’s Operator/TPA-first layouts); **split support** (EDB + Red Hat AAP).
- **Cost:** Typically **higher** than RH-aligned community/PostgreSQL on RHEL because of **EDB licensing** and HA/DR scope (S3 WAL archive, multi-DC).

Do **not** treat EDB_Testing as replacing [container enterprise topology](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a) or [external PostgreSQL install guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-con_configuring-an-external-postgresql-database) until architecture is mapped explicitly.

**Enterprise topology note:** Red Hat’s [enterprise diagram](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/plan-ref_cont_b_env_a#cont-b-env-a___infrastructure_topology) shows an **externally managed database service** (not Postgres on the controller VMs). That aligns with the **external** configuration path, not necessarily omitting a dedicated DB VM.

### Pros — Red Hat–aligned (installer-managed OR external on RHEL meeting requirements)

- **Documented install and upgrade** paths in RH docs.
- **PostgreSQL 15** alignment with “AAP managed database” version line.
- **Containerized backup/restore playbooks** can include **database dumps** when using the RH-documented approach (PG **15** tooling).
- **Support calls** focus on “AAP + conforming database config,” not on third-party operators.
- **Simpler RACI:** Linux/DBA team on RHEL 10; no mandatory OpenShift database platform.
- **Lower third-party licensing** (no Crunchy subscription required).

### Cons — Red Hat–aligned

- Customer still **operates** the database VM (patching, capacity, HA) unless using a managed cloud Postgres built to spec.
- **PostgreSQL HA** (Patroni, failover) is **customer architecture**, not fully prescribed in the enterprise topology diagram.
- **Installer-managed** path locks to **PG 15** and a single `[database]` host pattern; **external** allows PG 16/17 but then **backup/restore must be external** per RH docs.
- Red Hat support does **not** replace a DBA for performance tuning and disaster-recovery drills.

### Pros — Non–Red Hat supported (e.g. Crunchy, bespoke DBaaS)

- Can match **existing enterprise standards** (central OpenShift data services, Crunchy HA, pgBackRest).
- **PostgreSQL 16/17** and advanced HA features if the platform team already runs them.
- Possible **consolidation** with other apps on shared Postgres operator fleets.

### Cons — Non–Red Hat supported

- **Support boundary:** Red Hat → AAP; **customer/Crunchy/cloud** → database cluster issues.
- **Higher integration risk:** ICU, extensions, connectivity from **all** RHEL 10 AAP hosts on **5432**, version skew.
- **Enterprise + RHEL 10 VMs + Crunchy on OCP** = cross-platform networking and ownership overhead.
- **PG 16/17:** must implement **your own** backup/restore; AAP utilities tied to PG 15 story.
- Often **higher license and labor** cost (see below).

### What costs more?

| Cost type | Usually lowest | Usually highest |
|-----------|----------------|-----------------|
| **Infrastructure** | One **RHEL 10 DB VM** (either installer-managed or external Postgres on RHEL) — same ballpark as enterprise topology “+1 DB” | **Crunchy on OCP** (workers, storage, operator) **plus** RHEL 10 AAP fleet **plus** possible **Crunchy commercial** subscription |
| **Licenses** | AAP + RHEL on app VMs + RHEL on DB VM | Above **+ Crunchy** (if not already sunk cost) **+** premium cloud DB features |
| **People / time** | RH-aligned **PG 15** + installer `postgresql_admin_*` or AAP backup playbooks | Greenfield **Crunchy** adoption, custom backup for PG 16/17, cross-team runbooks |
| **Risk / downtime cost** | Conforming config → fewer “unsupported” escalations | Misconfiguration → failed install, failed upgrade, or split support |

**Practical answer for SSE:** For this customer (**AAP enterprise on RHEL 10 VMs**), **Red Hat–aligned external PostgreSQL 15 on a RHEL 10 database VM** is usually **lower total cost** than **Crunchy/non-RH**. **Non-RH** costs more when you include Crunchy licensing, OpenShift database platform effort, and split support—unless Crunchy is already a **sunk cost** across the estate.

**Exception:** If the organization **already** runs Crunchy at scale, marginal **incremental** cost of one more cluster can be small—but **integration and support RACI** cost remains.

---

## 2. Start with what Red Hat already assumes

- Enterprise container install is **multi-VM** (gateway, controller, hub, EDA, mesh, Redis colocation rules).
- Topology table includes **1 × externally managed database** — not PostgreSQL colocated on controller VMs.
- All components reach the DB on **TCP 5432** (see network ports table in the same doc).
- **Do not** put a `[database]` group in inventory when using an external database (installer guidance).
- **External Redis is not supported** for containerized AAP — Redis stays with the documented colocation model.

So the conversation is: **how** you run external Postgres, not whether enterprise uses external Postgres.

---

## 3. Side-by-side (summary table)

| Dimension | Red Hat–aligned external PostgreSQL | Customer external via Crunchy (PGO) |
|-----------|-------------------------------------|-------------------------------------|
| **What it is** | PostgreSQL on RHEL (VM or approved host), provisioned per RH external-DB install guide | PostgreSQL clusters managed by Crunchy Data Operator (often on OpenShift) |
| **PostgreSQL versions (2.6)** | **15** matches “AAP managed database” version line; external allowed **15–17** with ICU | Typically **15–17** if operator version matches; must meet ICU + connectivity requirements |
| **Install complexity** | Lower if using `postgresql_admin_*`: installer creates DBs/users. Moderate if DBAs pre-create objects | Higher upfront: operator install, cluster CRs, secrets, storage class, networking, then AAP inventory `*_pg_*` |
| **AAP install complexity** | Documented inventory vars (`gateway_pg_host`, `controller_pg_host`, etc.) | Same inventory pattern; plus cross-team coordination (OCP ↔ RHEL VMs) |
| **Day-2 operations** | DBA / Linux team: patch PG, disk, backups. AAP **containerized backup/restore** playbooks apply when PG **15** and using RH-documented external setup | Customer owns Crunchy backup (pgBackRest, snapshots), failover, upgrades. **PG 16/17: external backup/restore required** per RH docs |
| **Support boundary** | Red Hat: AAP + RHEL (as entitled). Database: customer unless RHEL for PostgreSQL is in scope | Red Hat: AAP when DB meets requirements. Crunchy/operator/DB cluster: **customer** (unless separate Crunchy/RH consulting) |
| **Infrastructure cost** | +1 (or HA pair) of DB VMs, storage, RHEL + optional RH PostgreSQL subs; predictable VM economics | OCP worker/storage overhead for DB operator; possibly dedicated cluster; license/support for Crunchy if commercial |
| **HA** | Customer implements (Patroni, RH HA patterns, cloud RDS, etc.) — **not** defined in enterprise topology diagram | Crunchy PGO HA is a strength — if team already standardizes on it |
| **Performance tuning** | [Tune PostgreSQL for AAP](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/optimize-tuning-postgresql) + DBA practice | Customer + Crunchy features; validate latency from AAP VMs to OCP DB service |
| **Security / compliance** | Familiar VM hardening, firewall pin **5432** from each AAP component group | Add OCP RBAC, network policies, secrets rotation; audit Crunchy backup encryption |
| **Uninstall / lifecycle** | Customer responsible for dropping DBs/data per RH external DB notes | Customer deletes Crunchy clusters + PVCs; coordinate with AAP uninstall |

---

## 4. Cost (how to talk about it without fake numbers)

**Capital / cloud spend**

- **Both** need highly available automation tier VMs per enterprise diagram (~12 nodes) — database choice does not remove that.
- **Red Hat–aligned DB:** usually **+1–2 database VMs** (or managed cloud PostgreSQL) with storage sized for controller + hub + gateway + EDA schemas.
- **Crunchy on OCP:** cost of **worker nodes, persistent volumes, and operator footprint**; may consolidate if org already runs a shared data services cluster.

**People cost (often dominates)**

- **Red Hat–aligned:** Linux/DBA skills; installer can automate schema/user creation with superuser creds.
- **Crunchy:** OpenShift admin + DBA + AAP admin coordination; higher learning curve if Crunchy is new to the org.

**Licensing**

- AAP subscription is required either way.
- RHEL subscriptions on all component VMs either way.
- Crunchy may add **vendor subscription** depending on edition/support — confirm with customer procurement.

---

## 5. Complexity (install and run)

### Red Hat–aligned external PostgreSQL

**Pros**

- Follows the **example enterprise inventory** in the topology doc (`externaldb.example.org` pattern).
- Clear doc path: [External PostgreSQL for containerized install](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/install-con_configuring-an-external-postgresql-database).
- Installer path with `postgresql_admin_username` / `postgresql_admin_password` (superuser) reduces manual SQL.

**Cons**

- Customer must still **operate** PostgreSQL (patching, backup, HA).
- Four logical databases (gateway, controller, hub, EDA) on one instance — capacity planning required.

### Crunchy (customer-operated external)

**Pros**

- Strong fit if customer **already** standardizes on PGO for Postgres on OpenShift.
- Native HA, backup, and versioning tooling in the Crunchy ecosystem.
- Can host **multiple databases** on one Postgres instance (same as RH external pattern).

**Cons**

- **Platform split:** enterprise AAP on **RHEL VMs** + DB on **OCP** adds network, firewall, and latency paths (5432 from many sources).
- **Support split:** AAP issues vs database cluster issues require clear runbooks.
- **Backup story:** if PostgreSQL **16 or 17**, plan **outside** AAP’s containerized backup utilities (RH documentation).
- Validate extensions (e.g. **hstore** for some Operator external DB upgrades) — confirm against Crunchy image and AAP requirements.

---

## 6. Support and risk

| Risk | Red Hat–aligned external | Crunchy external |
|------|--------------------------|------------------|
| Wrong PG version / no ICU | Install fail or unsupported config | Same — customer must certify stack |
| Weak backup/restore | Mitigated with PG 15 + AAP backup docs | Customer must prove pgBackRest/snapshot restore |
| Upgrade AAP 2.6 → future | Follow RH upgrade guides; DB migration plan | Same + Crunchy version skew matrix |
| Performance bottlenecks | Tune PG + controller per RH optimize guides | Cross-network DB may hide latency until load test |

**Red Hat support** generally covers **Ansible Automation Platform** behavior when the database meets published requirements. It does **not** replace a customer’s database operations team or Crunchy vendor support.

---

## 7. Recommendation framing (with RHEL 10 VMs chosen)

| Customer situation | Lean toward |
|--------------------|-------------|
| **This customer — AAP 2.6 enterprise on RHEL 10 VMs** | **Red Hat–aligned external PostgreSQL 15** on a **RHEL 10** DB VM (or approved external Postgres service meeting RH requirements) |
| Existing OpenShift + Crunchy mandate from central platform team | **Crunchy** only if architecture board accepts RHEL 10 → OCP **5432** dependency; document support RACI |
| Strict RPO/RTO; no K8s DB practice | **RHEL 10 Postgres VM** or cloud RDS — avoid new Crunchy adoption for AAP alone |
| Future move of AAP to **Operator on OCP** | Revisit Crunchy when platform shifts; not required for current RHEL 10 VM decision |

---

## 8. One-line elevator pitch

> Container enterprise already uses an **external** database; choosing “Red Hat–aligned Postgres on RHEL” optimizes for **installer documentation and AAP backup integration**, while choosing **Crunchy** optimizes for **Kubernetes-native database operations** at the cost of **cross-platform complexity and a sharper support boundary**.
