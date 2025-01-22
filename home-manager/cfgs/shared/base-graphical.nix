{ pkgs, config, ... }:
{
  home.packages = (with pkgs; [
    # TODO: Figure out why Haruna fails builds under NixGL
    haruna
    ibm-plex
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
      # TODO: Change fonts in plasma as well lol
      serif = [ "IBM Plex Serif" "Twitter Color Emoji" ];
      sansSerif = [ "IBM Plex Sans" "Twitter Color Emoji" ];
      emoji = [ "Twitter Color Emoji" ];
      monospace = [ "Cascadia Mono NF SemiBold" ];
    };
  };
}
