{ pkgs, ... }: {
  # TODO: Add a wrapper function for KWin scripts
  home.file."KWin script - Sticky window snapping" = {
    target = ".local/share/kwin/scripts/sticky-window-snapping/";
    source =
      let
        src = pkgs.fetchzip {
          url = "https://github.com/Flupp/sticky-window-snapping/archive/refs/tags/v1.0.1.zip";
          sha256 = "sha256-RZ5J5wSoyj36e8yPBEy4G4KWpvR1up3u8xjQea0oCNc=";
          extension = "zip";
          stripRoot = true;
        };
      in
      "${src}/package/";
    recursive = true; # Fix for kwin not seeing it because of symlinked directories
  };
  programs.plasma.configFile.kwinrc = {
    Plugins.sticky-window-snappingEnabled = true; # Auto-enable
  };
}
