# ADR-0114: PHP and Blade editor support

- **Status:** Accepted
- **Decides:** Zed uses Phpactor for PHP, the project formatters on save, and task entries for setup and serving.

## Context

An editor should use the same format as the tasks. Completion and task entries help a developer work in a fresh copy.

## Decision drivers

1. **PHP editing.** The language server provides completion and navigation.
2. **Pin.** The server runs from the Nix dev shell.
3. **Access.** The server is open and needs no license key.

## Considered options

| Option | 1 PHP editing | 2 Pin | 3 Access | Verdict |
| --- | --- | --- | --- | --- |
| Syntax support alone | Syntax highlighting only | Uses the editor extension | Open | Good for a minimal editor |
| Intelephense | Completion and navigation | Can use a pinned Node package | Proprietary, with free and paid features | Good when a team depends on its features |
| **Phpactor** | Completion, navigation, and refactoring | In the pinned dev shell | Open and usable without a key | **Chosen** |

### Sources

- [Zed PHP support](https://zed.dev/docs/languages/php), [Zed Blade extension](https://zed.dev/extensions/blade), and [Phpactor](https://phpactor.readthedocs.io/).
- [Zed tasks](https://zed.dev/docs/tasks) and the editor rules in [ADR-0105](0105-editor.md).

## Decision

Phpactor supplies PHP language features. Zed passes buffers to Pint and Blade formatter with the same project configs as `just format`. The task list exposes `just setup` and `just dev`.

## Consequences

Pint is available after Composer setup. Zed needs its PHP and Blade extensions and the dev shell loaded through direnv.

## Rules

- Zed uses the same PHP and Blade formatters as the tasks.
- The editor task starts the app through `just dev`.
