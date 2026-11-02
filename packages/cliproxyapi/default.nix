{
  lib,
  buildGoModule,
  fetchFromGitHub,
  go_1_27,
  versionCheckHook,
}:
buildGoModule.override {go = go_1_27;} rec {
  pname = "cli-proxy-api";
  version = "8.0.52";

  src = fetchFromGitHub {
    owner = "router-for-me";
    repo = "CLIProxyAPI";
    tag = "v${version}";
    hash = "sha256-wIx1XCj1MxJ7jQf9Tnm0PXyL3UfjFBFLtBR5FphS9BE=";
  };

  vendorHash = "sha256-YZf38f5X+z/rICUQKHuzmZxkPH3AAap6XkIho/injVA=";

  subPackages = ["cmd/server"];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X main.Commit=nixpkgs"
    "-X main.BuildDate=1970-01-01T00:00:00Z"
  ];

  postInstall = ''
    mv $out/bin/server $out/bin/cli-proxy-api
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [versionCheckHook];

  meta = {
    description = "Unified proxy providing OpenAI/Gemini/Claude/Codex compatible APIs for AI coding CLI tools";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    changelog = "https://github.com/router-for-me/CLIProxyAPI/releases";
    license = lib.licenses.mit;
    sourceProvenance = [lib.sourceTypes.fromSource];
    mainProgram = "cli-proxy-api";
    platforms = lib.platforms.all;
  };
}
