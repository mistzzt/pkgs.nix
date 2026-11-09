{
  fetchFromGitHub,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation {
  pname = "gitignore";
  version = "0-unstable-2026-11-09";

  src = fetchFromGitHub {
    owner = "github";
    repo = "gitignore";
    rev = "8ba69a4220df77b696fe97b60fb70eb668fb00e1";
    hash = "sha256-hBGCYXigdkj6I9wRobZlpcj7X1kv7+eclTyqINve804=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r . "$out/"
    runHook postInstall
  '';
}
