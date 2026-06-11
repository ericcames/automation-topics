# AAP as an OIDC Identity Provider for HashiCorp Vault

> *"Ansible Automation Platform now acts as an OIDC Identity Provider for
> HashiCorp Vault."* — what that sentence actually means, in plain terms.

**Audience:** customers, sales teammates, and SEs. Use it to explain the feature
in a conversation or to brief yourself before one. No customer-specific detail —
generic patterns only.

**Applies to:** Ansible Automation Platform **2.7** (introduced at Red Hat Summit
2026). Verify exact field names against the 2.7 product docs linked at the bottom
before you configure a live environment.

---

## The one-sentence version

AAP 2.7 can hand **each automation job** a short-lived, cryptographically signed
identity token (a **JWT**). HashiCorp Vault verifies that token and returns **only
the secrets that job is allowed** — so you **stop storing a Vault credential
inside AAP**.

## The problem it solves (lead with this)

Secrets management has a chicken-and-egg problem:

> To pull secrets *out* of Vault, a job needs a credential to authenticate *to*
> Vault. So where do you store **that** credential — securely?

The traditional answer was a **long-lived Vault token** (or AppRole `secret-id`)
stashed inside an AAP credential. That is exactly the kind of standing secret you
were trying to get rid of: it sits in another system, it has to be rotated, and if
it leaks it unlocks Vault.

**AAP-as-OIDC-IdP removes that bootstrap secret entirely.** Instead of *storing* an
identity, the job *proves* its identity at run time with a token AAP signs on the
spot. This is **workload identity** — the same pattern that lets GitHub Actions
authenticate to AWS/GCP and Kubernetes service accounts authenticate to Vault,
with no static cloud key.

## A 30-second OIDC primer

- **OIDC (OpenID Connect)** is an identity layer on top of OAuth 2.0.
- An **Identity Provider (IdP)** signs short-lived **JWTs** (JSON Web Tokens) that
  assert *"this workload is who it claims to be,"* carrying **claims** (facts about
  the caller).
- Any system can **verify** that signature without contacting the IdP live, by
  fetching the IdP's **public keys** from a standard, unauthenticated discovery
  endpoint:
  - `…/.well-known/openid-configuration` — the OIDC discovery document
  - a **JWKS** URL (JSON Web Key Set) — the public keys used to check signatures
- The verifier also checks the claims (issuer, audience, subject, expiry) against
  rules you configure.

In this feature, **AAP is the IdP** and **Vault is the verifier**.

## How it works, end to end

```text
1. A job launches in AAP, using a "HashiCorp Vault … (OIDC)" credential.
        │
        ▼
2. AAP (the OIDC IdP) MINTS a short-lived JWT for THAT job.
   - Signed with AAP's private key
   - Carries claims about the job (issuer, subject, audience, etc.)
   - Expiry is bounded — matches the job timeout when one is set
        │  presents the JWT
        ▼
3. Vault's JWT/OIDC auth method VERIFIES the token:
   - Checks the signature against AAP's JWKS (public keys from discovery URL)
   - Validates the bound claims and audience
   - Maps the token to a Vault ROLE → POLICY
        │  token valid + claims match
        ▼
4. Vault issues a SHORT-LIVED, SCOPED Vault token and returns ONLY the
   secrets that policy permits.
        │
        ▼
5. The job uses the secret. Tokens expire on their own — nothing long-lived
   was stored in AAP, and no standing Vault credential exists for this path.
```

The trust is **one-time setup**: you point Vault's JWT auth method at AAP's OIDC
discovery URL once, and define which AAP claims map to which Vault role/policy.
After that, every job authenticates with a freshly minted, self-expiring token.

## The two credential types

AAP 2.7 ships two OIDC-based HashiCorp Vault credential types. Pick by **what the
job needs from Vault**:

| Credential type | Use it for |
|-----------------|-----------|
| **HashiCorp Vault Secret Lookup (OIDC)** | Pull a **secret value** out of Vault's KV (or other secret engines) at job run time |
| **HashiCorp Vault Signed SSH (OIDC)** | Have Vault's **SSH secrets engine sign an SSH key/cert** so the job can log into target hosts without a static key |

