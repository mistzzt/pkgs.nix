{
  fetchFromGitHub,
  runCommand,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
  src = fetchFromGitHub {
    owner = "obra";
    repo = "superpowers";
    rev = "v${data.version}";
    hash = data.hash;
  };
in
  runCommand "superpowers-skills" {} ''
    cp -r ${src}/skills $out
  ''
