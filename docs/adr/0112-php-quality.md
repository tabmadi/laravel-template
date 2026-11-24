# ADR-0112: PHP format and types

- **Status:** Accepted
- **Decides:** Pint formats PHP, and PHPStan with Larastan checks PHP types at level 10.

## Context

Laravel uses runtime behavior for Eloquent and request helpers. The app needs type checks that understand those calls and a format that works in the editor and CI.

## Decision drivers

1. **Style.** The formatter supports Laravel conventions and an editor input mode.
2. **Laravel fit.** The analyzer handles the Laravel calls in the starter.
3. **Tool cost.** The tools run from a pinned environment with few configs.

## Considered options

| Option | 1 Style | 2 Laravel fit | 3 Tool cost | Verdict |
| --- | --- | --- | --- | --- |
| Mago | Offers a Laravel format preset and editor input | Reports the validated request array as mixed in this sample | One Nix binary and one config | Good when its analyzer fits the app |
| PHP CS Fixer and PHPStan with Larastan | Fine-grained PHP rules and custom fixers | The same Laravel-aware type checks | Two tools with a PHP format config | Good when a project needs custom fixers |
| **Pint and PHPStan with Larastan** | The first-party Laravel preset and editor input | Passes the sample, including the validated data passed to Eloquent | Two Composer tools and two configs | **Chosen** |

### Sources

- [Pint docs](https://laravel.com/docs/13.x/pint), [PHP CS Fixer](https://cs.symfony.com/doc/usage.html), and [Mago format presets](https://mago.carthage.software/1.59.0/en/tools/formatter/configuration-reference/).
- [Mago analyzer](https://mago.carthage.software/1.59.0/en/tools/analyzer/overview/), [PHPStan levels](https://phpstan.org/user-guide/rule-levels), and [Larastan](https://github.com/larastan/larastan).

## Decision

Pint applies the Laravel preset and adds strict types to PHP files. It reads `.config/pint.json`. Blade formatting follows [ADR-0116](0116-blade-format.md).

PHPStan loads Larastan and checks the application, migration, routes, and tests at level 10. Its config is `.config/phpstan.neon`.

The analyzer comparison covers the sample call to `FormRequest::validated` and its use in Eloquent. It measures no other Laravel patterns.

## Consequences

Larastan boots the application to resolve types. It needs the locked packages and a bootstrap that works in the checks.

## Rules

- Pint formats PHP in the editor, the hook, and the tasks. `(CI: lint-php)`
- PHPStan runs with Larastan at level 10 without a baseline. `(CI: lint-php)`
