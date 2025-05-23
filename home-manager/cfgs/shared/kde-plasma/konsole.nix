{ lib, cfg, pkgs, ... }:
{
  config = lib.mkIf cfg.enable {
    # Add fonts
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      cascadia-code
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
          ColorScheme = "Leaf Dark";
          Font = "Cascadia Mono NF SemiBold,10,-1,5,600,0,0,0,0,0,0,0,0,0,0,1,Regular";
          AntiAliasFonts = true;
          BoldIntense = true;
          UseFontBrailleChararacters = true;
          UseFontLineChararacters = false; # On true can cause spaces between characters in certain scenarios
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
  };
}
