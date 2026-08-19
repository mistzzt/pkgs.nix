{pkgs}: {
  anthropic-skills = pkgs.callPackage ./anthropic-skills {};
  claude-code-statusline = pkgs.callPackage ./claude-code-statusline {};
  cli-proxy-api-management-center = pkgs.callPackage ./cli-proxy-api-management-center {};
  codex-plugin-cc = pkgs.callPackage ./codex-plugin-cc {};
  extract-keyframes = pkgs.callPackage ./extract-keyframes {};
  herdr-preview = pkgs.callPackage ./herdr-preview {};
  onscripter-yuri = pkgs.callPackage ./onscripter-yuri {};
  pdfcropmargins = pkgs.callPackage ./pdfcropmargins {popplerUtils = pkgs.poppler-utils;};
  personal-skills = pkgs.callPackage ./personal-skills {};
  scripts = pkgs.callPackage ./scripts {};
  simple-english-skills = pkgs.callPackage ./simple-english-skills {};
  superpowers-skills = pkgs.callPackage ./superpowers-skills {};
}
