{
  fetchFromGitHub,
  herdr,
  rustPlatform,
  zig_0_15,
}:
herdr.overrideAttrs (finalAttrs: prev: {
  version = "unstable-2026-09-05";

  src = fetchFromGitHub {
    owner = "herdrdev";
    repo = "herdr";
    rev = "9e9bc8a144667a6b7debfd4f0c7a31ff0e11493a";
    hash = "sha256-X0yb+XqNkqAFoKFJSxhtidun5gsKxrd0+84CFvQWv9o=";
  };

  # buildRustPackage reads cargoHash from its original arguments, so overriding
  # it alone has no effect; wire it into an explicit cargoDeps instead.
  cargoHash = "sha256-4VThqPwYYEsGvaOKjBeL6XAC5bnNWB6oUMWP/uXc/UQ=";
  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = finalAttrs.cargoHash;
  };

  zigDeps = zig_0_15.fetchDeps {
    inherit (finalAttrs) pname version;
    src = "${finalAttrs.src}/vendor/libghostty-vt";
    fetchAll = true;
    hash = "sha256-PnM+hZIlLyQwK8vJgd/Bhjt1lNIz06T8FahwliRmMrY=";
  };

  # Head builds report the base release version, which fails versionCheckHook.
  doInstallCheck = false;
})
