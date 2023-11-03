{ config, lib, pkgs, ... }: {
  imports = [ ];
  options = {
    programs.autologin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "";
      };
    };
  };

  config = lib.mkIf config.programs.autologin.enable {
    environment.systemPackages = [ pkgs.autologin ];

    security.pam.services."autologin" = {
      startSession = true;
      allowNullPassword = true;
      showMotd = true;
      updateWtmp = true;
    };
  };
}
