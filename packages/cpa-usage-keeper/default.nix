{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);

  src = fetchFromGitHub {
    owner = "Willxup";
    repo = "cpa-usage-keeper";
    rev = "v${data.version}";
    hash = data.hash;
  };

  web = buildNpmPackage {
    pname = "cpa-usage-keeper-web";
    inherit (data) version;
    src = "${src}/web";

    npmDepsHash = data.npmDepsHash;

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
  buildGoModule {
    pname = "cpa-usage-keeper";
    inherit src;
    inherit (data) version;

    vendorHash = data.vendorHash;

    env.CGO_ENABLED = 1;

    subPackages = ["cmd/server"];

    postInstall = ''
      mv $out/bin/server $out/bin/cpa-usage-keeper
      mkdir -p $out/bin/web
      cp -r ${web} $out/bin/web/dist
    '';

    meta = with lib; {
      description = "Standalone CPA usage persistence and visualization service";
      homepage = "https://github.com/Willxup/cpa-usage-keeper";
      license = licenses.mit;
      mainProgram = "cpa-usage-keeper";
      platforms = platforms.unix;
    };
  }
