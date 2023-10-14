{ config, pkgs, lib, ... }:
with lib;
let cfg = config.my._1password;
in {
  # Set up 1Password GUI with CLI integration
  # NOTE: Still need to enable "Security > Unlock system using authentication service" and "Developer > CLI integration"
  #       - plus SSH agent
  # TODO: Add full configuration for this shiz

  options.my._1password = {
    enable = mkEnableOption "Enable 1Password";
    user = mkOption { type = types.str; };
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
        polkitPolicyOwners = [ cfg.user ]; # TODO: Create config
        package = pkgs._1password-gui;
      };

      programs.ssh.extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    })

    (mkIf (cfg.enable && cfg.autostart.enable) {
      home-manager.users.${cfg.user}.home.file.".config/autostart/1password.desktop".text =
        generators.toINI { } {
          "Desktop Entry" = {
            Comment = "Password manager and secure wallet";
            Exec =
              "${config.programs._1password-gui.package}/bin/1password --silent %U";
            Icon = "1password";
            Name = "1Password";
            Terminal = false;
            Type = "Application";

            StartupWMClass = "1Password";
            StartupNotify = false;
            X-KDE-StartupNotify = false;
            X-KDE-SubstituteUID = false;
          };
        };
    })
  ];
}
