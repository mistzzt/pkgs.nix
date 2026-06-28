{
  fetchFromGitHub,
  runCommand,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
  src = fetchFromGitHub {
    owner = "openai";
    repo = "codex-plugin-cc";
    rev = "v${data.version}";
    hash = data.hash;
  };
in
  # The Claude Code plugin lives in plugins/codex; expose that directory
  # (containing .claude-plugin/plugin.json plus commands, agents, skills,
  # hooks, scripts, ...) as the package output so it can be passed straight
  # to home-manager's programs.claude-code.plugins via --plugin-dir.
  runCommand "codex-plugin-cc" {} "cp -r ${src}/plugins/codex $out"
