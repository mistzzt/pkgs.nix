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
    rev = "6bb5af7a1b050e5add3a71b6e6365c93498822ac";
    hash = "sha256-f2MBx5AXS8xVvwM24/3GUloU9gv2MBpIcWWiAN3O0lg=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
