{ config, pkgs, ... }: {
  # Give the main user permissions for decky-related stuff, needed for some plugins to work!
  users.users.${config.jovian.steam.user}.extraGroups = [ config.users.users.decky.group ];

  jovian.decky-loader = {
    enable = true;
    user = "decky";
    stateDir = "/var/lib/decky-loader";
    package = with pkgs; decky-loader;

    extraPackages = with pkgs; [
      # Generic packages
      curl
      unzip
      util-linux
      gnugrep
      gawk

      readline.out
      procps
      pciutils
      libpulseaudio
    ];
    extraPythonPackages = pythonPackages: with pythonPackages; [
      pyyaml # hhd-decky
    ];

    plugins = {
      # TODO: Add SteamGridDB, ProtonDB Badges - Both need node packaging with builds!
      "SDH-CssLoader" = {
        src = pkgs.decky.plugins.css-loader.override {
          managedSymlink = true;
          mutableThemeConfigs = true;
        };
      };

      "moondeck" = {
        src = pkgs.decky.plugins.moondeck;
      };

      "playcount" = {
        src = pkgs.decky.plugins.playcount;
      };
    };

    mutableThemeConfigs = true;
    themes =
      let
        SteamDeckThemesRepo1 = pkgs.fetchFromGitHub {
          owner = "suchmememanyskill";
          repo = "Steam-Deck-Themes";
          rev = "59b66c98178b9dc40240712f36a09c4cdc7a5866";
          sha256 = "sha256-mFE0mIDRKx1Iva1ysuzBSVCEHBFYe/GKqu5bJjNcy2U=";
        };
      in
      {
        "handheld-controller-glyphs" = {
          enable = true;
          src = pkgs.decky.themes.handheld-controller-glyphs;
          config = {
            # "active" = true;
            "Handheld" = "Lenovo Legion Go";
            "Swap View/Menu with Guide/QAM" = "No";
          };
        };

        # Fully opaque footer
        "Footer Editor" = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "GrodanBool";
            repo = "Steam-Deck-Tweak-Footer-Editor";
            rev = "565d5f0f210ca1d9e985e31c45d0c71bb470dee0";
            sha256 = "sha256-/qpS0ORVc5MXIYJQjsBK/GooZfpRMTyPIp+jcMl+CGM=";
            # Change root
            postFetch = ''
              rootName="Footer-Editor"
              mv "$out/$rootName" $TMPDIR/tmp
              rm -rf $out/*
              mv $TMPDIR/tmp/* $out
            '';
          };
          config = {
            "Opacity" = "1";
            "Clean Gameview Patch" = "None";
            "Homescreen Only" = "No";
            "Switch Like Home Patch" = "No";
            "Centered Home Patch" = "No";
            "Remove Footer" = "No";
          };
        };

        "Switch Like Home" = {
          enable = true;
          src = "${SteamDeckThemesRepo1}/switch_like_home";
          config = {
            "No Friends" = "Yes"; # real
            "Lift Hero" = "10";
          };
        };

        "QAM Select bar right-hand Side" = {
          enable = true;
          # NOTE: No repository source
          src = pkgs.fetchzip {
            url = "https://api.deckthemes.com/blobs/aa379060-5c4c-46c9-97d7-a494311d5f2a";
            sha256 = "sha256-RsvEWaGU+TU1lQjXj1UwR9edEtoXTdfG/V4/pdl4uYI=";
            stripRoot = true;
            extension = "zip";
          };
          config = {
            "No Friends" = "No";
          };
        };
      };
  };
}
