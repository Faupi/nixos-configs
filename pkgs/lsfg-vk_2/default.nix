# Temporary packaging of the WIP LSFG-VK 2.0 project

{ buildUI ? false
, lib
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, vulkan-headers
, vulkan-loader
, shaderc
, stdenv
, kdePackages
, mesa
}:
stdenv.mkDerivation {
  pname = "lsfg-vk";
  version = "unstable-20260205-test1";

  src = fetchFromGitHub {
    owner = "PancakeTAS";
    repo = "lsfg-vk";
    rev = "997bc665f7f0f229c8d89a59cf3567ee3930927c";
    hash = "sha256-HQWUxyOMxvT91azl44Z4uNWLq1oX/pKmjVcWB86xMrA=";
    fetchSubmodules = true;
  };

  cmakeFlags = [
    "-G Ninja"

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
  ++ lib.optionals buildUI (with kdePackages; [
    qtbase
    qtdeclarative
    qttools
    wrapQtAppsHook
  ]);

  buildInputs = [
    vulkan-headers
    vulkan-loader
    mesa
    shaderc
  ];

  meta = with lib; {
    description = "Vulkan layer for frame generation (Requires owning Lossless Scaling)";
    homepage = "https://github.com/PancakeTAS/lsfg-vk/";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
