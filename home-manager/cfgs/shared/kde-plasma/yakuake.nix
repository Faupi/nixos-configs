{ pkgs, lib, cfg, ... }:
let
  inherit (lib) mkOption types mkIf mkMerge;
in
{
  options.flake-configs.plasma.yakuake = {
    shortcut = mkOption {
      type = types.str;
      default = "Meta+Alt";
    };
  };

  config = (mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        materia-kde-theme
        kdePackages.yakuake

        (pkgs.makeAutostartItem rec {
          name = "yakuake";
          package = pkgs.makeDesktopItem {
            inherit name;
            desktopName = "Yakuake";
            exec = "yakuake";
            extraConfig = {
              OnlyShowIn = "KDE";
            };
          };
        })
      ];

      programs.plasma = {
        shortcuts = {
          yakuake = {
            "toggle-window-state" = mkIf (cfg.yakuake.shortcut != null) "${cfg.yakuake.shortcut},,Open/Retract Yakuake";
          };
        };

        configFile.yakuakerc = {
          Animation = {
            UseWMAssist = true;
            Frames = 17;
          };
          Appearance = {
            Skin = "materia-dark";
            SkinInstalledWithKns = false;
            HideSkinBorders = false;
            TerminalHighlightOnManualActivation = false;
            Translucency = false;
          };
          AutoOpen = {
            PollMouse = false;
          };
          Behavior = {
            OpenAfterStart = false;
            RememberFullscreen = false;
          };
          Dialogs = {
            FirstRun = false;
            ConfirmQuit = true;
          };
          Window = {
            ShowTitleBar = true;
            ShowTabBar = true;
            Height = 50;
            Width = 90;
            KeepOpen = false;
            KeepAbove = true;
            ToggleToFocus = false;
            ShowOnAllDesktops = true;
            ShowSystrayIcon = false;
          };
        };
      };
    }
  ]));
}
