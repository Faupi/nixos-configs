{ lib, pkgs, fop-utils, ... }:
with lib; {
  # Needed fonts
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override {
      fonts = [
        "LiberationMono" # 0xFF0 - editor
        "Hack" # 0x0FF - terminal
      ];
    })
  ];

  programs = {
    vscode = fop-utils.recursiveMerge [

      # General
      {
        enable = true;
        package = mkDefault pkgs.vscodium;
        extensions = with pkgs.vscode-extensions; [
          esbenp.prettier-vscode
          naumovs.color-highlight
        ];

        userSettings = {
          # Updates
          "update.enableWindowsBackgroundUpdates" = false;
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;

          # UI
          "editor.fontFamily" = "LiterationMono Nerd Font Mono, monospace"; # 0xFF0
          "editor.fontLigatures" = true;
          "editor.minimap.renderCharacters" = false;
          "editor.minimap.showSlider" = "always";
          "terminal.integrated.fontFamily" = "Hack Nerd Font Mono, monospace"; # 0x0FF
          "terminal.integrated.fontSize" = 14;
          "terminal.integrated.gpuAcceleration" = "on";
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "terminal.integrated.minimumContrastRatio" = 1; # Disable color tweaking
          "workbench.colorTheme" = "Default Dark Modern";
          "workbench.colorCustomizations" = {
            "statusBar.background" = "#007ACC";
            "statusBar.foreground" = "#F0F0F0";
            "statusBar.noFolderBackground" = "#222225";
            "statusBar.debuggingBackground" = "#511f1f";
          };
          "workbench.editor.labelFormat" = "short"; # Always show directory in tab
          "breadcrumbs.enabled" = true;
          "window.menuBarVisibility" = "toggle";

          # Git
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.inputValidation" = "off";
          "github.gitProtocol" = "ssh";

          # Misc
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
        };
      }

      # Nix-IDE
      {
        extensions = with pkgs.vscode-extensions; [ jnoortheen.nix-ide ];
        userSettings =
          let nixfmt-path = "${pkgs.unstable.nixpkgs-fmt}/bin/nixpkgs-fmt";
          in {
            "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
            "nix.formatterPath" = nixfmt-path; # Fallback for LSP
            "nix.enableLanguageServer" = true;
            "nix.serverPath" = getExe pkgs.unstable.nil;
            "nix.serverSettings" = {
              "nil" = { "formatting" = { "command" = [ nixfmt-path ]; }; };
            };
          };
      }

      # Shell
      {
        extensions = [
          pkgs.vscode-extensions.editorconfig.editorconfig # Dependency for shfmt
          (pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "shfmt";
            publisher = "mkhl";
            version = "1.3.0";
            sha256 = "sha256-lmhCROQfVYdBO/fC2xIAXSa3CHoKgC3BKUYCzTD+6U0=";
          })
        ];
        userSettings = {
          "[shellscript]" = { "editor.defaultFormatter" = "mkhl.shfmt"; };
          "shfmt.executablePath" = getExe pkgs.shfmt;
          "shfmt.executableArgs" = [ "--indent" "2" ];
        };
      }

      # Sops
      {
        extensions = [
          (pkgs.vscode-utils.extensionFromVscodeMarketplace {
            name = "signageos-vscode-sops";
            publisher = "signageos";
            version = "0.8.0";
            sha256 = "sha256-LcbbKvYQxob2zKnmAlylIedQkJ1INl/i9DSK7MemW9Y=";
          })
        ];
        userSettings = {
          "sops.binPath" = getExe pkgs.sops;
        };
      }

      # Todo Tree
      {
        extensions = with pkgs.vscode-extensions; [ gruntfuggly.todo-tree ];
        userSettings = {
          "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];
        };
      }

      # XML
      {
        extensions = with pkgs.unstable.vscode-extensions; [ redhat.vscode-xml ];
        userSettings = {
          "[xml]" = { "editor.defaultFormatter" = "redhat.vscode-xml"; };
          "redhat.telemetry.enabled" = false;
          "xml.server.binary.path" = getExe' pkgs.unstable.lemminx "lemminx";
          "xml.server.binary.trustedHashes" = [
            "ac771f518c29e21e9f8f98ed23350e2753892f785ac39fb9389e3aed7d6c64bf"
          ];
        };
      }

      # GitLens
      {
        extensions = with pkgs.unstable.vscode-extensions; [ eamodio.gitlens ];
      }

      # Python
      {
        extensions = with pkgs.unstable.vscode-extensions; [ ms-python.python ];
        userSettings = {
          "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
          "python.formatting.autopep8Path" = getExe' pkgs.python311Packages.autopep8 "autopep8";
        };
      }
    ];
  };
}
