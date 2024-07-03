{ fetchFromGitHub
, lib
, python3
}:
python3.pkgs.buildPythonApplication rec {
  pname = "adjustor";
  version = "2.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "hhd-dev";
    repo = "adjustor";
    rev = "v${version}";
    hash = "sha256-KgeK2lC3b9VbjYmy7rD/ImODWDDx3pWIzWgNnSLJeDs=";
  };

  propagatedBuildInputs = with python3.pkgs; [
    setuptools
    rich
    pyroute2
  ];

  # This package doesn't have upstream tests.
  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/hhd-dev/adjustor/";
    description = "Allows for TDP control of AMD Handhelds under handheld-daemon support";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
