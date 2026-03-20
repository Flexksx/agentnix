{ lib, runCommand, writeText, symlinkJoin, makeBinaryWrapper }:

{
  name,
  description,
  skillContent ? "",
  license ? null,
  compatibility ? null,
  metadata ? {},
  allowedTools ? [],
  references ? [],
  scripts ? [],
  examples ? [],
  dependencies ? [],
}:

let
  # --- YAML frontmatter generation ---

  metadataLines = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "  ${k}: ${builtins.toJSON v}") metadata
  );

  frontmatter = lib.concatStringsSep "\n" (
    [ "name: ${name}" "description: ${description}" ]
    ++ lib.optional (license != null) "license: ${license}"
    ++ lib.optional (compatibility != null) "compatibility: ${compatibility}"
    ++ lib.optional (metadata != {}) "metadata:\n${metadataLines}"
    ++ lib.optional (allowedTools != []) "allowed-tools: ${lib.concatStringsSep " " allowedTools}"
  );

  fullContent = "---\n${frontmatter}\n---\n\n${skillContent}";

  # --- File entry helpers ---

  mkFile = entry:
    if entry ? content then
      writeText entry.name entry.content
    else if entry ? src then
      entry.src
    else
      throw "mkSkill: each entry must have either 'content' or 'src' — got neither for '${entry.name}'";

  mkSubdir = dirName: entries:
    lib.concatMapStringsSep "\n" (entry:
      let src = mkFile entry;
      in "cp ${src} $out/${dirName}/${entry.name}"
    ) entries;

  hasRefs = references != [];
  hasScripts = scripts != [];
  hasExamples = examples != [];
  hasDeps = dependencies != [];

  skillMd = writeText "SKILL.md" fullContent;

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
