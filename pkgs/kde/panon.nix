{ stdenv
, fetchFromGitHub
, kdePackages
, python3
}:
let
  # Python requirements in main README of the project
  pythonEnv = (python3.withPackages (python-pkgs: with python-pkgs; [
    docopt
    numpy
    pyaudio
    cffi
    websockets
    soundcard
  ]));
in
stdenv.mkDerivation {
  pname = "panon";
  version = "unstable-20240824";

  src = fetchFromGitHub {
    owner = "flafflar";
    repo = "panon";
    rev = "f62e887a580685eb371ecc43868a05005a0eced4";
    hash = "sha256-acBe6zNZZ3Fbe01T5fB1jlJZbTtud9Agp8ROiP8WJ+0=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace plasmoid/contents/scripts/panon/effect/build_shader_source.py \
      --replace '/usr/lib64/qt6/bin/qsb' '${kdePackages.qtshadertools}/bin/qsb'

    for i in `grep -l -R 'python3' .`; do
      echo "Patching python3 in $i"
      substituteInPlace $i \
        --replace "python3" "${pythonEnv}/bin/python3"
    done
  '';

  nativeBuildInputs = [ kdePackages.kpackage ];
  buildInputs = [ kdePackages.qtwebsockets pythonEnv ];
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall
    
    kpackagetool6 --install plasmoid --packageroot $out/share/plasma/plasmoids/

    runHook postInstall
  '';
}
