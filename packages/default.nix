{pkgs}: {
  anthropic-skills = pkgs.callPackage ./anthropic-skills {};
  cliproxyapi-management-center = pkgs.callPackage ./cliproxyapi-management-center {};
  cpa-usage-keeper = pkgs.callPackage ./cpa-usage-keeper {};
  onscripter-yuri = pkgs.callPackage ./onscripter-yuri {};
  scripts = pkgs.callPackage ./scripts {};
  superpowers-skills = pkgs.callPackage ./superpowers-skills {};
}
