{ config, pkgs, lib, fop-utils, ... }:
with lib;
let
  cfg = config.programs._1password;
  mainPackage = pkgs._1password-gui.override {
    # TODO: Check if system authentication is doable with HM
    polkitPolicyOwners = [ config.home.username ];
  };

  # TODO: 0xFF0
  browserConnector = "${mainPackage}/share/1password/1Password-BrowserSupport";

  # browserConnWrappedHomePath = ".1password/1Password-BrowserSupport";
  # browserConnWrappedFullPath = "${config.home.homeDirectory}/${browserConnWrappedHomePath}";
in
{
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
    (mkIf cfg.enable (fop-utils.recursiveMerge [
      {
        home.packages = with pkgs; [ _1password mainPackage ];
      }
      # Fix for browsers on user installations
      {
        # TODO: 0xFF0 Figure out a non-manual install
        # home.activation."install-1PasswordBrowserConnector" = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        #   ln -sf ${browserConnector} ${browserConnWrappedFullPath}
        #   chgrp onepassword ${browserConnWrappedFullPath}
        #   chmod g+s ${browserConnWrappedFullPath}
        # '';

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

          BROWSER_SUPPORT_PATH="${browserConnector}"
          chgrp "''${GROUP_NAME}" $BROWSER_SUPPORT_PATH
          chmod g+s $BROWSER_SUPPORT_PATH

          exit 0
        '';

        # Firefox
        home.file.".mozilla/native-messaging-hosts/com.1password.1password.json".text = lib.generators.toJSON { } {
          "name" = "com.1password.1password";
          "description" = "Native connector for 1Password";
          "path" = browserConnector;
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
      home.file.".config/autostart/1password.desktop".text =
        generators.toINI { } {
          "Desktop Entry" = {
            Comment = "Password manager and secure wallet";
            # TODO: Add autostart.silent integration
            Exec = "${mainPackage}/bin/1password --silent %U";
            Icon = "1password";
            Name = "1Password";
            StartupWMClass = "1Password";
            Terminal = false;
            Type = "Application";
            StartupNotify = false;
            NotShowIn = "gamescope";
          };
        };
    })
  ];
}
