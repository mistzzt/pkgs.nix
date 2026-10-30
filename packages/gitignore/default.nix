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
    rev = "9402f6ab0fb9dbbc6be7958f75ff43d7a83f92ca";
    hash = "sha256-f3RAZSo3nysUZeaUSs1ql8VD/olvGYei5+8lGQ0Q+qA=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
