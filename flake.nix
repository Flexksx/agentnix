{
  description = "agentnix — declarative agent skills via Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = nixpkgs.legacyPackages.${system};
          inherit system;
        }
      );

      # System-independent lib constructor — consumers call this with their pkgs
      mkLib = pkgs: import ./lib {
        inherit (pkgs) lib runCommand writeText symlinkJoin makeBinaryWrapper writeShellScript writeShellApplication;
      };
    in
    {
      # Expose the lib constructor for consumers
      lib.mkLib = mkLib;

      # Per-system outputs for local development / testing
      packages = forAllSystems ({ pkgs, ... }:
        let
          agentnix = mkLib pkgs;

          exampleSkill = agentnix.mkSkill {
            name = "example";
            skillContent = ''
              ---
              name: example
              description: An example skill to demonstrate agentnix.
              ---
              # Example Skill

              This is a demonstration skill built with agentnix.
            '';
            references = [
              { name = "usage.md"; content = "# Usage\n\nSee the main SKILL.md for details."; }
            ];
          };

          exampleSet = agentnix.mkSkillSet {
            skills = [ exampleSkill ];
          };
        in {
          default = exampleSkill;
          example-skill = exampleSkill;
          inherit (exampleSet) activationScript;
        }
      );

      devShells = forAllSystems ({ pkgs, ... }:
        let
          agentnix = mkLib pkgs;

          exampleSkill = agentnix.mkSkill {
            name = "example";
            skillContent = ''
              ---
              name: example
              description: An example skill to demonstrate agentnix.
              ---
              # Example Skill

              This is a demonstration skill built with agentnix.
            '';
            references = [
              { name = "usage.md"; content = "# Usage\n\nSee the main SKILL.md for details."; }
            ];
          };

          exampleSet = agentnix.mkSkillSet {
            skills = [ exampleSkill ];
          };
        in {
          default = pkgs.mkShell {
            shellHook = exampleSet.shellHook;
          };
        }
      );
    };
}
