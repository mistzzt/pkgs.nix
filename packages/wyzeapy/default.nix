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
  version = "0.8.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "SecKatie";
    repo = "wyzeapy";
    tag = "v${version}";
    hash = "sha256-p5ynpVel8ozFMN/XVQfbt1F2fMZ6u9CTS9HxtXntCQo=";
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
