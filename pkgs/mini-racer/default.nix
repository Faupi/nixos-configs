# https://github.com/Chikage0o0/nixos-config/blob/98f959556c9caf73f6110db3c2de862cc4eb73be/pkgs/home-assistant-python-deps.nix#L43-L66

{ pkgs
, python3Packages
}:
python3Packages.buildPythonPackage {
  pname = "mini-racer";
  version = "0.14.1-py3";
  format = "wheel";

  src = pkgs.fetchurl {
    url = "https://files.pythonhosted.org/packages/c2/3c/c5bd479784826bbbc69f713aae2bcfd5ef353ba4e5e0e661666938474535/mini_racer-0.14.1-py3-none-manylinux_2_27_x86_64.whl";
    hash = "sha256-zfOgiOE2PxamlSiPiCq/drNwW44d8hQYIIuH7QEAN6Q=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];

  pythonImportsCheck = [ "py_mini_racer" ];
  doCheck = false;

  meta = {
    description = "Embedded V8 runtime for Python";
    homepage = "https://github.com/bpcreech/PyMiniRacer";
    license = pkgs.lib.licenses.isc;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ pkgs.lib.sourceTypes.binaryNativeCode ];
  };
}
