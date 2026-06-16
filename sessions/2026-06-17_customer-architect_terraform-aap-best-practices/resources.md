# Resources

## Certified content (share this with the customer)

- **`hashicorp.terraform` — Red Hat Ansible Certified Content** (Automation Hub):
  <https://console.redhat.com/ansible/automation-hub/collections/published/hashicorp/terraform/details>
  AAP-side integration for **Terraform Cloud / Enterprise**. Modules:
  `workspace`, `project`, `configuration_version`, `run`, `output`, `view_plan`.
  Requires Python ≥ 3.10, ansible-core ≥ 2.16, and the `pytfe` library; auth via `TFE_TOKEN`
  (env var or module param — inject it as an **AAP credential**).
- **Upstream source repo:** <https://github.com/hashicorp/terraform-ansible-collection>
- **`cloud.terraform` collection** — for **open-source `terraform` CLI** workflows from Ansible: run
  plan/apply, and a **state-backed inventory plugin** so AAP builds dynamic inventory from Terraform
  outputs. (Use this path when the certified TFC/TFE modules don't apply.)

## Reference implementation (POC)

- **`ericcames/Terraform-Cloud`** — personal POC built at a customer site: Terraform definition files +
  **`playbooks/`**, designed to run from AAP via a **custom Terraform execution environment**
  (`quay.io/zigfreed/hashicorp_terraform_ee`). Concrete example of the "run Terraform from AAP inside a
  pinned EE" pattern. (Audit before sharing externally — confirm it carries no customer-identifying detail.)

## How to run Terraform from AAP (the EE pattern)

- Build a **custom execution environment** with `ansible-builder` that bundles the **`terraform` binary**
  + required **provider plugins** + the relevant collection. **Pin all versions** (Terraform, providers,
  collections) for reproducible, immutable runs.
- Inject `TFE_TOKEN` / cloud credentials as **AAP credentials** (or via **HashiCorp Vault** lookup),
  never in playbook text.

## Key concepts (quick reference)

- **The state file** — Terraform's record of real infrastructure. **One writer (Terraform).** Keep it
  **remote and locked** (TFC/TFE, or S3+DynamoDB / Azure Storage / GCS). AAP **reads outputs**, never writes.
- **Outputs → inventory** — Terraform `output` values (IPs, hostnames, IDs) are the handoff into AAP,
  via the `output` module or a Terraform inventory plugin.
- **Immutable infrastructure** — change by **replacement**, not in-place edit. Build a new image, deploy
  it, retire the old. AAP builds the images; Terraform deploys them.
- **Two integration directions** — (1) **AAP orchestrates Terraform** (job template/workflow drives a
  TFC run or a CLI run), or (2) **Terraform/pipeline hands off to AAP** (inventory plugin, or Terraform
  triggers an AAP job template).
- **Pick the tool by the API** — high-quality provider (cloud, OpenShift) → Terraform; weak/no provider
  (much datacenter gear) → AAP.

## Demos / runbooks to reference

- **AAP-orchestrates-Terraform workflow:** survey → `run` (provision via TFC/EE) → `output` → configure
  job → validate. Add a `view_plan` diff + **approval node** for change review.
- **Pipeline-hands-off-to-AAP:** `terraform apply` in CI → Terraform inventory plugin → AAP configures
  the new hosts.
- **Golden-image flow:** AAP builds image → Terraform deploys image → AAP configures / redeploys (no
  in-place mutation of the immutable layer).

## Internal References

- (Add Red Hat + HashiCorp joint solution briefs / battle cards on **AAP + Terraform** here — do not link
  login-gated or customer-identifying material in this public repo.)
