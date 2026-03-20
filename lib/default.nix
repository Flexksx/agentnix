{ lib, runCommand, writeText, symlinkJoin, makeBinaryWrapper, writeShellScript, writeShellApplication }:

{
  mkSkill = import ./mkSkill.nix { inherit lib runCommand writeText symlinkJoin makeBinaryWrapper; };
  mkSkillSet = import ./mkSkillSet.nix { inherit lib writeShellScript writeShellApplication; };
}
