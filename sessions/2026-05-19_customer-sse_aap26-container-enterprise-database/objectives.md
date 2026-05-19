# Objectives

## Decisions this comparison should support

- [x] Deployment target: **containerized enterprise on RHEL 10 VMs** (customer choice; not OCP Operator for AAP).
- [ ] Choose **database operations owner** (platform team vs DBA vs OpenShift team running Crunchy).
- [ ] Choose **PostgreSQL major version** (15 aligns with simplest AAP backup/restore story; 16/17 external requires customer backup tooling).
- [ ] Define **HA/RPO/RTO** for PostgreSQL independent of AAP app-tier HA.
- [ ] Align **support boundaries** with customer expectations (what opens a Red Hat AAP case vs a database vendor case).

## Success criteria

- SSE can explain the tradeoff in one conversation without conflating “enterprise topology” with “Crunchy on OCP.”
- Architect has a written list of **inventory**, **network** (TCP 5432), and **day-2** differences before install.
