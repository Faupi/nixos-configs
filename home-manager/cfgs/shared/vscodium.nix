{ lib, pkgs, fop-utils, ... }:
with lib;
let
  liberationFont = (pkgs.nerdfonts.override {
    fonts = [
      "LiberationMono" # #FF0 - editor
    ];
  });

  hackFont = pkgs.nerdfont-hack-braille; # #0FF - terminal

  # Make user configurations mutable
  # Depends on home-manager/modules/mutability.nix
  # https://gist.github.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa
  mutabilityWrapper = (builtins.fetchurl {
    url = "https://gist.githubusercontent.com/piousdeer/b29c272eaeba398b864da6abf6cb5daa/raw/41e569ba110eb6ebbb463a6b1f5d9fe4f9e82375/vscode.nix";
    sha256 = "fed877fa1eefd94bc4806641cea87138df78a47af89c7818ac5e76ebacbd025f";
  });
in
{
  imports = [
    mutabilityWrapper
  ];

  # Needed fonts
  fonts.fontconfig.enable = true;
  home.packages = [
    liberationFont # #FF0
    hackFont # #0FF
  ];

  programs = {
    vscode = fop-utils.recursiveMerge [

      # General
      {
        enable = true;
        package = mkDefault pkgs.vscodium;
        extensions =
          with pkgs.unstable.vscode-extensions;
          with pkgs.unstable.vscode-utils;
          [
            esbenp.prettier-vscode
            naumovs.color-highlight
            (extensionFromVscodeMarketplace {
              name = "vscode-vtools";
              publisher = "venryx";
              version = "1.0.7";
              sha256 = "sha256-CTGTaeDg73fFvrcu6wncTRi/2QqNSBhHmiZGWw0r4tQ=";
            })
          ];

        userSettings = {
          # Updates
          "update.mode" = "none";
          "extensions.autoUpdate" = false;
          "extensions.autoCheckUpdates" = false;

          # UI
          "workbench.editor.labelFormat" = "short"; # Always show directory in tab
          "breadcrumbs.enabled" = true;
          "window.menuBarVisibility" = "toggle";
          "vtools.autoHideSideBar" = true;
          "vtools.autoHideDelay" = 0;

          # Git
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.inputValidation" = "off";
          "github.gitProtocol" = "ssh";

          # Misc
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
          "terminal.integrated.gpuAcceleration" = "off"; # When enabled, it seems to cut off input text on intel
          "terminal.integrated.defaultProfile.linux" = "zsh";
          "color-highlight.matchRgbWithNoFunction" = true;
        };
      }

      # Visuals
      {
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "material-icon-theme";
            publisher = "PKief";
            version = "4.33.0";
            sha256 = "sha256-Rwpc5p7FOSodGa1WWrjgkexzAp8RlgZCYBXhep1G5Pk=";
          })
        ];
        userSettings = {
          # Workbench
          "workbench.iconTheme" = "material-icon-theme";
          "workbench.colorTheme" = "Default Dark Modern";
          "workbench.colorCustomizations" = {
            "statusBar.background" = "#007ACC";
            "statusBar.foreground" = "#F0F0F0";
            "statusBar.noFolderBackground" = "#222225";
            "statusBar.debuggingBackground" = "#511f1f";
          };

          # Editor 
          "editor.fontFamily" = "${fop-utils.getFontFamily pkgs liberationFont "mono-"}, monospace"; # #FF0
          "editor.fontLigatures" = true;
          "editor.minimap.showSlider" = "always";
          "editor.minimap.renderCharacters" = false;

          # Terminal
          "terminal.integrated.fontFamily" = "${fop-utils.getFontFamily pkgs hackFont "mono"}, monospace"; # #0FF
          "terminal.integrated.fontSize" = 14;
          "terminal.integrated.minimumContrastRatio" = 1; # Disable color tweaking
        };
      }

      # Spell check - TODO: Check if it's really worth using, Nix needs a ton of specific words added
      # {
      #   extensions = with pkgs.vscode-extensions; [ streetsidesoftware.code-spell-checker ];
      #   userSettings = {
      #     "cSpell.checkOnlyEnabledFileTypes" = false; # Disable filetypes with `"cSpell.enableFiletypes": ["!filetype"]`
      #     "cSpell.showAutocompleteSuggestions" = true;
      #     "cSpell.ignorePaths" = [
      #       "package-lock.json"
      #       "node_modules"
      #       "vscode-extension"
      #       ".git/objects"
      #       ".vscode"
      #       ".vscode-insiders"
      #       "result"
      #     ];
      #     "cSpell.userWords" = [
      #       "faupi"
      #     ];
      #   };
      # }

      # Nix-IDE
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          jnoortheen.nix-ide
        ];
        userSettings =
          let nixfmt-path = getExe pkgs.unstable.nixpkgs-fmt;
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
        extensions =
          with pkgs.unstable.vscode-extensions;
          with pkgs.unstable.vscode-utils;
          [
            # Dependency for shfmt
            (editorconfig.editorconfig)

            (extensionFromVscodeMarketplace {
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
        extensions = with pkgs.unstable.vscode-utils; [
          (extensionFromVscodeMarketplace {
            name = "signageos-vscode-sops";
            publisher = "signageos";
            version = "0.9.1";
            sha256 = "sha256-b1Gp+tL5/e97xMuqkz4EvN0PxI7cJOObusEkcp+qKfM=";
          })
        ];
        userSettings = {
          "sops.binPath" = getExe pkgs.unstable.sops;
        };
      }

      # Todo Tree
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          gruntfuggly.todo-tree
        ];
        userSettings = {
          "todo-tree.general.tags" = [ "BUG" "HACK" "FIXME" "TODO" "XXX" ];
        };
      }

      # XML
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          redhat.vscode-xml
        ];
        userSettings =
          let
            lemminxBinary = getExe' pkgs.unstable.lemminx "lemminx";
          in
          {
            "[xml]" = { "editor.defaultFormatter" = "DotJoshJohnson.xml"; };
            "redhat.telemetry.enabled" = false;
            "xml.server.binary.path" = lemminxBinary;
            "xml.server.binary.trustedHashes" = [ (builtins.hashFile "sha256" lemminxBinary) ];
          };
      }

      # GitLens
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          eamodio.gitlens
        ];
      }

      # Python
      {
        extensions = with pkgs.unstable.vscode-extensions; [
          ms-python.python
        ];
        userSettings = {
          "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
          "python.formatting.autopep8Path" = getExe' pkgs.python311Packages.autopep8 "autopep8";
        };
      }
    ];
  };
}
