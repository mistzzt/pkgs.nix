{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-09-19";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "856b64b9bfd41b9d3d82e2375ed5b4bf941fda28";
    hash = "sha256-a4NvdWxYdZWj2gxDjJXWKaLnjeEUtoD+3loCPQtZVNs=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-1VAmsDE3zeU0wMVQKleQcd/zq8/k/oor8tasrsRQfeY=";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = finalAttrs.cargoHash;
  };

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-9n18CdoV1pxrLFPcRd+h6HESmrAqucORlz3klFf/gyk=";
  };

  # Head builds report the base release version, which fails versionCheckHook.
  doInstallCheck = false;
})
