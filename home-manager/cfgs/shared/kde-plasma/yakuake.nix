{ pkgs, lib, cfg, ... }:
let
  inherit (lib) mkIf mkMerge;
in
{
  config = (mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        kde.themes.materia
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
            "toggle-window-state" = "Meta+`";
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
            Height = 70; # Enough space for btop on LeGo
            Width = 90;
            KeepOpen = false;
            KeepAbove = true;
            ToggleToFocus = false;
            ShowOnAllDesktops = true;
            ShowSystrayIcon = false;
          };
          Shortcuts = {
            toggle-window-state = "Esc"; # Allow collapsing with Esc
          };
        };
      };
    }
  ]));
}
