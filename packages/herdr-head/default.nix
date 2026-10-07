{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "1b23719b3e01d56d8ee11097040ee0a7b5379dd3";
    hash = "sha256-wrgSOz4d6RG1xY5jgmtGJ+UQPRWTsWA7Z+SVvRb3Luw=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-hqjxn5+5+wB/aQceEKA0JxZCoag8GiYi88K+xUmxdGA=";
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
