# Hands-off containerized AAP 2.7 install (registry, subscription & EULA, no UI steps)

**Goal:** run the containerized Ansible Automation Platform 2.7 installer so the
platform comes up **already authenticated to the registry, already licensed, and
with the EULA accepted** — no manual `podman login`, no subscription picker, and
no license click-through after the install.

Companion file: [`aap-hands-off-inventory.example`](aap-hands-off-inventory.example).

---

## TL;DR — three variables do it

Everything you'd otherwise do by hand collapses into three inventory variables in
`[all:vars]` (with `registry_auth` left at its default of `true`):

| Manual step you're eliminating | Inventory variable | Notes |
|---|---|---|
| `podman login registry.redhat.io` | `registry_username`, `registry_password` | Fed by a Red Hat **Registry Service Account**. Gated by `registry_auth=true` (default). |
| Uploading a manifest / picking a subscription in the UI | `controller_license_file` | Full local path to `manifest.zip`. |
| Accepting the EULA in the UI | *(none)* | Supplying the manifest **through the installer** accepts the license non-interactively. There is no separate `eula_accept` variable. |

All three are confirmed against the AAP 2.7 docs:
- `registry_username` / `registry_password` / `registry_auth` / `registry_url` /
  `registry_tls_verify` — *Install → general variables*.
- `controller_license_file` — "Path to the automation controller license file"
  — *Install → automation controller variables*. (American spelling — the British
  `controller_licence_file` is a typo the installer silently ignores.)

---

## Where the two inputs come from

**Registry Service Account** (for `registry_username` / `registry_password`):
create one at <https://access.redhat.com/terms-based-registry>. The service
account's **username** and **token** map directly onto the two variables. A
service account (not your personal Red Hat login) is the right pattern — it's
scoped, revocable, and shareable across a team without exposing a human's
credentials.

**Subscription manifest** (for `controller_license_file`): at
<https://access.redhat.com/management/subscription_allocations> create an
allocation, attach your AAP entitlement, and export `manifest.zip`. Copy it to
the installer host at a local, absolute path readable by the install user
(e.g. `/opt/aap/manifest.zip`).

---

## Vault the secrets (this is the part I teach customers)

**Never put `registry_password`, admin passwords, or PostgreSQL passwords in a
plaintext inventory.** Keep them in an `ansible-vault`-encrypted file and load it
at install time. In the inventory itself the secret lines stay commented out with
a `<vaulted>` marker so it's obvious where they come from:

```ini
# registry_username=<vaulted>      # -> set in vault.yml
# registry_password=<vaulted>      # -> set in vault.yml
```

### 1. Put the real secrets in a YAML vars file

`vault.yml` (plaintext for now — we encrypt it in the next step):

```yaml
---
registry_username: "1234567|my-sa"
registry_password: "eyJhbGciOi...service-account-token..."

gateway_admin_password: "..."
controller_admin_password: "..."
hub_admin_password: "..."
eda_admin_password: "..."

controller_pg_password: "..."
hub_pg_password: "..."
eda_pg_password: "..."
gateway_pg_password: "..."
```

### 2. Encrypt it

```bash
ansible-vault encrypt vault.yml
```

At rest the file is now ciphertext. Store the vault password out of band — a
password manager, or a `--vault-password-file` that is itself protected (never
commit either).

### 3. Run the installer, loading the vault as extra-vars

The extra-vars from `vault.yml` fill in the credentials the inventory left
vaulted. Match the playbook/command to what your installer bundle documents; for
the collection-based containerized installer it's:

```bash
ansible-playbook -i inventory \
  ansible.containerized_installer.install \
  -e @vault.yml \
  --ask-vault-pass
```

Use `--vault-password-file /path/to/.vault_pass` instead of `--ask-vault-pass`
for an unattended run.

> **Why extra-vars?** `-e @vault.yml` has the highest precedence, so the secrets
> land regardless of the inventory. The commented `<vaulted>` lines in the
> inventory are documentation — they tell the next engineer exactly which values
> live in the vault file.

**Alternative (single-file):** if you'd rather keep everything in one place, you
can `ansible-vault encrypt` the **entire inventory** and run with
`--ask-vault-pass`. That protects every secret in the file, but you lose the
at-a-glance `<vaulted>` markers and can no longer diff the inventory in the
clear. For teaching the pattern, the separate `vault.yml` above is cleaner.

---

## Result

With the service account creds and manifest wired in through the inventory +
vault, the installer finishes with the controller **authenticated, licensed, and
EULA-accepted** — log in and the platform is ready, zero post-install UI steps.

## Gotchas

- **`registry_auth=true`** is the default and must stay true for an online
  install, or the installer won't use the credentials. Only disconnected installs
  skip registry auth.
- **`controller_license_file`** must be a **local, absolute** path on the machine
  running the installer, readable by the install user.
- **Spelling:** `controller_license_file` (American). `controller_licence_file`
  is silently ignored and drops you back to a manual manifest upload.
- **Don't commit secrets** — `vault.yml` (encrypted or not), `.vault_pass`, real
  service-account tokens, manifests, or customer FQDNs/IDs never go in a tracked
  file.
