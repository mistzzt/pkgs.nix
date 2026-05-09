{pkgs}: {
  anthropic-skills = pkgs.callPackage ./anthropic-skills {};
  cliproxyapi-management-center = pkgs.callPackage ./cliproxyapi-management-center {};
  onscripter-yuri = pkgs.callPackage ./onscripter-yuri {};
  scripts = pkgs.callPackage ./scripts {};
  superpowers-skills = pkgs.callPackage ./superpowers-skills {};
}
