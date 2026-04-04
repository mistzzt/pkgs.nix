{pkgs}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
  managementHtml = pkgs.fetchurl {
    url = "https://github.com/router-for-me/Cli-Proxy-API-Management-Center/releases/download/v${data.version}/management.html";
    sha256 = data.hash;
  };
in
  pkgs.linkFarm "cliproxyapi-management-center" [
    {
      name = "index.html";
      path = managementHtml;
    }
  ]
