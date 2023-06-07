{ config, pkgs, lib, ... }: {
  imports = [
    ./hardware.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "homeserver"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.UTF-8";
    LC_IDENTIFICATION = "cs_CZ.UTF-8";
    LC_MEASUREMENT = "cs_CZ.UTF-8";
    LC_MONETARY = "cs_CZ.UTF-8";
    LC_NAME = "cs_CZ.UTF-8";
    LC_NUMERIC = "cs_CZ.UTF-8";
    LC_PAPER = "cs_CZ.UTF-8";
    LC_TELEPHONE = "cs_CZ.UTF-8";
    LC_TIME = "cs_CZ.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.faupi = {
    isNormalUser = true;
    description = "Faupi";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  firefox
    #  thunderbird
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAXCxrSb0+rjhKkU6l/4R226O/M3xq3iosfMlRWyayUU23zr/eBKq0YKQGPEkRK7a6cOOPXE7uKZ+BXkxX6aIDpp/s5W76GElUI886wU82j7bR/msVf/LN8SpnOVl4ZptNo3bvc2zlUNHXChXYJ9aVoU5dW755G8vsfE6mtCQy2F2Ju4f8l4g23O9hOpTFdjcefjUaRkD5TOV315/cOW5HVzyI5poW4RmDA60A1wddDlXadjJPiI+wrSZofc4iwORI1lXCcz+5Qmy3VrQrOa7Jxzgj5ibvAYB/8KH7wpd6Ik3ZbOVrax1ME7KUiN/DRY9ybOTfDGF13CV8wpNzSjoD faupi@Faupi-PC"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  environment.shellAliases = {
    nixconf="nano /etc/nixos/configuration.nix";
    octoconf="nano /var/lib/octoprint/config.yaml";
    sayhi="echo hi dumbass";
  };

  programs.nano.nanorc = ''
    set tabstospaces
    set tabsize 2
  '';

  # Enable the OpenSSH daemon
  services.openssh.enable = true;

  # OctoPrint
  nixpkgs.overlays = with lib; [(self: super: {
    octoprint = super.octoprint.override {
      packageOverrides = pyself: pysuper: {
        widescreen = pyself.buildPythonPackage rec {
          pname = "Widescreen";
          version = "0.1.4";
          src = self.fetchFromGitHub {
            owner = "jneilliii";
            repo = "OctoPrint-WideScreen";
            rev = "${version}";
            sha256 = "sha256-y0yINi03e8YutsdHckSfjZtob8Je3Ff1aSbQxtLnbgw=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        cura-thumbnails = pyself.buildPythonPackage rec {
          pname = "Cura Thumbnails";
          version = "1.0.2";
          src = self.fetchFromGitHub {
            owner = "jneilliii";
            repo = "OctoPrint-UltimakerFormatPackage";
            rev = "${version}";
            sha256 = "sha256-EvD3apeFV4WbeCdxBwFOtv4Luaid7RojQg6XYUTY2NQ=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        heater-timeout = pyself.buildPythonPackage rec {
          pname = "Better Heater Timeout";
          version = "1.3.0";
          src = self.fetchFromGitHub {
            owner = "tjjfvi";
            repo = "OctoPrint-BetterHeaterTimeout";
            rev = "v${version}";
            sha256 = "sha256-tBG94nLxhO+krXZeaWfUf21paVvFsSDI7yWfn+gwlwQ=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
        pretty-gcode = pyself.buildPythonPackage rec {
          pname = "Pretty GCode";
          version = "1.2.4";
          src = self.fetchFromGitHub {
            owner = "Kragrathea";
            repo = "OctoPrint-PrettyGCode";
            rev = "v${version}";
            sha256 = "sha256-q/B2oEy+D6L66HqmMkvKfboN+z3jhTQZqt86WVhC2vQ=";
          };
          propagatedBuildInputs = [ pysuper.octoprint ];
          doCheck = false;
        };
      };
    };
  })];

  services.octoprint = {
    enable = true;
    port = 5000;
    plugins = plugins: with plugins; [ 
      displaylayerprogress
      octoprint-dashboard
      touchui
      bedlevelvisualizer
      printtimegenius
      themeify
      widescreen
      cura-thumbnails
      heater-timeout
      pretty-gcode
    ];
  
    extraConfig = {
      plugins = {
        _disabled = [
          "softwareupdate"
        ];

        themeify = {
          theme = "discoranged";
          enableCustomization = true;
          tabs = {
            enableIcons = true;
            icons = [
              {
                domId = "#temp_link";
                enabled = true;
                faIcon = "fa fa-thermometer-half";
              }
              {
                domId = "#control_link";
                enabled = true;
                faIcon = "fa fa-gamepad";
              }
              {
                domId = "#gcode_link";
                enabled = true;
                faIcon = "fa fa-object-ungroup";
              }
              {
                domId = "#term_link";
                enabled = true;
                faIcon = "fa fa-terminal";
              }
              {
                domId = "#tab_plugin_dashboard_link";
                enabled = true;
                faIcon = "fa fa-tachometer";
              }
              {
                domId = "#tab_plugin_bedlevelvisualizer_link";
                enabled = true;
                faIcon = "fa fa-balance-scale";
              }
              {
                domId = "#timelapse_link";
                enabled = true;
                faIcon = "fa fa-clock-o";
              }
              {
                domId = "#tab_plugin_prettygcode_link";
                enabled = true;
                faIcon = "fa fa-cube";
              }
            ];
          };
        };
        widescreen = {
          right_sidebar_items = [
            "connection"
            "state"
          ];
        };
        DisplayLayerProgress = {
          showAllPrinterMessages = false;
          showOnFileListView = false;
        };
        UltimakerFormatPackage = {
          inline_thumbnail = true;
          inline_thumbnail_align_value = "right";
          inline_thumbnail_position_left = true;
          inline_thumbnail_scale_value = "15";
          scale_inline_thumbnail = true;
          state_panel_thumbnail_scale_value = "50";
        };
        touchui = {
          # Note: With customization it tries to write into its package, which throws errors. 
          #       Fixing this is not possible without rewriting the whole thing.
          closeDialogsOutside = true;
          useCustomization = false;
        };
      };
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5000 ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}
