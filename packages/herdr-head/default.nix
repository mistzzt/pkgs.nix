{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-09-24";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "9c96f7ddb3be2cc575a159d4d1f1d49fb10d7006";
    hash = "sha256-DmZAcvejRDvQhJ80OaGgOPU0w8wC3CfCx7oCFEQ1WAM=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-nHDij4yZSdj/7jak8v5FfQUaGfaojlCWEUsle/vmDtM=";
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
