{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./builder.nix
    ./cloudflared.nix

    ./containers/minecraft-server
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.autoUpgrade.enable = true; # Hands-free updates

  # Cura
  services.openssh.settings.X11Forwarding = true;
  environment.systemPackages = [ pkgs.waypipe ];
  my = {
    cura.enable = true; # Remoted via X11 forwarding
    vintagestory = {
      server.enable = false;
      mods.enable = true;
    };
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };
  system.stateVersion = "22.11";
}
