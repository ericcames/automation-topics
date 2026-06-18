# Questions to Ask

## Discovery

> Start here — and start by asking him to **teach you his framework**. It signals respect and surfaces the 1:1 mapping.

1. Walk me through your 4-phase framework — what does each phase do today, and what did you build it in?
2. What does "automate config generation" mean for you specifically — golden configs, day-0 provisioning, drift
   remediation, or all of the above?
3. How many devices are in scope, and which platforms (Cisco IOS/NX-OS, Arista, Juniper, Palo Alto, others)?
4. Is the new Ansible-based platform built yet, or still a plan? Is the PHP/Python 4-phase framework in production now?
5. How many people on the team can run or maintain automation today — and what happens when you're on vacation or out?
6. What does the organization require as **evidence of who changed what, when** — and are changes approved before they run?

## Depth Probes

> Use when discovery opens a door. These are designed to let *him* notice the gap.

1. When you say "build it myself" — who owns the CVEs in your orchestration code, your Python/PHP, and the Galaxy
   collections you pull? Who patches them, and on what timeline, for a life-safety system?
2. If the auto-rollback itself fails *during* a live outage at 2 a.m., what's the support path? Who's the second person
   who understands it well enough to fix it under pressure?
3. You're building on RHEL rather than compiling your own Linux — what drove that choice? (Then: doesn't the same
   reasoning apply one layer up, to the automation engine?)
4. You're already running Ansible Core, which is our upstream — what specifically would you be building that AAP's
   workflows + Event-Driven Ansible don't already give you, supported?
5. If you're promoted again or move on, what's the plan for the platform you built? Who inherits it?
6. How are you thinking about using AI here — to write automation content, or to generate the platform itself? (Then:
   who reviews and owns AI-generated platform code nobody else has read?)

## Qualification

1. Is the cost concern a hard budget ceiling, an open-source preference, or about owning what you built? (Often all three.)
2. Who actually signs off on this decision — and who is accountable if a change causes an outage?
3. What would you need to see to believe a supported platform runs your 4-phase flow as-is? (Teeing up the proof-of-value.)
4. If we ran your exact pre-validate → push → post-validate → rollback flow as a workflow on a handful of your real
   devices, would that be a fair test of build-vs-buy for you?
5. What's the timeline — when do you need automation running against production, and how does that compare to your
   build-it-yourself estimate?
