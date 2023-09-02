{ config, pkgs, lib, erosanix, ... }:

# TODO:
#   MODULARIZE THIS FINALLY
#   Rest of KDE setup (localization, whatnot)
#   home server nix builder
#   Remote builders (homeserver)

let 
  startMoonlight = pkgs.writeShellScriptBin "start-moonlight" ''
    trap "kill %1" SIGINT SIGCHLD
    ${pkgs.ffmpeg}/bin/ffmpeg -ac 1 -f pulse -i default -acodec mp2 -ac 1 -f rtp rtp://192.168.88.254:25000 & moonlight
    exit 0
  '';
  moonlight-mic-wrapper = pkgs.makeDesktopItem {
    name = "com.moonlight_stream.Moonlight_microphone";
    comment = "Stream games from your NVIDIA GameStream-enabled PC";
    desktopName = "Moonlight (with mic)";
    exec = "${startMoonlight}/bin/start-moonlight";
    terminal = false;
    icon = "moonlight";
    type = "Application";
    categories = [ "Qt" "Game" ];
    keywords = [ "nvidia" "gamestream" "stream" ];
  };
  webcam-streamer = pkgs.makeDesktopItem {
    name = "ip-webcam-streamer";
    desktopName = "Webcam streamer";
    # Don't fucking look >:(
    exec = "${pkgs.ffmpeg_6-full}/bin/ffmpeg -i http://faupi:amogus@192.168.88.174:8080/video -pix_fmt yuv420p -f v4l2 /dev/video0";
    terminal = true;
    icon = "webcamoid";
    type = "Application";
    categories = [ "Office" "Utility" ];
  };

  # https-handler-script = pkgs.writeShellScriptBin "https-open" ''
  #   if [[ "$1" == "https://teams.microsoft.com/"* ]]; then
  #     chromium --app="$1"
  #   else
  #     xdg-open "$1" # Just open with the default handler
  #   fi
  # '';
  # https-handler = pkgs.makeDesktopItem {
  #   name = "https-handler";
  #   desktopName = "HTTP Scheme Handler";
  #   exec = "${https-handler-script}/bin/https-open %u";
  #   type = "Application";
  #   mimeTypes = [ "x-scheme-handler/https" ];
  #   startupNotify = false;
  # };

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
in
{
  imports = [
    ./boot.nix
    ./hardware.nix
    ./external-display.nix
    ./audio.nix
  ]; 

  # TODO: Slap into custom wrapper
  networking.hostName = "deck";
  networking.networkmanager.enable = true;

  # Module configurations
  my = {
    plasma = {
      enable = true;
      useCustomConfig = true;
      user = "faupi";
    };
    steamdeck = {
      enable = true;
      opensd = {
        enable = false;  # TODO: Figure out proper config - default is IMO worse than basic Deck config
      };
      steam = {
        enable = true;
        user = "faupi";
        desktopSession = "plasmawayland";  # TODO: Switch to "plasma" for non-docked mode - fixes Steam input mapping for desktop use
      };
    };
  };

  # Gamestreaming mic passthrough RTP
  networking.firewall.allowedUDPPorts = [ 25000 ];

  hardware.opengl.driSupport32Bit = true;  # Needed for some apps

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
          spotify
          telegram-desktop
          discord
          xwaylandvideobridge
          webcam-streamer

          # Gaming
          protontricks
          wineWowPackages.wayland

          # Game-streaming
          moonlight-qt
          moonlight-mic-wrapper

          pinta  # Paint.NET alternative
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
            package = pkgs.vscodium-fhs;
            extensions = with pkgs.vscode-extensions; [
              esbenp.prettier-vscode
              bbenoist.nix
              naumovs.color-highlight
              sumneko.lua
              ms-python.python
            ];
            userSettings = {
              "update.enableWindowsBackgroundUpdates" = false;
              "update.mode" = "none";
              "extensions.autoUpdate" = false;
              "extensions.autoCheckUpdates" = false;

              "editor.fontFamily" = "Consolas, 'Consolas Nerd Font', 'Courier New', monospace";
              "editor.fontLigatures" = true;
              "editor.minimap.renderCharacters" = false;
              "editor.minimap.showSlider" = "always";
              "terminal.integrated.fontFamily" = "CaskaydiaCove NF Mono";
              "terminal.integrated.gpuAcceleration" = "on";
              "workbench.colorTheme" = "Default Dark Modern";
              "workbench.colorCustomizations" = {
                  "statusBar.background" = "#007ACC";
                  "statusBar.foreground" = "#F0F0F0";
                  "statusBar.noFolderBackground" = "#222225";
                  "statusBar.debuggingBackground" = "#511f1f";
              };
              "git.autofetch" = true;
              "git.confirmSync" = false;
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
          chromium = {
            # For meetings
            enable = true;
            package = pkgs.ungoogled-chromium;
          };
          oh-my-posh = {
            enable = true;
            settings = builtins.fromJSON (
              builtins.unsafeDiscardStringContext (
                builtins.readFile (
                  builtins.fetchurl {
                    url = "https://raw.githubusercontent.com/Faupi/faupi.github.io/master/faupi.omp.json";
                    sha256 = "sha256:0rxm4cdrzllpqswfh4ylnlvvr5l5d59dfj9d73fhdwcafdyvjwmd";  # TODO: Allow updates without requirement of a specific hash
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

  # Wayland support for Electron and Chromium apps
  # 0xBAD: Breaks a bunch of things if system-wide, it's better to wrap specific packages
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Fonts
  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  # Webcam
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  
  system.stateVersion = "23.05";
}
