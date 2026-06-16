# Session: Terraform + AAP best practices — the provisioning/configuration boundary

| Field | Value |
|-------|-------|
| Date | 2026-06-17 |
| Audience type | `customer-architect` |
| Topic | **Terraform + Ansible Automation Platform (AAP) best practices** — where each tool's job starts and stops, how they hand off cleanly, and who owns state |
| Format | 30-minute customer + account-team working session — **open with the boundary picture, then go deep** on the integration mechanics. Built to be left behind as a reference for both the customer and the account team |
| Contributors | Claude (Claude Code) |

## Goal

Give the customer and the account team a **shared, opinionated mental model** for using Terraform and
AAP together: **Terraform provisions and tears down infrastructure + the OS** (declarative, immutable,
where the platform exposes high-quality APIs); **AAP does everything after the OS** (configuration,
day-2, orchestration) **and covers the systems Terraform can't** (datacenters that lack good APIs).
Land the single most important rule — **one system owns state** — and leave with the discovery facts
needed to recommend a concrete integration pattern.

## The one-sentence version

> **Terraform builds the box; AAP makes it useful — and AAP never writes Terraform's state file.**

## The boundary in one picture

```
        TERRAFORM  (declarative, immutable)        |        AAP / ANSIBLE  (procedural, day-2)
  ------------------------------------------------ | --------------------------------------------------
  • Provision & deprovision infrastructure         |  • Everything AFTER the OS is up
  • Stand up / tear down the OS                     |  • Configure, patch, harden, app deploy
  • Cloud / platforms with high-quality APIs        |  • Datacenter gear with weak / no Terraform APIs
  • Owns the STATE FILE  ───────────────────────►  |  • READS Terraform outputs, NEVER writes state
  • Build images (with AAP) → Terraform deploys     |  • Builds the images; deploys to environments
```

## Two best practices that do the most work

1. **Pick the tool by the API, not by habit.** Terraform depends on high-quality provider APIs. Public
   cloud and platforms like OpenShift have them — Terraform is the right hand there. Much datacenter
   gear (legacy network, storage, appliances) does **not** — that's AAP's job. Drawing the line by
   "where's the good API?" resolves most "which tool?" arguments before they start.
2. **One system owns state.** Terraform owns the state file. AAP **consumes outputs read-only** (via the
   certified collection's `output` module or a Terraform inventory plugin) and **never writes back**.
   Two writers to one state = drift and corruption. This is the rule most worth saying out loud.

## Files

| File | Purpose |
|------|---------|
| [context.md](context.md) | Audience, the boundary model, the source notes, walk-in assumptions |
| [objectives.md](objectives.md) | What we want to achieve and how to measure it |
| [talking-points.md](talking-points.md) | Opening frame, key messages, integration-pattern deep dive |
| [questions.md](questions.md) | Discovery, depth probes, qualification |
| [resources.md](resources.md) | Certified collection, modules, EE pattern, docs |
| [notes.md](notes.md) | Post-conversation capture (fill in after) |
