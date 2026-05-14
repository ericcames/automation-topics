# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

### Added
- [AGENTS.md](AGENTS.md) for AI contributor orientation
- Cursor project rule [`.cursor/rules/read-agents.mdc`](.cursor/rules/read-agents.mdc) (`alwaysApply`) so agents load that guidance automatically

### Changed
- CI validates session folder naming, requires each session folder in the README Session Index, and checks that index links point at existing directories
- CONTRIBUTING and AGENTS.md note the session-related CI checks

## [1.1.0] - 2026-05-14

### Changed
- Linked file names in session README and `_template/README.md` to actual files so they are clickable on GitHub

## [1.0.0] - 2026-05-14

### Added
- Initial repository structure
- Session template (`_template/`)
- `.github` community health files (SECURITY, issue templates, PR template, CI workflow)
- CONTRIBUTING.md and CODE_OF_CONDUCT.md
- First session: `2026-05-14_customer-sse_aap26-cicd-pipelines`
