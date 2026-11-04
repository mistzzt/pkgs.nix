{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "d3feaa21d534865b9ab597bc46c7047a1520e97c";
    hash = "sha256-8+/GH+SSmyz80VZAvNcfbO0nac3cC+AFos06PJnHEAg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
