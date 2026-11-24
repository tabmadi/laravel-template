# ADR-0111: Composer dependencies

- **Status:** Accepted
- **Decides:** Composer owns the PHP lock, and the Nix vendor builder provides the packages for the offline checks.

## Context

Laravel and the PHP tools need the same packages in the dev shell and CI. The Nix checks run without network access.

## Decision drivers

1. **One lock.** Local and CI use the same Composer versions.
2. **Sandbox.** Packages enter the check as an input.
3. **App boot.** The check can run Laravel package discovery in a writable tree.
4. **Updates.** Renovate can update the lock and its Nix hash.

## Considered options

| Option | 1 One lock | 2 Sandbox | 3 App boot | 4 Updates | Verdict |
| --- | --- | --- | --- | --- | --- |
| Composer install from the network in CI | Yes | Needs network access in the check | Composer hooks run normally | Renovate updates the lock | Fits a networked CI job |
| Commit the vendor directory | Yes | Yes | Composer can build its autoloader in a copy | Updates include a large vendor diff | Fits a repo that must keep copies of its packages |
| **Composer and the Nix vendor builder** | Yes | Yes, with a fixed output hash | The check runs package discovery in its work tree | Renovate can call `just deps-sync` | **Chosen** |

### Sources

- [Composer lock usage](https://getcomposer.org/doc/01-basic-usage.md), [Nixpkgs PHP builders](https://nixos.org/manual/nixpkgs/unstable/#sec-php), and [Renovate Composer manager](https://docs.renovatebot.com/modules/manager/composer/).
- [Laravel package discovery](https://laravel.com/docs/13.x/packages#package-discovery) and the inherited update workflow in [ADR-0102](0102-dependency-updates.md).

## Decision

Composer installs from `composer.lock`. Its normal project script runs `artisan package:discover` after an autoload change.

Nix fetches locked packages with `php.mkComposerVendor`, with dev packages enabled. The check copies the vendor input, restores the autoloader, and runs package discovery offline.

The hash lives in `nix/composer-vendor-hash`. Renovate calls `just deps-sync` when its changes affect the vendor input.

## Consequences

A manifest, lock, or toolchain change can change the vendor hash. Laravel can write package and view caches within the test tree.

## Rules

- Commit `composer.lock` and the matching vendor hash. `(CI: lint-php)`
- Package discovery and all application checks run in the writable sandbox tree. `(CI: ci)`
