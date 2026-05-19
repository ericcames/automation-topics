# Questions

## Topology and platform

- [x] Target: **containerized enterprise on RHEL 10 VMs** (confirmed).
- Will PostgreSQL run on a **RHEL 10 DB VM** in the same datacenter, or remote (cloud RDS, Crunchy on OCP)?
- Is **Crunchy still under consideration**, or can the DB decision default to **RH-aligned external Postgres on RHEL 10**?
- Does “Red Hat supported database” mean **PostgreSQL per AAP docs**, or **EnterpriseDB** per [EDB_Testing](https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing)?
- Is an **EnterpriseDB subscription** already in place or budgeted?

## Database team

- Is **Crunchy PGO** already a supported standard, or would this be a **first** OpenShift database operator adoption?
- Who owns **backup/restore drills** (RPO/RTO)? Who owns **PostgreSQL major upgrades**?

## Requirements

- Required **PostgreSQL major version** (15 vs 16 vs 17)? Any compliance mandate for external backup tooling?
- **HA** expectation for PostgreSQL (active/passive, multi-AZ, synchronous replicas)?
- Expected **automation volume** (jobs/day, hub storage, EDA event rate) for DB sizing?

## Support

- What does the customer expect to open with **Red Hat** vs **internal DBA** vs **Crunchy** support?
- Is there an existing **enterprise DBaaS** (RDS, Azure Database) that could satisfy “external” without Crunchy?
