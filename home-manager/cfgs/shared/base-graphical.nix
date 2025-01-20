{ pkgs, config, ... }:
{
  home.packages = (with pkgs; [
    # TODO: Figure out why Haruna fails builds under NixGL
    haruna
    noto-fonts
    twitter-color-emoji
  ])
  ++ (map (x: (config.lib.nixgl.wrapPackage x)) (with pkgs; [
    qpwgraph
    filelight
    krita
  ]));


  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      serif = [ "Noto Sans" "Twitter Color Emoji" ];
      sansSerif = [ "Noto Sans" "Twitter Color Emoji" ];
      emoji = [ "Twitter Color Emoji" ];
    };
  };
}
