{
  ananicy.enable = true;
  avahi.enable = true;
  gaming-mice.enable = true;
  plymouth.enable = true;

  mango = {
    enable = true;
    displayManager = {
      enable = true;
      userConfigHome = "/home/masp";
    };
  };

  audio = {
    enable = true;
    user = "masp";
  };

  _1password = {
    enable = true;
    users = [ "masp" ];
    autoStart = true;
    useSSHAgent = true;
  };

  nix-ld = {
    enable = true;
    useLibraries.deadZoneRevive = true;
  };
}
