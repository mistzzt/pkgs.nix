{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-14";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "b71db924d35085e481ad7c7ad8a7435b8d8b3016";
    hash = "sha256-4Byb5gjUptoOIJhElurPdpF3dZURIbMWJ6zX664GqmI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
