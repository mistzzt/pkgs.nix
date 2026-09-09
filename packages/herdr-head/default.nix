{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-09-09";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "120c682008a85dc17d7a13cc619a2fd5d25f3924";
    hash = "sha256-uFiVgNSDwxcQqOzhOckTIMMxbS0yXmmsIsBwlERRiyg=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-CW/SF/cAPDv47gS5B7XbVZEE6LC9F1a2I1TLTJ4AWdw=";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = finalAttrs.cargoHash;
  };

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-PnM+hZIlLyQwK8vJgd/Bhjt1lNIz06T8FahwliRmMrY=";
  };

  # Head builds report the base release version, which fails versionCheckHook.
  doInstallCheck = false;
})
