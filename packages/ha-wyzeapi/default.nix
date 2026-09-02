{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (home-assistant) python3Packages;
  wyzeapy = python3Packages.callPackage ../wyzeapy {};
in
  buildHomeAssistantComponent rec {
    owner = "SecKatie";
    domain = "wyzeapi";
    version = "unstable-${builtins.substring 0 7 data.rev}";

    src = fetchFromGitHub {
      inherit owner;
      repo = "ha-wyzeapi";
      rev = data.rev;
      hash = data.hash;
    };

    dependencies = [
      wyzeapy
      python3Packages.websockets
    ];
  }
