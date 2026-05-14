# Questions to Ask

## Discovery

1. Walk me through your current CI/CD pipeline — what tools are in the chain from code commit to production?
2. Where does infrastructure automation live in that pipeline today? Is it automated, or are there still manual steps?
3. Are you using Ansible today — and if so, is it managed through a control plane like Tower or AAP, or more ad hoc?
4. What prompted this conversation — is there a specific problem or project that's driving the interest in AAP?

## Depth Probes

Use these when a discovery answer opens a thread worth pulling:

1. *(If they have manual steps)* Who owns those steps today, and what happens when that person is unavailable?
2. *(If they're using Ansible ad hoc)* What does credential management look like — are secrets handled consistently across the team?
3. *(If they mention events or monitoring)* Have you looked at any event-driven approaches, or is everything triggered by a human or a schedule?
4. *(If they mention a specific tool like Terraform)* How are you drawing the line between what Terraform owns and what Ansible owns?

## Qualification

1. Besides yourself, who else would be involved in evaluating or deciding on something like this?
2. Is there a specific project or timeline that's making this more urgent right now?
3. What would a useful next step look like from your perspective — a deeper technical demo, a proof-of-concept, or something else?
