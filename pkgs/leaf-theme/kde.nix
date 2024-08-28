{ stdenvNoCC
, fetchFromGitHub
, ruby
}:
stdenvNoCC.mkDerivation rec {
  pname = "leaf-kde";
  version = "unstable-20240826";

  src = fetchFromGitHub {
    owner = "qewer33";
    repo = pname;
    rev = "8308d1583dcebca666938d9ea9668d73e48d265c";
    hash = "sha256-5KY9JmIfwqWd/i2EW4su4v/f7PO/dFyu097Pxn6liWA=";
  };

  postPatch = ''
    substituteInPlace components.rb \
      --replace '#{Dir.home}/.local' "$out"
  '';

  nativeBuildInputs = [
    ruby
  ];

  installPhase = ''
    runHook preInstall
    patchShebangs .

    echo "Running install script"
    ruby ./install.rb

    runHook postInstall
  '';

  meta = {
    description = "Leaf KDE Plasma Theme";
    homepage = "https://github.com/qewer33/leaf-kde";
  };
}
