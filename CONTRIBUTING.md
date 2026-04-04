# Contributing to cherrytree_flutter

Thanks for helping. This project is **GPLv3** — see [`LICENSE`](LICENSE). It is **not** the official [CherryTree](https://github.com/giuspen/cherrytree) desktop app; keep this codebase separate unless you are explicitly contributing upstream there.

## Before you open a pull request

1. Read **[`AGENTS.md`](AGENTS.md)** — boundaries (platforms, scope, style) and verify commands.
2. Check **[`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md)** — prefer work that maps to an open checkbox or a filed issue so direction stays aligned.
3. Run locally (same as CI):
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```
   Integration tests under `integration_test/` need a device/emulator; they are **not** run in CI yet.

## Pull request expectations

- **Small, focused diffs** — one feature or fix per PR when possible.
- **No drive-by refactors** or unrelated dependency bumps; discuss larger changes in an issue first.
- **Update docs** when behavior is user-visible: [`CHANGELOG.md`](CHANGELOG.md) under **Unreleased**, and [`PATH_OF_ATTACK.md`](PATH_OF_ATTACK.md) if you complete a planned item.
- **License**: contributed code must be compatible with **GPLv3**.

## Reviews and CI

- Pull requests should pass **[GitHub Actions](.github/workflows/ci.yml)** (`flutter analyze`, `flutter test`).

## Branch protection on `main`

The default branch is protected. In practice that means:

| Rule | What you need to do |
| ---- | -------------------- |
| **Pull request required** | Open a PR; do not push directly to `main`. |
| **Approvals** | At least one approving review before merge. |
| **Code Owners** | A review from someone listed in [`.github/CODEOWNERS`](.github/CODEOWNERS) is required. |
| **Signed commits** | Commits must be **signed** (GPG or SSH) and show as “Verified” on GitHub. Configure signing on your machine, then rebase or amend if older commits are unsigned. See [Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits) and [Displaying verification for all commits](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rules-for-repositories/about-rule-sets#require-signed-commits). |

Squash-merge still counts as long as the resulting commit satisfies the rule (GitHub documents behavior for squash vs merge — prefer signing locally before pushing your branch).

## Security

- Do not commit secrets, keystores, or API keys.
- Scrutinize changes to `pubspec.yaml` / `pubspec.lock`, native projects, and anything that touches the network or file system.

## Questions

Open a [GitHub issue](https://github.com/huubee/cherrytree-flutter/issues) for bugs, features, or design discussion. For day-to-day engineering detail, see also [`DEVELOPMENT_GUIDELINES.md`](DEVELOPMENT_GUIDELINES.md) and [`AI_DEVELOPMENT.md`](AI_DEVELOPMENT.md).
