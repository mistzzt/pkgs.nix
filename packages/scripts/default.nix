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
  openssh,
  python3,
  rsync,
  unzip,
}: let
  shellScripts = {
    extract-and-strip = [arxiv-latex-cleaner coreutils findutils getopt unzip];
    git-prune-local = [git];
    rcode = [coreutils hostname];
  };
  pythonScripts = {
    remote = []; # use system bundled binaries
  };
  mkShellScript = name: runtimeInputs:
    writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile (./. + "/${name}.sh");
    };
  mkPythonScript = name: runtimeInputs:
    writeShellApplication {
      inherit name;
      runtimeInputs = runtimeInputs ++ [python3];
      text = ''exec python3 ${./. + "/${name}.py"} "$@"'';
    };
  individual =
    lib.mapAttrs mkShellScript shellScripts
    // lib.mapAttrs mkPythonScript pythonScripts;
in
  symlinkJoin {
    name = "scripts";
    paths = lib.attrValues individual;
    passthru = individual;
  }
