{
  aiodns,
  aiohttp,
  buildPythonPackage,
  certifi,
  fetchFromGitHub,
  hatchling,
  pycryptodome,
}:
buildPythonPackage rec {
  pname = "wyzeapy";
  version = "0.7.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SecKatie";
    repo = "wyzeapy";
    tag = "v${version}";
    hash = "sha256-DL3K9ORmzPDGRLI+QokANRmcXzXtTBELIN/O3R2B4m0=";
  };

  build-system = [hatchling];

  dependencies = [
    aiohttp
    aiodns
    certifi
    pycryptodome
  ];

  doCheck = false;
}
