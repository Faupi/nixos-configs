{ config, pkgs, lib, ... }:
with lib;
let 
  host-config = config;
  cfg = config.my.vintagestory;

  modsRepo = pkgs.fetchFromGitHub {
    owner = "Faupi";
    repo = "VintageStoryMods";
    rev = "master";
    sha256 = "sha256-yKbvIQ9dfVsLXMCfkdC73/sLPD1lJCopcHm+nYcFdnw=";
  };
in
{
  options.my.vintagestory = {
    client = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.vintagestory;
      };
      user = mkOption {
        type = types.str;
      };
    };
    server = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      package = mkOption {
        type = types.package;
        default = pkgs.vintagestory;
      };
      dataPath = mkOption {
        type = types.str;
        default = "vintagestory";
        description = "Path under /etc to save server data under.";
      };
    };
    mods = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkMerge [

    # Client
    (mkIf cfg.client.enable {
      home-manager.users."${cfg.client.user}" = mkMerge [
        {
          home.packages = with pkgs; [
            cfg.client.package
          ];
        } 
        (mkIf cfg.mods.enable {
          home.file.".config/VintagestoryData/Mods".source = modsRepo;
        })
      ];
    })

    # Server
    (mkIf cfg.server.enable {

      networking.firewall = {
        allowedTCPPorts = [ 42420 ];
      };

      containers.vintagestory-server = {
        autoStart = true;
        privateNetwork = false;
        forwardPorts = [
          {
            containerPort = 42420;
            hostPort = 42420;
            protocol = "tcp";
          }
        ];
        extraFlags = [ "-U" ];  # Security

        config = { config, pkgs, ... }: mkMerge [
          {
            # Inherit overlays
            nixpkgs.overlays = host-config.nixpkgs.overlays;

            networking.firewall = {
              enable = true;
              allowedTCPPorts = [ 42420 ];
            };
            
            # Service
            systemd.services.vintagestory-server = {
              enable = true;
              description = "Vintage story server";
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ];
              serviceConfig = {
                Restart = "always";
                RestartSec = 30;
                StandardOutput = "syslog";
                StandardError = "syslog";
                SyslogIdentifier = "VSSRV";
                ExecStart = "${cfg.server.package}/bin/vintagestory-server --dataPath '/etc/${cfg.server.dataPath}'";
                WorkingDirectory = "/etc/${cfg.server.dataPath}";
              };
            };

            # Server config
            environment.etc."${cfg.server.dataPath}/serverconfig.json".text = 
              builtins.toJSON (import ./serverconfig.nix { inherit (cfg.server) dataPath; });

            environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

            system.stateVersion = "23.05";
          }
          (mkIf cfg.mods.enable {
            environment.etc."${cfg.server.dataPath}/Mods".source = modsRepo;
          })
        ];
      };
    })

  ];
}