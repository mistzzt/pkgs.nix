{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_16,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-11-19";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "e8d7d9705a7a2c89cef4dd42079379f05685af87";
    hash = "sha256-x+DOzoMhorpWTf8yN29g2P6Ha+oSGbaZdV7soxdSmaY=";
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
