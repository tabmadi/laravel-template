# Every task, per ADR-0103. A recipe that calls a tool runs only inside the dev shell of flake.nix.

set shell := ["bash", "-euo", "pipefail", "-c"]

import? 'template/justfile'

# List the recipes
default:
    @just --list

pint := "php vendor/bin/pint --config .config/pint.json"
blade := "blade-formatter --config .config/blade-formatter.json"

# Install dependencies and prepare the local app
setup: in-shell
    composer install --no-interaction --prefer-dist
    if [[ ! -e .env ]]; then umask 077; cp .env.example .env; fi
    if grep -qx 'APP_KEY=' .env; then php artisan key:generate --no-interaction; fi
    test -e database/database.sqlite || touch database/database.sqlite
    php artisan migrate --no-interaction

# Start the Laravel development server
[positional-arguments]
dev host="127.0.0.1" port="8000": in-shell
    php artisan serve --host="$1" --port="$2"

# Apply every formatter
format: in-shell
    {{ pint }} . artisan
    {{ blade }} --write 'resources/views/**/*.blade.php'
    rumdl check --fix .
    nixfmt $(git ls-files '*.nix')
    dprint fmt
    just --fmt

# Check the Composer lock, PHP and Blade format, and PHP types
lint-php: in-shell
    composer validate --strict
    composer check-platform-reqs --lock
    {{ pint }} --test . artisan
    {{ blade }} --check-formatted 'resources/views/**/*.blade.php'
    APP_ENV=testing php vendor/bin/phpstan analyse --configuration=.config/phpstan.neon --memory-limit=512M --no-progress

# Prose, comments, and ADRs, per ADR-0001
lint-prose: in-shell
    tabkit check

# Markdown structure and formatting, per ADR-0001
lint-md: in-shell
    rumdl check .

# Scan the working tree for committed secrets
lint-secrets: in-shell
    gitleaks dir . --config .config/gitleaks-local.toml --no-banner

# JSON, JSONC, TOML, and YAML format, per ADR-0104
lint-data: in-shell
    dprint check

# Nix format, per ADR-0104
lint-nix: in-shell
    nixfmt --check $(git ls-files '*.nix')

# justfile format, per ADR-0104
lint-just:
    just --fmt --check

# Run every linter
lint: lint-php lint-prose lint-md lint-secrets lint-data lint-nix lint-just

# Run the tests
test: in-shell
    APP_ENV=testing php vendor/bin/phpunit --bootstrap vendor/autoload.php tests

# The fast gate: run it before you finish a change
check: lint test

# Run exactly what CI runs: every check of flake.nix, in the Nix sandbox
ci:
    nix flake check --print-build-logs

# Push what CI built to the binary cache, per ADR-0101. Without NIX_CACHE_URL it does nothing
cache-push: in-shell
    nix-cache-push

# Make the labels of the forge match .github/labels.yml, per ADR-0101. It deletes every other label
labels: in-shell
    tabkit-labels --prune

# Run Renovate over this repository, per ADR-0102. The renovate workflow calls it
ci-renovate: in-shell
    nix run --inputs-from . nixpkgs#renovate

# Refresh the Nix vendor hash after a Composer lock or toolchain change
deps-sync: in-shell
    #!/usr/bin/env bash
    set -euo pipefail
    hash_file=nix/composer-vendor-hash
    probe=$(nix eval --raw .#composer-vendor --apply '
      vendor: (vendor.overrideAttrs (_: {
        outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      })).drvPath
    ')
    build_log=$(nix build --no-link "$probe^*" 2>&1) || true
    hash=$(sed -nE 's/^[[:space:]]*got:[[:space:]]+(sha256-[A-Za-z0-9+/=]+)[[:space:]]*$/\1/p' <<< "$build_log")
    if [[ ! "$hash" =~ ^sha256-[A-Za-z0-9+/]{43}=$ ]]; then
      printf '%s\n' "$build_log" >&2
      exit 1
    fi
    if [[ "$hash" != "$(cat "$hash_file")" ]]; then
      temp_hash=$(mktemp "$hash_file.XXXXXX")
      trap 'rm -f "$temp_hash"' EXIT
      printf '%s\n' "$hash" > "$temp_hash"
      chmod 644 "$temp_hash"
      mv "$temp_hash" "$hash_file"
    fi

[private]
in-shell:
    @test -n "${IN_NIX_SHELL:-}" || { echo "Enter the dev shell first: run nix develop, or allow direnv." >&2; exit 1; }
