{ config, fop-utils, ... }@args:
let
  hostConfig = config;
in
{
  portForwardedContainers.home-assistant = {
    enable = true;
    autoStart = true;

    ports = {
      open = true;
      tcp = { "8123" = 8123; };
    };

    config = { pkgs, ... }: {
      nixpkgs.overlays = hostConfig.nixpkgs.overlays;

      services.home-assistant = {
        enable = true;
        package = pkgs.unstable.home-assistant;
        extraPackages = python3Packages: with python3Packages; [
          numpy
          pycryptodome
          python-miio
          paho-mqtt
          pkgs.nur.repos.milahu.python3Packages.mini-racer
        ];

        configWritable = true;
        config = fop-utils.recursiveMerge [
          (import ./config/sonoff-energy-readings.nix args)
          {
            default_config = { };
            history = { };

            automation = "!include automations.yaml";
            script = "!include scripts.yaml";
            scene = "!include scenes.yaml";

            frontend = {
              themes = "!include_dir_merge_named themes";
            };

            homeassistant = {
              name = "Home";
              latitude = "!secret latitude";
              longitude = "!secret longitude";
              unit_system = "metric";
              time_zone = "Europe/Prague";
              packages = "!include_dir_named packages";
            };
          }
        ];
      };

      environment.systemPackages = with pkgs; [
        wget
        curl
        unzip
      ];

      system.stateVersion = "26.05";
    };
  };
}
