{ mkSkill, pkgs }:

mkSkill {
  name = "nix-development";
  description = "Guide for Nix flake development, packaging, and debugging. Use when writing flake.nix, derivations, or troubleshooting Nix builds.";
  compatibility = "Requires Nix 2.4+ with flakes enabled";
  allowedTools = [ "Bash(nix:*)" "Read" "Write" ];

  skillContent = ''
    # Nix Development

    ## Common Tasks

    ### Build a package
    ```bash
    nix build .#packageName
    ```

    ### Enter a dev shell
    ```bash
    nix develop
    ```

    ### Check flake outputs
    ```bash
    nix flake show
    ```

    ### Update a single input
    ```bash
    nix flake update --update-input nixpkgs
    ```

    ## Debugging

    - Use `--show-trace` on any nix command to get full error traces
    - Use `nix repl` and `:lf .` to interactively explore flake outputs
    - Use `nix log /nix/store/<hash>-name` to see build logs

    ## Best Practices

    - Pin inputs in `flake.lock`, update intentionally
    - Use `lib.optional` / `lib.optionalString` instead of `if` where possible
    - Prefer `runCommand` for simple file assembly, `stdenv.mkDerivation` for compiled packages
    - Keep `flake.nix` thin — import logic from `lib/`, `packages/`, etc.

    See [references/flake-template.md](references/flake-template.md) for a starter template.
  '';

  references = [
    {
      name = "flake-template.md";
      content = ''
        # Flake Template

        ```nix
        {
          inputs = {
            nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
          };

          outputs = { self, nixpkgs }:
            let
              systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
              forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
                f { pkgs = nixpkgs.legacyPackages.''${system}; }
              );
            in {
              packages = forAllSystems ({ pkgs }: {
                default = pkgs.hello;
              });

              devShells = forAllSystems ({ pkgs }: {
                default = pkgs.mkShell {
                  packages = [ pkgs.nil pkgs.nixfmt-rfc-style ];
                };
              });
            };
        }
        ```
      '';
    }
  ];

  scripts = [
    {
      name = "check-flake.sh";
      content = ''
        #!/usr/bin/env bash
        set -euo pipefail
        echo "Checking flake..."
        nix flake check --no-build 2>&1
        echo "Showing outputs..."
        nix flake show 2>&1
      '';
    }
  ];

  dependencies = [ pkgs.nix pkgs.nixfmt-rfc-style ];
}
