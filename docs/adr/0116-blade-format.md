# ADR-0116: Blade format

- **Status:** Accepted
- **Decides:** The Nix-pinned Blade formatter formats Blade in the editor, hook, and gate.

## Context

Blade mixes template directives and HTML. The app needs a formatting check and editor support for that file type.

## Decision drivers

1. **Blade support.** The tool recognizes directives and HTML.
2. **Pin.** The dev shell and checks use the same version.
3. **Setup cost.** The style check needs few tools and no asset build.

## Considered options

| Option | 1 Blade support | 2 Pin | 3 Setup cost | Verdict |
| --- | --- | --- | --- | --- |
| Pint Blade rule | First-party command with a Blade rule | Pint is Composer locked | The rule needs Prettier and two plugins | Good for a project with those Node tools |
| Prettier with the Blade plugin | Formats Blade directives and HTML | A Node lock can pin the tool and plugin | Adds a Prettier setup | Good for a project already using Prettier |
| **Blade formatter** | Formats the sample directives and HTML and reads editor input | In the pinned Nix input | One command in the shell and no app asset build | **Chosen** |

### Sources

- [Pint Blade formatting](https://laravel.com/docs/13.x/pint), [Blade formatter](https://github.com/shufo/blade-formatter), and [Prettier Blade plugin](https://github.com/shufo/prettier-plugin-blade).

## Decision

Blade formatter reads `.config/blade-formatter.json`. It formats directives and HTML, including indentation. The gate checks the files under `resources/views/`.

## Consequences

The formatter brings a Node runtime through its Nix package. The app and its templates run with PHP alone.

## Rules

- Blade uses only the Blade formatter. `(CI: lint-php)`
- The editor, hook, and gate use the project config.
