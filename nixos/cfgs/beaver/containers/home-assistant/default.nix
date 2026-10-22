{ config, ... }:
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
        extraPackages = python3Packages: with python3Packages; [
          numpy
          pycryptodome
          python-miio
          paho-mqtt
          pkgs.nur.repos.milahu.python3Packages.mini-racer
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
