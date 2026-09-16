{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-09-16";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "cee4fc2dc6ef2b9269636fc5dc876ecb44ee039f";
    hash = "sha256-MAWXZWpOPR9EXCZ+9oNb2PoT0U2ExcW9AgKeGJOQRdc=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-W4+In8pEdfN22Kl940v3ng+YZmr84Qu5prF6y0h0Zm8=";
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
