# Talking Points

## Opening Frame

"AAP isn't trying to replace your CI system — it handles the infrastructure automation layer that CI tools aren't built for. The goal today is to understand where you are and whether there's a specific gap we can actually solve."

This framing signals respect for what they already have and focuses the conversation on fit rather than features.

## Key Messages

1. **AAP complements CI tools, it doesn't replace them.**
   Your build, test, and artifact stages stay in Jenkins/GitLab CI/GitHub Actions. AAP handles provisioning, configuration, and post-deploy validation — the things that require idempotency, RBAC, and audit trails.

2. **Webhooks and the AAP API make integration straightforward.**
   A job template can be triggered by a webhook or API call from any CI system. The pipeline doesn't care that AAP is on the other end — it's just an HTTP call with a callback.

3. **Event-Driven Ansible (EDA) adds a reactive layer.**
   Rather than only running when a human or pipeline triggers it, EDA can listen to events — alerts, cloud events, Kafka topics — and trigger automation in response. This is the step beyond scheduled or pipeline-driven runs.

4. **RBAC and audit trail are built in, not bolted on.**
   SSEs running automation in pipelines often hit the question: who ran what, when, and with what credentials? AAP gives you job history, credential vaulting, and role-based access without custom tooling.

## Supporting Evidence

- Webhook integration is documented for GitHub, GitLab, Bitbucket, and Gitea out of the box
- EDA Controller GA'd in AAP 2.4; has been in production deployments since then
- Execution Environments (EE) give reproducible Ansible runs — same behavior in the pipeline as on the developer's laptop

## Things to Avoid

- Don't lead with features — lead with questions. SSEs disengage fast when they feel like they're being pitched at.
- Don't position AAP as a replacement for their CI tool — it will immediately raise a "we already have Jenkins" objection that's hard to recover from.
- Avoid the word "agentless" unless they bring it up — it's overused and SSEs know it.
- Don't claim EDA solves problems you haven't confirmed they have yet.
