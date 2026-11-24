# Laravel Template

A Laravel starter for a server-rendered web app. The sample lets you save and list notes. It shows a Blade form, request validation, an Eloquent model, and a migration.

## Stack

| Tool | Owns |
| --- | --- |
| [PHP](https://www.php.net/) and [Laravel](https://laravel.com/) | The PHP 8.5 runtime and Laravel 13 app |
| [Blade](https://laravel.com/docs/13.x/blade) and [SQLite](https://www.sqlite.org/) | Server-rendered pages and the local database |
| [Composer](https://getcomposer.org/) | PHP packages and the lock file |
| [Pint](https://laravel.com/docs/13.x/pint) and [Blade formatter](https://github.com/shufo/blade-formatter) | PHP and Blade formatting |
| [PHPStan](https://phpstan.org/) with [Larastan](https://github.com/larastan/larastan) | Type checks for Laravel code |
| [PHPUnit](https://phpunit.de/) | HTTP and database tests |
| [Nix](https://nixos.org/), [tabkit](https://github.com/tabmadi/tabkit), and [just](https://just.systems/) | Pinned tools, git hooks, and the sandboxed gate |
| [Renovate](https://docs.renovatebot.com/) | Dependency updates |

## Getting started

Install [Nix](https://nixos.org/download/) with flakes enabled. Run these commands in the repo.

```bash
nix develop
just setup
just dev
```

Open [the notes app](http://127.0.0.1:8000) and save a note. The local database is `database/database.sqlite`. The health route is `/up`.

## Editor

Install the PHP and Blade extensions in [Zed](https://zed.dev/). Install [direnv](https://direnv.net/) with [nix-direnv](https://github.com/nix-community/nix-direnv), then run `direnv allow`.

Zed loads Phpactor from the dev shell. Run `just setup` before editing so Pint is available. Open `task: spawn` and select `just dev` to start the app.

## Tasks

| Task | Does |
| --- | --- |
| `just setup` | Installs locked packages, creates local settings and a key if needed, and runs migrations |
| `just dev` | Starts Artisan on `127.0.0.1:8000` |
| `just format` | Formats PHP, Blade, and shared file types |
| `just lint` | Checks Composer, PHP and Blade formatting, types, and shared file types |
| `just test` | Runs the HTTP and database tests |
| `just check` | Runs lint and tests with the local dependencies |
| `just ci` | Runs the same Nix checks as CI and the pre-push hook |
| `just deps-sync` | Refreshes the Nix vendor hash after a dependency or toolchain change |

## Layout

| Path | Holds |
| --- | --- |
| `app/` | The controller, form request, model, and app provider |
| `bootstrap/` | The Laravel application and package cache |
| `routes/web.php` | The notes routes |
| `resources/views/` | Blade templates |
| `database/migrations/` | Database schema changes |
| `public/` | The HTTP entry point |
| `tests/Feature/` | HTTP and database tests |
| `composer.json`, `composer.lock` | The package manifest and locked versions |
| `flake.nix`, `nix/composer-vendor-hash` | The dev shell, hooks, checks, and locked vendor input |
| `docs/adr/` | Project decisions |

## Configuration

`just setup` copies `.env.example` if `.env` is missing. It sets a blank `APP_KEY` and keeps an existing key. The app uses SQLite, file sessions, and a file cache for local work.

Feature tests use a fresh in-memory SQLite database and array sessions. They leave the local database alone.

## Starting a project

Make a new project with Nix. It copies the project files and omits the template scope.

```bash
nix flake new -t github:tabmadi/laravel-template my-project
cd my-project
git init
git add -A
nix develop
just setup
```

1. Set the name and description in `composer.json`. Run `composer update --lock` and `just deps-sync`.
2. Replace the sample routes, note code, view, migration, and tests with your app.
3. Rewrite this README. Update the contacts in `.github/SECURITY.md` and the copyright line in `LICENSE`.
4. Remove the setup line from `AGENTS.md` if it remains.
5. Set GitHub to squash merge with the pull request title and an empty message body. Add the `RENOVATE_TOKEN` repository secret.

### With the GitHub template button

Clone the new repository and run `nix develop`. Run `just init` to remove the template scope and the setup line from `AGENTS.md`.

Before anyone else clones the new repo, replace the initial commit title.

```bash
git commit --amend -m "chore: start from laravel-template"
git push --force-with-lease
```

Follow the project steps above and run `just setup`.

## Decisions

See the [ADR index](docs/adr/README.md) for the tools, alternatives, and rules.

## Contributing

Run `just format` and `just check` before a change. Run `just ci` to check the full Nix gate.

## Security

See the [security policy](.github/SECURITY.md).

## License

See [LICENSE](LICENSE). The Laravel entry points and starter layout use the [Laravel skeleton](https://github.com/laravel/laravel/tree/v13.11.0). See its [MIT notice](LICENSE.laravel-skeleton).
