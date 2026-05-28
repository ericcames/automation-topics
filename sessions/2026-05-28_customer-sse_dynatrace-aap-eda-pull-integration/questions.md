# Questions to Ask

## Discovery

1. When Dynatrace detects a problem today, what happens — manual triage, a webhook somewhere, nothing? What's the highest-value problem you'd want AAP to act on first?
2. Is the **2.5 production** AAP on OpenShift or on VMs, and is it on a private network? (Pull doesn't need inbound, but it tells us the egress story.)
3. From the OpenShift cluster (and the prod network), is **outbound HTTPS to the internet** allowed, and does it go through an **egress proxy**?
4. Who owns the **Dynatrace tenant** and can issue an **access token** scoped to read problems?

## Depth Probes

1. What should the trigger condition be — severity, a **management zone**, a tag, an affected entity/service? How do we keep it from firing on noise?
2. Should the action be a **Controller job template** (your existing remediation) or a **playbook** run directly from the rulebook? Is there a closed-loop step — comment back on the Dynatrace problem?
3. What detection-to-action **latency** is acceptable? That sets the poll interval.
4. Do you also want **Dynatrace Workflows** to orchestrate any of this? (That's the push path and reintroduces EdgeConnect — separate workstream.)

## Qualification

1. Is the goal a **production** capability in 2.5, or a proof in 2.6 test for now? What's the timeline?
2. Who needs to sign off on **token issuance** and **egress** changes — and are those the long pole?
3. After the first use case works, how many problem→automation pairings do you expect to onboard? (Sizing the rollout.)
