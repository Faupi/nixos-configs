{ cfg, ... }: {
  networking = {
    interfaces.${cfg.mainInterface}.wakeOnLan.enable = true;
    firewall.interfaces.${cfg.mainInterface}.allowedUDPPorts = [ 9 ];
  };
}
