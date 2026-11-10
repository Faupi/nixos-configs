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

  home-manager.users.faupi.xdg.configFile."keyd/app.conf".text = lib.generators.toINI { } rec {
    # NOTE: Keyd uses dashes instead of special characters like underscores and dots

    # SnowRunner, rebind mouse back and forward for gear shifting binds under Next Gen Gameplay
    # Uses snowrunner.exe on wayland, steam-app-1465360 on xwayland
    snowrunner-exe = {
      # mouse2 is forward, mouse1 is back for some godforsaken reason
      mouse2 = "kpplus";
      mouse1 = "kpminus";
    };
    steam-app-1465360 = snowrunner-exe;
  };
}
