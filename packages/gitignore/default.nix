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
    rev = "eeb775f7cbd229e8cd487ef06a1176dc239201d9";
    hash = "sha256-YjyLEV+mzOrNZ9RfO2ek1e2sfrgmC8yE+0Rn7jJoNS8=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
