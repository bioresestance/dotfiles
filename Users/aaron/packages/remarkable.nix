{
  lib,
  python3Packages,
  fetchFromGitHub,
  wrapGAppsHook3,
  gobject-introspection,
  gtk3,
  gtksourceview3,
  webkitgtk_4_1,
  glib,
  wkhtmltopdf,
}:

python3Packages.buildPythonApplication rec {
  pname = "remarkable";
  version = "1.95";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "jamiemcg";
    repo = "Remarkable";
    rev = "v${version}";
    hash = "sha256-TKLy8ke/QQLR+7Hci5anbsQRWcKs2hBNiwy4Or582ig=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk3
    gtksourceview3
    webkitgtk_4_1
    glib
  ];

  propagatedBuildInputs = with python3Packages; [
    pygobject3
    pycairo
    markdown
    beautifulsoup4
    lxml
    pygtkspellcheck
    pyenchant
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install Python packages
    siteDir=$out/lib/${python3Packages.python.libPrefix}/site-packages
    mkdir -p $siteDir
    cp -r remarkable $siteDir/
    cp -r remarkable_lib $siteDir/
    cp -r pdfkit $siteDir/

    # Install data files
    mkdir -p $out/share/remarkable
    cp -r data/* $out/share/remarkable/

    # Patch the data directories to include our Nix store path
    substituteInPlace $siteDir/remarkable_lib/remarkableconfig.py \
      --replace-fail \
        "__remarkable_data_directories__ = ['../data', '/usr/share/remarkable']" \
        "__remarkable_data_directories__ = ['$out/share/remarkable', '../data', '/usr/share/remarkable']"

    # Fix relative imports for modules inside the remarkable package
    substituteInPlace $siteDir/remarkable/RemarkableWindow.py \
      --replace-fail "import styles" "from remarkable import styles" \
      --replace-fail "from findBar import FindBar" "from remarkable.findBar import FindBar"

    # Install the entry point script
    mkdir -p $out/bin
    cat > $out/bin/remarkable <<EOF
    #!${python3Packages.python}/bin/python3
    import sys
    import os
    sys.path.insert(0, "$siteDir")
    import remarkable
    remarkable.main()
    EOF
    chmod +x $out/bin/remarkable

    # Install desktop file and icons
    mkdir -p $out/share/applications
    cp remarkable.desktop $out/share/applications/
    substituteInPlace $out/share/applications/remarkable.desktop \
      --replace-fail "Exec=/usr/bin/remarkable" "Exec=$out/bin/remarkable" \
      --replace-fail "Icon=remarkable" "Icon=$out/share/remarkable/media/remarkable.svg"

    runHook postInstall
  '';

  # Disable all Python-specific phases we don't need
  dontUseSetuptoolsBuild = true;
  dontUsePipInstall = true;
  dontUseSetuptoolsCheck = true;

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PATH : ${lib.makeBinPath [ wkhtmltopdf ]}
    )
  '';

  meta = with lib; {
    description = "A fully featured markdown editor for Linux";
    homepage = "https://remarkableapp.github.io";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "remarkable";
  };
}
