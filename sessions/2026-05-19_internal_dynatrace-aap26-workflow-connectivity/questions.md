# Questions

## Answered

- **Is EdgeConnect required for on-prem?** Yes for **Dynatrace SaaS → AAP on private OpenShift** in the usual case. EdgeConnect is a **Dynatrace** component (not AAP); deploy it where it can reach the AAP **Route** URL. See [resources.md § EdgeConnect](resources.md#edgeconnect-dynatrace-saas--aap-on-openshift-on-prem).

## Open

- EdgeConnect deployment namespace, HA, and proxy settings for this cluster?
- Which trigger type for production remediation—Problem, Event, or Schedule?
- Will remediation target **Controller job templates**, **EDA rulebooks**, or both?
