{ lib, runCommand, writeText, symlinkJoin, makeBinaryWrapper }:

{
  name,
  skillContent,
  references ? [],
  scripts ? [],
  examples ? [],
  dependencies ? [],
}:

let
  # Resolve a single file entry: { name; content?; src?; } -> derivation
  mkFile = entry:
    if entry ? content then
      writeText entry.name entry.content
    else if entry ? src then
      entry.src
    else
      throw "mkSkill: each entry must have either 'content' or 'src' — got neither for '${entry.name}'";

  # Build a subdirectory derivation from a list of file entries
  mkSubdir = dirName: entries:
    let
      copyCommands = lib.concatMapStringsSep "\n" (entry:
        let src = mkFile entry;
        in "cp ${src} $out/${dirName}/${entry.name}"
      ) entries;
    in copyCommands;

  hasRefs = references != [];
  hasScripts = scripts != [];
  hasExamples = examples != [];
  hasDeps = dependencies != [];

  # When dependencies exist, create a bin/ directory with wrapped PATH
  depsBinPath = lib.makeBinPath dependencies;

  skillMd = writeText "SKILL.md" skillContent;

in runCommand "agent-skill-${name}" {} ''
  mkdir -p $out

  cp ${skillMd} $out/SKILL.md

  ${lib.optionalString hasRefs ''
    mkdir -p $out/references
    ${mkSubdir "references" references}
  ''}

  ${lib.optionalString hasScripts ''
    mkdir -p $out/scripts
    ${mkSubdir "scripts" scripts}
    chmod +x $out/scripts/*
  ''}

  ${lib.optionalString hasExamples ''
    mkdir -p $out/examples
    ${mkSubdir "examples" examples}
  ''}

  ${lib.optionalString hasDeps ''
    mkdir -p $out/bin
    for dep in ${lib.concatMapStringsSep " " (d: "${d}/bin/*") dependencies}; do
      [ -f "$dep" ] && ln -sf "$dep" "$out/bin/$(basename "$dep")"
    done
  ''}
''
