{fetchFromGitHub}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
in
  fetchFromGitHub {
    owner = "anthropics";
    repo = "skills";
    rev = data.rev;
    hash = data.hash;
  }
