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
    rev = "4dc23bb15d4a2fd2c093abfb509f903c3015bf56";
    hash = "sha256-h88bIuSW/i5/YiIqKMPah6JZmyMWpq7/6KylfbUgWQw=";
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
