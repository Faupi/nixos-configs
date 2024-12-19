{ fetchFromGitHub
, python3Packages
, libayatana-appindicator
, openvpn3
, gnumake
, gnused
, zip
, desktop-file-utils
, shared-mime-info
, gtk3
, gobject-introspection
, json-glib
, wrapGAppsHook3
}:
python3Packages.buildPythonApplication {
  pname = "openvpn3-indicator";
  version = "unstable-20241010";

  src = fetchFromGitHub {
    owner = "OpenVPN";
    repo = "openvpn3-indicator";
    rev = "bc871e0fcbf3b549939f302d1475f2edb9d2e30d";
    hash = "sha256-A9pupZbQoV1m6dy54n4DmZUohaCqCM15uLa50D1D6MI=";
  };

  postPatch = ''
    patchShebangs .

    echo "Replace build targets"
    substituteInPlace Makefile \
      --replace-fail "DESTDIR ?=" "DESTDIR ?= $out" \
      --replace-fail "/usr/local" "/" \
      --replace-fail 's|/usr/bin/|$(BINDIR)/|g' 's|/usr/bin/|$(DESTDIR)$(BINDIR)/|g'
  '';

  nativeBuildInputs = [
    gnumake
    gnused
    zip
    desktop-file-utils
    shared-mime-info
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    openvpn3
    libayatana-appindicator
    json-glib
    gtk3
  ];

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    secretstorage
    setproctitle
    pygobject3
  ];

  pyproject = false;

  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';
}
