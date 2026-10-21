{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_16,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-10-21";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "5bd900d88c80d95f5b145397e45bbeea398b8165";
    hash = "sha256-f5+w+PBSYVXA2vQYC/c4+oaDIfmU9esBs9EoHNvR/2g=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-a6DgQodo+qa5yg/d+yMfsM9EUv2LQRFrqZgmwgVxggE=";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = finalAttrs.cargoHash;
  };

  zigDeps = zig_0_16.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-Cy0DdSvce+fhOFIfxHMQGF2b2j16UkS27UpGbfC42XI=";
  };

  # Head builds report the base release version, which fails versionCheckHook.
  doInstallCheck = false;
})
