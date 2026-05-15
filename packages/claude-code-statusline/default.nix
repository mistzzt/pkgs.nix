{
  writeShellApplication,
  coreutils,
  git,
  jq,
}:
writeShellApplication {
  name = "claude-code-statusline";

  runtimeInputs = [
    coreutils
    git
    jq
  ];

  text = builtins.readFile ./statusline.sh;
}
