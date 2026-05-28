# Context

## Audience Profile

Customer **Senior Systems Engineer** who owns/operates Ansible Automation Platform and has a **Dynatrace SaaS** tenant. Comfortable with AAP objects (credentials, projects, templates) and OpenShift. Cares about reliability, security (token scope, egress control), operational ownership of the loop, and a clean path from test to production. Walked in believing **EdgeConnect** is required.

## Topology (as described)

| Environment | Version | Where | Routing |
|-------------|---------|-------|---------|
| Production | AAP **2.5** | on-prem | *confirm* — private? VM or OpenShift? |
| Test | AAP **2.6** | on-prem **OpenShift** | private route |
| Monitoring | Dynatrace **SaaS** | vendor cloud | reachable over the internet (outbound) |

## Topic Background

Goal is **event-driven automation triggered by Dynatrace** — Davis detects a problem, AAP reacts. Two directions exist, and the direction is what decides whether EdgeConnect is needed:

| Direction | Path | Reachability needed | EdgeConnect |
|-----------|------|---------------------|-------------|
| **Push** | Dynatrace Workflows → AAP event stream | SaaS must reach the **private AAP route** (inbound) | **Required** for on-prem |
| **Pull** *(chosen)* | EDA rulebook polls Dynatrace problems API | AAP makes **outbound** HTTPS to SaaS | **Not required** |

**Chosen: pull.** EDA uses the certified `dynatrace.event_driven_ansible` collection's **`dt_esa_api`** source plugin to poll the Dynatrace problems API on an interval, evaluate rulebook conditions, and launch automation (a Controller job template or a playbook).

## Likely Assumptions They're Walking In With

- *"We need EdgeConnect to integrate Dynatrace with AAP."* — True only for the **push** direction. The Dynatrace EdgeConnect docs state it exists to let SaaS reach **private/on-prem endpoints** and is **not** needed when an external system calls Dynatrace APIs. Pull is outbound, so EdgeConnect is out of scope.
- They may picture Dynatrace **pushing** events (the Workflows canvas). Pull moves orchestration/decisioning into **AAP/EDA** instead.

## Potential Concerns or Objections

- **Latency vs push.** Polling adds a poll-interval delay and steady API calls; push (event stream) is near-real-time. Frame the tradeoff honestly.
- **Egress.** Does the OpenShift cluster allow outbound 443 to the Dynatrace tenant, and is there an egress **proxy** to honor?
- **Token security.** Dynatrace API token scope (least privilege) and storage as an AAP credential, never in the rulebook.
- **2.5 production parity.** EDA shipped in 2.5; confirm the EDA controller, decision-environment registry access, and collection version match what we prove in 2.6.
