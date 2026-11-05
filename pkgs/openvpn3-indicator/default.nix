{ desktop-file-utils
, fetchFromGitHub
, glib
, gnumake
, gnused
, gobject-introspection
, gtk3
, gzip
, lib
, libappindicator-gtk3
, libayatana-appindicator
, openvpn3
, python3
, shared-mime-info
, stdenv
, wrapGAppsHook3
, zip
}:
stdenv.mkDerivation rec {
  pname = "openvpn3-indicator";
  version = "unstable-20241010";

  src = fetchFromGitHub {
    owner = "OpenVPN";
    repo = "openvpn3-indicator";
    rev = "33e5a55e7e3aeb441e4fcaa94abdeade6b1d4325";
    hash = "sha256-jsFlmybscDvSKupiAaVkFj2Pg6ej8360OQOnDh9RsbQ=";
  };

  postPatch = ''
    patchShebangs scripts/build_executable
  '';

  pythonEnv = python3.withPackages (ps: with ps; [
    secretstorage
    dbus-python
    pygobject3
    setproctitle
  ]);

  nativeBuildInputs = [
    gnumake
    gnused
    gzip
    zip
    desktop-file-utils
    shared-mime-info
    gobject-introspection
    glib
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    libayatana-appindicator
    openvpn3
    pythonEnv
  ];

  makeFlags = [
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
    "BINDIR=${placeholder "out"}/bin"
    "DATADIR=${placeholder "out"}/share"
    "AUTOSTART=${placeholder "out"}/etc/xdg/autostart"
    "HARDCODE_PYTHON=${pythonEnv}/bin/python3"
  ];

  buildFlags = [ "all" ];
  installTargets = [ "package" ];

  postInstall = ''
    glib-compile-schemas "$out/share/glib-2.0/schemas"
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "${openvpn3}/${python3.sitePackages}"
    )
  '';

  meta = {
    description = "Simple GTK indicator GUI for OpenVPN 3";
    homepage = "https://github.com/OpenVPN/openvpn3-indicator";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "openvpn3-indicator";
  };
}
