{ pkgs, ... }: {
  home.file."Plasma wallpaper - HTML wallpaper type" = {
    target = ".local/share/plasma/wallpapers/de.unkn0wn.htmlwallpaper/";
    # TODO: Move to packages
    source = pkgs.fetchzip {
      url = "https://github.com/Marcel1202/HTMLWallpaper/releases/download/v2.2/de.unkn0wn.htmlwallpaper-2.2.zip";
      sha256 = "";
      extension = "zip";
      stripRoot = false;
    };
    recursive = true;
  };

  # TODO: For auto-enabling, file:///home/faupi/.config/plasma-org.kde.plasma.desktop-appletsrc needs a module
}
