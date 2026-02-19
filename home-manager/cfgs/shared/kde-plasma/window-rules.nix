{ lib, cfg, ... }:
let
  regex = string: string; # Funny highlights

  force = value: { inherit value; apply = "force"; };
  # NOTE: Honestly the other options seemed pretty pointless
  # Docs: https://github.com/nix-community/plasma-manager/blob/trunk/modules/window-rules.nix

  mkPrefixed = prefix: config@{ description, ... }: ({
    description = "${prefix} - ${config.description}";
  } // config);

  mkDesktopFileLink = windowClass: desktopFile: extra: mkPrefixed "~Desktop file link" ({
    description = desktopFile;

    match = {
      window-class = {
        value = windowClass;
        type = "exact";
        match-whole = true;
      };
    };
    # Fix the desktop file link
    apply = {
      desktopfile = force desktopFile;
    };
  } // extra);

  mkPopup = windowClass: name: extra: mkPrefixed "~Popup" ({
    description = name;

    match = {
      window-class = {
        value = windowClass;
        type = "exact";
        match-whole = true;
      };
    };
    apply = {
      layer = force "popup";
    };
  } // extra);

  mkCritical = windowClass: name: extra: mkPrefixed "~Critical" ({
    description = name;

    match = {
      window-class = {
        value = windowClass;
        type = "exact";
        match-whole = true;
      };
    };
    apply = {
      layer = force "critical-notification";
    };
  } // extra);
in
{
  config = lib.mkIf cfg.enable {
    programs.plasma.window-rules = [
      {
        description = "KRunner";

        match = {
          window-class = {
            value = "krunner krunner";
            type = "exact";
            match-whole = true;
          };
        };
        apply = {
          layer = force "overlay";
          fpplevel = force 4; # Extreme focus protection
        };
      }

      {
        description = "Vivaldi picture-in-picture";

        match = {
          window-class = {
            value = "vivaldi-bin vivaldi-bin";
            type = "exact";
            match-whole = true;
          };
          title = {
            value = "Picture in picture";
            type = "exact";
          };
        };
        # Keep above
        apply = {
          above = force true;
        };
      }

      {
        description = "Discord";

        match = {
          window-class = {
            value = regex ''(discord|vesktop)'';
            type = "regex";
            match-whole = false;
          };
        };
        apply = {
          fsplevel = force 4; # Extreme - no splash, whatever
        };
      }

      {
        description = "Steam on-screen keyboard";

        match = {
          window-class = {
            value = "steamwebhelper steam";
            type = "exact";
            match-whole = true;
          };
          title = {
            value = "Steam Input On-screen Keyboard";
            type = "exact";
          };
        };
        apply = {
          above = force true;
          acceptfocus = force false;
          screen = force 0; # Built-in / internal
          size = force "1130,360";
          skipswitcher = force true;
          skiptaskbar = force true;
        };
      }

      (mkCritical "org.kde.polkit-kde-authentication-agent" "KDE Authentication" {
        match = {
          window-class = {
            type = "substring"; # Can have appended `-1` etc
            match-whole = false;
          };
          title = {
            value = "Authentication Required";
            type = "substring";
          };
        };
      })
      (mkCritical "ksecretd org.kde.ksecretd" "KDE Wallet Service" { })

      (mkPopup "1password 1password" "1Password" {
        # Match just the authentication prompt - not settings
        match.title = { type = "exact"; value = "1Password"; };
      })

      (mkDesktopFileLink "localsend_app localsend_app" "LocalSend" { })
      (mkDesktopFileLink "codium codium-url-handler" "codium" { })

    ];
  };
}
