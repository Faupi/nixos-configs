# TODO: Migrate to plasma-manager panels, probably just to LeGo as a whole

{ pkgs, lib, fop-utils, ... }:
with lib;
{
  home-manager.users.faupi = {
    programs.plasma.panels = [
      {
        location = "top";
        hiding = "none";
        alignment = "center";
        height = 30;
        widgets = [
          "org.kde.plasma.panelspacer"

          {
            name = "org.kde.plasma.digitalclock";
            config = {
              Appearance = {
                use24hFormat = toString 2; # Force 24h format specifically
                showDate = "false";
              };
            };
          }

          "org.kde.plasma.systemtray" # Config below

          "org.kde.plasma.panelspacer"
        ];

        # Extra JS
        extraSettings = (readFile (pkgs.substituteAll {
          src = "${fop-utils.homeSharedConfigsPath}/kde-plasma/system-tray.js";

          # TODO: Rename to contained, visible, hidden? Maybe always add visible and hidden to contained (extra), so nothing breaks
          extraItems = concatStringsSep "," [
            "org.kde.plasma.battery"
            "org.kde.plasma.volume"
            "org.kde.plasma.notifications"
            "chrome_status_icon_1"
            "spotify-client"
            "TelegramDesktop"
            "steam"
          ];
          shownItems = concatStringsSep "," [
            "org.kde.plasma.battery"
            "org.kde.plasma.volume"
            "spotify-client"
            "TelegramDesktop"
          ];
          hiddenItems = concatStringsSep "," [
            "chrome_status_icon_1"
            "steam"
          ];
        }));
      }
    ];
  };
}
