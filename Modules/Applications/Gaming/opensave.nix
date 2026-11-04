{
  autoPatchelfHook,
  fetchurl,
  gdk-pixbuf,
  glib,
  gtk3,
  lib,
  libsoup_3,
  stdenvNoCC,
  webkitgtk_4_1,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "opensave";
  version = "2.4.1";

  src = fetchurl {
    url = "https://github.com/Liquid-co/OpenSave/releases/download/v${finalAttrs.version}/opensave-linux-amd64.tar.gz";
    hash = "sha256-Bh9iCGOqjbRvQcCrib+Jn9KbFjy5lrAIDzoGfGdSJrI=";
  };

  sourceRoot = "opensave-linux";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [
    gdk-pixbuf
    glib
    gtk3
    libsoup_3
    webkitgtk_4_1
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 opensave "$out/bin/opensave"
    install -Dm755 opensave-cli "$out/bin/opensave-cli"
    install -Dm755 opensave-relay "$out/bin/opensave-relay"
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
