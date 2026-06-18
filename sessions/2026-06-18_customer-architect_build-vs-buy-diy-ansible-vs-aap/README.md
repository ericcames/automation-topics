# Session: Build vs. buy — a self-built Ansible platform vs. AAP for life-safety network automation

| Field | Value |
|-------|-------|
| Date | 2026-06-18 |
| Audience type | `customer-architect` |
| Topic | A newly-promoted lead network engineer plans to **build his own automation platform** on RHEL with **Ansible Core + AI-assisted code**, instead of adopting **Ansible Automation Platform (AAP)**, citing per-device licensing cost at scale. The work runs in a **life-safety / emergency-call context where outages are not acceptable**. |
| Format | Technical decision-maker working session — **honor what he built, then reframe the decision**. Primary audience is the lead engineer (acting as architect); secondary tracks for **executives** (accountability) and the **Red Hat sales team** (how to position). |
| Contributors | Claude (Claude Code) |

## Goal

Help a capable, dev-minded lead engineer arrive — **on his own and without losing face** — at the conclusion that adopting a **supported automation platform** is the better decision than building and maintaining his own, *especially* in a life-safety context. Do it by **validating his instincts**, not overriding them.

## The one thing to internalize first

He has not decided to skip a platform. He has decided to **build one**. His own **4-phase change framework** —
**(1) pre-validation → (2) push change → (3) post-validation → (4) automatic rollback on failure** — is a
near-exact description of an **AAP workflow job template with success/failure branches plus Event-Driven Ansible
for the rollback trigger**. He has independently reinvented the thing AAP productizes. **That is the opening, and
it is a complimentary one.** See [talking-points.md](talking-points.md).

## Two arguments do the heavy lifting

- **The RHEL analogy (the humane reframe).** He is building this *on RHEL* — he didn't compile Linux From Scratch.
  He already made this exact build-vs-buy call once, for the OS, and chose the supported, hardened, CVE-pipelined
  distribution. **Ansible Core → AAP is the same relationship as Fedora/CentOS Stream → RHEL.** This moves the
  conversation off "proprietary vs. open source" (AAP *is* open source) and onto a decision he's already comfortable making.
- **Bus factor (the exec argument).** A custom orchestrator understood by **exactly one** newly-promoted lead, sitting
  in front of a system where **outages can't happen**, is a single point of failure. The honest question is not about
  money — it's *"who runs the rollback automation at 2 a.m. during an outage when the one person who wrote it is unreachable?"*
  This protects **him** too.

## Files

| File | Purpose |
|------|---------|
| [context.md](context.md) | The audience, the situation, what "build my own AAP" really means, and what AAP actually adds |
| [objectives.md](objectives.md) | What success looks like and what we need to learn |
| [talking-points.md](talking-points.md) | The reframe, the capability map, and per-audience tracks (architect / exec / sales) |
| [questions.md](questions.md) | Discovery, depth probes, and qualification questions |
| [resources.md](resources.md) | Collections, docs, and demo hooks |
| [notes.md](notes.md) | Post-conversation capture (fill in after) |
