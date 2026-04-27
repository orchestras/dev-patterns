<!-- markdownlint-disable MD041 MD012 -->

# {{ skel.project_name }}

> {{ skel.project_description }}

A batteries-included Deno project template modelled after [orchestras/python3](https://github.com/orchestras/python3). All automation lives in `.mise/tasks/` as executable scripts, making tasks portable via the `deno1a` channel in [orchestras/dev-patterns](https://github.com/orchestras/dev-patterns). Git hooks are managed via the same channel.

[![CI](https://img.shields.io/github/actions/workflow/status/{{ skel.github_org }}/{{ skel.repo_name }}/ci.yml?branch=develop&label=CI)](../../actions/workflows/ci.yml)
[![GHAS](https://img.shields.io/github/actions/workflow/status/{{ skel.github_org }}/{{ skel.repo_name }}/ghas-scan.yml?label=GHAS)](../../actions/workflows/ghas-scan.yml)
[![mise](https://img.shields.io/badge/managed%20by-mise-blue)](https://mise.jdx.dev/)

---

## Features

| Tool | Role |
|------|------|
| [Deno 2](https://deno.com) | TypeScript runtime + built-in lint/fmt/test/check |
| [Mise](https://mise.jdx.dev) | Tool version manager + task runner |
| [GHAS / CodeQL](https://github.com/features/security) | GitHub Advanced Security scanning |
| [Dependabot](https://docs.github.com/en/code-security/dependabot) | Automated dependency updates |
| [dev-patterns deno1a](https://github.com/orchestras/dev-patterns) | Shared hooks + task channel |

---

## Quick Start

```bash
# 1. Install mise
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc && source ~/.bashrc

# 2. Clone and initialise
git clone https://github.com/{{ skel.github_org }}/{{ skel.repo_name }} my-project
cd my-project

# 3. Full project init (installs tools, syncs version, configures git, installs hooks)
mise run project:init

# 4. Run the app
mise run execute
```

---

## Task Reference

Run `mise tasks` to list all tasks with descriptions. All tasks live in `.mise/tasks/`.

### Development

```bash
mise run execute      # deno run src/mod.ts
mise run build        # regenerate src/version.ts from deno.json version
mise run install      # cache all Deno dependencies
```

### Code Quality

```bash
mise run lint:check   # deno lint
mise run lint:fix     # deno lint --fix
mise run fmt:fix      # deno fmt
mise run fmt:check    # deno fmt --check (CI-safe, exits non-zero if unformatted)
mise run typecheck    # deno check src/mod.ts
```

### Testing

```bash
mise run test               # deno test -A --reporter=pretty
mise run test [filter]      # run tests matching a filter string
```

### CI

```bash
mise run ci           # full pipeline: lint:check → fmt:check → typecheck → test → build → execute
```

### Scanning & SAST

```bash
mise run scan:deps        # deno audit — known vulnerability check
mise run scan:sast        # deno lint with security rules + hardcoded-secret heuristics
mise run scan:complexity  # cyclomatic complexity analysis
mise run scan:ghas        # trigger CodeQL via GitHub Actions (local dispatch)
```

### Version Bumping

```bash
mise run version:show       # show current version from deno.json
mise run bump:patch         # v0.1.5 → v0.1.6  (auto-cascades at 9)
mise run bump:minor         # v0.1.5 → v0.2.0
mise run bump:major         # v0.1.5 → v1.0.0
mise run bump:prerel alpha  # v0.1.5 → v0.1.5-alpha.1
mise run tag:push           # push tags → triggers release.yml
```

### Dispatch Workflows

```bash
mise run dispatch:autobump [auto|patch|minor|major] [--dry-run]
# → triggers dispatch-autobump-release.yml on GitHub Actions

mise run dispatch:configure [--dry-run]
# → triggers dispatch-autoconfigure-rulesets.yml (3 branch rulesets)

mise run dispatch:ghas
# → triggers ghas-scan.yml
```

### Patterns & Skeleton Sync

```bash
mise run patterns:sync      # sync hooks + tasks from dev-patterns deno1a channel
mise run sync:down          # pull updated skel files from dev-patterns into a PR branch
mise run sync:up            # push newer local files back to dev-patterns in a PR branch
```

### Git & VCS

```bash
mise run git:config              # configure delta, GPG, rebase-only, hooks path
mise run vcs:rebase              # rebase feature branch onto origin/develop
mise run vcs:integrate feat/xyz  # integrate feature → develop (rebase, no merge commits)
mise run vcs:release             # release develop → main (rebase + force push)
mise run vcs:protect             # apply 3 branch rulesets via GitHub API
```

### Git Hooks

```bash
mise run hooks:sync     # sync hooks from orchestras/dev-patterns (deno1a channel)
mise run hooks:install  # register config/githooks/hooks path in git config
```

### Binary Compilation

```bash
mise run deno:compile   # cross-compile binaries for all 5 platforms to ./bin/
mise run deno:upgrade   # update all deno.json dependencies to latest
```

> For automated cross-platform release binaries, push a version tag — the
> [release workflow](.github/workflows/release.yml) compiles on Linux AMD64/ARM64,
> macOS ARM64/AMD64, and Windows AMD64 in parallel and publishes a GitHub Release.

---

## Project Structure

```
.
├── .github/
│   ├── workflows/           # CI/CD pipelines
│   ├── dependabot.yml       # Dependabot config
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── CODEOWNERS
├── .mise/
│   └── tasks/               # All mise tasks (executable scripts)
│       ├── execute, test, typecheck, build, ci, install, completions
│       ├── bump/patch, minor, major, prerel
│       ├── tag/push, list, sync, remote, fetch, create, clean
│       ├── vcs/rebase, integrate, release, protect
│       ├── version/show, sync, init
│       ├── scan/ghas, deps, sast, complexity
│       ├── hooks/sync, install
│       ├── git/config
│       ├── gh/token
│       ├── deno/compile, upgrade
│       ├── fmt/fix, check
│       ├── lint/check, fix
│       ├── patterns/sync
│       ├── sync/down, up
│       ├── secrets/init, resolve
│       ├── npm/set-registry, reset-registry
│       ├── dispatch/autobump, configure, ghas
│       └── project/init
├── config/
│   └── githooks/
│       ├── hooks/           # Git hooks (commit-msg, pre-commit, pre-push)
│       └── githooks.toml    # Channel manifest
├── scripts/                 # Shared bash utilities (colors, semver, secrets)
├── src/
│   ├── mod.ts               # Application entry point
│   ├── version.ts           # Auto-generated — do not edit manually
│   ├── make_version.ts      # Build script: generates version.ts from deno.json
│   └── tests/
│       └── mod.test.ts      # Test suite
├── AGENTS.md                # AI agent instructions
├── CHANGELOG.md             # Changelog
├── CONTRIBUTING.md          # Contributor guide
├── deno.json                # Deno config (imports, lint, fmt, tasks)
└── mise.toml                # Tool versions + task discovery
```

---

## Branch Workflow

```
feature/xyz → develop → main → tag → release
```

**No merge commits.** Every integration is a rebase.

### Keep your feature branch current

```bash
mise run vcs:rebase
# → git pull --rebase origin develop
```

### Integrate a feature branch into develop

```bash
mise run vcs:integrate feat/my-feature
# 1. Rebase feature onto origin/develop
# 2. git checkout develop && git pull
# 3. git rebase feat/my-feature
# 4. git push --force-with-lease origin develop
```

### Release develop → main

```bash
mise run vcs:release
# 1. git checkout main
# 2. git rebase origin/develop
# 3. git push --force-with-lease origin main
```

Then bump and tag:

```bash
mise run bump:patch   # (or :minor / :major)
mise run tag:push     # triggers binary + Docker release CI
```

---

## GitHub Status Checks Setup

For required status checks in branch rulesets to work:

1. Push this template to GitHub (on `develop` branch)
2. Open one PR to trigger the `pr-check` workflow — this registers the check names
3. Run `mise run vcs:protect` to apply the ruleset via GitHub API
4. The following checks will be required:
   - `pr-check / lint`
   - `pr-check / typecheck`
   - `pr-check / test`
   - `pr-check / security`

---

## Supported Platforms

darwin (amd64, arm64) · linux (amd64, arm64) · windows (amd64)

---

## License

MIT © [ørchestras](https://github.com/orchestras) 2025
