{ config, pkgs, lib, ... }:
with lib;
{
  services.displayManager.defaultSession = "steam-wayland";

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

  environment.systemPackages = [
    (pkgs.makeAutostartItem rec {
      name = "steam";
      package = pkgs.makeDesktopItem {
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
  jovian.decky-loader = {
    enable = true;
    user = "faupi";
    stateDir = "/home/faupi/.local/share/decky"; # Keep scoped to user
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

      # SimpleDeckyTDP | TODO: Remove once hhd TDP control is verified 
      ryzenadj # actual TDP util
      kmod # modprobe for acpi_call check
    ];
    extraPythonPackages = pythonPackages: with pythonPackages; [
      pyyaml # hhd-decky
    ];

    plugins = {
      "hhd-decky" = {
        src = fetchTarball {
          url = "https://github.com/hhd-dev/hhd-decky/releases/download/v0.1.0/hhd-decky.tar.gz";
          sha256 = "15gpll079gwnx21gjf6qivb36dzpnrx58dkbpk0xnjjx2q0bcc47";
        };
      };
      "SDH-CssLoader" = {
        src = pkgs.fetchzip {
          url = "https://github.com/DeckThemes/SDH-CssLoader/releases/download/v2.1.1/SDH-CSSLoader-Decky.zip";
          sha256 = "1vp8h46di4a1qrfsbp0xhyb92x0k0cvv5w7ak2mi995xwl8x9n4j";
          extension = "zip";
          stripRoot = true;
        };
      };
    };

    themes = {
      # Base LeGo theme
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
        # Source is from deckthemes because the repo has like 20 different themes
        src = pkgs.fetchzip {
          url = "https://api.deckthemes.com/blobs/ea864a72-41e6-4936-a617-8f1b28ec37ca";
          sha256 = "sha256-HC7jIcy28wT6XUblP4NjLWuREhKL5eWFgcr1E+oGmM8=";
          stripRoot = true;
          extension = "zip";
        };
        config = {
          "No Friends" = "No";
        };
      };

      "QAM Select bar right-hand Side" = {
        enable = true;
        # Source is from deckthemes because the repo has like 20 different themes
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
        src = pkgs.fetchFromGitHub {
          owner = "MSeys";
          repo = "Steam-Deck-Themes";
          rev = "fba5130e5d78e5f34b711ec3489f3b2eb6e516e8";
          sha256 = "sha256-06cWA2iyG015qzmr458dApqberNvyFBKw5j5XywTTUw=";
          # Change root
          postFetch = ''
            rootName="Reduce Shoulder Icons Size"
            mv "$out/$rootName" $TMPDIR/tmp
            rm -rf $out/*
            mv $TMPDIR/tmp/* $out
          '';
        };
        config = {
          "Size" = "70%";
        };
      };
    };
  };
}
