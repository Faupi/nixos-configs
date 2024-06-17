{ config, lib, pkgs, fop-utils, ... }:
with lib;
{
  options.apparmor =
    let
      profileOpts = { name, config, options, ... }: {
        options = {
          package = mkOption {
            type = with types; nullOr package;
            default = null;
          };
          # TODO: Add option to override which binary it's supposed to link, for now it's just the mainProgram
          # binary = mkOption {
          #   description = "Binary path or expression to set the rule for";
          #   type = with types; nullOr str;
          #   default = null;
          # };
          flags = mkOption {
            default = [ "unconfined" ];
            type = with types; listOf str;
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
          binary = fop-utils.runCommand pkgs [ profileConfig.package ] "readlink -e '${getExe profileConfig.package}'";
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
            "sudo cp '${profile.path}' /etc/apparmor.d/nix-${profile.name}"
          ))}
          sudo systemctl restart apparmor
        '';
      };
    };
}
