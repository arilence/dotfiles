# Repository Instructions

## Nix package fixes

Renovate manages this repository's lock file. Only update it when the user explicitly requests a lock-file update. If a package or fix is available in a newer Nixpkgs revision but missing from the locked revision, tell the user the pin is out of date and identify the revision or version that provides it. Leave the update to Renovate by default.

Before backporting or locally patching packaged software, check whether the fix is already available from a newer package in the repository's configured Nixpkgs channels.

Use this order:

1. Identify the version in the current lock file.
2. Check the target Nixpkgs branch, relevant backports, and open or merged update pull requests.
3. If a newer package already contains the fix, report it to the user and follow the lock-file policy above.
4. Only add a source patch or trigger a local package build after cached package options have been ruled out, or when the user explicitly chooses that tradeoff.

For potentially large source builds, explain the expected compilation and download cost before starting. Do not assume that building a patched dependency locally is acceptable merely because the patch is technically correct.

## Git Commits

- Use the [Conventional Commits](https://www.conventionalcommits.org/) format for every commit message.
- Keep each commit focused on a single logical change. Avoid mixing unrelated refactors, formatting, or behavior changes.
- Do not commit secrets, credentials, local environment files (such as `.env`), or generated build artifacts.
