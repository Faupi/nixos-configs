{ pkgs, lib, fop-utils, ... }:
{
  home.packages = with pkgs;
    let
      vesktop = SOCIALS.vesktop.overrideAttrs
        (oldAttrs: {
          desktopItems = [
            (makeDesktopItem {
              name = "vesktop";
              desktopName = "Vesktop";
              exec = "${lib.getExe SOCIALS.vesktop} %U";
              # I don't like the Vencord icon - override it
              # + overriding the desktop file would need actual Discord installed
              icon = "discord";
              startupWMClass = "Vesktop";
              genericName = "Internet Messenger";
              keywords = [ "discord" "vencord" "electron" "chat" ];
              categories = [ "Network" "InstantMessaging" "Chat" ];
            })
          ];
        });
    in
    [
      (fop-utils.enableWayland {
        package = vesktop;
        inherit pkgs;
      })
    ];

  xdg.configFile."vesktop/themes/midnight.theme.css".source = pkgs.vencord-midnight-theme;
}
