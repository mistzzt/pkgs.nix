{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-09-28";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "d5680d84fd1df3b592424eae5c50d54642f0727d";
    hash = "sha256-15yMjtzgMG/w1VslznzVNrgZGZ8u99KS2UPzbAUo9qk=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-AqbC/E4Uoer/eMzqZFXoOomRvFfDMEfYJsZfSp4ozBE=";
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
