# TODO: Rework into a proper module with config

{ lib, ... }:
let
  listToAttrsKeyed = field: list:
    builtins.listToAttrs (map
      (v: {
        name = v.${field};
        value = v;
      })
      list); # https://discourse.nixos.org/t/list-to-attribute-set/20929/4
  # ^ TODO: Move to a util module of sorts

  customRules = (listToAttrsKeyed "Description" [
    {
      # File picker dialog
      Description = "File dialog";
      types = 32; # Dialog window type
      windowrole = "GtkFileChooserDialog";
      windowrolematch = 1;

      fsplevelrule = 2;
      fsplevel = 0; # None - file picker
    }
    {
      # Firefox
      Description = "Firefox";
      wmclass = "firefox firefox";
      wmclasscomplete = true;
      wmclassmatch = 1;

      fsplevelrule = 2;
      fsplevel = 0; # None - opening links
    }
    {
      Description = "Discord";
      wmclass = "discord";
      wmclassmatch = 1;

      fsplevelrule = 2;
      fsplevel = 4; # Extreme - splash screen etc
    }
    {
      Description = "Steam on-screen keyboard";
      title = "Steam Input On-screen Keyboard";
      titlematch = 1;
      wmclass = "steamwebhelper steam";
      wmclasscomplete = true;
      wmclassmatch = 1;

      above = true;
      aboverule = 2;
      acceptfocus = false;
      acceptfocusrule = 2;
      screen = 0; # Internal
      screenrule = 2;
      skipswitcher = true;
      skipswitcherrule = 2;
      skiptaskbar = true;
      skiptaskbarrule = 2;
      type = 16; # Torn-off menu
      typerule = 2;
    }
  ]);
  customRuleKeys =
    (lib.attrsets.mapAttrsToList (name: value: name) customRules);
in
{
  programs.plasma.configFile = {
    kwinrc = {
      Windows.FocusStealingPreventionLevel = 1;

      Compositing.WindowsBlockCompositing = true;
      # ^ Was a fix for tearing, but GPU drivers fixed it - games run mega smooth with it on
      Desktops.Rows = 1;
      Tiling.padding = 4;
      Input.TabletMode = "auto";
      Effect-windowview.BorderActivateAll = 9; # Disable top-left corner

      # Window decorations
      "org.kde.kdecoration2" = {
        ButtonsOnRight = "LIAX";
        ShowToolTips =
          false; # Avoid lingering tooltips when moving cursor to another display (something like Windows)
        library = "org.kde.breeze";
        theme = "Breeze";
      };
    };

    kwinrulesrc = {
      General = {
        count = builtins.length customRuleKeys;
        rules = lib.strings.concatStringsSep "," customRuleKeys;
      };
    } // customRules;
  };
}
