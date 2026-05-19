# Notes

## Customer decision

- AAP **2.6 containerized enterprise** on **RHEL 10** VMs (not OCP Operator for AAP install).

## Database implication

- Primary recommendation: **Red Hat–aligned external PostgreSQL** on **RHEL 10** (PG 15 for simplest backup/restore alignment with AAP docs).
- Crunchy on OCP remains optional only if mandated; adds cross-platform complexity from RHEL 10 AAP fleet.

## EDB_Testing repo (added later)

- Not in original session; link: https://github.com/Red-Hat-EnterpriseDB-Testing/EDB_Testing
- Separate path: **EnterpriseDB Postgres Advanced Server** + AAP (HA/DR reference), not the same as generic external PostgreSQL in AAP 2.6 install guide.
