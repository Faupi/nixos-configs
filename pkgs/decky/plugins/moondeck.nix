{ stdenv
, fetchFromGitHub
, python3
, gawk
, nodejs
, pnpm
, typescript
}:
let
  pythonEnv = (python3.withPackages (python-pkgs: with python-pkgs; [
    tkinter
  ]));
in
stdenv.mkDerivation rec {
  pname = "moondeck";
  version = "unstable-20241201";

  src = fetchFromGitHub {
    owner = "FrogTheFrog";
    repo = "moondeck";
    rev = "b31f90203f01af171b2bccd778af895f9979f513";
    hash = "sha256-PhvodxepNjoo/pr60bBM7KHAw9ag26PaP3v9zENsDzc=";
  };

  pnpmDeps = pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-Sks7zJMf9UdUIBEAFbd7Mqwj/EmE/AnTgoa54hjytEg=";
  };

  postPatch = ''
    echo "Replace python references"
    (
      substituteInPlace defaults/python/externals/wakeonlan/__init__.py \
        --replace-fail "/usr/bin/env python3" "${pythonEnv}/bin/python3"
      substituteInPlace defaults/python/externals/bin/wakeonlan \
        --replace-fail "/usr/bin/python" "${pythonEnv}/bin/python3"
      substituteInPlace defaults/python/moondeckrun.sh \
        --replace-fail "/usr/bin/python" "${pythonEnv}/bin/python3"
    )

    echo "Replace awk reference"
    substituteInPlace defaults/python/lib/constants.py \
      --replace-fail "awk" "${gawk}/bin/awk"
  '';

  nativeBuildInputs = [
    nodejs
    typescript
    pnpm.configHook
  ];

  buildInputs = [
    pythonEnv
    gawk
  ];

  buildPhase = ''
    pnpm run build
  '';

  installPhase = ''
    runHook preInstall
    
    shopt -s extglob
    mkdir -p $out
    cp -a defaults/* "$out/"
    cp -a !(defaults|node_modules|src|pnpm-lock.yaml|rollup.config.js|tsconfig.json) "$out/"

    runHook postInstall
  '';
}
