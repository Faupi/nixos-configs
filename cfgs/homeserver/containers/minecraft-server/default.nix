{ config, pkgs, lib, ... }:
with lib;
let
  hostConfig = config;
  externalPort = 25565;
  internalPort = externalPort;
  dataDir = "/srv/minecraft";

  modsRepo = pkgs.fetchFromGitHub {
    owner = "Faupi";
    repo = "MinecraftMods";
    rev = "a1178067eaafa0a2771ba3e39a71291add894612";
    sha256 = "1bma67l6l99ygkcxwphg42hiy247xm772as63mfjlrxq9s8i7rmf";
  };
  modBlacklist = [
    "DistantHorizons"
  ];

  # cba to make a proper option for this yet
  opsFile = pkgs.writeText "ops.json"
    (builtins.toJSON
      (mapAttrsToList (n: v: { name = n; uuid = v.uuid; level = v.level; }) {
        Faupi = {
          uuid = "b36aeccb-99b6-4384-b986-a685d39f364b";
          level = 4;
        };
        KudoTheYeen = {
          uuid = "e4b86d34-6a04-404e-bb1a-203cf18881dd";
          level = 4;
        };
      }));
in
{
  networking.firewall = {
    allowedTCPPorts = [ externalPort ];
    allowedUDPPorts = [ externalPort ];
  };

  containers.minecraft-server = {
    autoStart = true;
    privateNetwork = false;
    forwardPorts = [{
      hostPort = externalPort;
      containerPort = internalPort;
      protocol = "tcp";
    }];
    extraFlags = [ "-U" ]; # Security

    config = { config, pkgs, ... }: {
      nixpkgs.overlays = hostConfig.nixpkgs.overlays;

      services.minecraft-server = {
        enable = true;
        package = pkgs.minecraft-server-fabric_1_20_4;
        inherit dataDir;
        eula = true;
        openFirewall = true;
        declarative = true;

        serverProperties = {
          motd = "HEWWO OWO :3 :D";
          server-port = internalPort;
          spawn-protection = 0;
          max-tick-time = 5 * 60 * 1000;
          allow-flight = true;
          pvp = true;
          view-distance = 16;
        };

        whitelist = {
          # https://mcuuid.net/
          Faupi = "b36aeccb-99b6-4384-b986-a685d39f364b";
          KudoTheYeen = "e4b86d34-6a04-404e-bb1a-203cf18881dd";
          randomdragon6396 = "a1bb61eb-f7e4-44c7-b09c-fe58cc5a0916";
          Banananke = "71fdb609-7e4c-4961-839d-bdf9268b3f25";
        };

        jvmOpts = concatStringsSep " " [
          "-Xmx8G" # Max RAM
          "-Xms2G" # Initial RAM
          "-XX:+UseG1GC"
          "-XX:+ParallelRefProcEnabled"
          "-XX:MaxGCPauseMillis=200"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+DisableExplicitGC"
          "-XX:+AlwaysPreTouch"
          "-XX:G1NewSizePercent=40"
          "-XX:G1MaxNewSizePercent=50"
          "-XX:G1HeapRegionSize=16M"
          "-XX:G1ReservePercent=15"
          "-XX:G1HeapWastePercent=5"
          "-XX:G1MixedGCCountTarget=4"
          "-XX:InitiatingHeapOccupancyPercent=20"
          "-XX:G1MixedGCLiveThresholdPercent=90"
          "-XX:G1RSetUpdatingPauseTimePercent=5"
          "-XX:SurvivorRatio=32"
          "-XX:+PerfDisableSharedMem"
          "-XX:MaxTenuringThreshold=1"
        ];
      };

      system.activationScripts.linkServerData = ''
        ln -sf ${opsFile} ${dataDir}/ops.json
        
        install -Dm660 -o minecraft -g minecraft ${modsRepo}/config/* ${dataDir}/config/

        mkdir -p ${dataDir}/mods
        rm -rf ${dataDir}/mods/*
        ln -sf ${modsRepo}/mods/*.jar ${dataDir}/mods/

        ${
          # Handle blacklisted mods by removing their links
          concatStringsSep "\n" (map (blacklistedMod: ''
            rm -f ${dataDir}/mods/${blacklistedMod}*.jar
          '') 
          modBlacklist)
        }
      '';

      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      system.stateVersion = "23.11";
    };
  };
}
