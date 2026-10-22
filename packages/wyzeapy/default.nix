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
  version = "0.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SecKatie";
    repo = "wyzeapy";
    tag = "v${version}";
    hash = "sha256-dw5TTmxheT/KzBBfRFB6iuEPIJya7NhaGJ33B3P2Vgs=";
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
