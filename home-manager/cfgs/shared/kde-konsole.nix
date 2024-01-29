{ lib, pkgs, ... }: {
  # Add fonts
  fonts.fontconfig.enable = true;
  home.packages = [
    pkgs.nerdfont-hack-braille
  ];

  # Create custom ZSH profile
  home.file.".local/share/konsole/custom-zsh.profile".text =
    lib.generators.toINI { } {
      General = {
        Command = "${pkgs.zsh}/bin/zsh";
        Name = "Custom ZSH";
        Parent = "FALLBACK/";
      };
      Appearance = {
        ColorScheme = "Vapor";
        # TODO: Get from `fc-scan ${pkgs.nerdfont-hack-braille}/.../.ttf?
        Font = "HackNerdFontMono Nerd Font,10,-1,5,50,0,0,0,0,0";
      };
    };

  # Set Konsole default profile
  programs.plasma.configFile = {
    konsolerc = {
      "Desktop Entry" = { DefaultProfile = "custom-zsh.profile"; };
      TabBar = {
        CloseTabOnMiddleMouseButton = true;
        TabBarPosition = "Top";
        TabBarVisibility = "AlwaysShowTabBar";
      };
    };
  };
}
