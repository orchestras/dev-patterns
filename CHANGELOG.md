# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed — deno1a channel catch-up (sync with orchestras/deno template)

- **`bump:patch/minor/major/prerel`** — switched to `v`-prefixed tags (`v0.1.0` not `0.1.0`);
  tasks now also regenerate `src/version.ts` via `deno run src/make_version.ts` when present
- **`deno:compile`** — upgraded to cross-platform multi-target compilation (darwin-arm64,
  darwin-amd64, linux-amd64, linux-arm64, windows-amd64) outputting to `./bin/`
- **`ci:all`** — restructured as a step-runner (lint → fmt:check → typecheck → test → build →
  execute); reports pass/fail counts; `build` and `execute` steps are skipped when
  `src/make_version.ts` is absent
- **`install`** — updated default entry point fallback to `src/mod.ts`
- **`typecheck`** — updated default entry point fallback to `src/mod.ts`
- **`run`** — updated default entry point fallback to `src/mod.ts`
- **`project:init`** — adds `dispatch:configure` hint; calls `secrets:init` gracefully
- **`vcs:protect`** — full per-branch ruleset implementation (Restrictions: All Branches,
  Protection: develop, Protection: main) with idempotent delete-then-create; creates `develop`
  branch if absent; separate required-status-checks per branch
- **`version:init`** — uses `v`-prefixed tags (`v0.1.0`)
- **`version:sync`** — uses `v`-prefixed tag pattern; regenerates `src/version.ts` when present
- **`tag:clean`** — updated to use `v*` tag glob (v-prefix)
- **`tag:create`** — auto-prefixes `v` if version from `deno.json` lacks it
- **`tag:_default` / `tag:fetch` / `tag:remote`** — updated to `v*` tag glob
- **`scan:sast`** — added `eval()` and hardcoded-secret heuristic scans targeting `src/`
- **`test`** — added `--reporter=pretty` and optional `--filter` argument
- **`gh:token`** — expanded output with token-management advice
- **`hooks:install`** — added `ls -la` listing of installed hooks on success

### Added — deno1a channel (new tasks)

- **`build`** — regenerates `src/version.ts` from `deno.json` version via `src/make_version.ts`
- **`execute`** — runs the app entry point (`deno run --allow-all src/mod.ts`)
- **`completions`** — installs mise shell completions for bash/zsh/fish (interactive)
- **`dispatch:autobump`** — triggers `dispatch-autobump-release.yml` workflow via `gh workflow run`
- **`dispatch:configure`** — triggers `dispatch-autoconfigure-rulesets.yml` workflow
- **`dispatch:ghas`** — triggers `ghas-scan.yml` workflow
- **`npm:set-registry`** — configures NPM to use Artifactory (RT_URL/RT_USER/RT_KEY)
- **`npm:reset-registry`** — resets NPM registry to npmjs.org
- **`scan:complexity`** — cyclomatic complexity analysis via `deno lint` + function-length
  heuristic; thresholds configurable via CCN/MAX\_LINES/MAX\_ARGS env vars
- **`tag:list`** — lists local `v*` semver tags
- **`lint:check`** — canonical `lint:check` alias (used by CI pipeline and pre-push hook)
- **`fmt:fix`** — explicit `fmt:fix` alias for `deno fmt` (deno template convention)
- **`version:show`** — prints current version from `deno.json`

### Added — deno1a channel (initial)

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
