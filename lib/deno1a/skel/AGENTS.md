# AGENTS.md

## Cursor Cloud Agent Instructions

### Overview

Deno 2 TypeScript template managed by **mise en place**. All tasks in
`.mise/tasks/` as executable scripts. Run `mise tasks` for the full
auto-documented list.

Patterns channel: **`deno1a`** from [orchestras/dev-patterns](https://github.com/orchestras/dev-patterns).

### Key commands

```sh
mise run execute          # run app (deno run src/mod.ts)
mise run build            # regenerate src/version.ts from deno.json
mise run install          # cache Deno dependencies
mise run lint:check       # deno lint
mise run lint:fix         # auto-fix lint issues
mise run fmt:fix          # deno fmt
mise run fmt:check        # check formatting (CI-safe)
mise run typecheck        # deno check src/mod.ts
mise run test             # deno test -A --reporter=pretty
mise run ci               # full CI pipeline (lint:check → fmt:check → typecheck → test → build → execute)

mise run version:show     # show current version
mise run version:sync     # fetch remote tags, sync deno.json + version.ts
mise run bump:patch       # bump from latest remote tag (v-prefix, e.g. v0.1.5 → v0.1.6)
mise run bump:minor       # v0.1.5 → v0.2.0
mise run bump:major       # v0.1.5 → v1.0.0
mise run tag:push         # push tags to origin → triggers release.yml
mise run vcs:rebase       # rebase current branch onto origin/develop
mise run vcs:integrate    # integrate feature branch into develop (rebase, no merge commits)
mise run vcs:release      # rebase main onto develop, push
mise run vcs:protect      # apply 3 branch rulesets via GitHub API

mise run scan:ghas        # trigger CodeQL scan via workflow dispatch
mise run scan:sast        # SAST + secret heuristics
mise run scan:complexity  # cyclomatic complexity analysis
mise run scan:deps        # deno audit — dependency vulnerability check

mise run dispatch:autobump [auto|patch|minor|major]  # trigger GitHub autobump workflow
mise run dispatch:configure [--dry-run]              # trigger GitHub repo autoconfigure workflow
mise run dispatch:ghas                               # trigger GHAS CodeQL scan

mise run hooks:sync       # sync hooks from orchestras/dev-patterns (deno1a)
mise run hooks:install    # register config/githooks/hooks path in git config
mise run patterns:sync    # full sync: tasks + hooks + skel from dev-patterns channel
mise run sync:down        # pull updated skel files from dev-patterns into a feature PR branch
mise run sync:up          # push newer local files back to dev-patterns skel in a PR branch
```

### Task structure

All tasks live in `.mise/tasks/` as executable scripts (not inline TOML).
Task directories use `:` (colon) for namespacing when referenced:

- `execute`, `test`, `typecheck`, `build`, `ci`, `install`, `completions` — core
- `lint/check`, `lint/fix` — lint tasks
- `fmt/fix`, `fmt/check` — formatting tasks
- `dispatch/autobump`, `dispatch/configure`, `dispatch/ghas` — workflow triggers
- `bump/patch`, `bump/minor`, `bump/major`, `bump/prerel` — versioning
- `tag/push`, `tag/list`, `tag/sync`, `tag/fetch`, `tag/remote`, `tag/create`, `tag/clean`
- `vcs/rebase`, `vcs/integrate`, `vcs/release`, `vcs/protect`
- `version/show`, `version/sync`, `version/init`
- `scan/ghas`, `scan/deps`, `scan/sast`, `scan/complexity`
- `hooks/sync`, `hooks/install`
- `sync/down`, `sync/up` — skeleton file sync
- `git/config`, `gh/token`
- `deno/compile`, `deno/upgrade`
- `patterns/sync`
- `secrets/init`, `secrets/resolve`
- `npm/set-registry`, `npm/reset-registry`
- `project/init`

### Version management

All version tags use `v`-prefix (`v0.1.0`, not `0.1.0`). Version is stored in
`deno.json` and mirrored to `src/version.ts` via `mise run build`.

```sh
mise run version:show     # read from deno.json
mise run bump:patch       # v0.1.5 → v0.1.6 (updates deno.json, version.ts, commits, tags)
mise run tag:push         # push tag → release.yml compiles + publishes GitHub Release
```

### Important rules

1. **Never edit `src/version.ts` manually** — always use `mise run build` or bump tasks
2. **Never merge branches** — always rebase: `mise run vcs:rebase`
3. **Version bump + tag in one step** — bump tasks commit + tag; push separately with `mise run tag:push`
4. **Skel files** — files in the `[skel]` section of `mise.toml` are managed by `patterns:sync`
   and `sync:down`. Do not manually edit them; submit changes via `mise run sync:up` instead.
5. **CI task name** — the CI task file is `.mise/tasks/ci` (invoked as `mise run ci`); the
   channel also provides `ci/all` as an alias from dev-patterns.

### Git workflow

```
feature/xxx → develop → main → vX.Y.Z tag → release
```

- Feature branches target `develop`
- `main` is always releasable and protected (linear history, signed commits required)
- `develop` is the integration branch; PRs require 1 approval + passing status checks
- Tags trigger `.github/workflows/release.yml` which cross-compiles + publishes a GitHub Release
