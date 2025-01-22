{ pkgs, config, ... }:
{
  home.packages = (with pkgs; [
    # TODO: Figure out why Haruna fails builds under NixGL
    haruna
    ibm-plex
    (google-fonts.override {
      fonts = [ "Outfit" ];
    })
    twitter-color-emoji
    cascadia-code
  ])
  ++ (map (x: (config.lib.nixgl.wrapPackage x)) (with pkgs; [
    qpwgraph
    filelight
    krita
  ]));


  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "IBM Plex Serif" "Cascadia Code NF" "Twitter Color Emoji" ];
      sansSerif = [ "Outfit" "Cascadia Code NF" "Twitter Color Emoji" ];
      emoji = [ "Twitter Color Emoji" ];
      monospace = [ "Cascadia Mono NF SemiBold" ];
    };
  };
}
