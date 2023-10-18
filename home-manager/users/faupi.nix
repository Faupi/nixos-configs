{ lib, pkgs, fop-utils, ... }: {
  imports = [
    ./base.nix
  ];

  home = rec {
    username = "faupi";
    homeDirectory = "/home/${username}";
    stateVersion = "23.05";
  };

  programs = {
    _1password = {
      enable = true;
      autostart = {
        enable = true;
        silent = true;
      };
      useSSHAgent = true;
    };

    vscode = fop-utils.recursiveMerge [
      {
        # General
        enable = true;
        package = pkgs.vscodium-fhs-nogpu;
        extensions = with pkgs.vscode-extensions; [
          esbenp.prettier-vscode
          naumovs.color-highlight
          ms-python.python
          sumneko.lua
        ];

        userSettings = {
          # Updates
          "update.enableWindowsBackgroundUpdates" = false;
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;

          # UI
          "editor.fontFamily" =
            "Consolas, 'Consolas Nerd Font', 'Courier New', monospace";
          "editor.fontLigatures" = true;
          "editor.minimap.renderCharacters" = false;
          "editor.minimap.showSlider" = "always";
          "terminal.integrated.fontFamily" = "CaskaydiaCove Nerd Font Mono";
          "terminal.integrated.gpuAcceleration" = "on";
          "workbench.colorTheme" = "Default Dark Modern";
          "workbench.colorCustomizations" = {
            "statusBar.background" = "#007ACC";
            "statusBar.foreground" = "#F0F0F0";
            "statusBar.noFolderBackground" = "#222225";
            "statusBar.debuggingBackground" = "#511f1f";
          };

          # Git
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.inputValidation" = "off";
          "github.gitProtocol" = "ssh";

          # Misc
          "[json]" = {
            "editor.defaultFormatter" = "vscode.json-language-features";
          };
        };
      }
      {
        # Nix-IDE
        extensions = with pkgs.vscode-extensions; [ jnoortheen.nix-ide ];
        userSettings = {
          "nix.formatterPath" = "${pkgs.nixfmt}/bin/nixfmt";
          "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
        };
      }
      {
        # Sops
        extensions = [
          (pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "signageos-vscode-sops";
            publisher = "signageos";
            version = "0.8.0";
            sha256 = "sha256-LcbbKvYQxob2zKnmAlylIedQkJ1INl/i9DSK7MemW9Y=";
          })
        ];
        userSettings = { "sops.binPath" = "${pkgs.sops}/bin/sops"; };
      }
      {
        # Todo Tree
        extensions = with pkgs.vscode-extensions; [ gruntfuggly.todo-tree ];
        userSettings = {
          "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];
        };
      }
    ];

    git = {
      userName = "Faupi";
      userEmail = "matej.sp583@gmail.com";
    };
  };
}
