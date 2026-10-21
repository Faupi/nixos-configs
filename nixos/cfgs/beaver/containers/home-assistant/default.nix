{ ... }: {
  portForwardedContainers.home-assistant = {
    enable = true;
    autoStart = true;

    ports = {
      open = true;
      tcp = { "8123" = 8123; };
    };

    config = { pkgs, ... }: {
      services.home-assistant = {
        enable = true;
        # openFirewall = true;
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
