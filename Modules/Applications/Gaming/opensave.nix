{
  fetchurl,
  gdk-pixbuf,
  glib,
  glibc,
  gtk3,
  lib,
  libsoup_3,
  stdenvNoCC,
  webkitgtk_4_1,
}:

let
  libraryPath = lib.makeLibraryPath [
    gdk-pixbuf
    glib
    glibc
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opensave";
  version = "2.4.1";

  src = fetchurl {
    url = "https://github.com/Liquid-co/OpenSave/releases/download/v${finalAttrs.version}/opensave-linux-amd64.tar.gz";
    hash = "sha256-Bh9iCGOqjbRvQcCrib+Jn9KbFjy5lrAIDzoGfGdSJrI=";
  };

  sourceRoot = "opensave-linux";
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    for program in opensave opensave-cli opensave-relay; do
      install -Dm755 "$program" "$out/libexec/opensave/$program"
      mkdir -p "$out/bin"
      cat > "$out/bin/$program" <<EOF
    #!/bin/sh
    EOF
      if [ "$program" = opensave ]; then
        echo 'export WEBKIT_DISABLE_COMPOSITING_MODE=1' >> "$out/bin/$program"
      fi
      cat >> "$out/bin/$program" <<EOF
    exec ${glibc}/lib/ld-linux-x86-64.so.2 --library-path ${libraryPath} "$out/libexec/opensave/$program" "\$@"
    EOF
      chmod +x "$out/bin/$program"
    done

    install -Dm644 opensave.desktop "$out/share/applications/opensave.desktop"
    install -Dm644 opensave.png "$out/share/icons/hicolor/512x512/apps/opensave.png"
    install -Dm644 man/opensave.1 "$out/share/man/man1/opensave.1"
    install -Dm644 completions/opensave.bash "$out/share/bash-completion/completions/opensave"
    install -Dm644 completions/_opensave "$out/share/zsh/site-functions/_opensave"
    install -Dm644 completions/opensave.fish "$out/share/fish/vendor_completions.d/opensave.fish"

    runHook postInstall
  '';

  meta = {
    description = "Peer-to-peer game save synchronization";
    homepage = "https://www.opensave.org/";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "opensave";
  };
})
