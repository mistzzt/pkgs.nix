{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  python3Packages,
  wyzeapy,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
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
