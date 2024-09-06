{ fetchFromGitHub
, hidapi
, kmod
, lib
, python3
, toybox
}:
let
  py = python3.override {
    self = py;
    packageOverrides = lib.foldr lib.composeExtensions (self: super: { }) [
      (self: super: {
        adjustor = self.buildPythonPackage rec {
          pname = "adjustor";
          version = "3.4.5";
          pyproject = true;
          doCheck = false;

          src = fetchFromGitHub {
            owner = "hhd-dev";
            repo = "adjustor";
            rev = "v${version}";
            hash = "sha256-tde9FfP9MVOw1/0c4y8fQxVNmvvqjPG97S4bphOdqws=";
          };

          propagatedBuildInputs = with self; [
            setuptools
            rich
            pyroute2
            fuse
            pygobject3
            dbus-python
          ];

          postPatch = ''
            substituteInPlace src/adjustor/drivers/amd/__init__.py \
              --replace "sys.executable" "'${py.interpreter}'"
          '';

          meta = with lib; {
            homepage = "https://github.com/hhd-dev/adjustor/";
            description = "Allows for TDP control of AMD Handhelds under handheld-daemon support";
            platforms = platforms.linux;
            license = licenses.mit;
            mainPackage = "adjustor";
          };
        };
      })
      (self: super: {
        handheld-daemon = self.buildPythonPackage rec {
          pname = "handheld-daemon";
          version = "3.3.11";
          pyproject = true;

          src = fetchFromGitHub {
            owner = "hhd-dev";
            repo = "hhd";
            rev = "refs/tags/v${version}";
            hash = "sha256-vjJY9YrULRHEgVIgzwLS5gKfQnbHFKXigU+rlm+BiJQ=";
          };

          propagatedBuildInputs = with self; [
            evdev
            hidapi
            kmod
            pyyaml
            rich
            setuptools
            toybox
            xlib
            adjustor
          ];

          # This package doesn't have upstream tests.
          doCheck = false;

          postPatch = ''
            # handheld-daemon contains a fork of the python module `hid`, so this hook
            # is borrowed from the `hid` derivation.
            hidapi=${hidapi}/lib/
            test -d $hidapi || { echo "ERROR: $hidapi doesn't exist, please update/fix this build expression."; exit 1; }
            sed -i -e "s|libhidapi|$hidapi/libhidapi|" src/hhd/controller/lib/hid.py

            # The generated udev rules point to /bin/chmod, which does not exist in NixOS
            chmod=${toybox}/bin/chmod
            sed -i -e "s|/bin/chmod|$chmod|" src/hhd/controller/lib/hide.py
          '';

          postInstall = ''
            install -Dm644 $src/usr/lib/udev/rules.d/83-hhd.rules -t $out/lib/udev/rules.d/
          '';

          meta = with lib; {
            homepage = "https://github.com/hhd-dev/hhd/";
            description = "Linux support for handheld gaming devices like the Legion Go, ROG Ally, and GPD Win";
            platforms = platforms.linux;
            license = licenses.mit;
            maintainers = with maintainers; [ appsforartists toast ];
            mainProgram = "hhd";
          };
        };
      })
    ];
  };
in
with py.pkgs;
toPythonApplication handheld-daemon
