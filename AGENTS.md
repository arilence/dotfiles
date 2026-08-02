# Repository Instructions

## Nix package fixes

Before backporting or locally patching packaged software, check whether the fix is already available from a newer package in the repository's configured Nixpkgs channels.

Use this order:

1. Identify the version in the current lock file.
2. Check the target Nixpkgs branch, relevant backports, and open or merged update pull requests.
3. Prefer a targeted lock-file update or another binary-cached Nixpkgs package when it already contains the fix.
4. Only add a source patch or trigger a local package build after cached package options have been ruled out, or when the user explicitly chooses that tradeoff.

For potentially large source builds, explain the expected compilation and download cost before starting. Do not assume that building a patched dependency locally is acceptable merely because the patch is technically correct.
