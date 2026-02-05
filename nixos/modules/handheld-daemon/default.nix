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
    config = mkOption {
      type = types.attrsOf yamlValue;
      default = { };
    };
  };

  config = mkIf (cfg.enable && cfg.config != { }) {
    system.activationScripts.hhdMergeState =
      let
        statePath = "/etc/hhd/state.yml";
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
          yq="${yqBin}"
          install="${installBin}"

          mkdir -p /etc/hhd
          if [ -f "$state" ]; then
            override="$override" "$yq" eval -i '. * load(strenv(override))' "$state"
          else
            "$install" -m 0644 -o root -g root "$override" "$state"
          fi
        '';
      };
  };
}
