# Original credits to https://discourse.nixos.org/t/system-autoupgrade-with-e-mail-notificaitons/32063/4

{ config, lib, ... }:
let
  cfg = config.services.notify-email;
in
{
  options.services.notify-email = {
    enable = lib.mkEnableOption "Email notifications for systemd failures";
    recipient = lib.mkOption {
      description = "Email recipient of failure messages";
      type = lib.types.str;
    };
    services = lib.mkOption {
      description = "Services to send failure emails for";
      type = lib.types.listOf lib.types.str;
      default = [ "nixos-upgrade" "nixos-store-optimize" ];
    };
  };

  config = lib.mkIf (cfg.enable) {
    assertions = [
      {
        assertion = (config.programs.msmtp.enable);
        message = "programs.msmtp.enable must be enabled for email notifications!";
      }
      {
        assertion = (config.programs.msmtp.accounts.notify-email != null);
        message = "programs.msmtp.accounts.notify-email must be defined for email notifications!";
      }
    ];

    systemd.services = {
      "notify-email@" = {
        environment = {
          EMAIL_ADDRESS = lib.strings.replaceStrings [ "%" ] [ "%%" ] cfg.recipient;
          SERVICE_ID = "%i";
        };
        path = [ "/run/wrappers" "/run/current-system/sw" ];
        script = ''
          {
             echo "Date: $(date -R)"
             echo "From: root@$(hostname) (systemd notify-email)"
             echo "To: $EMAIL_ADDRESS"
             echo "Subject: [$(hostname)] service $SERVICE_ID failed"
             echo "Auto-Submitted: auto-generated"
             echo
             systemctl status "$SERVICE_ID" ||:
          } | sendmail \
            --account notify-email \
            --read-envelope-from \
            --read-recipients
        '';
      };

      # Merge `onFailure` attribute for all monitored services
    } // (lib.attrsets.genAttrs cfg.services (name: {
      onFailure = lib.mkBefore [ "notify-email@%i.service" ];
    }));
  };
}
