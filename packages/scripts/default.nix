{
  lib,
  writeShellApplication,
  symlinkJoin,
  arxiv-latex-cleaner,
  coreutils,
  findutils,
  getopt,
  git,
  hostname,
  unzip,
}: let
  scripts = {
    extract-and-strip = [arxiv-latex-cleaner coreutils findutils getopt unzip];
    git-prune-local = [git];
    rcode = [coreutils hostname];
  };
  mkScript = name: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile (./. + "/${name}.sh");
    };
  individual = lib.mapAttrs mkScript scripts;
in
  symlinkJoin {
    name = "scripts";
    paths = lib.attrValues individual;
    passthru = individual;
  }
