# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

All version tags use **bare semver** format: `0.1.0` (no `v`-prefix).  
Pre-release tags include the label suffix: `0.1.5-alpha.1`.

---

## [Unreleased]

---

## [0.1.6] - 2026-04-28

### Added

- **`API.md`** — complete task API reference covering both channels: subscription tasks,
  python3a tasks, deno1a tasks, git hooks, VCS workflow, version/bump, skeleton sync,
  scanning, dispatch workflows, and environment variables
- **`deno1a` skel system** (`lib/deno1a/skel/`) — canonical template files synced to
  subscriber repos by `patterns:sync` with `{{ skel.var }}` Jinja interpolation:
  `README.md`, `AGENTS.md`, `.github/CODEOWNERS`, `.github/PULL_REQUEST_TEMPLATE.md`,
  `.github/settings.yml`, `.github/workflows/ci.yml`, `.github/workflows/pr-check.yml`,
  `.github/workflows/dispatch-sync-down.yml`, `.github/workflows/dispatch-sync-up.yml`,
  `mise.toml`
- **`mise run sync:down`** — pull updated skel files from dev-patterns with Jinja
  interpolation; CI creates `feature/sync-down-<date>` branch + draft PR; locally prompts
- **`mise run sync:up`** — compare local `[skel]` files against dev-patterns via SHA-256;
  upload differing files to `lib/deno1a/skel/`; create draft PR in dev-patterns
- **`dispatch-sync-down.yml` / `dispatch-sync-up.yml`** — workflow dispatch triggers
  for bidirectional sync, included as skel files
- **`.github/settings.yml` (deno1a skel)** — declarative Settings-app equivalent of
  the three branch rulesets
- **New deno1a tasks (catch-up with orchestras/deno)**: `build`, `execute`, `completions`,
  `dispatch/autobump`, `dispatch/configure`, `dispatch/ghas`, `npm/set-registry`,
  `npm/reset-registry`, `scan/complexity`, `tag/list`, `lint/check`, `fmt/fix`,
  `version/show`

### Changed

- **`scripts/sync_patterns.sh`** — now tries `gh api` (gh CLI) first to download
  `sync_patterns.py`; falls back to `curl` / `wget` for unauthenticated access
- **`scripts/sync_patterns.py` `_gh_available()`** — changed from `gh auth status`
  (which fails with multiple gh accounts) to `gh --version` (checks binary presence only)
- **`deno1a` bump tasks** (`bump:patch/minor/major/prerel`) — reverted to bare semver
  tags (`0.1.0`, not `v0.1.0`); tag search patterns updated from `v[0-9]*` to
  `[0-9]*.[0-9]*.[0-9]*` with `grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'` filter
- **`deno1a` tag tasks** — all glob patterns updated to bare semver (`[0-9]*` not `v*`)
- **`deno1a` version tasks** — `version:init` creates `0.1.0` (not `v0.1.0`);
  `version:sync` uses bare semver pattern
- **`deno1a` completions task** — reads parent shell from `$SHELL` env var (correctly
  inherited into the mise bash subshell); uses `read </dev/tty` so prompts work when
  mise runs tasks in a non-interactive pipeline subshell
- **`deno1a` vcs:protect** — rewrote as three idempotent rulesets using `upsert_ruleset()`
  helper (explicit name-based delete-then-create):
  - `branch-and-commit-restrictions` (all branches): signed commits, PR + code-owner,
    status checks (pr-check/lint/typecheck/test/security + CodeQL), code scanning gate,
    branch name + commit message regex
  - `develop-protection`: restrict creation/update/deletion/force-push on develop
  - `main-protection`: restrict creation/update/deletion/force-push on main
- **`deno1a` skel `pr-check.yml`** — fixed action versions to `checkout@v4`,
  `mise-action@v2`, `codeql-action@v3`; job names exactly match ruleset contexts
- **`patterns:sync`** — extended to sync `skel/` files after tasks and hooks; `skel`
  directory is excluded from the legacy top-level copy fallback
- **`lib/deno1a/mise/mise.toml`** — added `[skel]` file registry and `[skel.vars]`
  default values; bumped channel version to `0.2.0`
- **`.github/settings.yml`** (dev-patterns own) — rewrote to three-ruleset structure
  matching `vcs:protect`; added branch/commit pattern rules and CodeQL gate
- **`.github/workflows/pr-check.yml`** (dev-patterns own) — updated to `checkout@v4`,
  `mise-action@v2`, `codeql-action@v3`; added CodeQL step to security job
- **`README.md`** — simplified and improved; added channel comparison table,
  `sync:down`/`sync:up` commands, security section; links to `API.md`

### Fixed

- **`scripts/sync_patterns.py`** — `_gh_available()` no longer calls `gh auth status`,
  which fails when multiple GitHub accounts are configured; uses `gh --version` instead
- **`deno1a` completions** — `$SHELL` is now read correctly inside mise's bash subshell;
  `read` uses `/dev/tty` so the prompt is displayed even in non-interactive contexts
- **`deno1a` bump/tag/version** — all tag patterns now use bare semver (`0.1.0`) to
  match the Deno ecosystem convention and avoid `grep -v` interference with `v`-prefix

---

## [0.1.5] - 2026-04-26

### Added

- **`deno1a` channel** (`lib/deno1a/`) — patterns subscription for Deno projects:
  full hook suite (`pre-commit`, `commit-msg`, `pre-push`) + complete mise task set +
  `scripts/` utilities
- **`deno1a` mise tasks (initial)**: `install`, `run`, `fmt`, `fmt:check`, `lint`,
  `lint:fix`, `typecheck`, `test`, `test:cov`, `test:watch`, `deno:compile`,
  `deno:bundle`, `deno:upgrade`, `ci:all`, `bump:*`, `tag/*`, `version/*`, `vcs/*`,
  `hooks/*`, `git:config`, `project:init`, `scan:deps/sast/ghas`, `secrets/*`,
  `patterns/*`
- **Native TLS** — `DENO_TLS_CA_STORE = "system,mozilla"` in channel `mise.toml`

---

## [0.1.0] - 2026-04-12

### Added

- **`dev_patterns` Python package** — OOP sync engine, git hook installer,
  version-spec resolver, styled terminal UI
- **`python3a` channel** (`lib/python3a/`) — hooks + mise tasks for Python 3 projects
- **Declarative `githooks.toml` manifest** — TOML-based hook declarations
- **`scripts/sync_patterns.sh`** — thin bootstrap wrapper
- **`scripts/sync_patterns.py`** — standalone stdlib-only sync script (Python 3.12+)
- **Version-spec resolution** — priority chain from env → `mise.toml` → `.githooks-version`
  (new `repo/channel/version` or legacy `0.1.12`)
- **`patterns:setup`**, **`patterns:sync`**, **`patterns:subscribe`**, **`patterns:check-hash`**
- **`.github/settings.yml`** — declarative repo settings via GitHub Settings app
- **85 pytest tests** with 80%+ coverage

[Unreleased]: https://github.com/orchestras/dev-patterns/compare/0.1.6...HEAD
[0.1.6]: https://github.com/orchestras/dev-patterns/compare/0.1.5...0.1.6
[0.1.5]: https://github.com/orchestras/dev-patterns/compare/0.1.0...0.1.5
[0.1.0]: https://github.com/orchestras/dev-patterns/releases/tag/0.1.0
