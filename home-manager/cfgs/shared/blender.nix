{ config, pkgs, lib, ... }:
let
  cfg = config.flake-configs.blender;
  extensionPath = "blender/${lib.versions.majorMinor cfg.package.version}/extensions/user_default";
  addonsPath = "blender/${lib.versions.majorMinor cfg.package.version}/scripts/addons";
in
{
  options.flake-configs.blender = {
    enable = lib.mkEnableOption "Blender";
    package = lib.mkOption {
      type = lib.types.package;
      default = with pkgs; blender;
    };
    # Add addons option?
    # Addon settings path e.g. `~/.config/blender/4.4/config/bl_ext.user_default.Modifier_List_Fork/preferences.json`
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (cfg.package.withPackages (py: [ py.py-slvs ]))
    ];

    xdg.configFile =
      # NOTE: Honestly not sure what decides this and I don't have enough time to handle it right now :3
      # Extensions
      (lib.attrsets.mapAttrs'
        (name: value: lib.attrsets.nameValuePair name {
          source = value;
          target = "${extensionPath}/${name}";
        })
        {
          "CAD_Sketcher" = pkgs.fetchFromGitHub {
            owner = "hlorus";
            repo = "CAD_Sketcher";
            rev = "3fb273c1d346450f7f6e458840ab3e3a6a1cefff";
            sha256 = "0zxf38dnxni4hdxsii39rrzllpy7f52ry0p8x7sc8qb3b4h9b162";
          };

          "Modifier_List_Fork" = pkgs.fetchFromGitHub {
            owner = "Dangry98";
            repo = "Modifier_List_Fork";
            rev = "033fc5674dbacb73c129e9f3a507e831ff83e217";
            sha256 = "03cb61y78n6gzs84gag6gc3c52xdivrh1k4imj8vdd5sirxmabgj";
          };

          "apply_modifiers_with_shape_keys" = pkgs.fetchFromGitHub {
            owner = "CGCookie";
            repo = "apply_modifiers_with_shape_keys";
            rev = "c591707af070bf680688ce0065c04713ad5c599b";
            sha256 = "0xhwwc5diifsfvs1shxby8w2fpzn0696vn1vxwfw2cjkdvj2iibb";
          };
        })

      # Addons
      // (lib.attrsets.mapAttrs'
        (name: value: lib.attrsets.nameValuePair name {
          source = value;
          target = "${addonsPath}/${name}";
        })
        {
          "shape_keys_plus" = pkgs.fetchFromGitHub {
            owner = "MichaelGlenMontague";
            repo = "shape_keys_plus";
            rev = "3dd64988647633663efba83d201655401270e085";
            sha256 = "0qzkghfzl5cdvx9g7arjx403pc1b99v75qj98dra4srxkjpd56qs";
          };
        });
  };
}
