# TODO: Set up 1Password GUI with CLI integration
# NOTE: Still need to enable "Security > Unlock system using authentication service" and "Developer > CLI integration"
#       - plus SSH agent
# TODO: Polkit system-auth integration

{ config, pkgs, lib, fop-utils, ... }:
with lib;
let
  cfg = config.programs._1password;

  # TODO: 0xFF0
  browserConnectorOriginal = "${cfg.package}/share/1password/1Password-BrowserSupport";
  browserConnectorWrapped = "/run/wrappers/bin/1Password-BrowserSupport";
in
{
  options.programs._1password = {
    enable = mkEnableOption "Enable 1Password";
    package = mkOption {
      type = types.package;
      default = pkgs._1password-gui;
    };
    autostart = {
      enable = mkEnableOption "Start with system";
      silent = mkEnableOption "Start hidden";
    };
    useSSHAgent = mkEnableOption "Use 1Password SSH agent";
  };

  config = mkMerge [
    (mkIf cfg.enable (fop-utils.recursiveMerge [
      {
        home.packages = with pkgs; [ _1password cfg.package ];
      }
      # Fix for browsers on user installations
      {
        # TODO: 0xFF0 Figure out a non-manual install

        # 1Password's post-install script adapted to work with this nix setup (only for browser)
        # WARN: Needs to be run manually!
        home.file.".1password/post-install.sh".source = pkgs.writeShellScript "post-install.sh" ''
          if [ "$(id -u)" -ne 0 ]; then
            echo "You must be running as root to run 1Password's post-installation process"
            exit
          fi

          GROUP_NAME="onepassword"

          if [ ! "$(getent group "''${GROUP_NAME}")" ]; then
            groupadd "''${GROUP_NAME}"
          fi

          BROWSER_SUPPORT_PATH="${browserConnectorOriginal}"
          chgrp "''${GROUP_NAME}" $BROWSER_SUPPORT_PATH
          chmod g+s $BROWSER_SUPPORT_PATH

          mkdir -p "/run/wrappers/bin"
          ln -sf "${browserConnectorOriginal}" "${browserConnectorWrapped}"

          exit 0
        '';

        # Firefox
        home.file.".mozilla/native-messaging-hosts/com.1password.1password.json".text = lib.generators.toJSON { } {
          "name" = "com.1password.1password";
          "description" = "Native connector for 1Password";
          "path" = browserConnectorWrapped;
          "type" = "stdio";
          "allowed_extensions" = [ "{d634138d-c276-4fc8-924b-40a0ea21d284}" ];
        };
      }
    ]))

    (mkIf (cfg.enable && cfg.useSSHAgent) {
      programs.ssh.extraConfig = ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
      home.sessionVariables.SSH_AUTH_SOCK = "$HOME/.1password/agent.sock";
    })

    (mkIf (cfg.enable && cfg.autostart.enable) {
      home.file."1Password Autostart" = config.lib.fop-utils.makeAutostartItem {
        name = "1password";
        desktopName = "1Password";
        icon = "1password";
        exec = "${lib.getExe cfg.package} --silent %U";
        noDisplay = true;
      };
    })
  ];
}
