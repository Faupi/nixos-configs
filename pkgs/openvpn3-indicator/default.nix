# When you spend multiple hours to find out that you just need a setup.py...
# Anyway most of this was fixed thanks to the existing package on https://github.com/nix-community/nur-combined/blob/master/repos/mloeper/pkgs/openvpn3-indicator/default.nix

{ desktop-file-utils
, fetchFromGitHub
, gnumake
, gnused
, gobject-introspection
, libappindicator-gtk3
, libayatana-appindicator
, openvpn3
, python3Packages
, shared-mime-info
, wrapGAppsHook3
, zip
}:
python3Packages.buildPythonApplication {
  pname = "openvpn3-indicator";
  version = "unstable-20241010";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "OpenVPN";
    repo = "openvpn3-indicator";
    rev = "bc871e0fcbf3b549939f302d1475f2edb9d2e30d";
    hash = "sha256-A9pupZbQoV1m6dy54n4DmZUohaCqCM15uLa50D1D6MI=";
  };
  patches = [
    ./add-setup-py.patch
  ];

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
    libappindicator-gtk3
    libayatana-appindicator
  ];

  propagatedBuildInputs = with python3Packages; [
    setuptools

    secretstorage
    dbus-python
    pygobject3
    setproctitle
    openvpn3
  ];

  postInstall = ''
    cp -r $src/share $out/share
    
    substituteInPlace $out/share/applications/net.openvpn.openvpn3_indicator.desktop \
      --replace-fail "/usr/bin/openvpn3-indicator" "$out/bin/openvpn3-indicator"
  '';

  # Avoid double wrapping https://nixos.org/nixpkgs/manual/#ssec-gnome-common-issues-double-wrapped
  dontWrapGApps = true;
  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';
}
