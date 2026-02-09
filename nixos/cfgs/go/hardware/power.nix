{ pkgs, ... }: {
  powerManagement.enable = true; # Battery and general power management

  services = {
    power-profiles-daemon.enable = false;
    tuned = {
      enable = true;
      package = pkgs.tuned;

      ppdSupport = true;
      ppdSettings = {
        main = {
          default = "balanced";
          battery_detection = true;
        };

        battery = {
          balanced = "balanced-battery";
        };

        profiles = {
          power-saver = "powersave";
          balanced = "balanced";
          performance = "throughput-performance";
        };
      };

      settings = {
        daemon = true;
      };
    };
  };
}
