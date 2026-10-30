{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-10-30";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "47c9b1c96aa0879010fe3f51cfb5c0ef754736e8";
    hash = "sha256-LEu5S9c6Cb2aPlLyDqTgLOz2r064cYBwaicAZa6WNxg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
