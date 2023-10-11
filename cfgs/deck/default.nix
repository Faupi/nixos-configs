{ config, pkgs, lib, ... }:

# TODO:
#   MODULARIZE THIS FINALLY
#   Rest of KDE setup (localization, whatnot)

let 
  script-work-freerdp = pkgs.writeShellScriptBin "run" ''
    op signin
    CRED_CSV=$(/run/wrappers/bin/op item get icn3dn53ifc2ni2uf5xvublcvu --fields label=domain,label=username,label=password,label=local-ip)
    op signout

    CREDS=(''${CRED_CSV//,/ })
    ${pkgs.freerdp}/bin/wlfreerdp +auto-reconnect -clipboard /sound /dynamic-resolution /gfx-h264:avc444 +gfx-progressive /bpp:32 /d:''${CREDS[0]} /u:''${CREDS[1]} /p:''${CREDS[2]} /v:''${CREDS[3]}
  '';
  freerdp-work-remote = pkgs.makeDesktopItem {
    name = "work-remote";
    desktopName = "Remote to work";
    exec = "${script-work-freerdp}/bin/run";
    terminal = false;
    icon = "computer";
    type = "Application";
    categories = [ "Office" ];
  };

  steam-fetch-artwork = pkgs.writeShellScriptBin "steam-fetch-artwork" ''
    ${pkgs.coreutils}/bin/yes "" | ${pkgs.steamgrid}/bin/steamgrid -steamdir ~/.steam/steam -nonsteamonly -onlymissingartwork -steamgriddb "$(<${config.sops.secrets.steamgrid-api-key.path})"
  '';
in
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./external-display.nix
    ./audio.nix
  ]; 

  services.openssh.enable = true;
  
  networking.networkmanager.enable = true;

  nix.distributedBuilds = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  # Module configurations
  my = {
    plasma = {
      enable = true;
      user = "faupi";
      useCustomConfig = true;
      virtualKeyboard.enable = true;
    };
    steamdeck = {
      enable = true;
      opensd = {
        # TODO: Figure out proper config - default is IMO worse than basic Deck config
        enable = false;
      };
      gamescope = {
        enable = true;
        user = "faupi";
        desktopSession = "plasmawayland";
        # TODO: Switch to "plasma" for non-docked mode - fixes Steam input mapping for desktop use
        remotePlay.openFirewall = true;
      };
    };
    vintagestory = {
      client = {
        enable = true;
        user = "faupi";
      };
      mods.enable = true;
    };
    _1password = {
      enable = true;
      user = "faupi";
      autostart = {
        enable = true;
        silent = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    waypipe  # Cura remoting
    update-nix-fetchgit  # Updating nix hashes
  ];

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    disabledPlugins = [ "sap" ];
  };

  # User 
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users = {
      faupi = rec {
        home.username = "faupi";
        home.homeDirectory = "/home/faupi";
        home.stateVersion = config.system.stateVersion;

        home.packages = with pkgs; [
          # Socials and chill
          (spotify.overrideAttrs (OldAttrs: { deviceScaleFactor = 1; }))
          telegram-desktop
          discord
          xwaylandvideobridge

          # Gaming
          steam-fetch-artwork
          protontricks
          wineWowPackages.wayland
          grapejuice  # Roblox
          libstrangle  # Frame limiter

          # Game-streaming
          moonlight-qt

          krita
          mpv
          freerdp-work-remote
        ];

        home.file.".local/share/konsole/custom-zsh.profile".text = lib.generators.toINI {} {
          General = {
            Command = "${programs.zsh.package}/bin/zsh";
            Name = "Custom ZSH";
            Parent = "FALLBACK/";
          };
          Appearance = {
            Font = "Hack Nerd Font Mono,10,-1,5,50,0,0,0,0,0";
          };
        };

        programs = {
          vscode = {
            enable = true;
            package = pkgs.vscodium-fhs-nogpu;
            extensions = with pkgs.vscode-extensions; [
              esbenp.prettier-vscode
              jnoortheen.nix-ide
              naumovs.color-highlight
              sumneko.lua
              ms-python.python
            ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "signageos-vscode-sops";
                publisher = "signageos";
                version = "0.8.0";
                sha256 = "sha256-LcbbKvYQxob2zKnmAlylIedQkJ1INl/i9DSK7MemW9Y=";
              }
            ];
            userSettings = {
              # Updates
              "update.enableWindowsBackgroundUpdates" = false;
              "update.mode" = "none";
              "extensions.autoUpdate" = false;
              "extensions.autoCheckUpdates" = false;

              # UI
              "editor.fontFamily" = "Consolas, 'Consolas Nerd Font', 'Courier New', monospace";
              "editor.fontLigatures" = true;
              "editor.minimap.renderCharacters" = false;
              "editor.minimap.showSlider" = "always";
              "terminal.integrated.fontFamily" = "CaskaydiaCove Nerd Font Mono";
              "terminal.integrated.gpuAcceleration" = "on";
              "workbench.colorTheme" = "Default Dark Modern";
              "workbench.colorCustomizations" = {
                  "statusBar.background" = "#007ACC";
                  "statusBar.foreground" = "#F0F0F0";
                  "statusBar.noFolderBackground" = "#222225";
                  "statusBar.debuggingBackground" = "#511f1f";
              };

              # Git
              "git.autofetch" = true;
              "git.confirmSync" = false;
              "github.gitProtocol" = "ssh";

              # Nix
              "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
              "[nix]" = {
                "editor.defaultFormatter" = "jnoortheen.nix-ide";
              };

              # Sops
              "sops.binPath" = "${pkgs.sops}/bin/sops";

              # Misc
              "[json]" = {
                "editor.defaultFormatter" = "vscode.json-language-features";
              };
            };
          };
          git = {
            enable = true;
            userName = "Faupi";
            userEmail = "matej.sp583@gmail.com";
          };
          obs-studio = {
            enable = true;
            plugins = with pkgs; [
              obs-studio-plugins.wlrobs
              obs-studio-plugins.obs-pipewire-audio-capture
              obs-studio-plugins.obs-backgroundremoval
            ];
          };
          oh-my-posh = {
            enable = true;
            settings = builtins.fromJSON (
              builtins.unsafeDiscardStringContext (
                builtins.readFile (
                  builtins.fetchurl {
                    # TODO: Allow updates without requirement of a specific hash
                    url = "https://faupi.net/faupi.omp.json";
                    sha256 = "11ay1mvl1hflhx0qiqmz1qn38lwkmr1k4jidsq994ra91fnncsji";
                  }
                )
              )
            );
          };
          bash = {
            enable = true;
            bashrcExtra = ''eval "$(oh-my-posh init bash)"'';
          };
          zsh = {
            enable = true;
            package = pkgs.zsh;
            enableAutosuggestions = true;
            initExtra = ''eval "$(oh-my-posh init zsh)"'';
          };
          command-not-found.enable = true;  # Allow ZSH to show Nix package hints
          plasma.configFile = {
            # Set Konsole default profile
            konsolerc."Desktop Entry".DefaultProfile = "custom-zsh.profile";
          };
        };
      };
    };
  };

  # ZSH completion link
  environment.pathsToLink = [ "/share/zsh" ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";  # Wayland support for Electron and Chromium apps
  };

  # Fonts
  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  # Autoload
  boot.kernelModules = [
    "v4l2-loopback"
  ];
  
  system.stateVersion = "23.05";
}
