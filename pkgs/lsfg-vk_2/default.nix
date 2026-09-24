# Temporary packaging of the WIP LSFG-VK 2.0 project

{ buildUI ? false
, cmake
, lib
, ninja
, pkg-config
, qt6
, stdenv
, vulkan-loader
}:
stdenv.mkDerivation rec {
  pname = "lsfg-vk";
  version = "2.0.0";

  strictDeps = true;

  src = fetchTarball {
    url = "https://git.lsfg-vk.dev/lsfg-vk/snapshot/lsfg-vk-${version}.tar.xz";
    sha256 = "sha256-vp0/adJdVV73C2RFjcEE90KjWiZJQhiqqOlYQ89RG+Y=";
  };

  cmakeFlags = [
    "-G Ninja"
    "-DCMAKE_BUILD_TYPE=Release"

    "-DLSFGVK_BUILD_VK_LAYER=ON"
    "-DLSFGVK_BUILD_CLI=ON"

    # Vulkan layer must point to installed .so inside the output
    "-DLSFGVK_LAYER_LIBRARY_PATH=${placeholder "out"}/lib/liblsfg-vk-layer.so"
  ]
  ++ lib.optionals buildUI [
    "-DLSFGVK_BUILD_UI=ON"
    "-DLSFGVK_INSTALL_XDG_FILES=ON"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ]
  ++ lib.optionals buildUI [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    vulkan-loader
  ]
  ++ lib.optionals buildUI [
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qt5compat
  ];

  postFixup = lib.strings.optionalString buildUI /*sh*/''
    # Force desktop portal - otherwise a fallback file dialog is used
    wrapProgram $out/bin/lsfg-vk-ui \
      --set QT_QPA_PLATFORMTHEME xdgdesktopportal
  '';

  meta = with lib; {
    description = "Vulkan layer for frame generation (Requires owning Lossless Scaling)";
    homepage = "https://github.com/PancakeTAS/lsfg-vk/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
