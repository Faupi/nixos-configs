# NOTE: For some reason MoonDeck can have various issues (apps are null, CORS issues) 
#       - in that case a full Steam restart (and decky while Steam is down) seems to be enough

{ stdenv
, fetchFromGitHub
, fetchPnpmDeps
, python3
, gawk
, nodejs
, pnpm
, pnpmConfigHook
, typescript
}:
let
  pythonEnv = (python3.withPackages (python-pkgs: with python-pkgs; [
    tkinter
  ]));
in
stdenv.mkDerivation rec {
  pname = "moondeck";
  version = "unstable-20261020";

  src = fetchFromGitHub {
    owner = "FrogTheFrog";
    repo = "moondeck";
    rev = "00f8c31a6d9324878811178a2f8a319e4ca5c7c2";
    hash = "sha256-l8tqH/h7YitLul8cpw51cf9Y7UC0tIQF9OhIB+m+d4I=";
    fetchSubmodules = true;
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm;
    fetcherVersion = 4;
    hash = "sha256-BmUCykZwJjUlnqpspXU8cDUzfy9XN1320xLgECuek7Q=";
  };

  # patches = [
  #   # REVIEW: OLD PATCHES, LIKELY BROKEN
  #   ./safe-flatpak-kill.patch # MoonDeck tries to hard-kill flatpak, which doesn't exist and it's not safeguarded...
  #   ./stringify-null.patch # Might be needed for Buddy status - getting it from Buddy can sometimes throw an error and crash the UI
  #   ./group-logs.patch # Adds group-write permissions to log files - needed for runner logs under multiuser decky

  #   # TODO: Maybe not upstream but would be nice
  #   ./use-decky-dirs.patch # Map config, data, log directories under decky

  #   # TODO: `defaults/python/moondeckrun.sh` might need to be built separately, so existing shortcuts don't need to be purged with every small update 
  #   # NOTE: ^ Different hash in path, MoonDeck does some sanity checks for shortcut exec paths in case they got swapped or something
  # ];

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
    (pnpmConfigHook.override { pnpm = pnpm; })
    pnpm
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
