# Original credits to https://discourse.nixos.org/t/system-autoupgrade-with-e-mail-notificaitons/32063/4

{ config, pkgs, lib, ... }:
let
  cfg = config.services.notify-email;
in
{
  options.services.notify-email = {
    enable = lib.mkEnableOption "Email notifications for systemd failures";
    tokenPath = lib.mkOption {
      description = "Path to the token used for email authentication";
      type = lib.types.path;
    };
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
    systemd.services = {
      "notify-email@" = {
        environment = {
          EMAIL_ADDRESS = lib.strings.replaceStrings [ "%" ] [ "%%" ] cfg.recipient;
          SERVICE_ID = "%i";
          TOKEN_PATH = cfg.tokenPath;
        };
        path = [ "/run/wrappers" "/run/current-system/sw" ];
        script = ''
          {
             echo "Date: $(date -R)"
             echo "From: root (systemd notify-email)"
             echo "To: $EMAIL_ADDRESS"
             echo "Subject: [$(hostname)] service $SERVICE_ID failed"
             echo "Auto-Submitted: auto-generated"
             echo
             systemctl status "$SERVICE_ID" ||:
          } | ${lib.getExe' pkgs.msmtp "sendmail"} \
            --auth=on --tls=on \
            --host smtp.gmail.com \
            --port 587 \
            --user $(cat $TOKEN_PATH) \
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
