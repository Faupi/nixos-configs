{
  ananicy.enable = true;
  avahi.enable = true;
  gaming.enable = true;
  gaming-mice.enable = true;
  plymouth.enable = true;

  mango = {
    enable = true;
    displayManager = {
      enable = true;
      userConfigHome = "/home/faupi";
    };
  };

  audio = {
    enable = true;
    user = "faupi";
  };

  _1password = {
    enable = true;
    users = [ "faupi" ];
    autoStart = true;
    useSSHAgent = true;
  };

  vr = {
    enable = true;
    autoStart = true;
  };

  nix-ld = {
    enable = true;
    useLibraries.deadZoneRevive = true;
  };
}
