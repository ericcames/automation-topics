# Session: Dynatrace workflow → AAP 2.6 EDA event stream

| Field | Value |
|-------|-------|
| Date | 2026-05-19 |
| Audience type | `internal` |
| Topic | Dynatrace SaaS Workflows to AAP 2.6 EDA (event stream); on-prem OpenShift needs EdgeConnect |
| Format | Hands-on integration test |
| Contributors | Auto (Cursor) |

## Goal

Send workflow data from Dynatrace to an AAP **event stream** and verify it in **Event streams → Details** (Body), without deploying OneAgent.

## Current status (2026-05-19)

| Approach | Status | Doc |
|----------|--------|-----|
| **Option 1** — static JSON in **Event data** | **In use** | [resources.md § Option 1](resources.md#option-1-static-event-data-in-use) |
| **Option 2** — **Run JavaScript** + `fetch` POST | **Deferred** | [resources.md § Option 2](resources.md#option-2-deferred-run-javascript--fetch-post) |
| **EdgeConnect** (SaaS → on-prem OpenShift) | **Required for on-prem** | [resources.md § EdgeConnect](resources.md#edgeconnect-dynatrace-saas--aap-on-openshift-on-prem) |

## Files

| File | Purpose |
|------|---------|
| [context.md](context.md) | Integration path, UI constraints discovered in testing |
| [objectives.md](objectives.md) | Done vs deferred success criteria |
| [talking-points.md](talking-points.md) | Option 1 steps (beginner-friendly) |
| [questions.md](questions.md) | Open questions |
| [resources.md](resources.md) | Payloads, troubleshooting, Option 2 script for later |
| [cribnotes.md](cribnotes.md) | Hub/settings reference (from personal crib sheet, redacted) |
| [notes.md](notes.md) | Session capture |
