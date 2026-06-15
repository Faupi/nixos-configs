{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    dotnet-runtime
  ];

  # Dynamic linker allowing unpatched binaries to work
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # toolchain / stdlib
      stdenv.cc.cc
      stdenv.cc.cc.lib
      libgcc

      # core deps
      zlib
      openssl
      icu
      curl
      libunwind
      libuuid
      krb5

      # font / text
      fontconfig
      freetype
      expat
      harfbuzz

      # image codecs (Skia)
      libpng
      libjpeg
      libwebp

      # X11 stack
      libX11
      libXext
      libXrender
      libXrandr
      libXi
      libXcursor
      libXfixes
      libxcb
      libICE
      libSM
    ];
  };
}
