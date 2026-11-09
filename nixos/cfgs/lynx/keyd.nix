{ pkgs, ... }: {
  services.keyd = {
    enable = true;
    package = pkgs.keyd;

    applicationMapper = {
      enable = true;
      users = [ "faupi" ];
    };

    # Mice need to be added to ids specifically
    keyboards.g502.ids = [ "m:046d:c08b:15ad94e9" ];

    apps = {
      # SnowRunner, rebind mouse back and forward for gear shifting binds under Next Gen Gameplay
      steam_app_1465360 = {
        mouse1 = "kpplus";
        mouse2 = "kpminus";
      };
    };
  };
}
