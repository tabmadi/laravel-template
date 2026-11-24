# ADR-0113: Laravel tests

- **Status:** Accepted
- **Decides:** PHPUnit 13 runs Laravel feature tests with an in-memory SQLite database.

## Context

The sample needs to check routing, validation, persistence, and page output. The tests also need their own database and sessions.

## Decision drivers

1. **Laravel fit.** The runner can use Laravel HTTP helpers and database assertions.
2. **Setup cost.** The sample can run offline with few packages.
3. **Support.** The runner receives fixes and fits the PHP line.

## Considered options

| Option | 1 Laravel fit | 2 Setup cost | 3 Support | Verdict |
| --- | --- | --- | --- | --- |
| PHPUnit 12.5 | Used by the upstream Laravel 13 skeleton | Direct runner and Laravel test helpers | Supports PHP 8.3 and newer | Good when a project still supports PHP 8.3 |
| Pest 5 | Uses PHPUnit 13 and offers a Laravel plugin | Adds a test API and plugin choices | Supports the PHP line | Good when a team wants its syntax or plugins |
| **PHPUnit 13** | Laravel 13 framework tests support it, and the sample passes with its helpers | Direct runner plus Mockery for Laravel test helpers | Supports PHP 8.4 and newer | **Chosen** |

### Sources

- [Laravel HTTP tests](https://laravel.com/docs/13.x/http-tests), [Laravel database tests](https://laravel.com/docs/13.x/database-testing), and [Laravel framework dependencies](https://github.com/laravel/framework/blob/13.x/composer.json).
- [Laravel skeleton dependencies](https://github.com/laravel/laravel/blob/13.x/composer.json), [PHPUnit support](https://phpunit.de/supported-versions.html), and [Pest 5](https://pestphp.com/docs/pest5-now-available).

## Decision

PHPUnit runs the feature tests from `composer.lock`. Mockery supports the Laravel test helpers that run migrations. The test case selects SQLite in memory and array storage for sessions and cache.

## Consequences

The tests check real Laravel routes and database writes. Projects with another database also need to test behavior specific to that database.

## Rules

- The local task and the sandbox run the same PHPUnit suite. `(CI: test)`
- Feature tests use an isolated database. `(CI: test)`
