{
  description = "agentnix — declarative agent skills via Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
            inherit system;
          }
        );

      mkLib =
        pkgs:
        import ./lib {
          inherit (pkgs)
            lib
            runCommand
            writeText
            symlinkJoin
            makeBinaryWrapper
            writeShellScript
            writeShellApplication
            ;
        };
    in
    {
      # Expose the lib constructor for consumers
      lib.mkLib = mkLib;

      # Per-system outputs for local development / testing
      packages = forAllSystems (
        { pkgs, ... }:
        let
          inherit (mkLib pkgs) mkSkill mkSkillSet;

          codeReview = import ./example/skills/code-review.nix { inherit mkSkill pkgs; };
          gitConventions = import ./example/skills/git-conventions.nix { inherit mkSkill; };
          nixDev = import ./example/skills/nix-development.nix { inherit mkSkill pkgs; };

          skillSet = mkSkillSet {
            skills = [ codeReview gitConventions nixDev ];
          };
        in
        {
          default = codeReview;
          code-review = codeReview;
          git-conventions = gitConventions;
          nix-development = nixDev;
          inherit (skillSet) activationScript;
        }
      );

      devShells = forAllSystems (
        { pkgs, ... }:
        let
          inherit (mkLib pkgs) mkSkill mkSkillSet;

          codeReview = import ./example/skills/code-review.nix { inherit mkSkill pkgs; };
          gitConventions = import ./example/skills/git-conventions.nix { inherit mkSkill; };
          nixDev = import ./example/skills/nix-development.nix { inherit mkSkill pkgs; };

          skillSet = mkSkillSet {
            skills = [ codeReview gitConventions nixDev ];
          };
        in
        {
          default = pkgs.mkShell {
            shellHook = skillSet.shellHook;
          };
        }
      );
    };
}
