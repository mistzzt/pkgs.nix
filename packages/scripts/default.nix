{
  lib,
  writeShellApplication,
  symlinkJoin,
  arxiv-latex-cleaner,
  coreutils,
  findutils,
  getopt,
  git,
  gnutar,
  hostname,
  unzip,
}: let
  shellScripts = {
    extract-and-strip = [arxiv-latex-cleaner coreutils findutils getopt gnutar unzip];
    git-prune-local = [git];
    rcode = [coreutils hostname];
  };
  mkShellScript = name: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile (./. + "/${name}.sh");
    };
  individual = lib.mapAttrs mkShellScript shellScripts;
in
  symlinkJoin {
    name = "scripts";
    paths = lib.attrValues individual;
    passthru = individual;
  }
