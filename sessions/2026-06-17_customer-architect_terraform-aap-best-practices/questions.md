# Questions to Ask

## Discovery

1. **Which Terraform are you running** — HCP Terraform / Terraform Cloud, Terraform Enterprise
   (self-hosted), or open-source `terraform` CLI? (Decides whether the certified `hashicorp.terraform`
   collection applies directly, or it's `cloud.terraform` + a Terraform EE.)
2. **Where does your state live today**, and is **locking** on — TFC/TFE, a remote backend
   (S3+DynamoDB / Azure Storage / GCS), or local state files in a repo? (Local/unlocked is the first
   thing to fix.)
3. **What are you provisioning** — public cloud, on-prem/vSphere, or a hybrid of both? Where does the
   "good API" run out and force you to script things by hand today?
4. **Who runs Terraform now** — engineers at a CLI, a CI/CD pipeline, or already AAP? (Decides whether
   AAP orchestrates Terraform, or a pipeline hands off to AAP.)
5. **How does configuration learn about freshly provisioned infra today** — manual inventory, dynamic
   inventory, or copy-pasting outputs/IPs? (This is the seam we want to make clean.)

## Depth Probes

1. Has anyone ever had **Ansible (or any tool) write back to Terraform state**, or talked about "keeping
   state in sync" from both sides? (Find and stop this early.)
2. Do you **build golden images / templates** today, and with what? Could AAP own image build, with
   Terraform deploying the image? (Maps onto "build images with AAP / deploy with AAP.")
3. For the datacenter gear that **lacks a good Terraform provider** — what are those targets (legacy
   network, storage, appliances), and how are they automated now?
4. How are **secrets** handled — the `TFE_TOKEN`, cloud provider creds, SSH/WinRM creds? Vault? AAP
   credentials? Env vars in a pipeline? (Drives the credential design.)
5. Do you want a **change-review/approval gate** on infra changes? (The `view_plan` diff + an AAP
   workflow approval node is a clean fit.)
6. Are you running Terraform inside a **container/EE** today, and are versions **pinned** (Terraform,
   providers, collections)?

## Qualification

1. What does a **win in 90 days** look like — a clean provision→configure handoff, killing manual
   inventory, a supported integration replacing custom glue, a state model you trust?
2. Would a **small reference implementation** land — one AAP workflow that provisions via Terraform
   (certified collection or EE) and then configures the result — as the concrete next step?
3. **Who owns this end-to-end** on your side, and who needs to bless the **state model** and the
   **secrets handling**?
