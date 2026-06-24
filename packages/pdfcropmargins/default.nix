{
  lib,
  python3Packages,
  fetchPypi,
  ghostscript,
  popplerUtils,
}: let
  data = builtins.fromJSON (builtins.readFile ./hashes.json);
in
  python3Packages.buildPythonApplication {
    pname = "pdfCropMargins";
    version = data.version;
    pyproject = true;

    src = fetchPypi {
      # PyPI normalizes the sdist filename to all-lowercase.
      pname = "pdfcropmargins";
      version = data.version;
      hash = data.hash;
    };

    build-system = [python3Packages.setuptools];

    dependencies = with python3Packages; [
      pillow
      pymupdf
    ];

    # ghostscript / pdftoppm are invoked at runtime for bounding-box detection.
    makeWrapperArgs = [
      "--prefix PATH : ${lib.makeBinPath [ghostscript popplerUtils]}"
    ];

    pythonImportsCheck = ["pdfCropMargins"];

    meta = {
      description = "Crop the margins of a PDF file by adjusting the CropBox (no re-render, no bloat)";
      homepage = "https://github.com/abarker/pdfCropMargins";
      license = lib.licenses.gpl3Plus;
      mainProgram = "pdfcropmargins";
    };
  }
