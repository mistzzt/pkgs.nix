{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-20";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "36e3c82ac1cb0e6368cbfe4fc050f97ee3350841";
    hash = "sha256-bEyWS9Wfm4+HdfjXaCtltXofh58t8WJNIXF7kq2Td1U=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
