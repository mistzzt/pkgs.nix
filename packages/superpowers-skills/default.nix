{
  fetchFromGitHub,
  lib,
  runCommand,
  selectedSkills ? null,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
  src = fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v${data.version}";
    hash = data.hash;
  };
  script =
    if selectedSkills == null
    then "cp -r ${src}/skills $out"
    else ''
      mkdir -p $out
      ${lib.concatMapStringsSep "\n" (s: "cp -r ${src}/skills/${s} $out/${s}") selectedSkills}
    '';
in
  runCommand "superpowers-skills" {} script
