{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-09-28";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "62f3997f1917b30f6eaee0c53ac2d791426513f2";
    hash = "sha256-YSQo7rC4TYZ90X6E2A/O5nx0tam1HkCZO6HQmYiuRHg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
