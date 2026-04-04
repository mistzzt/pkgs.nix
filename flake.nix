{
  description = "Custom package repository with auto-updates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);

    pkgsFor = system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
  in {
    packages = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      import ./packages {inherit pkgs;});

    overlays.default = final: prev: self.packages.${prev.stdenv.hostPlatform.system};
  };
}
