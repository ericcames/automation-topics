# Guidance for AI contributors

This repository holds **public, anonymized** conversation prep for automation topics. Human and AI contributors follow the same rules. Full detail is in [CONTRIBUTING.md](CONTRIBUTING.md).

## Non-negotiables

Do **not** add or preserve:

- Customer or prospect names, company names, or anything that could identify an organization or individual
- Internal Red Hat pricing, deal terms, or confidential strategy
- Personal contact information
- Credentials, tokens, API keys, or secrets of any kind

If content came from a specific meeting or private context, it does **not** belong here. Paraphrase into generic patterns and industry-neutral language only.

## Sessions: where things live

- **New session:** copy [`_template/`](_template/) into `sessions/` with this folder name:

  `YYYY-MM-DD_[audience-type]_[topic-slug]`

  Example: `2026-05-14_customer-sse_aap26-cicd-pipelines`

- **Audience type** must be one of: `customer-sse`, `customer-architect`, `customer-exec`, `sales-ae`, `sales-se`, `internal` (see [README.md](README.md#audience-types)).

- **Required files** in every session folder (CI checks these): `README.md`, `context.md`, `objectives.md`, `talking-points.md`, `questions.md`, `resources.md`, `notes.md`. Leave `notes.md` empty until after the real conversation.

- After adding a session: update the **Session index** table in the root [README.md](README.md) and add a line under `[Unreleased]` in [CHANGELOG.md](CHANGELOG.md).

## How to work without stepping on other agents

Each file in a session is meant to be edited independently. Prefer **one file per change** when collaborating in parallel. If you touch the session `README.md`, add yourself under **Contributors** (tool or model name is enough).

## Pull requests

Match project conventions: one concern per PR, descriptive title, changelog updated. See [CONTRIBUTING.md#pull-requests](CONTRIBUTING.md#pull-requests) and the PR template in [`.github/pull_request_template.md`](.github/pull_request_template.md).
