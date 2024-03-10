{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./containers/minecraft-server
  ];

  networking.networkmanager.enable = true;
  services.openssh.enable = true;

  system.autoUpgrade.enable = true; # Hands-free updates
  nix.gc.automatic = true; # Builder, should take care of garbage

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

  nix.settings.trusted-users = [
    "nixremote" # Builder user
  ];

  users.groups.nixremote = { };
  users.users.nixremote = {
    isNormalUser = true;
    createHome = true;
    homeMode = "500";
    group = "nixremote";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZC7qNbk9YSvZB73i1BXsBaJnZe+NPNeqjngRZLvqo1Ukkm9an5Oj36I9xOQ6nz4va4njdNO2wtcrxaZY34pnft2+QLMCKhANFh5XXkoSJP8dVslSrrqc6ww/rnExG5aw/xKlihB/BrDWP/i4TBqZrzzyL5M4i5sfVlHcNfCUlAZLm/dC9ql1JUMRmg37/jNzF52gCF7SnHQQJu3TcYlMkZsxitHhqrGIc8WR+yroMkY+hKnzxY72ybILPVQQvOlrcX9ne8AQ3yr3uJbbK+N7bMSx+v8UhEm4NQXOCZmgi6jT/rqwFOwKMiGx40NQBpTEZZDBecEsaI8ER1RujFEuREgOCEE0xD9jTzv2XkG7yRylENQ30zJuta8NjrFcIfadmT/08paYD1t0E/g3RqZqfBgkgFlyL3iHBg8Eq+de7dOwjbYfzW+1xyEh9DUNXGYGUGT5N6Wyfj3PrprXQ4cWPWchlsVsEkgY8Ci5EH7831EdqOT7L1e+1OzIDfuNJ4Hk= root@deck"
    ];
  };

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 8192;
      cores = 4;
    };
  };

  system.stateVersion = "22.11";
}
