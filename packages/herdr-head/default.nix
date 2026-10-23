{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_16,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "5608de0608918aba2f9d501e7793b984a0ca9cfa";
    hash = "sha256-s4TJ7vVMGxukdwl3IYNcvT+JgBgRFgwfdBWWhzohf7I=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-hppCIcIEAbefGYz1PgHmGuwCcnsr5iS9WtjTA+gCI2M=";
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
