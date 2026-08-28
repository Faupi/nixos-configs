{ pkgs, lib, fop-utils, config, ... }@args:
{
  imports = [
    ./moonlight.nix
  ];

  flake-configs = {
    blender.enable = true;
    clipboard-actions.enable = true;
    dank-material-shell.enable = true;
    dolphin.enable = true;
    konsole.enable = true;
    unityhub.enable = true;

    vscodium = {
      enable = true;
      setAsDefault = true;
      folderHandling.enable = true;
    };
  };

  home.packages = with pkgs; [
    telegram-desktop

    winetricks
    wineWow64Packages.waylandFull

    (bottles.override { removeWarningPopup = true; })
  ];

  programs = {
    zen-browser = {
      enable = true;
      profiles.faupi = (import "${fop-utils.homeSharedConfigsPath}/firefox-profiles/faupi.nix" args) // { isDefault = true; };
    };

    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        # obs-vkcapture # TODO: Infinitely hangs on checks - https://github.com/NixOS/nixpkgs/issues/349053
        obs-vaapi
      ];
    };
  };

  # Zen as default browser (since no shared module)
  home.sessionVariables = {
    BROWSER = lib.getExe config.programs.zen-browser.package;
  };
  xdg.mimeApps = {
    enable = lib.mkDefault true;
    defaultApplications = fop-utils.mimeDefaultsFor "zen.desktop" [
      "text/html"
      "text/xml"
      "application/xml"
      "application/xhtml+xml"
      "application/xhtml_xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
