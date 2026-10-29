{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-10-29";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "9700d7b289cafdf0d9e08306302ec881ffd6d79d";
    hash = "sha256-QiWdDTrI0G2Qcyy80qHlTkyrgDfYYaywmNKW61lxWwQ=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
