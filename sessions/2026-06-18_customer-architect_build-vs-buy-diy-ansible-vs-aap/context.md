# Context

## Audience Profile

**Primary: a newly-promoted lead network engineer**, acting as the de-facto architect for network automation. Key traits:

- **Strong software/web background** dating to the early 2000s — thinks programmatically, scripts comfortably, and
  treats networking as a coding problem. This is a **strength**, not a liability; he is exactly the kind of engineer
  who succeeds with Ansible. It also means **he can build a lot himself**, which is precisely why he's tempted to.
- **Recently promoted** — motivated to prove the promotion was right, likely with something he personally built.
  Pride of authorship is a real and legitimate factor; handle it with respect.
- **Cost-conscious** — the stated blocker is **per-device licensing at scale** (hundreds to thousands of devices).
  This concern is legitimate and must be answered with **TCO**, not dismissed.

**Secondary audiences** (covered as separate tracks in [talking-points.md](talking-points.md)):

- **Executives** who will be **accountable** for the outcome of this decision while they hold their seats. They care
  about **risk, supportability, and accountability** far more than feature lists.
- **The Red Hat sales team**, who need to know how to position this without alienating a technical buyer who is
  (understandably) proud of his own approach.

## The Situation (keep generic — no identifying detail)

| Element | State |
|---------|-------|
| Domain | **Life-safety / emergency-call operation** — outages are not acceptable; change risk is existential |
| Platform | Building on **RHEL** |
| Proposed approach | **Self-managed Ansible Core** + **AI-assisted code generation** to build a *custom* automation platform |
| Driver | **Per-device licensing cost** of AAP at hundreds–thousands of devices |
| Existing asset | A **custom 4-phase change framework** previously built in **PHP + Python** |
| Build maturity | **Idea / proposal stage** — not yet built on the new approach (best-case timing to redirect) |
| Goal he stated | **Automate the generation of device configurations** |

## What "build my own AAP" actually means

Ansible Core is the open-source automation engine — free, legitimate, and **Red Hat's own upstream**. There is
nothing wrong with using it. The risk is **not** Ansible Core; it's everything you have to **build and then forever
maintain around it** to make it a *platform*:

| Capability he'd have to build & maintain himself | What it is | What AAP ships, supported |
|---|---|---|
| A way to run his 4-phase flow with branching | Orchestration / workflow engine | **Workflow job templates** (visual, branchable on success/failure) |
| The "auto-rollback on failure" trigger | Event/condition → action | **Event-Driven Ansible (EDA)** |
| Who-changed-what-when | Audit logging & RBAC | **Built-in RBAC + audit trail** |
| Secrets not living in scripts | Credential management | **Credential store / external vault integration** |
| "Works on my box" → reproducible runs | Versioned runtime | **Execution Environments** (container images) |
| Reaching thousands of devices across sites | Scale / distribution | **Automation mesh** |
| Trusted, patched content | Supply-chain / CVE pipeline | **Certified, signed collections + Red Hat security response** |
| Letting others run automation safely | Self-service & delegation | **Surveys + RBAC** |
| Someone to call at 2 a.m. | Support | **Red Hat support SLA** |

His **4-phase framework maps almost 1:1** onto a workflow + EDA. He has effectively written the spec for AAP.

## His actual goal — config generation — is squarely an Ansible content problem

"Automate the generation of configurations" is **Jinja2 templating + facts + certified network resource modules**
(`cisco.ios`, `cisco.nxos`, `arista.eos`, `junipernetworks.junos`, `paloaltonetworks.panos`, `ansible.netcommon`).
This is the **high-value work** — and it runs identically on Ansible Core **or** AAP. The build-vs-buy decision is
**not** about whether he writes this content; it's about **what platform runs it**. That separation is key to keeping
the conversation non-adversarial.

## Likely Assumptions He's Walking In With

- *"AAP is just a paid GUI on top of free Ansible — I can build the GUI."* — It's the GUI **plus** RBAC, audit, EDA,
  secrets, scale, supported content, and a CVE pipeline. The GUI is the smallest part.
- *"This is proprietary vs. open source, and I prefer open."* — **AAP is open source.** Ansible Core is the upstream;
  AAP is the productized, hardened distribution. Same relationship as **Fedora/Stream → RHEL** — which he already chose.
- *"Licensing at this scale is a non-starter."* — The sticker price is real; the **comparison is wrong**. The honest
  comparison is AAP cost **vs. the fully-loaded cost of building + maintaining + supporting + carrying the risk of** a
  homegrown platform — including the cost of a **single outage** in a life-safety context.
- *"AI can write the platform for me, so maintenance is cheap."* — AI accelerates writing code; it does **not** remove
  the burden of **owning, securing, and supporting** that code — and a pile of AI-generated platform code that **one
  person (or no person) fully understands** is a *worse* bus-factor problem, not a better one.

## Potential Concerns or Objections

- **Cost / budget** — legitimate; answer with TCO and the cost-of-outage framing, never with "it's worth it, trust us."
- **Pride of authorship** — he built the 4-phase framework and is newly promoted. **Honor it.** Position the platform
  as the thing that **elevates** his design, not the thing that **discards** it.
- **Open-source preference / lock-in fear** — neutralize with "AAP *is* open source; you're already running our
  upstream" and the RHEL analogy.
- **"I can clearly build this"** — yes, he can. The question is not *can he build it* but *should he be the one
  maintaining, securing, supporting, and being the single point of failure for it* — in a life-safety system.
- **Skepticism of vendor pitches** — he's technical and proud; a feature-dump will backfire. Lead with **his own design**.
