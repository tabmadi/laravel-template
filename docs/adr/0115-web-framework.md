# ADR-0115: Web framework and starter scope

- **Status:** Accepted
- **Decides:** The project starts with Laravel 13, Blade, Eloquent, and a portable local SQLite database.

## Context

The sample needs a web form, validation, database writes, and tests. The first run should work with one dev shell and one local process.

## Decision drivers

1. **App features.** The stack supplies routing, validation, views, and data access.
2. **Local setup.** The sample needs few tools and services.
3. **Fit.** The starter leaves room to add app features without replacing the sample framework.

## Considered options

| Option | 1 App features | 2 Local setup | 3 Fit | Verdict |
| --- | --- | --- | --- | --- |
| Slim | Routing and middleware, with packages chosen for the other parts | A small HTTP core | Good for a narrow service | Good when the project wants few framework services |
| Symfony | Full web stack with selectable components | The project picks its own components and defaults | Good for apps that want separate building blocks | Good when a team prefers Symfony components |
| Laravel auth starter kit | Laravel plus sign-in and a frontend stack | Adds auth choices and asset build tools | Good for apps that already need sign-in | Good when those requirements are known |
| **Laravel with Blade and SQLite** | Framework routes, request checks, Blade, and Eloquent | A local SQLite file and no asset build | Adds normal Laravel features as the app grows | **Chosen** |

### Sources

- [Laravel releases](https://laravel.com/docs/13.x/releases), [Laravel starter kits](https://laravel.com/docs/13.x/starter-kits), and [Blade](https://laravel.com/docs/13.x/blade).
- [Symfony setup](https://symfony.com/doc/current/setup.html), [Slim](https://www.slimframework.com/docs/v4/), and [Laravel databases](https://laravel.com/docs/13.x/database).

## Decision

The starter uses the Laravel 13 application layout. Blade serves the notes form and list, and Eloquent stores notes in SQLite. The sample uses Laravel web middleware and server-side validation.

`just setup` installs the dependencies, prepares the local environment, and runs the migrations. `just dev` uses the Artisan server for local work.

## Consequences

SQLite makes the sample portable. A web app with concurrent writers or a shared database can choose PostgreSQL or another supported database and test its behavior.

## Rules

- The sample runs with the local SQLite file and the Artisan server.
- A note passes the form request validation before it is written. `(CI: test)`
