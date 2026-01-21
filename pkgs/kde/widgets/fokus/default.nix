{ addFlowIcon ? false
, stdenv
, stdenvNoCC
, lib
, fetchFromGitLab
, kdePackages
, python3
, libcanberra
, glib
, libnotify
, gdk-pixbuf
, makeWrapper
}:

let
  pythonEnv = python3.withPackages (python-pkgs: with python-pkgs; [
    pygobject3
  ]);

  pythonGI = stdenvNoCC.mkDerivation {
    pname = "unstable-2025-10-01";
    version = "1.0.0";
    nativeBuildInputs = [ makeWrapper ];
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${lib.getExe pythonEnv} $out/bin/python3 \
        --prefix GI_TYPELIB_PATH : "${glib}/lib/girepository-1.0:${libnotify}/lib/girepository-1.0:${gdk-pixbuf}/lib/girepository-1.0" \
        --prefix LD_LIBRARY_PATH : "${glib}/lib:${libnotify}/lib:${gdk-pixbuf}/lib"
    '';

    meta.mainProgram = "python3";
  };
in
stdenv.mkDerivation {
  pname = "fokus";
  version = "unstable-2025-10-01";

  src = fetchFromGitLab {
    owner = "divinae";
    repo = "focus-plasmoid";
    rev = "488cb0f024acd1fb592b200c61ffc2c25f888360";
    hash = "sha256-9xcNjJypaEnq6QTF71dkeBV1v71R+mJFUZrq+a+EALM=";
  };

  patches = lib.optional addFlowIcon ./flowmodoro-icon.patch; # TODO: Create an actual custom icon

  postPatch = ''
    substituteInPlace package/contents/ui/NotificationManager.qml \
      --replace-fail 'python3' '${lib.getExe pythonGI}'

    substituteInPlace package/contents/scripts/notification.py \
      --replace-fail '/usr/bin/python3' '${lib.getExe pythonGI}' \
      --replace-fail 'CDLL("libcanberra.so.0")' 'CDLL("${libcanberra}/lib/libcanberra.so.0")'
  '';

  installPhase = ''
    path=$out/share/plasma/plasmoids
    mkdir -p $path
    kpackagetool6 --install package --packageroot $path
  '';

  nativeBuildInputs = [ kdePackages.kpackage ];
  dontWrapQtApps = true;
}
