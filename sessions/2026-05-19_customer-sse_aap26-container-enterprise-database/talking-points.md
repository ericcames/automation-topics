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

### If the customer raises EnterpriseDB

EDB is a real path but **only if the customer already has an EDB subscription or compliance requires it**. The customer in this session has not raised it, so it is **not** carried as a column in the side-by-side. If it comes up, route to [resources.md → Red Hat EnterpriseDB testing with AAP](resources.md#red-hat-enterprisedb-testing-with-aap-not-referenced-before-2026-05-19) for the deep-dive (pros/cons, cost, repo scope, support RACI).

### Third path — Managed DBaaS (AWS RDS / Azure Database for PostgreSQL)

If "external Postgres" can be a **cloud-managed service**, this is the lowest-day-2-labor option and often the cleanest support RACI:

- **Pros:** Cloud team owns patching, HA (multi-AZ), backup/restore, minor upgrades. TLS by default, IAM-based access (per SKU), monitoring built in. Red Hat → AAP support; cloud provider → DB.
- **Cons:** **No `postgresql_admin_*` superuser** — DBs and users **must be pre-created manually** before AAP install. Verify ICU, required extensions (e.g. **hstore**), and PG version against AAP 2.6 requirements **per cloud SKU and parameter group**. **AAP containerized backup utilities may not integrate** with cloud-managed snapshot lifecycles — accept cloud-native backup as the source of truth.
- **Cost:** Per-vCPU / storage / I/O monthly cost; usually higher than a single RHEL DB VM at low scale, **comparable or lower at enterprise scale** once HA and ops labor are included.
- **Network:** AAP VMs reach the DB endpoint over VPN / Direct Connect / ExpressRoute (or in-cloud) — latency budget must be measured, not assumed.

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

**Cost framing for SSE (not a recommendation):** All else equal, **RH-aligned external PostgreSQL on RHEL** tends to carry lower total cost than **Crunchy** or **EDB** in greenfield estates, because the latter add subscription cost and (for Crunchy) an OpenShift database-platform footprint. This **flips** when:

- The customer **already** runs Crunchy or EDB at scale — incremental cost of one more cluster is small.
- **Managed DBaaS** (RDS / Azure Database) is on the table — operational labor drops, but `postgresql_admin_*` superuser flow does not work and DBs/users must be pre-created.
- **HA / RPO / RTO** is tight — the RH-aligned path's apparent simplicity disappears once you cost a real Patroni or RH HA Add-on build.

Final path selection lives in [§7](#7-recommendation-framing--conditional-on-discovery-answers) and depends on discovery, not on this cost generalization.

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

Three customer-operated paths are compared below. **EDB** is not carried as a column — see [resources.md → EDB](resources.md#red-hat-enterprisedb-testing-with-aap-not-referenced-before-2026-05-19) if the customer raises it.

| Dimension | RH-aligned external PG on RHEL 10 VM | Managed DBaaS (RDS / Azure DB for PostgreSQL) | Crunchy PGO (customer-operated) |
|-----------|--------------------------------------|------------------------------------------------|---------------------------------|
| **What it is** | PostgreSQL on RHEL 10 VM(s) per RH external-DB install guide | Cloud-managed PostgreSQL consumed via endpoint | PostgreSQL clusters managed by Crunchy Data Operator on Kubernetes |
| **PostgreSQL versions (2.6)** | **15** aligns with “AAP managed database” line; external allowed **15–17** with ICU | **15–17** depending on SKU; verify ICU + required extensions per AAP docs | **15–17** if operator version matches; verify ICU + required extensions |
| **Install complexity** | Lower with `postgresql_admin_*`; moderate if DBAs pre-create objects | Higher: **no true superuser** → DBs/users **pre-created manually**; secrets + endpoint mgmt | Higher upfront: operator install, cluster CRs, secrets, storage class, networking |
| **AAP install pattern** | Inventory `*_pg_host` vars; omit `[database]` group | Same inventory vars; pre-create runbook required | Same inventory vars; plus cross-team coord (K8s ↔ RHEL VMs) |
| **Day-2 ops** | DBA / Linux team: patch PG, disk, backups, HA | **Cloud team** owns patching, HA, backups — least operational labor of the three | Customer Crunchy ops: pgBackRest, failover, upgrades |
| **HA** | **Customer must design** — Patroni / RH HA Add-on / streaming repl. See [Appendix A](#appendix-a-ha-pattern-decision-must-commit-before-install) | **Cloud-native multi-AZ failover** — strongest of the three on this dimension | Crunchy PGO HA is a strength if team standardizes on it |
| **Backup / restore** | PG 15: AAP containerized backup utilities. PG 16/17: **customer-owned** | Cloud-managed snapshots; **may not integrate** with AAP backup playbooks — accept cloud-native backup as source of truth | Customer pgBackRest / snapshots; PG 16/17 customer-owned |
| **Support boundary** | Red Hat: AAP + RHEL. DB: customer (unless RH PG sub in scope) | Red Hat: AAP. DB: **cloud provider** — often the cleanest RACI | Red Hat: AAP when DB meets reqs. DB cluster: **customer** (or Crunchy commercial) |
| **Infrastructure cost** | +1–2 DB VMs + storage; predictable VM economics | Cloud DB monthly cost (per-vCPU / storage / I/O); HA and ops labor included | OCP worker + PV cost; possible Crunchy commercial subscription |
| **Performance tuning** | [RH tuning guide](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.6/html/optimize-tuning-postgresql) + DBA practice | Limited tuning surface; parameter groups / SKU upgrades | Customer + Crunchy features; validate latency from AAP VMs |
| **Security / compliance** | VM hardening, 5432 firewall pin, TLS to DB | Cloud IAM, security groups / NSGs, private endpoints, TLS by default | OCP RBAC, network policies, secrets rotation, audit Crunchy backup encryption |
| **Network path** | AAP VMs → DB VM on 5432 (same DC) | AAP VMs → cloud endpoint (**VPN / Direct Connect / ExpressRoute latency matters**) | AAP VMs → K8s service / external LB on 5432 |
| **`postgresql_admin_*` flow** | **Available** if DBA team accepts | **Not available** — managed PG denies true superuser | Possible if operator configured; usually pre-create |
| **Uninstall / lifecycle** | Customer drops DBs/data per RH external DB notes | Customer destroys DB instance via cloud console / IaC | Customer deletes Crunchy clusters + PVCs; coordinate with AAP uninstall |

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

## 7. Recommendation framing — conditional on discovery answers

**Do not pre-commit to a path.** The recommendation depends on three answers the customer has not yet given (see [questions.md](questions.md) and the open items in [objectives.md](objectives.md)):

1. **RPO/RTO target** — does the database need RPO ≈ 0 / RTO < 5 min, or is overnight-backup RPO acceptable?
2. **Superuser availability** — will the DBA team hand `postgresql_admin_*` superuser credentials to the installer, or must databases and users be **pre-created** by the DBA team?
3. **DBaaS on the table?** — Is **AWS RDS** / **Azure Database for PostgreSQL** a viable host (ICU + version + required extensions met), or is the database constrained to **customer-operated** hosts (RHEL VM, Crunchy, EDB)?

### Decision tree

| If… | Then lean toward | Watch out for |
|-----|------------------|---------------|
| RPO/RTO tight **and** DBaaS allowed **and** managed PG meets AAP requirements (version, ICU, extensions) | **Managed DBaaS** (RDS / Azure Database) | `postgresql_admin_*` superuser flow is **not** available — DBs/users must be pre-created; verify ICU, hstore, and TLS cert chain |
| RPO/RTO tight **and** DBaaS not allowed **and** team already operates Patroni / RH HA Add-on / Crunchy PGO | **The HA stack the team already runs** — RH-aligned PG on RHEL with a *named* HA pattern, or Crunchy if it is the standard | HA design must be committed and tested **before** AAP install; Crunchy adds cross-platform 5432 + support RACI |
| RPO/RTO relaxed (overnight backup acceptable) **and** superuser available | **RH-aligned external PG on RHEL 10 VM**, installer-driven object creation via `postgresql_admin_*` | PG **15** EOL **Nov 2027** — pick PG version with an upgrade plan; DR (cross-site) is still customer-owned |
| RPO/RTO relaxed **and** superuser blocked by DBA policy | **RH-aligned external PG on RHEL 10 VM**, DBAs **pre-create** databases/users | Install runbook must include pre-create SQL; verify ICU and required extensions before install date |
| Customer already runs Crunchy at scale with an existing operations team | **Crunchy** — leverages sunk cost; not justified by AAP alone | Confirm latency and connectivity from **all** enterprise AAP hosts; document AAP vs Crunchy support boundary |
| EnterpriseDB subscription already in place or compliance requires it | **EDB path** — see [resources.md → EDB](resources.md#red-hat-enterprisedb-testing-with-aap-not-referenced-before-2026-05-19) for pros/cons, repo scope, and support boundary | Validate **RHEL 10** + **containerized enterprise on VMs** against repo's tested configurations; support is split (Red Hat AAP + EDB) |
| Future move of AAP to **Operator on OCP** | Revisit DB path when platform shifts; not a driver for the current RHEL 10 VM decision | Do not pre-buy Crunchy now in anticipation |

### What this section deliberately does NOT recommend

Until the three discovery answers are in, this brief does **not** recommend:

- A specific PostgreSQL major version (15 vs 16 vs 17 depends on the backup-tooling decision in [objectives.md](objectives.md))
- A specific HA pattern for the RH-aligned path (Patroni vs RH HA Add-on vs DBaaS-native)
- Whether to use `postgresql_admin_*` superuser or pre-create databases/users

Locking these in before discovery skips the questions that change the answer.

---

## 8. One-line elevator pitch

> Container enterprise already uses an **external** database; choosing “Red Hat–aligned Postgres on RHEL” optimizes for **installer documentation and AAP backup integration**, while choosing **Crunchy** optimizes for **Kubernetes-native database operations** at the cost of **cross-platform complexity and a sharper support boundary**.

---

## Appendix A — HA pattern decision (must commit before install)

The "RH-aligned external PG on RHEL VM" recommendation is **not complete** until an HA pattern is named. Without one, "external Postgres on a RHEL VM" is a single point of failure under the most critical AAP component.

| HA pattern | What it is | Best fit when… | Watch out for |
|-----------|-----------|----------------|----------------|
| **Single VM, no HA** | One Postgres instance, backups only | Lab / dev / non-prod tier; RPO/RTO ≥ overnight | Not an enterprise prod answer |
| **Streaming replication + manual failover** | Primary + ≥ 1 standby, async (or sync); manual promotion | Customer has Linux team but no Patroni experience; RTO measured in tens of minutes | Promotion runbook + tested; client reconnect behavior on the AAP side |
| **Patroni + etcd / Consul** | Automated leader election + failover | Team has K8s / etcd experience or willing to operate it; RTO < 5 min target | etcd cluster availability becomes its own dependency |
| **RH HA Add-on (Pacemaker + Corosync)** | RHEL-native cluster manager with PG resource agent | Customer already standardizes on Pacemaker for other RHEL HA | Less Postgres-specific tooling than Patroni; fencing must be configured |
| **DBaaS-native (multi-AZ)** | Cloud-managed automatic failover | DBaaS path is selected (see [§3](#3-side-by-side-summary-table)) | Out of scope for "RH-aligned on RHEL VM" — this is a separate path |

**To populate during discovery:**

- [ ] HA pattern selected: ______________
- [ ] Replication topology (sync / async, N standbys): ______________
- [ ] Failover trigger (automated / manual) and **measured** RTO: ______________
- [ ] Cluster-manager owner (etcd / Pacemaker / cloud): ______________
- [ ] DR (cross-site) plan — **separate from HA**: ______________
- [ ] Backup target during failover (primary only? replica-tolerant?): ______________

**Network ports beyond 5432** (add to the AAP firewall plan, since the topology doc covers only 5432):

- Patroni REST API (typically 8008) between PG nodes
- etcd / Consul ports (etcd: 2379/2380; Consul: 8300–8302, 8500)
- Pacemaker / Corosync (UDP 5404/5405; pcsd 2224)
- Replication traffic on 5432 between PG nodes

---

## Appendix B — Preflight checklist (verify before install date)

Stubs — fill in owner and verified date during discovery / preparation. Items here block AAP install if missed.

### Database stack
- [ ] PostgreSQL version selected (**15 / 16 / 17**, gated on backup-tooling decision): ______________
- [ ] ICU enabled and version verified compatible with chosen PG major: ______________
- [ ] Required extensions enabled (confirm full list against AAP 2.6 docs; **hstore** known): ______________
- [ ] Backup target identified and **restore tested** (where dumps land, retention, encryption): ______________
- [ ] HA pattern committed and replication tested (see [Appendix A](#appendix-a-ha-pattern-decision-must-commit-before-install)): ______________

### Access and credentials
- [ ] `postgresql_admin_*` superuser available **OR** pre-create SQL runbook ready (gateway, controller, hub, EDA): ______________
- [ ] Per-component PG users created with their own database + password: ______________
- [ ] Secrets storage for PG creds (Vault / inventory encrypted with `ansible-vault`): ______________

### Network
- [ ] TCP **5432** from each AAP component class to DB endpoint — firewall rule confirmed end-to-end: ______________
- [ ] Replication / cluster-manager ports open between PG nodes (see [Appendix A](#appendix-a-ha-pattern-decision-must-commit-before-install)): ______________
- [ ] DB hostname resolvable from **every** AAP VM (gateway, controller, hub, EDA, mesh): ______________
- [ ] Latency budget **measured** (AAP VMs → DB endpoint, p99 round-trip): ______________

### TLS
- [ ] DB server certificate issued by CA trusted by AAP container trust store: ______________
- [ ] `sslmode` enforced (target: `verify-full`): ______________
- [ ] Certificate rotation plan documented (who, when, how): ______________

### Day-2
- [ ] Restore drill scheduled with owner named: ______________
- [ ] PG major-version upgrade plan documented (especially if PG **15** chosen — EOL Nov 2027): ______________
- [ ] Monitoring / alerting endpoint (connections, replication lag, disk, slow queries): ______________

---

## Appendix C — DB sizing placeholders (collect during discovery)

AAP per-VM minimums (16 GB RAM, 4 vCPU, 60 GB disk, 3000 IOPS) **do not apply** to the database tier. The DB must be sized independently from automation volume and connection counts.

**Inputs to collect:**

| Input | Value | Source |
|-------|-------|--------|
| Jobs / day (peak) | ______ | Customer automation ops |
| EDA events / sec (sustained, peak) | ______ | EDA source teams |
| Hub: collections published / week | ______ | Content team |
| Hub: artifact storage volume | ______ | (separate from DB — object/file store) |
| Concurrent active connections (peak) | ______ | Estimate from controller + gateway + hub + EDA worker counts |
| Retention windows (job events, audit) | ______ | Customer compliance |

**Stub sizing (replace with measured numbers once inputs collected):**

| Resource | Stub | Notes |
|----------|------|-------|
| vCPU | TBD (≥ 8 typical for enterprise) | Scale with concurrent connections + EDA event rate |
| RAM | TBD (≥ 32 GB typical) | Target ≥ working set of all four logical DBs |
| Storage | TBD | Four logical DBs (gateway, controller, hub, EDA) — controller usually dominates with job events |
| IOPS | TBD (3000 is the per-VM **minimum**, not a DB target) | Provision higher for DB tier; measure under expected EDA + job load |
| Connections / pooling | TBD | **Decide pooling strategy** (PgBouncer placement? per-component?) before sizing connections — AAP 2.6 does not ship an opinionated pooler for external DB |
| Network bandwidth (DB ↔ AAP) | TBD | EDA event ingestion can saturate small links |

**Per-environment scaling:** Test, staging, and prod will each have a DB tier. Decide whether non-prod gets HA, what scale, and whether DBaaS is permitted in all environments before committing.
