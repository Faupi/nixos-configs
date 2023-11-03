{ stdenv
, fetchFromGitLab
, cmake
, pkg-config
, extra-cmake-modules
, qt5
, libsForQt5
}: stdenv.mkDerivation {
  pname = "xwaylandvideobridge";
  version = "unstable-2023-07-24";

  src = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "system";
    repo = "xwaylandvideobridge";
    rev = "014111b4db6298968204fd56d5ce6f691137bf90";
    sha256 = "sha256-6ro5Y5GSiodzbsiPQls4IAOYGLcLE7j+0eumpW6+HeU=";
  };

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
  ];

  buildInputs = [
    qt5.qtbase
    qt5.qtquickcontrols2
    qt5.qtx11extras
    libsForQt5.kdelibs4support
    (libsForQt5.kpipewire.overrideAttrs (oldAttrs: {
      version = "unstable-2023-07-24";

      src = fetchFromGitLab {
        domain = "invent.kde.org";
        owner = "plasma";
        repo = "kpipewire";
        rev = "c21da54fef3d0c1f35c73c57e8a6a61b053b07bf";
        sha256 = "sha256-xcuSWURiyY9iuayeY9w6G59UJTbYXyPWGg8x+EiXNsY=";
      };
    }))
  ];

  dontWrapQtApps = true;
}
