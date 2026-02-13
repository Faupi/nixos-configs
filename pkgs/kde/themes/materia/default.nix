# Custom patch of Materia https://github.com/PapirusDevelopmentTeam/materia-kde to make it work better on Plasma 6

{ materia-kde-theme
, fetchurl
}:
(materia-kde-theme.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # Plasma 6 configs - e.g. fallback
    (fetchurl {
      url = "https://patch-diff.githubusercontent.com/raw/PapirusDevelopmentTeam/materia-kde/pull/160.patch";
      sha256 = "sha256-5OV3f6yQyRn6+CoW2HjKmX0xR3JED2VmE/YGRc+pocU=";
    })

    # Black corners on Yakuake
    (fetchurl {
      url = "https://patch-diff.githubusercontent.com/raw/PapirusDevelopmentTeam/materia-kde/pull/163.patch";
      sha256 = "sha256-qKSeELqTv7qiC2gPw1vYCLbV/KdNIER+6qX7n092EdQ=";
    })
  ];

  postPatch = (old.postPatch or "") + /*sh*/''
    # Fall back to the Breeze switch, as Materia has a missing background
    rm plasma/desktoptheme/Materia-Color/widgets/switch.svg
  '';
}))
