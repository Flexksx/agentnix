{ lib, writeShellScript, writeShellApplication }:

{
  skills,
  targetPath ? ".agents/skills",
}:

let
  # Extract skill name from the derivation name (strip "agent-skill-" prefix)
  skillName = drv:
    let
      full = drv.name;
      prefix = "agent-skill-";
    in
      if lib.hasPrefix prefix full
      then lib.removePrefix prefix full
      else full;

  # Generate symlink commands for all skills
  symlinkCommands = lib.concatMapStringsSep "\n" (skill:
    let name = skillName skill;
    in ''
      ln -sfn "${skill}" "$TARGET_DIR/${name}"
      echo "  ${name} -> ${skill}"
    ''
  ) skills;

  # Generate the set of expected skill names for stale-link cleanup
  expectedNames = lib.concatMapStringsSep " " (skill:
    ''"${skillName skill}"''
  ) skills;

  hookScript = ''
    # --- agentnix: activate agent skills ---
    _AGENTNIX_ROOT="''${PRO_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
    TARGET_DIR="$_AGENTNIX_ROOT/${targetPath}"

    mkdir -p "$TARGET_DIR"

    # Ensure target path is in .gitignore
    _GITIGNORE="$_AGENTNIX_ROOT/.gitignore"
    if [ -f "$_GITIGNORE" ]; then
      if ! grep -qxF '/${targetPath}' "$_GITIGNORE" 2>/dev/null; then
        printf '\n# agentnix managed skills\n/${targetPath}\n' >> "$_GITIGNORE"
      fi
    else
      printf '# agentnix managed skills\n/${targetPath}\n' > "$_GITIGNORE"
    fi

    # Create symlinks
    echo "agentnix: activating skills in ${targetPath}/"
    ${symlinkCommands}

    # Remove stale symlinks (symlinks pointing to /nix/store that are not in our set)
    _EXPECTED_NAMES=(${expectedNames})
    for link in "$TARGET_DIR"/*; do
      [ -L "$link" ] || continue
      _LINK_NAME="$(basename "$link")"
      _IS_EXPECTED=0
      for _name in "''${_EXPECTED_NAMES[@]}"; do
        if [ "$_LINK_NAME" = "$_name" ]; then
          _IS_EXPECTED=1
          break
        fi
      done
      if [ "$_IS_EXPECTED" = "0" ]; then
        echo "  removing stale: $_LINK_NAME"
        rm "$link"
      fi
    done
    # --- end agentnix ---
  '';

  activationScript = writeShellApplication {
    name = "agentnix-activate";
    text = hookScript;
  };

in {
  packages = skills;
  shellHook = hookScript;
  inherit activationScript;
}
