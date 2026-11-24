{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-24";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "5e329a286aeb62cf9f7ffa6cf8721c4c3caae5b4";
    hash = "sha256-Dujc02FPsK2slmR5EEetVCG5VgLlrwB3MEMQZ8TTnqs=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
