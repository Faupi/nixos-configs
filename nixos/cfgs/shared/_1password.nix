{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.flake-configs._1password;
in
{
  options.flake-configs._1password = {
    # TODO: autoStart, useSSHAgent, and the custom allowed browsers could be a part of the standard module rather than the custom config
    enable = mkEnableOption "Enable 1Password";
    autoStart = mkEnableOption "Start with system";
    useSSHAgent = mkEnableOption "Use 1Password SSH agent";
    users = mkOption {
      description = "A list of users who should be able to integrate 1Password with polkit-based authentication mechanisms.";
      type = types.listOf types.str;
      default = [ ];
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      programs = {
        _1password = {
          enable = true;
          package = pkgs._1password-cli;
        };
        _1password-gui = {
          enable = true;
          package = pkgs._1password-gui;
          polkitPolicyOwners = cfg.users;
        };
      };

      # Add zen-browser to allowed browsers
      # https://nixos.wiki/wiki/1Password
      environment.etc."1password/custom_allowed_browsers" = {
        text = ''
          .zen-wrapped
        '';
        mode = "0755";
      };
    })

    (mkIf (cfg.enable && cfg.useSSHAgent) {
      environment.sessionVariables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    })

    (mkIf (cfg.enable && cfg.autoStart) {
      environment.systemPackages = with pkgs; [
        (makeAutostartItem rec {
          name = "1password";
          package = makeDesktopItem {
            inherit name;
            desktopName = "1Password";
            icon = "1password";
            exec = "${lib.getExe config.programs._1password-gui.package} --silent %U";
          };
        })
      ];
    })
  ];
}
