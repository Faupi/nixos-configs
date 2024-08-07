# TODO: REVERT BACK TO UPSTREAM ONCE FIX IS MERGED https://github.com/NixOS/nixpkgs/pull/309530
{ fetchFromGitHub
, hidapi
, kmod
, lib
, python3
, toybox
}:
python3.pkgs.buildPythonApplication rec {
  pname = "handheld-daemon";
  version = "2.6.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hhd-dev";
    repo = "hhd";
    rev = "v${version}";
    hash = "sha256-S77APtE1GGfqnv1IkZdJOSlprPOBtrqVXV60yVMvopg=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    evdev
    hidapi
    kmod
    pyyaml
    rich
    setuptools
    toybox
    xlib
  ];

  # This package doesn't have upstream tests.
  doCheck = false;

  postPatch = ''
    # The generated udev rules point to /bin/chmod, which does not exist in NixOS
    substituteInPlace src/hhd/controller/lib/hide.py \
      --replace-fail /bin/chmod ${toybox}/bin/chmod

    # handheld-daemon contains a fork of the python module `hid`, so this hook
    # is borrowed from the `hid` derivation.
    substituteInPlace src/hhd/controller/lib/hid.py \
      --replace-fail libhidapi ${hidapi}/lib/libhidapi

    hidapi=${hidapi}/lib/
    test -d $hidapi || { echo "ERROR: $hidapi doesn't exist, please update/fix this build expression."; exit 1; }
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
}
