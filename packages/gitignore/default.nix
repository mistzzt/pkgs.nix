{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-10-02";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "0e5d690153ca3da8a4a1aef2d053406f408f531c";
    hash = "sha256-nFxjp+p0s5J3IwVkHs+ZAHLDd2cPliL7NqmAq3KIa/g=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
