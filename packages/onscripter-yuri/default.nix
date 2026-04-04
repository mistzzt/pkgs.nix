{
  fetchFromGitHub,
  lib,
  stdenv,
  pkg-config,
  cmake,
  bzip2,
  SDL2,
  SDL2_ttf,
  SDL2_image,
  SDL2_mixer,
  libjpeg_turbo,
  libpng,
  lua5_3_compat,
  mesa,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
in
  stdenv.mkDerivation {
    name = "OnscripterYuri";
    version = data.version;
    src = fetchFromGitHub {
      owner = "YuriSizuku";
      repo = "OnscripterYuri";
      rev = "v${data.version}";
      sha256 = data.hash;
    };

    nativeBuildInputs = [
      cmake
      pkg-config
      SDL2
      SDL2_ttf
      SDL2_mixer
      SDL2_image
      bzip2
      libjpeg_turbo
      libpng
      lua5_3_compat
      mesa
    ];

    cmakeBuildType = "MinSizeRel";
    installPhase = ''
      mkdir -p $out/bin
      cp onsyuri $out/bin
    '';

    meta = with lib; {
      description = "An enhancement ONScripter project porting to many platforms, especially web";
      homepage = "https://github.com/YuriSizuku/OnscripterYuri";
      license = licenses.gpl2Only;
      mainProgram = "onsyuri";
      platforms = platforms.unix;
    };
  }
