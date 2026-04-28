# API Reference — dev-patterns

Complete reference for mise tasks, git hooks, channel subscriptions, VCS workflow, and version bumping across the **python3a** and **deno1a** channels.

---

## Table of Contents

1. [Channel Subscription (both channels)](#1-channel-subscription)
2. [Python3a channel tasks](#2-python3a-channel-tasks)
3. [Deno1a channel tasks](#3-deno1a-channel-tasks)
4. [Git Hooks](#4-git-hooks)
5. [VCS workflow](#5-vcs-workflow)
6. [Version and Bump](#6-version-and-bump)
7. [Skeleton sync](#7-skeleton-sync)
8. [Scanning and security](#8-scanning-and-security)
9. [Dispatch workflows](#9-dispatch-workflows)

---

## 1. Channel Subscription

Manage the dev-patterns subscription in any subscriber repo.

### `mise run patterns:setup`

Interactive wizard: prompts for repo and channel, writes `PATTERNS_REPO` and `PATTERNS_CHANNEL` into `mise.toml [env]`, downloads `sync_patterns.sh`, and runs an initial sync.

```bash
mise run patterns:setup
mise run patterns:setup orchestras/dev-patterns python3a   # non-interactive
```

### `mise run patterns:subscribe`

Non-interactive subscribe. Reads repo/channel from CLI args or env vars.

```bash
PATTERNS_CHANNEL=deno1a mise run patterns:subscribe
mise run patterns:subscribe orchestras/dev-patterns deno1a
```

### `mise run patterns:sync`

Pull the latest tasks, hooks, and skel files from the configured channel. Skips if `.patterns-hash` already matches the latest commit SHA.

```bash
mise run patterns:sync
PATTERNS_CHANNEL=deno1a mise run patterns:sync
```

### `mise run patterns:check-hash`

Fetch the latest commit hash from dev-patterns; auto-syncs if the recorded `.patterns-hash` is stale.

```bash
mise run patterns:check-hash
```

### Bootstrap (first install)

```bash
# Using gh CLI (preferred — works for private repos):
gh api repos/orchestras/dev-patterns/contents/scripts/sync_patterns.sh \
  --jq '.content' | base64 -d > scripts/sync_patterns.sh
chmod +x scripts/sync_patterns.sh

# Using curl (public repos):
curl -sSfL \
  https://raw.githubusercontent.com/orchestras/dev-patterns/main/scripts/sync_patterns.sh \
  -o scripts/sync_patterns.sh && chmod +x scripts/sync_patterns.sh

# Run:
./scripts/sync_patterns.sh
```

---

## 2. Python3a channel tasks

Tasks distributed to Python 3 / UV / Ruff projects.

### Development

| Task | Command | Description |
|------|---------|-------------|
| `install` | `mise run install` | `uv sync --all-extras` |
| `run` | `mise run run` | `python -m dev_patterns` |
| `build` | `mise run build` | Sync `version.py` from `pyproject.toml` |

### Code quality

| Task | Command | Description |
|------|---------|-------------|
| `lint` | `mise run lint` | `ruff check src/ tests/` |
| `lint:fix` | `mise run lint:fix` | `ruff check --fix` |
| `fmt` | `mise run fmt` | `ruff format` |
| `fmt:check` | `mise run fmt:check` | `ruff format --check` (CI-safe) |
| `typecheck` | `mise run typecheck` | `ty check src/` |
| `test` | `mise run test` | `pytest` |
| `test:cov` | `mise run test:cov` | `pytest` with coverage report |
| `test:watch` | `mise run test:watch` | `pytest --watch` (continuous) |
| `ci:all` | `mise run ci:all` | Full pipeline: fmt → lint → typecheck → tests |

### Scanning

| Task | Command | Description |
|------|---------|-------------|
| `scan:deps` | `mise run scan:deps` | `pip-audit` dependency vulnerability check |
| `scan:sast` | `mise run scan:sast` | Bandit static analysis |
| `scan:ghas` | `mise run scan:ghas` | Trigger GitHub CodeQL scan |

### Release

| Task | Command | Description |
|------|---------|-------------|
| `bump:patch` | `mise run bump:patch` | `0.1.5 → 0.1.6` |
| `bump:minor` | `mise run bump:minor` | `0.1.5 → 0.2.0` |
| `bump:major` | `mise run bump:major` | `0.1.5 → 1.0.0` |
| `bump:prerel` | `mise run bump:prerel [label]` | `0.1.5 → 0.1.5-alpha.1` |
| `tag:push` | `mise run tag:push` | Push tags → trigger release CI |

---

## 3. Deno1a channel tasks

Tasks distributed to Deno 2 / TypeScript / Mise projects.

### Development

| Task | Command | Description |
|------|---------|-------------|
| `execute` | `mise run execute` | `deno run --allow-all src/mod.ts` |
| `build` | `mise run build` | Regenerate `src/version.ts` from `deno.json` |
| `install` | `mise run install` | Cache Deno dependencies (`deno cache --reload`) |
| `run` | `mise run run` | Alias for `execute` |
| `completions` | `mise run completions` | Install mise shell completions (interactive) |

### Code quality

| Task | Command | Description |
|------|---------|-------------|
| `lint:check` | `mise run lint:check` | `deno lint` |
| `lint:fix` | `mise run lint:fix` | `deno lint --fix && deno fmt` |
| `fmt:fix` | `mise run fmt:fix` | `deno fmt` |
| `fmt:check` | `mise run fmt:check` | `deno fmt --check` (CI-safe) |
| `typecheck` | `mise run typecheck` | `deno check src/mod.ts` |
| `test` | `mise run test [filter]` | `deno test -A --reporter=pretty` |
| `test:cov` | `mise run test:cov` | Tests with lcov coverage report |
| `test:watch` | `mise run test:watch` | `deno test --watch` |
| `ci` | `mise run ci` | Full pipeline: lint → fmt:check → typecheck → test → build → execute |

### Binary compilation

| Task | Command | Description |
|------|---------|-------------|
| `deno:compile` | `mise run deno:compile` | Cross-compile to 5 platforms → `./bin/` |
| `deno:upgrade` | `mise run deno:upgrade` | Update all `deno.json` dependencies |
| `deno:bundle` | `mise run deno:bundle` | Bundle for browser/Node via esbuild |

### NPM registry

| Task | Command | Description |
|------|---------|-------------|
| `npm:set-registry` | `mise run npm:set-registry` | Configure NPM to use Artifactory |
| `npm:reset-registry` | `mise run npm:reset-registry` | Reset NPM registry to npmjs.org |

### Scanning

| Task | Command | Description |
|------|---------|-------------|
| `scan:deps` | `mise run scan:deps` | `deno audit` vulnerability check |
| `scan:sast` | `mise run scan:sast` | `deno lint` with security + hardcoded-secret heuristics |
| `scan:complexity` | `mise run scan:complexity` | Cyclomatic complexity analysis |
| `scan:ghas` | `mise run scan:ghas` | Trigger GitHub CodeQL scan |

**Scan environment variables** (`scan:complexity`):

| Variable | Default | Description |
|----------|---------|-------------|
| `CCN` | `15` | Max cyclomatic complexity |
| `MAX_LINES` | `100` | Max function length in lines |
| `MAX_ARGS` | `8` | Max function argument count |

### Version and release (deno1a)

All version tags use bare semver format: `0.1.0` (no `v`-prefix). Pre-release tags include the label: `0.1.5-alpha.1`.

| Task | Command | Description |
|------|---------|-------------|
| `version:show` | `mise run version:show` | Print current version from `deno.json` |
| `version:init` | `mise run version:init` | Create `0.1.0` tag if no remote tags exist |
| `version:sync` | `mise run version:sync` | Sync `deno.json` + `version.ts` to latest remote tag |
| `bump:patch` | `mise run bump:patch` | `0.1.5 → 0.1.6` (updates `deno.json`, commits, tags) |
| `bump:minor` | `mise run bump:minor` | `0.1.5 → 0.2.0` |
| `bump:major` | `mise run bump:major` | `0.1.5 → 1.0.0` |
| `bump:prerel` | `mise run bump:prerel [label]` | `0.1.5 → 0.1.5-alpha.1` |
| `tag:push` | `mise run tag:push` | Push tags to origin → triggers `release.yml` |
| `tag:list` | `mise run tag:list` | List local semver tags |
| `tag:fetch` | `mise run tag:fetch` | Fetch all tags from origin |
| `tag:sync` | `mise run tag:sync` | Fetch + prune tags from origin |
| `tag:remote` | `mise run tag:remote` | Show remote semver tags |
| `tag:create` | `mise run tag:create` | Create tag from `deno.json` version (no push) |
| `tag:clean` | `mise run tag:clean` | Delete local tags not on remote |

> **Note:** Python repos (python3a) use semver tags too, but those are managed by `pyproject.toml` and the `mise run bump:*` tasks which update `[project] version`. Both channels use bare semver (`0.1.0`, not `v0.1.0`).

---

## 4. Git Hooks

Hooks are managed by the channel's `hooks/githooks.toml` manifest and installed via `mise run hooks:sync && mise run hooks:install`.

### `mise run hooks:sync`

Download hooks from dev-patterns for the configured channel (`GITHOOKS_PROFILE`). Writes to `config/githooks/hooks/`.

```bash
mise run hooks:sync
GITHOOKS_VERSION=0.1.6 mise run hooks:sync   # pin to a specific release tag
```

### `mise run hooks:install`

Register `config/githooks/hooks/` as `core.hooksPath` in local git config.

```bash
mise run hooks:install
```

### Hook behaviour by channel

#### python3a hooks

| Hook | Trigger | Checks |
|------|---------|--------|
| `pre-commit` | `git commit` | Ruff lint + format check on staged `.py` files |
| `commit-msg` | After message | Conventional Commits format |
| `pre-push` | `git push` | Full pytest suite; blocks direct push to `main` |

#### deno1a hooks

| Hook | Trigger | Checks |
|------|---------|--------|
| `pre-commit` | `git commit` | `deno fmt --check` + `deno lint` on staged TS/JS files; 5 MB file cap; debug-statement guard |
| `commit-msg` | After message | Conventional Commits format |
| `pre-push` | `git push` | `deno test -A` (when `deno.json` present); blocks direct push to `main` |

### Conventional Commits format

Both channels enforce:

```
<type>[(<scope>)][!]: <description>
```

Valid types: `feat`, `fix`, `chore`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `revert`

Examples:
```
feat(auth): add OAuth2 login
fix: handle null response from API
chore(deps): update deno to 2.1.0
feat!: remove deprecated login endpoint  (breaking change)
```

---

## 5. VCS Workflow

Rebase-only. No merge commits.

```
feature/xyz → develop → main → tag → release
```

### `mise run vcs:rebase`

Rebase the current feature branch onto `origin/develop`.

```bash
# From your feature branch:
mise run vcs:rebase
# → git fetch origin develop && git pull --rebase origin develop
```

### `mise run vcs:integrate [branch]`

Integrate a feature branch into `develop` via rebase (no merge commits).

```bash
mise run vcs:integrate feat/my-feature
# 1. git checkout feat/my-feature
# 2. git pull --rebase origin develop
# 3. git checkout develop && git pull origin develop
# 4. git rebase feat/my-feature  (fast-forward develop onto feature tip)
# 5. git push --force-with-lease origin develop
```

### `mise run vcs:release`

Release `develop` → `main` via rebase.

```bash
mise run vcs:release
# 1. git fetch origin develop main
# 2. git checkout main
# 3. git rebase origin/develop
# 4. git push --force-with-lease origin main
```

Then bump + tag:

```bash
mise run bump:patch     # (or :minor / :major)
mise run tag:push       # triggers release.yml
```

### `mise run vcs:protect`

Apply three idempotent branch rulesets via GitHub API (upsert by name):

| Ruleset | Target | Key rules |
|---------|--------|-----------|
| `branch-and-commit-restrictions` | `~ALL` | Signed commits, PR + code-owner, status checks, CodeQL gate, branch/commit naming |
| `develop-protection` | `refs/heads/develop` | Block create/update/delete/force-push |
| `main-protection` | `refs/heads/main` | Block create/update/delete/force-push |

Required status checks (configured by `vcs:protect`):
- `pr-check / lint`
- `pr-check / typecheck`
- `pr-check / test`
- `pr-check / security`
- `CodeQL`
- `code-scanning results / CodeQL`

```bash
mise run vcs:protect
```

---

## 6. Version and Bump

### Version format

Both channels use **bare semver** for release tags: `0.1.0` (no `v`-prefix).  
Pre-release tags include the label suffix: `0.1.5-alpha.1`.

### `mise run bump:patch` / `bump:minor` / `bump:major`

Fetch remote tags → compute next version → update version source → commit → create local annotated tag.

```
0.1.5  →(patch)→  0.1.6
0.1.5  →(minor)→  0.2.0
0.1.5  →(major)→  1.0.0
```

The tag is **not pushed** automatically. Push with `mise run tag:push`.

**python3a:** updates `[project] version` in `pyproject.toml` + regenerates `src/dev_patterns/version.py`  
**deno1a:** updates `.version` in `deno.json` + conditionally regenerates `src/version.ts`

### `mise run bump:prerel [label]`

```
0.1.5  →(prerel alpha)→  0.1.5-alpha.1
0.1.5  →(prerel rc)→     0.1.5-rc.1
```

### `mise run tag:push`

```bash
git push origin --tags
```

This triggers the `release.yml` workflow which compiles binaries (deno1a) or builds a Python package (python3a) and creates a GitHub Release.

---

## 7. Skeleton sync

The `skel/` directory in each channel holds canonical template files that are pushed to subscriber repos by `patterns:sync`. Files use `{{ skel.var }}` tokens for project-specific interpolation.

### Configuring skel variables

In the subscriber repo's `mise.toml`:

```toml
[skel.vars]
project_name        = "my-project"
project_description = "My Deno TypeScript project"
github_org          = "myorg"
repo_name           = "my-project"
deno_version        = "2.0.2"
codeowners          = "@myorg/team"
```

### `mise run sync:down`

Pull updated skel files from dev-patterns. Interpolates `{{ skel.var }}` tokens before writing.

- **In CI** (`CI=true`): creates `feature/sync-down-<date>` branch + opens draft PR
- **Locally**: prompts for confirmation before writing

```bash
mise run sync:down
SYNC_FORCE=true mise run sync:down     # force even if hash matches
SYNC_DRY_RUN=true mise run sync:down   # preview only
```

### `mise run sync:up`

Push newer local skel files back to dev-patterns. Only files listed in `[skel] files` in `mise.toml` that differ (by SHA-256) from the channel's `skel/` are uploaded. Creates a draft PR in dev-patterns.

```bash
mise run sync:up
SYNC_DRY_RUN=true mise run sync:up     # preview only
```

### Managed skel files (deno1a)

```
README.md
AGENTS.md
.github/CODEOWNERS
.github/PULL_REQUEST_TEMPLATE.md
.github/settings.yml
.github/workflows/ci.yml
.github/workflows/pr-check.yml
.github/workflows/dispatch-sync-down.yml
.github/workflows/dispatch-sync-up.yml
mise.toml
```

---

## 8. Scanning and security

### python3a

| Tool | Task | What it checks |
|------|------|----------------|
| Ruff | `mise run lint` | Python lint rules |
| Bandit | `mise run scan:sast` | Python security anti-patterns |
| pip-audit | `mise run scan:deps` | Known CVEs in Python dependencies |
| Lizard | CI `security` job | Cyclomatic complexity |
| CodeQL | `mise run scan:ghas` | Semantic code analysis (SARIF) |

### deno1a

| Tool | Task | What it checks |
|------|------|----------------|
| deno lint | `mise run lint:check` | TypeScript lint rules |
| deno audit | `mise run scan:deps` | Known CVEs in Deno/NPM dependencies |
| deno lint | `mise run scan:sast` | Security rules + hardcoded-secret heuristic |
| Custom | `mise run scan:complexity` | Cyclomatic complexity + function length |
| CodeQL | `mise run scan:ghas` | Semantic code analysis (SARIF) |

---

## 9. Dispatch workflows

GitHub Actions workflows that can be triggered manually via `gh workflow run` or the GitHub UI.

### `mise run dispatch:autobump [type] [--dry-run]`

Trigger `dispatch-autobump-release.yml`. Computes the next version, updates `deno.json`, regenerates `version.ts`, commits `[skip ci]`, creates + pushes the tag → triggers `release.yml`.

```bash
mise run dispatch:autobump              # auto (patch with cascade)
mise run dispatch:autobump minor
mise run dispatch:autobump major
mise run dispatch:autobump auto --dry-run
```

**Cascade logic (auto/patch):** patch overflows at 9 → bumps minor; minor overflows at 9 → bumps major.

### `mise run dispatch:configure [--dry-run]`

Trigger `dispatch-autoconfigure-rulesets.yml`. Applies all repository settings declaratively (description, topics, rulesets).

```bash
mise run dispatch:configure
mise run dispatch:configure --dry-run
```

### `mise run dispatch:ghas`

Trigger `ghas-scan.yml` CodeQL scan immediately.

```bash
mise run dispatch:ghas
```

---

## Environment variables reference

| Variable | Default | Description |
|----------|---------|-------------|
| `PATTERNS_REPO` | `orchestras/dev-patterns` | GitHub repo for patterns source |
| `PATTERNS_CHANNEL` | `python3a` | Channel to subscribe to |
| `PATTERNS_HASH` | _(written by sync)_ | Latest synced commit SHA |
| `GITHOOKS_REPO` | `orchestras/dev-patterns` | Repo to fetch hooks from |
| `GITHOOKS_VERSION` | `main` | Git ref/tag to pin hooks to |
| `GITHOOKS_PROFILE` | `python3a` | Channel subfolder for hooks |
| `DENO_TLS_CA_STORE` | `system,mozilla` | (deno1a) Native TLS for corporate proxies |
| `DENO_DIR` | `.deno-cache` | (deno1a) Deno module cache directory |
| `SYNC_FORCE` | `false` | Force `sync:down` even if hash matches |
| `SYNC_DRY_RUN` | `false` | Preview only — no writes, no PRs |
| `CCN` | `15` | Complexity threshold for `scan:complexity` |
| `MAX_LINES` | `100` | Function length threshold |
| `MAX_ARGS` | `8` | Function argument count threshold |
