# Notes

## Customer decision

- AAP **2.6 containerized enterprise** on **RHEL 10** VMs (not OCP Operator for AAP install).

## Database implication

- **No path recommended yet** — decision is gated on three discovery answers (see [talking-points.md §7](talking-points.md#7-recommendation-framing--conditional-on-discovery-answers) and [questions.md](questions.md)):
  1. RPO/RTO target
  2. Superuser availability for `postgresql_admin_*` (or DBA pre-creates DBs/users)
  3. Whether managed DBaaS (RDS / Azure Database) is in scope
- **PostgreSQL major version is also deferred** — PG 15 aligns with AAP containerized backup tooling but reaches community EOL **Nov 2027**; PG 16/17 requires customer-owned backup. Pick after the backup-tooling decision.
- **HA pattern for any RHEL-VM path must be named** (Patroni, RH HA Add-on, DBaaS-native) before install — "external PG on RHEL VM" without an HA design is not an enterprise answer.
- Crunchy and EDB remain viable where the customer already runs them at scale or where compliance/subscription dictates.

## EDB_Testing repo (added later)

- Not in original session; link: https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing
- Separate path: **EnterpriseDB Postgres Advanced Server** + AAP (HA/DR reference), not the same as generic external PostgreSQL in AAP 2.6 install guide.
