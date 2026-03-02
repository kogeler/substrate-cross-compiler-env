# AGENTS.md

## Repository Purpose

`substrate-cross-compiler-env` is an infrastructure repository used to:

- build Docker toolchain environments for `polkadot-sdk` and its forks;
- build selected binaries (`polkadot`, `substrate-node`, etc.) in GitHub Actions;
- publish binaries to GitHub Releases;
- build and publish runtime Docker images with those binaries to GHCR.

This repository does not store `polkadot-sdk` source as part of its own codebase. It builds from an external Git repository defined in `config.yml`.

## Repository Structure

Key files:

- `README.md` - basic local build workflow.
- `config.yml` - source of truth for CI build profiles.
- `.github/workflows/docker-images.yml` - builds and publishes the `substrate-cross-compiler-env` image.
- `.github/workflows/polkadot.yml` - builds binaries/releases/runtime images from profiles in `config.yml`.
- `dockerfiles/Dockerfile-env-amd64` - main CI toolchain image (Debian + Rust + Clang + Docker tooling).
- `dockerfiles/Dockerfile-env-aarch64` - separate local cross-compile environment for `aarch64`.
- `dockerfiles/Dockerfile-env-test` - smoke-test Dockerfile that verifies the env image can build `polkadot`.
- `dockerfiles/Dockerfile-amd64` - runtime image that packages a built binary.
- `build-env.sh` - local helper for building an env image.
- `run-env.sh` - local helper for running the env container with mounted cargo/git volumes.

Working/cache directories (local infrastructure, not repository logic):

- `git/` - local clones of external projects (for example `polkadot-sdk`).
- `cargo_home_git/`, `cargo_home_registry/`, `cargo_target_*` - cargo caches and build artifacts.
- `.gitignore` excludes `.idea`, `git`, and `cargo_*`.

## `config.yml` Model

`config.yml` is a map where each top-level key is a build profile name.

Current profile:

- `last-release`

Required fields for each profile:

- `code_git_repo` - GitHub repo in `owner/repo` format;
- `code_git_ref` - branch/tag/ref to checkout;
- `debian-versions` - list of Debian base versions;
- `rust-versions` - list of Rust versions;
- `clang-versions` - list of Clang versions;
- `rustc-targets` - list of `target-cpu` values;
- `components` - list of binaries/components to build for this profile.

Important: `components` belong to the selected profile. When a profile is chosen, all of its components are built.

## CI Logic: `docker-images.yml`

Workflow goal: build and publish the toolchain env image.

Flow:

1. Expand matrix by `debian-versions`, `rust-versions`, and `clang-versions`.
2. Build env image with `Dockerfile-env-amd64`.
3. Run smoke test using `Dockerfile-env-test` (sample `polkadot` build).
4. Push env image to `ghcr.io/<owner>/substrate-cross-compiler-env:debian-...-rust-...-clang-...`.

## CI Logic: `polkadot.yml`

Workflow goal: build binaries from an external repository and publish binaries + runtime images.

Trigger:

- `workflow_dispatch` with input `builds`.

`builds` input:

- `all` (default) - include all profiles from `config.yml`;
- CSV list (`profile-a,profile-b`) - include only listed profiles.

`setup-matrix` job:

- Python script reads `config.yml`;
- validates profile names and profile structure;
- expands the full matrix:
  `debian-versions x rust-versions x clang-versions x rustc-targets x components`;
- exports matrix for `build-binaries`.

`build-binaries` job:

1. Runs inside the matching env image.
2. Checks out target code (`code_git_repo`, `code_git_ref`).
3. Builds the specific component from matrix.
4. Collects artifacts.
5. Creates/uses GitHub Release (`tag_name = code_git_ref`).
6. Uploads binaries to the release.
7. Builds runtime Docker image (`Dockerfile-amd64`) from built artifact.
8. Pushes runtime image to GHCR.

## Local Workflow (without GitHub Actions)

1. Build env image:
   `./build-env.sh <debian-version> <arch>`
2. Run env container:
   `./run-env.sh <debian-version> <arch>`
3. Run `cargo build` inside the container in the external source repository.

## Agent Rules

- Change build targets/versions/refs through `config.yml` when the task is configuration-related.
- Add a new profile key for a new release set instead of modifying existing profiles unless explicitly requested.
- Do not commit or edit local cache/clone folders (`git/`, `cargo_*`) as part of feature changes.
- When editing workflows, keep matrix field names and environment variables consistent across jobs/steps.
- If adding a new `component`, ensure `Build binaries` has the corresponding build/copy branch for it.

## Quick Change Checklist

1. Update `config.yml` (profile/versions/components).
2. Update `Dockerfile-env-amd64` if toolchain/dependencies changed.
3. Update `polkadot.yml` if matrix or component build logic changed.
4. Validate YAML syntax.
5. Confirm expected image tags and binary naming.
