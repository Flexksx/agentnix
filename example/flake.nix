{
  description = "Example project using agentnix to manage agent skills";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    agentnix.url = "github:ccretu/agentnix"; # or path:../ for local dev
  };

  outputs =
    { self, nixpkgs, agentnix }:
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
    in
    {
      devShells = forAllSystems (
        { pkgs, ... }:
        let
          inherit (agentnix.lib.mkLib pkgs) mkSkill mkSkillSet;

          # Each skill lives in its own file under skills/
          codeReview = import ./skills/code-review.nix { inherit mkSkill pkgs; };
          gitConventions = import ./skills/git-conventions.nix { inherit mkSkill; };
          nixDev = import ./skills/nix-development.nix { inherit mkSkill pkgs; };

          # Combine all skills into a set — this generates the shellHook
          skillSet = mkSkillSet {
            skills = [
              codeReview
              gitConventions
              nixDev
            ];
            # targetPath = ".agents/skills";  # this is the default
          };
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.git ];
            shellHook = skillSet.shellHook;
          };
        }
      );
    };
}
