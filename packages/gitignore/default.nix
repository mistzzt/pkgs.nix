{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-03";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "df4087095eb4f77e4a5ae379b4e6efcb660fb3bf";
    hash = "sha256-XGcPbeCWs5bGfGFw7A7dgrqFRP21OiLAu9axA6oSP/c=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
