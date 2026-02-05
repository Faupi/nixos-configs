{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;

  cfg = config.services.handheld-daemon;

  yamlValue =
    types.nullOr (types.oneOf [
      types.bool
      types.int
      types.float
      types.str
      (types.listOf yamlValue)
      (types.attrsOf yamlValue)
    ]);
in
{
  options.services.handheld-daemon = {
    statePath = mkOption {
      type = types.str;
      default = "/etc/hhd/state.yml";
      description = ''
        Absolute path to the HHD state file.

        The value of {option}`services.handheld-daemon.config` is merged into this file
        on system activation. If the file does not exist, it is created from the override.
      '';
    };

    config = mkOption {
      type = types.attrsOf yamlValue;
      default = { };
      example = {
        hhd.settings = {
          rgb = true;
          tdp_enable = true;
          enforce_limits = true;
          amd_energy_enable = false;
          amd_energy_ppd = false;
        };
        hhd.http = {
          localhost = true;
          token = false;
        };
        controllers.legion_go.xinput.mode = "hidden";
      };
      description = ''
        Nix-defined HHD configuration overrides rendered as YAML and merged into the
        HHD state file during system activation.

        Mappings are merged recursively, scalars override existing values, and lists
        are replaced.
      '';
    };
  };

  config = mkIf (cfg.enable && cfg.config != { }) {
    system.activationScripts.hhdMergeState =
      let
        statePath = cfg.statePath;
        overrideFile = pkgs.writeText "hhd-state-override.yml" (lib.generators.toYAML { } cfg.config);
        yqBin = lib.getExe pkgs.yq-go;
        installBin = lib.getExe' pkgs.coreutils "install";
      in
      {
        deps = [ "etc" ];
        text = /*sh*/''
          set -euo pipefail

          # Nix subs
          override="${overrideFile}"
          state="${statePath}"
          dir="$(dirname "$state")"
          yq="${yqBin}"
          install="${installBin}"

          mkdir -p "$dir"
          if [ -f "$state" ]; then
            override="$override" "$yq" eval -i '. * load(strenv(override))' "$state"
          else
            "$install" -m 0644 -o root -g root "$override" "$state"
          fi
        '';
      };
  };
}
