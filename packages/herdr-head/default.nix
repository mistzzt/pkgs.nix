{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_16,
}:
(herdr.override {zig_0_15 = zig_0_16;}).overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-10-08";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "2563803dca97c040beaf3dc3acdcb5a3221b4238";
    hash = "sha256-CCHbrAwI51iNPu7/ubU/UUmyxeIWEYoIcoFC5A6+KX8=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-hqjxn5+5+wB/aQceEKA0JxZCoag8GiYi88K+xUmxdGA=";
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
