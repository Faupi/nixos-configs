{ pkgs, ... }: {
  home.packages = with pkgs; [ maliit-keyboard ];

  programs.plasma.configFile.kwinrc.Wayland = {
    InputMethod = "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";
    VirtualKeyboardEnabled = true;
  };

  dconf = {
    enable = true;
    settings = {
      "org.maliit.keyboard.maliit" = {
        key-press-haptic-feedback = true;
        theme = "BreezeDark";
      };
    };
  };
}
