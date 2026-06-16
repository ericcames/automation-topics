# Questions to Ask

## Discovery

1. Roughly how many hosts are we patching, and what's the split across **RHEL**, **SUSE**, and
   **architectures** (x86_64 vs the RHEL-on-Power boxes)?
2. How many **distinct patch schedules** exist today, and what drives the different cadences (the "not
   always every 2 weeks" detail)? What does a typical maintenance window look like?
3. Is a **ServiceNow change request + approval** a hard gate before patching today, or aspirational?
4. How do you decide *what* gets patched — Qualys findings, a fixed cadence, advisories, something else?
5. What's your **source of truth** for inventory today, and how far does the **CMDB** drift from reality?

## Depth Probes

1. The RHEL 7→8 example — is a **major-version upgrade (Leapp)** actually on the near-term roadmap, or
   was that the illustration for the rollback question? (Changes the safety-net design.)
2. Can hosts be **snapshotted** cheaply — hypervisor snapshots, **LVM + `boom`**, OCP-hosted VMs, bare
   metal? This decides how robust "set 1 host down a version" can be.
3. For SUSE: do you need **content management** for it (SUSE Manager/Uyuni), or is **patch orchestration
   via AAP `zypper`** enough for now?
4. What exactly are the **"Qualys repos"** — content mirrors you patch *from*, or Qualys Cloud Agent /
   scan data you patch *in response to*?
5. Do you have **Red Hat Insights** entitlement active (it ships with RHEL)? Would push-button
   "Remediate with Ansible" land with your change process?
6. When a patch run fails on a host, what should happen **automatically** vs require a human — auto
   rollback, auto ticket, hold the ring?

## Qualification

1. What's the appetite and **timeline for adopting Satellite**? Could we stand up a **pilot ring**
   (a Content View + Dev/Test/Prod lifecycle on a small host group) as the first concrete proof?
2. What would make this a **win** for you in 90 days — fewer schedules, a provable test→prod gate, a
   working rollback demo, CMDB accuracy?
3. Who owns this end-to-end on your side, and who needs to sign off on the **change-management**
   integration?
