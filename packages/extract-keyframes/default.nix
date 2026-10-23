{
  lib,
  stdenvNoCC,
  ffmpeg,
  makeWrapper,
  python3,
}:
let
  python = python3.withPackages (ps: [ps.numpy]);
in
stdenvNoCC.mkDerivation {
  pname = "extract-keyframes";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [./extract-keyframes ./tests];
  };

  nativeBuildInputs = [makeWrapper python];
  nativeCheckInputs = [ffmpeg];

  postPatch = ''
    patchShebangs extract-keyframes
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    python3 -m unittest discover -s tests
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 extract-keyframes $out/bin/extract-keyframes
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/extract-keyframes --prefix PATH : ${lib.makeBinPath [ffmpeg]}
  '';

  meta = {
    description = "Extract video frames using regional changes against the last retained frame";
    mainProgram = "extract-keyframes";
  };
}
