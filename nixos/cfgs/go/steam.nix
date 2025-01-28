{ config, pkgs, lib, ... }:
with lib;
{
  services.displayManager = {
    defaultSession = "steam-wayland";
    sddm.enable = false; # Jovian handles this
  };

  #region Steam
  programs.steam = {
    enable = true;
    extest.enable = true; # X11->Wayland SteamInput mapping
    platformOptimizations.enable = true; # SteamOS tweaks
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    (makeAutostartItem rec {
      name = "steam";
      package = makeDesktopItem {
        inherit name;
        desktopName = "Steam";
        exec = "steam -silent %U";
        icon = "steam";
        extraConfig = {
          OnlyShowIn = "KDE";
        };
      };
    })
  ];

  jovian.steam = {
    enable = true;
    user = "faupi";

    # Session management
    autoStart = true;
    desktopSession = "plasma";

    # Make sure the gamescope also sees the compat tools
    environment = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = makeSearchPathOutput "steamcompattool" "" config.programs.steam.extraCompatPackages;
    };
  };

  #region SteamOS
  jovian.steamos = {
    useSteamOSConfig = false; # No automatic enabling of stuff in the steamos module
    enableDefaultCmdlineConfig = false; # Already handled by hardware
    enableBluetoothConfig = true;
    enableProductSerialAccess = true;

    enableSysctlConfig = true; # Scheduling etc tweaks

    # These don't seem to do much than take forever to build
    enableVendorRadv = false;
    enableMesaPatches = false;
  };

  #region Decky 

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

      readline.out
      procps
      pciutils
      libpulseaudio
    ];
    extraPythonPackages = pythonPackages: with pythonPackages; [
      pyyaml # hhd-decky
    ];

    plugins = {
      "hhd-decky" = {
        src = pkgs.decky.plugins.hhd-decky;
      };
      "SDH-CssLoader" = {
        src = pkgs.fetchzip {
          url = "https://github.com/DeckThemes/SDH-CssLoader/releases/download/v2.1.2/SDH-CSSLoader-Decky.zip";
          sha256 = "sha256-7FWCiGf9JqgpW/qzwc0qiYuZJfgJSbhvPdq1YVVaSyg=";
          extension = "zip";
          stripRoot = true;
        };
      };
      "moondeck" = {
        src = pkgs.decky.plugins.moondeck;
      };
    };

    themes =
      let
        SteamDeckThemesRepo1 = pkgs.fetchFromGitHub {
          owner = "suchmememanyskill";
          repo = "Steam-Deck-Themes";
          rev = "df903b24313fdc4e509247f8611e30871e5aabef";
          sha256 = "1ghkcvwczc8x01dz5kf1afbnk9a8pc2zjj3nlprn8fq3h9ir677l";
        };
        SteamDeckThemesRepo2 = pkgs.fetchFromGitHub {
          owner = "MSeys";
          repo = "Steam-Deck-Themes";
          rev = "fba5130e5d78e5f34b711ec3489f3b2eb6e516e8";
          sha256 = "0amap3v5hgr1r8sffmf9m9pjgm2d2003xmsz5kx54y268gcda7w3";
        };
      in
      {
        # Base LeGo theme
        # TODO: Switch to https://deckthemes.com/themes/view?themeId=27d2dfb0-f58c-468f-81d5-f06534534133 and delete forked repository
        "SBP-Legion-Go-Theme" = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "faupi";
            repo = "SBP-Legion-Go-Theme";
            rev = "164d966f3687b5fa68bbfa7a0a26715ba7ea0c43";
            sha256 = "108ixzyi8y85ggvdians70mbxa2zxdv8ra9aql9lbvms5lkg33f7";
          };
          config = {
            "Apply" = "Legion Go";
            "Legion Logo" = "Yes";
            "L is Select" = "No";
            "L is Start" = "No";
          };
        };

        # Fully opaque footer
        "Footer Editor" = {
          enable = true;
          src = pkgs.fetchFromGitHub {
            owner = "GrodanBool";
            repo = "Steam-Deck-Tweak-Footer-Editor";
            rev = "927ebf3c2e7be5205e6df7cfd47274982a7759f0";
            sha256 = "sha256-XtWMfFayWuWJnR6xiyJvubzDSXWXl+0CSsrUTYPYytY=";
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
            "No Friends" = "No";
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

        "Reduce Shoulder Icons Size" = {
          enable = true;
          src = "${SteamDeckThemesRepo2}/Reduce Shoulder Icons Size";
          config = {
            "Size" = "70%";
          };
        };
      };
  };
}
