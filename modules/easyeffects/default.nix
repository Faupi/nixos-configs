{ config, lib, pkgs, ... }:
with lib;
let 
  cfg = config.my.easyeffects;
in
{
  options.my.easyeffects = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    user = mkOption {
      type = types.str;
      default = "faupi";
    };
  };

  config = (mkIf cfg.enable {
    programs.dconf.enable = true;  # Needed for settings

    home-manager.users."${cfg.user}" = {
      home.packages = with pkgs; [ easyeffects ];
      
      # TODO: Add EasyEffects configs to home configs
    };
  });
}