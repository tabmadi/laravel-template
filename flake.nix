# The toolchain, the git hooks, and the checks, per ADR-0100. The tabkit module holds every shared part.
{
  description = "A Laravel application with Blade, SQLite, and a sandboxed CI gate";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    # A new version is a new tag here.
    tabkit = {
      url = "github:tabmadi/tabkit/v0.24.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      # Only the own checks of tabkit read this input, so it adds no second nixpkgs here.
      inputs.nixos-stable.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, tabkit, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # The template scope adds its own checks and outputs. A copy has no template/ folder, so it adds nothing.
      imports = [
        tabkit.flakeModules.default
      ]
      ++ inputs.nixpkgs.lib.optional (builtins.pathExists ./template/scope.nix) ./template/scope.nix;

      perSystem =
        { pkgs, lib, ... }:
        let
          php = pkgs.php85;
          inherit (php.packages) composer;
          pint = "php vendor/bin/pint --config .config/pint.json";
          blade = "blade-formatter --config .config/blade-formatter.json";
          composerVendor = php.mkComposerVendor {
            pname = "laravel-app";
            version = "0";
            src = lib.fileset.toSource {
              root = ./.;
              fileset = lib.fileset.unions [
                ./composer.json
                ./composer.lock
              ];
            };
            vendorHash = lib.removeSuffix "\n" (builtins.readFile ./nix/composer-vendor-hash);
            composerNoDev = false;
          };

          phpCheck =
            name: command:
            pkgs.runCommand name
              {
                nativeBuildInputs = [
                  php
                  composer
                  pkgs.blade-formatter
                ];
                COMPOSER_DISABLE_NETWORK = "1";
                APP_ENV = "testing";
              }
              ''
                export HOME="$TMPDIR"
                cp -r ${./.} source
                chmod -R u+w source
                cd source
                cp -r --no-preserve=mode ${composerVendor}/vendor .
                composer install --no-plugins --no-scripts --no-interaction --no-progress
                php artisan package:discover --no-ansi --no-interaction
                ${command}
                touch "$out"
              '';
        in
        {
          tabkit.packages = [
            php
            composer
            pkgs.blade-formatter
            pkgs.phpactor
          ];

          tabkit.hooks.pint = {
            name = "Pint";
            entry = "${lib.getExe php} vendor/bin/pint --config .config/pint.json";
            files = "^artisan$|(?<!\\.blade)\\.php$";
          };
          tabkit.hooks.blade = {
            name = "Blade formatter";
            entry = "${lib.getExe pkgs.blade-formatter} --config .config/blade-formatter.json --write";
            files = "\\.blade\\.php$";
          };

          packages.composer-vendor = composerVendor;

          checks.lint-php = phpCheck "lint-php" ''
            composer validate --strict
            composer check-platform-reqs --lock
            ${pint} --test . artisan
            ${blade} --check-formatted 'resources/views/**/*.blade.php'
            php vendor/bin/phpstan analyse --configuration=.config/phpstan.neon --memory-limit=512M --no-progress
          '';
          checks.test = phpCheck "test" ''
            php vendor/bin/phpunit --bootstrap vendor/autoload.php tests
          '';
        };
    };
}
