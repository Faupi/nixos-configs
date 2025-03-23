# NOTE: For some reason MoonDeck can have various issues (apps are null, CORS issues) 
#       - in that case a full Steam restart (and decky while Steam is down) seems to be enough

{ stdenv
, fetchFromGitHub
, python3
, gawk
, nodejs
, pnpm_9
, typescript
}:
let
  pythonEnv = (python3.withPackages (python-pkgs: with python-pkgs; [
    tkinter
  ]));
in
stdenv.mkDerivation rec {
  pname = "moondeck";
  version = "unstable-20250312";

  src = fetchFromGitHub {
    owner = "FrogTheFrog";
    repo = "moondeck";
    rev = "c0689925683f70fa88fc9847ab3cbf0a0d07f11a";
    hash = "sha256-gie3Bn9DYHcHwAanyJ1hPwkyhWMCuyFaPOEyV9vq/iw=";
    fetchSubmodules = true;
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version src;
    hash = "sha256-8P9OfmlQ1gXQSdsSY5hEUQOJ5A7o5CvcUYfUUEtsNWs=";
  };

  patches = [
    ./stringify-null.patch # Actually needed for Buddy status - getting it from Buddy can sometimes throw an error and crash the UI
    ./no-flatpak-kill.patch # MoonDeck tries to hard-kill flatpak, which doesn't exist and it's not safeguarded...
    ./constants.patch
  ];

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

    patchShebangs .
  '';

  nativeBuildInputs = [
    nodejs
    typescript
    pnpm_9.configHook
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
