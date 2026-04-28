# dev-patterns

> Central patterns library for orchestras repositories — git hooks, mise tasks, and channel subscriptions

Distributes git hooks, mise tasks, and skeleton files to subscriber repos via declarative channel subscriptions. No YAML, no Node.js, no lefthook required.

[![CI](https://img.shields.io/github/actions/workflow/status/orchestras/dev-patterns/ci.yml?branch=main&label=CI)](../../actions/workflows/ci.yml)
[![Coverage](https://img.shields.io/badge/coverage-81%25-green)](../../actions)
[![Python](https://img.shields.io/badge/python-3.12%2B-blue)](https://python.org)
[![mise](https://img.shields.io/badge/managed%20by-mise-blue)](https://mise.jdx.dev/)

---

## Channels

| Channel | Stack | Description |
|---------|-------|-------------|
| `python3a` | Python · UV · Ruff · Ty | Python 3.12+ projects |
| `deno1a` | Deno 2 · TypeScript · Mise | Deno TypeScript projects |

Each channel ships: **hooks** (`pre-commit`, `commit-msg`, `pre-push`) + **mise tasks** + **skel files** (canonical project templates with `{{ skel.var }}` interpolation).

---

## Quick Start

### Bootstrap a new repo

```bash
# Using gh CLI (preferred — works for private repos):
gh api repos/orchestras/dev-patterns/contents/scripts/sync_patterns.sh \
  --jq '.content' | base64 -d > scripts/sync_patterns.sh
chmod +x scripts/sync_patterns.sh && ./scripts/sync_patterns.sh

# Using curl (public repos):
curl -sSfL \
  https://raw.githubusercontent.com/orchestras/dev-patterns/main/scripts/sync_patterns.sh \
  -o scripts/sync_patterns.sh && chmod +x scripts/sync_patterns.sh && ./scripts/sync_patterns.sh
```

### Sync an existing repo

```bash
mise run patterns:sync       # pull latest tasks + hooks + skel
mise run patterns:check-hash # check if stale; auto-syncs
```

### Pin to a specific version

Set in `mise.toml [env]`:

```toml
GITHOOKS_VERSION = "0.1.6"   # pin to a release tag
```

Or in `.githooks-version`:
```
orchestras/dev-patterns/python3a/0.1.6
```

---

## Version-spec resolution

Priority chain (first match wins):

1. `PATTERNS_REPO` + `PATTERNS_CHANNEL` env vars
2. `mise.toml [env]` → `GITHOOKS_REPO`, `GITHOOKS_VERSION`, `GITHOOKS_PROFILE`
3. `.githooks-version` — new format: `org/repo/channel/version`
4. `.githooks-version` — legacy format: `0.1.12` (pulls GitHub Release tarball)
5. Built-in defaults: `orchestras/dev-patterns`, `python3a`, `main`

---

## Channel structure

```
lib/
  <channel>/
    hooks/
      githooks.toml    # declarative hook manifest
      pre-commit
      commit-msg
      pre-push
    mise/
      mise.toml        # channel env vars + [skel] registry
      tasks/           # all mise tasks as executable scripts
    skel/              # canonical project template files
      README.md
      AGENTS.md
      .github/
        CODEOWNERS
        PULL_REQUEST_TEMPLATE.md
        settings.yml
        workflows/
```

---

## Task Reference

See **[API.md](API.md)** for the complete reference. Quick summary:

```bash
# Channel subscription
mise run patterns:setup      # interactive subscribe wizard
mise run patterns:sync       # pull latest (skips if .patterns-hash is current)
mise run patterns:subscribe  # non-interactive subscribe
mise run patterns:check-hash # lazy hash check; auto-syncs if stale

# Skeleton sync (deno1a)
mise run sync:down           # pull updated skel files from dev-patterns → PR
mise run sync:up             # push newer local files to dev-patterns → PR

# Code quality (python3a)
mise run lint && mise run fmt:check && mise run typecheck && mise run test:cov

# Code quality (deno1a)
mise run lint:check && mise run fmt:check && mise run typecheck && mise run test

# Versioning — bare semver tags (0.1.0, not v0.1.0)
mise run bump:patch          # 0.1.5 → 0.1.6
mise run bump:minor          # 0.1.5 → 0.2.0
mise run bump:major          # 0.1.5 → 1.0.0
mise run bump:prerel alpha   # 0.1.5 → 0.1.5-alpha.1
mise run tag:push            # push tags → trigger release CI

# VCS (rebase-only, no merge commits)
mise run vcs:rebase                    # rebase feature → origin/develop
mise run vcs:integrate feat/my-feature # integrate feature → develop
mise run vcs:release                   # develop → main
mise run vcs:protect                   # apply 3 branch rulesets via GitHub API
```

---

## Project structure

```
.
├── .github/
│   ├── settings.yml          # Declarative repo settings (3-ruleset config)
│   └── workflows/            # CI/CD pipelines
├── .mise/tasks/              # Mise task scripts for this repo
├── config/githooks/hooks/    # Installed git hooks
├── lib/
│   ├── python3a/             # Python 3 channel
│   └── deno1a/               # Deno channel
│       ├── hooks/            # Hook scripts + githooks.toml
│       ├── mise/             # mise.toml + tasks/
│       └── skel/             # Skeleton template files
├── scripts/
│   ├── sync_patterns.sh      # Bootstrap wrapper
│   └── sync_patterns.py      # Standalone sync (stdlib-only, Python 3.12+)
├── src/dev_patterns/         # Python package
│   ├── commands/             # CLI: sync, hooks
│   ├── core/                 # Base classes + console UI
│   ├── hooks/                # HookManifest + HookInstaller
│   ├── sync/                 # SyncEngine + GitHubClient
│   └── version_spec/         # VersionSpecResolver
├── tests/                    # 85 pytest tests, 80%+ coverage
├── API.md                    # Complete task API reference
├── AGENTS.md                 # AI agent instructions
└── CHANGELOG.md
```

---

## Branch workflow

```
feature/xyz → develop → main → tag → release
```

No merge commits — every integration is a rebase.

```bash
mise run vcs:rebase                    # keep feature branch current
mise run vcs:integrate feat/my-feature # land feature on develop
mise run vcs:release                   # develop → main
mise run bump:patch && mise run tag:push  # tag + publish release
```

---

## Security

Branch protection is enforced via three GitHub rulesets applied by `mise run vcs:protect`:

- **`branch-and-commit-restrictions`** (all branches): signed commits, PR required, CodeQL gate, conventional-commit naming
- **`develop-protection`**: blocks direct pushes
- **`main-protection`**: blocks direct pushes

Required PR status checks: `pr-check / lint`, `pr-check / typecheck`, `pr-check / test`, `pr-check / security`, `CodeQL`
