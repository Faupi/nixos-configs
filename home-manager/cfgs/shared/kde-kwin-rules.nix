{ ... }: {
  programs.plasma.kwin.rules = {
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
        skipswitcher = true;
        skipswitcherrule = 2;
        skiptaskbar = true;
        skiptaskbarrule = 2;
        type = 4; # Dock (aligns properly on single-screen, same setting as maliit)
        typerule = 2;
        fullscreen = true;
        fullscreenrule = 2;
      };
    };
    "1Password SSH Request" = {
      enable = true;
      extraConfig = {
        title = "1Password"; # This is the only unique matcher - main window has longer titles thankfully
        titlematch = 1;
        windowrole = "browser-window";
        windowrolematch = 1;
        wmclass = "1password 1password";
        wmclasscomplete = true;
        wmclassmatch = 1;

        # Center on screen (default is offset to the bottom)
        ignoregeometry = true;
        ignoregeometryrule = 3;
        placementrule = 2;
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
  };
}
