{ ... }:
let
  regex = string: string; # Funny highlights

  force = value: { inherit value; apply = "force"; };
  # NOTE: Honestly the other options seemed pretty pointless
  # https://github.com/nix-community/plasma-manager/blob/trunk/modules/window-rules.nix
in
{
  programs.plasma.window-rules = [
    {
      description = "01 Global min size";

      match = {
        window-types = [ "normal" ]; # Have to have at least this rule
      };
      # Force minimum size limit
      apply = {
        minsize = force "100,10"; # 10px vertical important to not force content if the window just wants a "title" e.g. KRunner
      };
    }

    {
      description = "File picker dialog";

      match = {
        window-role = {
          value = "GtkFileChooserDialog";
          type = "exact";
        };
        window-types = [ "dialog" ];
      };
      apply = {
        fsplevel = force 0;
      };
    }

    {
      description = "Firefox";

      match = {
        window-class = {
          value = "firefox firefox";
          type = "exact";
          match-whole = true;
        };
      };
      apply = {
        fsplevel = force 0; # None - Want to show when opening links and whatnot
      };
    }

    {
      description = "Discord";

      match = {
        window-class = {
          value = regex ''(discord|vesktop)'';
          type = "regex";
          match-whole = false;
        };
      };
      apply = {
        fsplevel = force 4; # Extreme - no splash, whatever
      };
    }

    {
      description = "Steam on-screen keyboard";

      match = {
        window-class = {
          value = "steamwebhelper steam";
          type = "exact";
          match-whole = true;
        };
        title = {
          value = "Steam Input On-screen Keyboard";
          type = "exact";
        };
      };
      apply = {
        above = force true;
        acceptfocus = force false;
        screen = force 0; # Built-in / internal
        size = force "1130,360";
        skipswitcher = force true;
        skiptaskbar = force true;
      };
    }

    {
      description = "KDE System settings";

      match = {
        window-class = {
          value = "systemsettings systemsettings";
          type = "exact";
          match-whole = true;
        };
      };
      apply = {
        minsize = force "700,300";
      };
    }

    {
      description = "UltiMaker Cura";

      match = {
        window-class = {
          value = "UltiMaker-Cura com/.https://ultimaker.UltiMaker-Cura"; # wtf
          type = "exact";
          match-whole = true;
        };
      };
      # Fix the desktop file link
      apply = {
        desktopfile = force "cura";
      };
    }
  ];
}
