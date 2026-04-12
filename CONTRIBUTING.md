# Contributing to solidity-scale-codec

Thank you for your interest in contributing! This document explains the workflow for contributors and maintainers.

## Getting Started

1. Fork the repository and clone it locally.
2. Install dependencies:
   ```bash
   npm ci
   ```
3. Run the tests to make sure everything works:
   ```bash
   npm test
   ```

## Making Changes

### Branching

Create a branch from `main` for your changes:

```bash
git checkout -b feat/my-feature
```

### Code Style

Before opening a PR, make sure your Solidity code passes the linter:

```bash
npm run lint:solhint
```

And is formatted correctly:

```bash
npm run format:prettier:check
```

---

## Describing Your Change (Changesets)

This project uses [Changesets](https://github.com/changesets/changesets) to manage versioning and changelogs. **Every PR that changes behavior must include a changeset.**

### What is a changeset?

A small markdown file in `.changeset/` that describes what changed and whether it is a `patch`, `minor`, or `major` bump:

| Type    | When to use                       |
| ------- | --------------------------------- |
| `patch` | Bug fix, no API change            |
| `minor` | New feature, backwards compatible |
| `major` | Breaking change                   |

### Adding a changeset

Run:

```bash
npx changeset
```

The CLI will ask you to select the bump type and write a short description. This creates a file like `.changeset/happy-lions-fly.md` — commit it alongside your changes.

Alternatively, create it manually:

```md
---
"solidity-scale-codec": patch
---

Fix encoding bug for negative int8 values.
```

> PRs without a changeset will not be merged unless the change is purely non-functional (e.g. docs, CI, tests).

---

## CI Checks

All PRs run the following checks automatically:

- **Tests** — `npm test` via Hardhat
- **Docs build** — `npm run docs:build` to verify documentation compiles
- **Lint** — `npm run lint:solhint`

All three must pass before a PR can be merged.

---

## Release Process (Maintainers Only)

Releases are fully automated via Changesets and GitHub Actions.

When PRs with changesets are merged into `main`, a bot automatically opens a **"Version Packages" PR** that:

- Bumps `package.json` version
- Aggregates all changeset descriptions into `CHANGELOG.md`
- Deletes the consumed `.changeset/*.md` files

When a maintainer merges that PR, the release workflow publishes to npm and creates a GitHub Release automatically.

**You do not need to run `npm version` or `git push --follow-tags` manually.**
