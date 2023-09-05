{ lib, ... }:
let 
  listToAttrsKeyed = field: list: builtins.listToAttrs ( map ( v: { name = v.${field}; value = v;  } ) list );  # https://discourse.nixos.org/t/list-to-attribute-set/20929/4
  # ^ TODO: Move to a util module of sorts

  customRules = ( listToAttrsKeyed "Description" [
    {
      # File picker dialog
      Description = "File dialog";
      types = 32;  # Dialog window type
      windowrole = "GtkFileChooserDialog";
      windowrolematch = 1;

      fsplevelrule = 2;
      fsplevel = 0;  # None - file picker
    }
    {
      # Firefox
      Description = "Firefox";
      wmclass = "firefox firefox";
      wmclasscomplete = true;
      wmclassmatch = 1;

      fsplevelrule = 2;
      fsplevel = 0;  # None - opening links
    }
    {
      Description = "Discord";
      wmclass = "discord";
      wmclassmatch = 1;

      fsplevelrule = 2;
      fsplevel = 4;  # Extreme - splash screen etc
    }
  ]);
  customRuleKeys = ( lib.attrsets.mapAttrsToList (name: value: name) customRules );
in
{
  kwinrc = {
    Windows.FocusStealingPreventionLevel = 1;

    Compositing.WindowsBlockCompositing = true;  
    # ^ Was a fix for tearing, but GPU drivers fixed it - games run mega smooth with it on
    Desktops.Rows = 1;
    Tiling.padding = 4;
    Input.TabletMode = "off";  # TODO: Docked mode
    Effect-windowview.BorderActivateAll = 9;  # Disable top-left corner
    
    # Window decorations
    "org\.kde\.kdecoration2" = {
      ButtonsOnRight = "LIAX";
      ShowToolTips = false;  # Avoid lingering tooltips when moving cursor to another display (something like Windows)
      library = "org.kde.breeze";
      theme = "Breeze";
    };
  };

  kwinrulesrc = {
    General = {
      count = builtins.length customRuleKeys;
      rules = lib.strings.concatStringsSep "," customRuleKeys;
    };
  }
  // customRules;
}
