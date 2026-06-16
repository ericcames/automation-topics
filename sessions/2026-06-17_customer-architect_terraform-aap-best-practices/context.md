# Context

## Audience Profile

A **mixed room**: the **Red Hat account team** plus the **customer**. The conversation is **architect-led**
— the customer asked broadly for "Terraform + AAP best practices," which is a *where-does-each-tool-fit*
and *how-do-they-hand-off* question, not a single feature ask. So **open at architecture altitude**
(the boundary model, who owns state) for the architects and the account team, and keep **SSE-level
mechanics** (collection modules, execution environments, inventory plugins) ready in a **go-deep**
section for the operators in the room.

It's a **30-minute** slot. Budget roughly: ~10 min on the boundary picture + the state rule, ~12 min on
the integration patterns and discovery, ~8 min on next steps. Leave the materials behind as a reference.

## Topic Background

The customer wants **best practices for using Terraform and AAP together**. The cleanest framing comes
straight from field experience (notes captured below): the two tools are **complementary, not
competing**, and the friction people hit is almost always about **boundaries** (which tool owns what)
and **state** (who is allowed to write it).

Red Hat ships **Red Hat Ansible Certified Content** for this exact integration — the **`hashicorp.terraform`**
collection — which lets AAP **orchestrate Terraform Cloud / Enterprise** (workspaces, runs, configuration
uploads, outputs, plan views). For open-source `terraform` CLI workflows, the **`cloud.terraform`**
collection plus a **Terraform-enabled execution environment** runs the binary from AAP. Both are covered
in [talking-points.md](talking-points.md); which one fits depends on discovery (see below).

## The source notes (field input, generalized)

These are the working principles this session is built on — captured from HashiCorp field input and
prior POC experience. They are the spine of the "best practices" the customer asked for:

| Principle | What it means in practice |
|-----------|----------------------------|
| **Terraform is immutable** | You replace, you don't mutate. Change = new resource, not in-place edits. |
| **Terraform depends on high-quality APIs** | It's only as good as the provider behind the target. Great in cloud; thin or absent for a lot of datacenter gear. |
| **Use Terraform to build *and tear down* the OS** | Terraform owns the full lifecycle of the infrastructure and the base OS — create through destroy. |
| **Datacenters lack high-quality APIs → use AAP** | Where there's no good Terraform provider, AAP/Ansible is the automation. (Note: there *is* a provider for OpenShift / Kubernetes.) |
| **Do not write to the Terraform state file with AAP** | AAP reads Terraform outputs; it never writes state. One owner of state. |
| **Use AAP to do everything after the OS install** | Configuration, patching, hardening, app deployment, day-2 — all AAP. |
| **Build your images with AAP** | Golden images / templates are produced by Ansible automation. |
| **Deploy your images to environments with AAP** | AAP promotes/deploys those images across environments. |

## The boundary, said plainly

- **Terraform = the "build the box and take it away" layer.** Provision and deprovision infrastructure
  and the OS, declaratively, where a high-quality API exists. It is the **system of record for what
  infrastructure exists** (the state file).
- **AAP = the "make the box useful and keep it that way" layer.** Everything after the OS is up:
  configuration, app deploy, patching, compliance, orchestration — **and** the systems Terraform can't
  reach because they have no decent provider.
- **The handoff is one-directional on state:** Terraform produces outputs (IPs, hostnames, IDs); AAP
  **consumes** them to build inventory and target work. AAP results do **not** flow back into state.

## Likely Assumptions They're Walking In With

- *"Terraform and Ansible overlap — we have to pick one."* — No. They own **different phases**.
  Overlap only happens when you push one past its boundary.
- *"We can have Ansible update the Terraform state so everything's in sync."* — **Don't.** That's the
  fastest way to corrupt state and create drift. AAP reads outputs; Terraform owns state.
- *"Terraform can manage all our infrastructure."* — Only where there's a good provider. Legacy network,
  storage, and appliance gear in the datacenter often has none — that's AAP's lane.
- *"Ansible can also provision, so let's just use Ansible for everything."* — Ansible *can* provision,
  but you lose Terraform's declarative plan/state model for infra lifecycle. Use each where it's strongest.

## Potential Concerns or Objections

- **"Isn't this two tools to maintain?"** — Yes, deliberately: a declarative infra tool and a procedural
  config/orchestration tool, each best-in-class for its phase. The certified collection makes the seam
  between them supported, not bespoke glue.
- **"Who runs Terraform — a pipeline or AAP?"** — Both patterns are valid. AAP can *orchestrate*
  Terraform (certified collection), or a CI/CD pipeline runs Terraform and *hands off* to AAP. Pick per
  their existing pipeline maturity (discovery).
- **"We use open-source Terraform, not Cloud/Enterprise."** — Then the certified `hashicorp.terraform`
  modules (which target TFC/TFE) don't apply directly; you drive the CLI via `cloud.terraform` in an EE
  and manage state with a remote backend. Cover both — see discovery.
- **"Where does state actually live?"** — Must be **remote and locked** (TFC/TFE, or a remote backend
  like S3+DynamoDB / Azure Storage). Never local, never two writers.
