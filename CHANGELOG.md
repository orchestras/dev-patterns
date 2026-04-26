# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added — deno1a channel

- **`/lib/deno1a/` channel directory** — patterns subscription for Deno projects:
  - `hooks/` — git hook scripts (`pre-commit`, `commit-msg`, `pre-push`) with `githooks.toml`
    TOML manifest; `pre-commit` runs `deno fmt --check` + `deno lint` on staged TS/JS files
  - `mise/mise.toml` — channel env var declarations including `DENO_TLS_CA_STORE=system,mozilla`
    for native TLS / corporate proxy support (Zscaler-compatible)
  - `mise/tasks/` — full task suite: `install`, `run`, `fmt`, `fmt:check`, `lint`, `lint:fix`,
    `typecheck`, `test`, `test:cov`, `test:watch`, `deno:compile`, `deno:bundle`, `deno:upgrade`,
    `ci:all`, `bump:patch/minor/major/prerel`, `tag/*`, `version/*`, `vcs/*`, `hooks/*`,
    `git:config`, `project:init`, `scan:deps/sast/ghas`, `secrets/*`, `patterns/*`
  - `scripts/` — `semver.sh`, `colors.sh`, `sync_patterns.sh` synced to consumer repo
- **No `v` prefix on release tags** — Deno channel uses bare semver tags (`0.1.0` not `v0.1.0`)
- **Version stored in `deno.json`** — `bump:*` tasks update `.version` in `deno.json` via `jq`
- **Native TLS** — `DENO_TLS_CA_STORE = "system,mozilla"` set in channel `mise.toml`

### Added — feature/000967-Base-Patterns

- **`dev_patterns` Python package** — replaces `python_template`; provides OOP sync engine,
  git hook installer, version-spec resolver, and styled terminal UI (mise/lefthook-style output)
- **`/lib/python3a/` channel directory** — central patterns subscription for Python 3 projects:
  - `hooks/` — git hook scripts with `githooks.toml` declarative TOML manifest
  - `mise/mise.toml` — channel env var declarations
  - `mise/tasks/patterns/` — `setup`, `sync`, `subscribe`, `check-hash` tasks
- **Declarative `githooks.toml` manifest** — TOML-based hook declarations (no YAML, no Node.js)
- **`scripts/sync_patterns.sh`** — thin bootstrap wrapper (downloads `sync_patterns.py` if absent)
- **`scripts/sync_patterns.py`** — standalone Python sync script (no package install required);
  resolves version spec, downloads tarball, applies channel files, writes `.patterns-hash`
- **Version-spec resolution** — priority chain: `PATTERNS_*` env → `mise.toml [env]` →
  `.githooks-version` (new `repo/channel/version` format) → `.githooks-version` (legacy `vX.Y.Z`)
  → built-in defaults; supports GitHub Release tarballs for tagged versions
- **`mise run patterns:setup`** — interactive channel subscription wizard
- **`mise run patterns:sync`** — pull latest channel files (skips when hash is current)
- **`mise run patterns:subscribe`** — non-interactive subscribe via env vars / CLI args
- **`mise run patterns:check-hash`** — lazy hash check; auto-syncs when stale
- **`.github/settings.yml`** — declarative repo settings via GitHub Settings app
  (rulesets, branch protection, GHAS, Dependabot, rebase-only merges)
- **85 pytest tests** covering version-spec, hook manifest, hook installer, sync engine,
  sync script, UI console, CLI commands

## [0.1.0] - 2026-04-12

### Added

- Initial template release
- UV package management with `uv sync`
- Ruff linting and formatting configuration
- Ty type checking integration
- pytest test suite with coverage reporting
- Mise task runner with all tasks as executable file tasks in `.mise/tasks/`
- PyInstaller binary compilation (`mise run compile`)
- Cross-platform release workflow (Linux AMD64/ARM64, macOS ARM64/AMD64, Windows AMD64)
- GitHub Advanced Security (GHAS) with CodeQL scanning
- Dependabot configuration for Python deps and GitHub Actions
- Branch protection ruleset automation via `mise run vcs:protect`
- Required status checks: lint, typecheck, test, security
- Git hooks: pre-commit (ruff), pre-push (tests + main protection), commit-msg (Conventional Commits)
- Hooks sync from orchestras/git-hooks (`mise run hooks:sync`)
- Semver bump tasks with git tag creation
- Rebase-only workflow enforcement
- Dev Container configuration
- AGENTS.md for AI coding assistant instructions

[Unreleased]: https://github.com/orchestras/python3/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/orchestras/python3/releases/tag/v0.1.0
