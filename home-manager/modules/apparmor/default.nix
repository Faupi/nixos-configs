{ config, lib, pkgs, ... }:
with lib;
{
  options.apparmor =
    let
      profileOpts = { name, config, options, ... }: {
        options = {
          target = mkOption {
            description = "Target path or expression to set the rule for";
            type = with types; str;
            default = null;
          };
          flags = mkOption {
            type = with types; listOf str;
            default = [ "unconfined" ];
          };
        };
      };
    in
    {
      enable = mkEnableOption "Enable apparmor config service";
      profiles = mkOption {
        default = { };
        type = with types; attrsOf (submodule profileOpts);
      };
    };

  config =
    let
      profileFiles = flip mapAttrsToList config.apparmor.profiles (name: profileConfig: {
        inherit name;
        path = (pkgs.substituteAll {
          src = ./template;
          inherit name;
          inherit (profileConfig) target;
          flags = concatStringsSep " " profileConfig.flags; # No idea what is the separator as documentation does not mention it. Too bad.
        });
      });
    in
    {
      # TODO: Build files into a single derivation - link stuff at once with a service or switch wrapper
      xdg.dataFile."AppArmor nix profiles" = {
        target = "nix-apparmor.sh";
        text = ''
          ${lib.strings.concatStringsSep "\n" (lib.lists.forEach profileFiles (profile:
            "sudo ln -sf '${profile.path}' /etc/apparmor.d/nix-${profile.name}"
          ))}
          sudo systemctl restart apparmor
        '';
      };
    };
}
