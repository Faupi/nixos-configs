{ ... }: {
  programs.plasma.kwin.rules = {
    "01 Global min size" = {
      enable = true;
      extraConfig = {
        wmclassmatch = 0; # Class unimportant
        types = 1; # All normal windows

        # Force minimum size limit
        minsize = "100,10"; # 10px vertical important to not force content if the window just wants a "title" e.g. KRunner
        minsizerule = 2;
      };
    };
    "File picker dialog" = {
      enable = true;
      extraConfig = {
        types = 32; # Dialog window type
        windowrole = "GtkFileChooserDialog";
        windowrolematch = 1;

        fsplevelrule = 2;
        fsplevel = 0; # None - file picker
      };
    };
    "Firefox" = {
      enable = true;
      extraConfig = {
        wmclass = "firefox firefox";
        wmclasscomplete = true;
        wmclassmatch = 1;

        fsplevelrule = 2;
        fsplevel = 0; # None - opening links
      };
    };
    "Discord" = {
      enable = true;
      extraConfig = {
        wmclass = "discord";
        wmclassmatch = 1;

        fsplevelrule = 2;
        fsplevel = 4; # Extreme - splash screen etc
      };
    };
    "Steam on-screen keyboard" = {
      enable = true;
      extraConfig = {
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
        size = "1130,360";
        sizerule = 2;
        skipswitcher = true;
        skipswitcherrule = 2;
        skiptaskbar = true;
        skiptaskbarrule = 2;
        type = 4; # Dock (aligns properly on single-screen, same setting as maliit)
        typerule = 2;
      };
    };
    "KDE System settings" = {
      enable = true;
      extraConfig = {
        wmclass = "systemsettings systemsettings";
        wmclasscomplete = true;
        wmclassmatch = 1;
        windowrole = "MainWindow#1";
        windowrolematch = 1;
        types = 1;

        minsize = "700,300";
        minsizerule = 2;
      };
    };
    "UltiMaker Cura" = {
      enable = true;
      extraConfig = {
        wmclass = "UltiMaker-Cura com/.https://ultimaker.UltiMaker-Cura"; # wtf
        wmclasscomplete = true;
        wmclassmatch = 1;

        # Fix the desktop file link
        desktopfile = "cura";
        desktopfilerule = 2;
      };
    };
  };
}
