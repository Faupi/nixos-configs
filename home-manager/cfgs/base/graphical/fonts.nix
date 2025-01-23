{ pkgs, ... }: {
  home.packages = with pkgs; [
    ibm-plex
    (google-fonts.override {
      fonts = [ "Outfit" ];
    })
    twitter-color-emoji
    cascadia-code
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [
        "IBM Plex Serif"
        "Cascadia Code NF"
        "Twitter Color Emoji"
      ];
      sansSerif = [
        "Outfit"
        "Cascadia Code NF"
        "Twitter Color Emoji"
      ];
      emoji = [ "Twitter Color Emoji" ];
      monospace = [ "Cascadia Mono NF SemiBold" ];
    };
  };
}
