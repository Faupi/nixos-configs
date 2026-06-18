{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.flake-configs.clipboard-actions;
in
{
  options.flake-configs.clipboard-actions = {
    enable = mkEnableOption "Enable clipboard action configuration";
  };

  config = (mkIf cfg.enable {
    services.clipboardActions = {
      enable = true;

      rules = [
        {
          name = "Any URL";
          regex = "^https?://\S+\?.*";
          commands = [
            {
              label = "Clean URL";
              runtimeInputs = [ pkgs.python3 ];
              command = "python3 ${./clean-url.py} '%s'";
              output = "copy";
            }
          ];
        }

        {
          name = "Spotify URL";
          regex = "^https?://open\\.spotify\\.com/";
          commands = [
            {
              label = "Create JamShare Link";
              runtimeInputs = with pkgs; [
                curl
                jq
              ];
              command = /*sh*/''
                curl -fsS --get \
                  --data-urlencode "url=%s" \
                  --data "json=1" \
                  --data "src=web" \
                  "https://jamshare.app/api/share" |
                  jq -r '.share_url'
              '';
              output = "copy";
            }
          ];
        }
      ];
    };
  });
}
