{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-09-25";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "b06d69d5a0b82a187180dac3d46a4ebe1e40bce5";
    hash = "sha256-FOc/YYH1ViN/GeHLN5DSDv1/Nx6q9r0ZJH+M8p3tIh4=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
