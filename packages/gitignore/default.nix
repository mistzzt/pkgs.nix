{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-09-11";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "356fd7baab4c05e092194a41f64dbd5afc8817e4";
    hash = "sha256-Nm+gwWE8yZye19qffYwk95Q0A9zMa1hdP7p5J5bBuUI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
