# Context

## Audience Profile

Senior Systems Engineers are hands-on practitioners. They want to understand how something actually works, not just what it does. They care about:

- Integration complexity — how much work is it to wire this in?
- Reliability and idempotency — what happens if it runs twice?
- Operational burden — who owns it, how do we troubleshoot it?
- Fit with what they already have — does this replace or complement their current toolchain?

They will evaluate claims skeptically. Concrete examples and demos carry more weight than slides.

## Topic Background

### AAP 2.6 CI/CD Integration Patterns

AAP is not a CI/CD tool — it is the **infrastructure automation layer** that CI/CD pipelines call into. The key integration patterns are:

**Webhooks (SCM-triggered jobs)**
- AAP job templates and workflow templates can be triggered by GitHub, GitLab, Bitbucket, or Gitea webhooks
- A push or PR merge fires a job in AAP — no polling, no scheduled runs
- Webhook payload can be passed as extra vars

**AAP as a pipeline stage**
- Jenkins, GitLab CI, GitHub Actions, and Tekton all have mechanisms to call the AAP API
- Pattern: build/test stages run in the CI tool; infrastructure provisioning, configuration, and post-deploy validation run in AAP
- AAP handles the "last mile" — the things Ansible does best

**Event-Driven Ansible (EDA) — GA in AAP 2.6**
- EDA Controller listens to event sources (webhooks, Kafka, alerting systems, cloud events)
- Rulebooks define: if this event, run that action (which can be an AAP job)
- Enables reactive automation — CI/CD failure triggers a rollback job, for example

**Key AAP 2.6 Platform Changes**
- Unified platform UI — AAP Controller, EDA Controller, and Private Automation Hub under one login
- Automation Hub improvements — curated content collections, execution environment management
- Workflow editor improvements — conditional branching, approval nodes

### Why SSEs Are Asking About This

Common drivers:
- They're already using Ansible ad hoc or via Tower and want to formalize it in their pipeline
- Their CI system works but infrastructure automation is still manual or fragile
- They're evaluating GitOps approaches and want to understand where AAP fits

## Likely Assumptions They're Walking In With

- "AAP is just a job scheduler, not a real CI/CD tool" — this is largely correct and worth affirming rather than fighting
- "We'd have to rip out Jenkins/GitLab CI to use this" — not true; it's additive
- "Ansible is for config management, not for pipelines" — outdated framing; EDA changes this
- "This will be complex to integrate" — the API and webhooks are well-documented; complexity depends on their environment

## Potential Concerns or Objections

- **Licensing cost** — AAP 2.6 is a subscription product; they may push back on cost vs. open-source alternatives
- **Skill gap** — Ansible/YAML familiarity may vary on their team
- **Overlap with existing tools** — if they're already heavy in Terraform or a config management tool, they'll question the overlap
- **EDA maturity** — EDA GA'd in 2.4; some SSEs will ask about production readiness and scale
