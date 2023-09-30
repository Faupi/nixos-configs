{ config, pkgs, lib, ... }:
with lib;
let 
  cfg = config.my._1password;
in 
{
  # Set up 1Password GUI with CLI integration
  # NOTE: Still need to enable "Security > Unlock system using authentication service" and "Developer > CLI integration"
  #       - plus SSH agent
  # TODO: Add full configuration for this shiz

  options.my._1password = {
    enable = mkEnableOption "Enable 1Password";
    user = mkOption {
      type = types.str;
    };
    autostart = {
      enable = mkEnableOption "Start with system";
      silent = mkEnableOption "Start hidden";
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      security.polkit.enable = true;
      programs._1password = {
        enable = true;
        package = pkgs._1password;
      };
      programs._1password-gui = {
        enable = true;
        polkitPolicyOwners = [ cfg.user ];  # TODO: Create config
        package = pkgs._1password-gui;
      };

      programs.ssh.extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    })

    (mkIf (cfg.enable && cfg.autostart.enable) {
      home-manager.users.${cfg.user}.home.packages = 
      let
        origName = "1password";
        origPackage = config.programs._1password-gui.package;

        silentPackage = pkgs.symlinkJoin {
          name = "${origPackage.name}-silent";
          paths = 
          let
            wrapped = pkgs.writeShellScriptBin "${origName}" ''
              exec ${origPackage}/bin/${origName} --silent "$@"
            '';
          in
          [
            wrapped
            origPackage
          ];
        };
      in 
      [
        (pkgs.makeAutostartItem {
          name = "1password";
          package = (if cfg.autostart.silent then silentPackage else origPackage);
        })
      ];
    })
  ];
}
