{
  lib,
  writeShellApplication,
  symlinkJoin,
  arxiv-latex-cleaner,
  coreutils,
  findutils,
  getopt,
  git,
  gnugrep,
  gnused,
  gnutar,
  hostname,
  rsync,
  unzip,
}: let
  shellScripts = {
    extract-and-strip = [arxiv-latex-cleaner coreutils findutils getopt gnugrep gnused gnutar unzip];
    git-prune-local = [git];
    rcode = [coreutils hostname];
    forward = [];
    rcp = [coreutils hostname];
    rgt = [coreutils rsync];
    rclip = [coreutils];
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
