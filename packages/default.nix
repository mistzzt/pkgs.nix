{pkgs}: {
  anthropic-skills = pkgs.callPackage ./anthropic-skills {};
  claude-code-statusline = pkgs.callPackage ./claude-code-statusline {};
  cli-proxy-api-management-center = pkgs.callPackage ./cli-proxy-api-management-center {};
  onscripter-yuri = pkgs.callPackage ./onscripter-yuri {};
  pdfcropmargins = pkgs.callPackage ./pdfcropmargins {popplerUtils = pkgs.poppler-utils;};
  scripts = pkgs.callPackage ./scripts {};
  superpowers-skills = pkgs.callPackage ./superpowers-skills {};
}
