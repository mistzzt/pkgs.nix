{
  lib,
  stdenvNoCC,
  ffmpeg,
  makeWrapper,
  python3,
}:
stdenvNoCC.mkDerivation {
  pname = "extract-keyframes";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [./extract-keyframes ./tests];
  };

  nativeBuildInputs = [makeWrapper python3];
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
    description = "Extract scene-change keyframes from a video with bounded ffmpeg passes, gap fill, and perceptual dedup";
    mainProgram = "extract-keyframes";
  };
}
