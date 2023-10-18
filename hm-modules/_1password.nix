{ config, pkgs, lib, ... }:
with lib;
let cfg = config.programs._1password;
in {
  # Set up 1Password GUI with CLI integration
  # NOTE: Still need to enable "Security > Unlock system using authentication service" and "Developer > CLI integration"
  #       - plus SSH agent

  options.programs._1password = {
    enable = mkEnableOption "Enable 1Password";
    autostart = {
      enable = mkEnableOption "Start with system";
      silent = mkEnableOption "Start hidden";
    };
    useSSHAgent = mkEnableOption "Use 1Password SSH agent";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = with pkgs; [ _1password _1password-gui ];
    })

    (mkIf (cfg.enable && cfg.useSSHAgent) {
      programs.ssh.extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    })

    (mkIf (cfg.enable && cfg.autostart.enable) {
      home.file.".config/autostart/1password.desktop".text =
        generators.toINI { } {
          "Desktop Entry" = {
            Comment = "Password manager and secure wallet";
            # TODO: Add autostart.silent integration
            Exec = "${pkgs._1password-gui}/bin/1password --silent %U";
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
