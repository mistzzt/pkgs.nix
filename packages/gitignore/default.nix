{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-07";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "41862c835a7bd7e03373f1dbe1d2350f47063b71";
    hash = "sha256-qz3WcbeWiOkSLrBeadg5zeJ8Y6DswX/ltFJJl2BQqJY=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
