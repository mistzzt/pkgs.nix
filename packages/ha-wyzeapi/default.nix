{
  buildHomeAssistantComponent,
  fetchFromGitHub,
  python3Packages,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);

  wyzeapy = python3Packages.buildPythonPackage rec {
    pname = "wyzeapy";
    version = data.wyzeapy.version;
    pyproject = true;

    src = fetchFromGitHub {
      owner = "SecKatie";
      repo = "wyzeapy";
      tag = "v${version}";
      hash = data.wyzeapy.hash;
    };

    build-system = with python3Packages; [hatchling];

    dependencies = with python3Packages; [
      aiohttp
      aiodns
      certifi
      pycryptodome
    ];

    doCheck = false;
  };
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
