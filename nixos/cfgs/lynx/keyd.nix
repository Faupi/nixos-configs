{ pkgs, lib, ... }: {
  services.keyd = {
    enable = true;
    package = pkgs.keyd;

    applicationMapper = {
      enable = true;
      users = [ "faupi" ];
    };

    # Mice need to be added to ids specifically
    keyboards.g502.ids = [ "m:046d:c08b:15ad94e9" ];
  };

  home-manager.users.faupi.xdg.configFile."keyd/app.conf".text = lib.generators.toINI { } {
    # NOTE: for some reason they use dashes instead of underscores as opposed to mango's get focusing-client

    # SnowRunner, rebind mouse back and forward for gear shifting binds under Next Gen Gameplay
    steam-app-1465360 = {
      # mouse2 is forward, mouse1 is back for some godforsaken reason
      mouse2 = "kpplus";
      mouse1 = "kpminus";
    };
  };
}
