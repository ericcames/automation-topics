# Objectives

## Primary Goal

Leave the room with a **shared, opinionated boundary model** the customer and account team both agree
on: **Terraform provisions/deprovisions infrastructure + OS where good APIs exist; AAP does everything
after the OS and covers what Terraform can't; Terraform owns state, AAP reads outputs read-only.**

## Secondary Goals

- **Land the state rule unambiguously** — one system writes Terraform state (Terraform). AAP consumes
  outputs; it never writes back. If they remember one sentence, make it this one.
- **Position the certified content** — show that Red Hat ships supported integration
  (`hashicorp.terraform` for TFC/TFE; `cloud.terraform` + a Terraform EE for CLI), so the seam between
  the tools is **supported, not bespoke glue**.
- **Map the two integration directions** — AAP-orchestrates-Terraform vs Terraform-hands-off-to-AAP —
  and identify which fits their current pipeline.
- **Reinforce the immutable + golden-image pattern** — AAP builds images, Terraform deploys them, AAP
  configures/redeploys rather than mutating in place.
- **Surface the discovery facts** that decide the concrete recommendation (TF flavor, where state lives,
  target infra, pipeline maturity, secrets handling).

## What Success Looks Like

- The customer can **draw the boundary** themselves by the end: Terraform left of the line, AAP right of
  it, state owned by Terraform, outputs flowing one way.
- They **accept the state rule** and stop any plan to have Ansible write Terraform state.
- They want a **follow-up that maps their stack onto a concrete pattern** — e.g. "AAP job template runs a
  TFC workspace via the certified collection, then a second template configures the result," or "pipeline
  runs `terraform apply`, Terraform inventory plugin feeds AAP."
- The account team has a **reusable artifact** (this folder) to carry the conversation forward.

## What We Want to Learn

- **Terraform flavor:** HCP Terraform / Terraform Cloud, Terraform Enterprise (self-hosted), or
  open-source `terraform` CLI? (Decides whether the certified collection applies directly.)
- **Where state lives today:** remote backend? TFC/TFE? local files in a repo (red flag)? Is locking on?
- **Target infrastructure:** public cloud, on-prem/vSphere, or hybrid? (Decides how much falls to
  Terraform vs AAP given API quality.)
- **Who runs Terraform today:** humans at a CLI, a CI/CD pipeline, or already AAP? (Decides the
  integration direction.)
- **Handoff today:** how does config (Ansible) currently learn about freshly provisioned infra — manual
  inventory, dynamic inventory, copy-paste outputs?
- **Secrets:** how are cloud creds and the `TFE_TOKEN` / provider credentials handled — Vault, AAP
  credentials, env vars in a pipeline?
- **Image strategy:** do they build golden images today, and with what? (Maps onto "build images with AAP.")
