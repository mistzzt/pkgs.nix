{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-10-01";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "d6b40d4edd550ccea081f089605a64314f8c8b27";
    hash = "sha256-AiruvCcV2wdbAU06TldsWj3i7LmKvH9NuTnlCY90ik0=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-RhCN4tlCgPqdP9tz/EayWNwCc0oWOUpjbAWV1VxT3yE=";
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