Both authenticate to Vault with the **AAP-issued JWT** instead of a stored Vault
token — that is the whole point. They are the OIDC counterparts to the older
token/AppRole-based HashiCorp Vault credential types, which still exist (see
*Additive, not a forced migration* below).

## What you configure where

| Side | What you set up (one time) |
|------|----------------------------|
| **AAP 2.7** | Enable AAP as the OIDC provider; create a **HashiCorp Vault Secret Lookup (OIDC)** and/or **Signed SSH (OIDC)** credential; attach it to the job templates that need Vault |
| **HashiCorp Vault** | Enable the **JWT/OIDC auth method**; point it at AAP's **OIDC discovery URL / JWKS**; define a **role** with **bound claims** + **bound audiences**; bind that role to a **policy** scoping which secret paths are allowed |

> Treat the exact claim names, the discovery URL path, and the audience value as
> things to **confirm against the AAP 2.7 docs** for your build — the public
> announcements describe the flow but not every field. The Vault side follows the
> standard [JWT/OIDC auth method](https://developer.hashicorp.com/vault/docs/auth/jwt).

## Why it matters — the talking points

1. **No stored Vault credential in AAP.** The bootstrap secret is gone. Fewer
   secrets to manage, rotate, and protect; a smaller attack surface.
2. **Ephemeral by design.** Every interaction with Vault uses a **short-lived**
   token; the AAP JWT's expiry is **bounded to the job** (matches the job timeout
   when available). Nothing long-lived to steal or leak.
3. **Zero standing privileges / zero trust.** A job gets **only the secrets it
   needs, only when it needs them, for as long as the job runs** — "never trust,
   always verify" applied to automation.
4. **AAP becomes the single source of authentication.** Identity and access
   decisions key off the job's verifiable identity, with Vault policies as the
   guardrail. Cleaner audit story: each token traces back to a specific job.

## Likely questions and objections

- **"Is this replacing my existing Vault integration?"** No — it's **additive**.
  The token/AppRole-based HashiCorp Vault credential types still work. OIDC is the
  stronger option when you want to eliminate the stored Vault credential.
- **"Do I have to be on 2.7?"** Yes — this is a **2.7** capability. On 2.5/2.6 you
  use the existing token/AppRole credential types.
- **"What stops any job from grabbing any secret?"** Vault's **role → policy**
  binding plus **bound claims** on the JWT. You scope which AAP identities map to
  which policy; Vault enforces least privilege.
- **"What if the AAP signing key rotates?"** Vault re-fetches AAP's public keys
  from the **JWKS** endpoint, so signature verification keeps working across key
  rotation — that's the point of publishing keys at a discovery URL.
- **"Latency / availability?"** Vault validates the JWT signature against cached
  JWKS; there's no live round-trip to AAP per request beyond key refresh.

## Additive, not a forced migration

Existing HashiCorp Vault credentials (token / AppRole) are untouched. Adopt OIDC
where removing the stored Vault credential is worth the one-time trust setup;
leave proven integrations in place until the OIDC path is validated. ("Additive
only — don't remove old capabilities until replacements are proven.")

## References

- Red Hat — *OIDC authentication for HashiCorp Vault* (AAP 2.7 What's New) —
  https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.7/whats_new-oidc_authentication_for_hashicorp_vault
- Red Hat blog — *Strengthening security and consistency in the cloud with Red Hat
  and HashiCorp* —
  https://www.redhat.com/en/blog/strengthening-security-and-consistency-cloud-red-hat-and-hashicorp
- HashiCorp blog — *Managing AAP credentials at scale with Vault* —
  https://www.hashicorp.com/en/blog/managing-ansible-automation-platform-aap-credentials-at-scale-with-vault
- HashiCorp Vault — *JWT/OIDC auth method* (the Vault side of the trust) —
  https://developer.hashicorp.com/vault/docs/auth/jwt
- HashiCorp validated pattern — *Integrate Vault SSH with AAP* (context for the
  Signed SSH credential type) —
  https://developer.hashicorp.com/validated-patterns/vault/integrate-vault-ssh-with-ansible-automation-platform
