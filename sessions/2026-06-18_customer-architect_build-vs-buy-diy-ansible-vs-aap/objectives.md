# Objectives

## Primary Goal

Lead the engineer to **conclude for himself** that running his automation on a **supported platform (AAP)** is the
better decision than **building and owning his own** — by showing him that his **4-phase framework is already an AAP
workflow**, that he's already made this build-vs-buy call once (RHEL), and that the platform **frees him to do the
high-value work** (config generation) instead of forever maintaining plumbing.

## Secondary Goals

- **Equip the executives** with the one argument they actually need: **key-person / bus-factor risk** on a
  **life-safety** system, plus **supportability** and **accountability** — framed as risk management, not tooling.
- **Equip the sales team** with a non-adversarial play: **honor the engineer's design first**, then qualify scale,
  change-control, and on-call realities — and avoid the traps (feature-dumping, dismissing cost, OSS fights).
- **Answer the cost objection honestly** with a **TCO + cost-of-outage** comparison, not a feature defense.
- **Separate the two questions** cleanly: *who writes the automation content* (him, on either platform) vs. *what
  platform runs it* (the actual decision). Keep config generation off the bargaining table — it's his either way.

## What Success Looks Like

- He **says it himself**: *"This is basically what I was about to build — and I'd own all of it."*
- He accepts the **RHEL analogy** and stops framing this as proprietary-vs-open.
- The **execs** understand the bus-factor / supportability risk and want it quantified.
- We leave with a concrete next step: a **scoped AAP proof-of-value** that runs **his 4-phase flow as a workflow** on
  a handful of his real device types — so he sees his own design running, supported, in an afternoon.
- Nobody felt talked down to — least of all the newly-promoted lead who is, genuinely, good at this.

## What We Want to Learn

- **Scale & vendors:** how many devices, which platforms (Cisco IOS/NX-OS, Arista, Juniper, Palo Alto, other)? Drives
  the certified-collection coverage story and the per-node cost reality.
- **Maturity:** is the new platform truly idea-stage, or is the **PHP/Python 4-phase framework already in production**
  against live infrastructure? Changes the migration vs. redirect approach.
- **Change-control & audit:** what does the org require for evidence of who changed what, when — and approvals?
  (Life-safety + accountability → this is usually a hard requirement that homegrown tooling under-serves.)
- **Team & on-call:** how many people can run/maintain automation today? **What happens when the lead is unavailable?**
- **Budget reality:** is the cost objection a hard budget wall, an OSS preference, pride of authorship — or a mix?
  (We assume a mix and address all three.)
- **What "config generation" means** to him specifically — golden configs, drift remediation, day-0 provisioning?
