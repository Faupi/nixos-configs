{ lib, pkgs, cfg, ... }:
let
  inherit (lib) mkIf mkMerge;
  autostartGuake = pkgs.makeAutostartItem rec {
    name = "guake";
    package = pkgs.makeDesktopItem {
      inherit name;
      desktopName = "Guake";
      exec = "guake";
      extraConfig = {
        OnlyShowIn = "GNOME";
      };
    };
  };
in
{
  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = with pkgs; [
        guake
        autostartGuake
      ];
      dconf.settings = {
        "org/guake/general" = {
          compat-delete = "delete-sequence";
          display-n = 0;
          display-tab-names = 0;
          gtk-use-system-default-theme = true;
          hide-tabs-if-one-tab = true;
          history-size = 1000;
          infinite-history = false;
          lazy-losefocus = true;
          load-guake-yml = true;
          max-tab-name-length = 100;
          mouse-display = true;
          open-tab-cwd = true;
          prompt-on-quit = true;
          quick-open-command-line = "gedit %(file_path)s";
          restore-tabs-notify = false;
          restore-tabs-startup = false;
          save-tabs-when-changed = false;
          schema-version = "3.10";
          scroll-keystroke = true;
          tab-ontop = true;
          use-default-font = true;
          use-popup = true;
          use-scrollbar = true;
          use-trayicon = true;
          window-halignment = 0;
          window-height = 65;
          window-losefocus = true;
          window-refocus = false;
          window-tabbar = true;
          window-valignment = 0;
          window-width = 100;
        };
        "org/guake/style" = {
          cursor-shape = 0;
        };
        "org/guake/style/background" = {
          transparency = 100;
        };
        "org/guake/style/font" = {
          allow-bold = true;
          palette = "#000000000000:#cccc00000000:#4e4e9a9a0606:#c4c4a0a00000:#34346565a4a4:#757550507b7b:#060698209a9a:#d3d3d7d7cfcf:#555557575353:#efef29292929:#8a8ae2e23434:#fcfce9e94f4f:#72729f9fcfcf:#adad7f7fa8a8:#3434e2e2e2e2:#eeeeeeeeecec:#ffffffffffff:#000000000000";
          "palette-name" = "Tango";
        };

        # Keybindings
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/guake-toggle" = {
          name = "Guake toggle";
          command = "guake -t";
          binding = [ "<Super>grave" "<Super>less" ];
        };
        "org/guake/keybindings/global" = {
          show-hide = "<Super>grave"; # This one just seems like a formality on wayland
        };
      };
    }
  ]);
}
