{
  buildGoModule,
  fetchNpmDeps,
  fetchFromGitHub,
  lib,
  nodejs_22,
  npmHooks,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);

  src = fetchFromGitHub {
    owner = "Willxup";
    repo = "cpa-usage-keeper";
    rev = "v${data.version}";
    hash = data.hash;
  };
in
  buildGoModule {
    pname = "cpa-usage-keeper";
    inherit src;
    inherit (data) version;

    vendorHash = data.vendorHash;
    npmDeps = fetchNpmDeps {
      src = "${src}/web";
      hash = data.npmDepsHash;
    };

    npmRoot = "web";

    env.CGO_ENABLED = 1;

    nativeBuildInputs = [
      nodejs_22
      npmHooks.npmConfigHook
    ];

    overrideModAttrs = oldAttrs: {
      nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
      preBuild = null;
    };

    preBuild = ''
      npm --prefix="$npmRoot" run build
    '';

    subPackages = ["cmd/server"];

    postInstall = ''
      mv $out/bin/server $out/bin/cpa-usage-keeper
    '';

    meta = with lib; {
      description = "Standalone CPA usage persistence and visualization service";
      homepage = "https://github.com/Willxup/cpa-usage-keeper";
      license = licenses.mit;
      mainProgram = "cpa-usage-keeper";
      platforms = platforms.unix;
    };
  }
