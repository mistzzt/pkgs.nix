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
    rev = "a2008661cd4a89ff6df22bf4a6b472bd413018be";
    hash = "sha256-peehz71KJrwdLEm7njiHpU2KfsXd0Ohh0t9muWpmMMQ=";
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
