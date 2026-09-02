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
  version = "0.6.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SecKatie";
    repo = "wyzeapy";
    tag = "v${version}";
    hash = "sha256-pyQIGS+p92gHVdoNaS3RIa1kZ7Ko3KbbTiXT6a2Z7xc=";
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
