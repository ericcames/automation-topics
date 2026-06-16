# Talking Points

## Opening Frame

"Terraform and AAP aren't competitors — they own **different phases of the same lifecycle**. Terraform's
job is to **build and tear down the box** wherever there's a high-quality API to do it. AAP's job is
**everything after the OS is up** — and everything Terraform *can't* reach because the API isn't there.
The whole 'best practices' conversation comes down to two things: **draw that boundary clearly**, and
**let exactly one system own the state file**. Let's draw the boundary first, then walk the integration
patterns against your stack."

## Key Messages

1. **Complementary, not competing.** Terraform = declarative infrastructure + OS lifecycle. AAP =
   procedural configuration, day-2, and orchestration. Most "which tool?" fights are really
   boundary-drawing problems.
2. **Pick the tool by the API.** Terraform is only as strong as the provider behind the target. Cloud and
   OpenShift have great APIs → Terraform. A lot of datacenter gear doesn't → AAP. "Where's the good API?"
   is the deciding question.
3. **One owner of state — and it's Terraform.** AAP **reads** Terraform outputs to build inventory and
   target work; it **never writes** the state file. Two writers = drift and corruption. This is the rule.
4. **Immutable means replace, not mutate.** Build golden **images with AAP**, have **Terraform deploy**
   them, and when something changes, **roll a new image** rather than hand-editing live infra. AAP keeps
   config in line and **redeploys** rather than patching the immutable layer.
5. **The seam is supported, not glue.** Red Hat ships **certified content** for the integration. You're
   not maintaining brittle wrapper scripts between the two tools.

---

## Deep dive — the integration patterns (the "go deep" section)

> Two questions decide everything here: **(a) which Terraform** are they running, and **(b) which
> direction** does the integration flow. Walk both.

### A) Which Terraform → which collection

| They run… | Use… | What it gives you |
|-----------|------|-------------------|
| **HCP Terraform / Terraform Cloud** or **Terraform Enterprise** | **`hashicorp.terraform`** (Red Hat **certified**) | AAP drives TFC/TFE via API: manage **workspaces** & **projects**, upload a **configuration_version**, trigger a **run** (plan/apply), pull **outputs**, and render a **view_plan** diff. State stays in TFC/TFE. |
| **Open-source `terraform` CLI** | **`cloud.terraform`** + a **Terraform execution environment** | AAP runs the `terraform` binary inside an EE that bundles the binary + provider plugins. State lives in a **remote backend** (S3+DynamoDB, Azure Storage, GCS, etc.). |

The certified **`hashicorp.terraform`** collection requires Python ≥ 3.10, ansible-core ≥ 2.16, and the
`pytfe` library, and authenticates with a `TFE_TOKEN` (env var or module param) — so the token rides in
as an **AAP credential**, not in playbook text. Its modules:

- `workspace` — create/lock/manage workspaces (tags, auto-apply)
- `project` — manage projects (execution mode, auto-destroy policy)
- `configuration_version` — upload Terraform configuration
- `run` — create / plan / apply a run
- `output` — **read** workspace outputs (including sensitive values) — *this is the read-only handoff*
- `view_plan` — fetch/show a plan in diff or JSON form (great for change review / approvals)

### B) Which direction does the integration flow

**Direction 1 — AAP orchestrates Terraform** (AAP is the control plane / front door):
- An AAP **job template** calls the `run` module to apply a TFC workspace (or `cloud.terraform` runs the
  CLI in an EE), then a **second template/workflow node** configures the result. Put a **survey** on the
  front for environment/size; use **workflow** nodes to sequence *provision → configure → validate*.
- Good when: AAP is already the automation hub, they want one pane of glass, approvals/RBAC in AAP.

**Direction 2 — Terraform (or a pipeline) hands off to AAP** (CI/CD owns provisioning):
- A pipeline runs `terraform apply`; AAP then consumes the result. Two clean handoff mechanisms:
  - **Terraform inventory plugin** (`cloud.terraform` / state-backed) — AAP builds **dynamic inventory**
    straight from Terraform state/outputs. No copy-paste of IPs.
  - **Terraform triggers AAP** — the Terraform **AAP/Ansible provider** (or a `local-exec` to the
    Controller API) kicks an AAP job template once infra is up.
- Good when: they already have mature CI/CD running Terraform and just need the configuration handoff.

> **Both directions obey the same rule:** the handoff is **outputs → AAP**, never **AAP → state**.

### Execution environments (the practical "how AAP runs Terraform")

To run Terraform from AAP you need a **custom execution environment** that bundles the `terraform`
binary and the required **provider plugins**, built with `ansible-builder`. **Pin versions** (Terraform
version, provider versions, collection versions) so runs are reproducible — immutability applies to your
*tooling* too. This is exactly the pattern in the reference POC repo (a `hashicorp_terraform_ee` image on
Quay feeding Terraform playbooks) — see [resources.md](resources.md).

### Where each layer's work lives (the boundary, concretely)

| Concern | Terraform | AAP / Ansible |
|---------|-----------|---------------|
| Create/destroy VM, network, load balancer, cloud resource | ✅ | — (only where no provider) |
| Stand up / tear down the OS | ✅ | — |
| OpenShift / Kubernetes objects | ✅ (provider exists) | ✅ (also a strong fit; pick per team) |
| Legacy network / storage / appliance with no good API | — | ✅ |
| Post-OS config, hardening, app deploy, patching, day-2 | — | ✅ |
| Build golden images / templates | — | ✅ |
| Deploy/promote images across environments | deploys what AAP built | ✅ builds & drives promotion |
| **Own the state file** | ✅ **only** | ❌ never writes it |
| Consume IPs/IDs/hostnames as inventory | produces (outputs) | consumes (read-only) |

## Supporting Evidence

- **Red Hat Ansible Certified Content** publishes `hashicorp.terraform` on Automation Hub — a supported,
  jointly-backed integration, not community glue (see [resources.md](resources.md)).
- The collection's **`output`** + **`view_plan`** modules make the **read-only handoff** and **change
  review** first-class — you don't script around the API.
- The **immutable + golden-image** flow (AAP builds → Terraform deploys → AAP configures/redeploys) is
  the standard pattern for keeping the declarative layer clean.

## Things to Avoid

- **Don't let AAP write Terraform state.** Repeat it. Outputs flow out; nothing flows back into state.
- **Don't position the tools as either/or.** They own different phases; "pick one" is the wrong frame.
- **Don't assume the certified collection fits open-source Terraform.** Its modules target **TFC/TFE**.
  For CLI, it's `cloud.terraform` + an EE + a remote backend.
- **Don't let Terraform creep into day-2 config**, or Ansible creep into being the infra system-of-record.
  Each loses its strength at the boundary.
- **Don't store `TFE_TOKEN` / cloud creds in playbooks.** Inject via **AAP credentials** / **Vault**.
- **Don't run Terraform from an unpinned EE.** Pin the binary, providers, and collections for reproducible,
  immutable runs.
- Prefer **`ansible.platform`** modules over legacy `ansible.controller` when expressing AAP-as-code.
