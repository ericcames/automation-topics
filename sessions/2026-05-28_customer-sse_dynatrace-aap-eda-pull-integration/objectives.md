# Objectives

## Primary Goal

Agree on the **pull** architecture (EDA polls Dynatrace) and confirm **EdgeConnect is not needed** for it — then commit to a plan that **builds in the 2.6 test environment** and **promotes the proven config to 2.5 production**.

## Secondary Goals

- Define the **trigger use case**: which Dynatrace problems (severity, tag, management zone) should fire, and **what automation** they run (which Controller job template / playbook).
- Pin down the **connectivity + security inputs**: OpenShift egress (and proxy), Dynatrace API token scope, and credential storage in AAP.

## What Success Looks Like

- In **2.6 test**: a **rulebook activation** runs `dt_esa_api`, polls the tenant, and a synthetic Dynatrace problem causes the activation to fire and **launch a job**.
- Customer agrees the **promotion path** (credential → decision environment → rulebook/project → activation) to 2.5 production.
- A short list of prod prerequisites is captured (egress confirmed, token issued, EDA controller/DE ready).

## What We Want to Learn

- Is the **2.5 production** AAP on OpenShift or VMs, and is it privately routed? (Affects only push; egress still matters for pull.)
- **Egress path** from each environment to `*.live.dynatrace.com` — direct or via proxy?
- **Target remediation** for the first use case — what's the highest-value problem→playbook pairing?
- **EDA version/parity** between 2.5 and 2.6, and decision-environment registry access in prod.
- Does the customer also want Dynatrace **Workflows** to orchestrate later (which would reintroduce the push path + EdgeConnect)?
