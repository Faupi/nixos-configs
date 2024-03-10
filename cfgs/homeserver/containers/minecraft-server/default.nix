{ inputs, config, lib, ... }:
with lib;
let
  host-config = config;
  server-port = 25565;

  # "Borrowed" from AllTheMods Discord
  jvmOpts = concatStringsSep " " [
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

  defaults = {
    white-list = true;
    spawn-protection = 0;
    max-tick-time = 5 * 60 * 1000;
    allow-flight = true;
  };
in
{
  networking.firewall = { allowedTCPPorts = [ server-port ]; };

  containers.minecraft-server = {
    autoStart = true;
    privateNetwork = false;
    forwardPorts = [{
      containerPort = server-port;
      hostPort = server-port;
      protocol = "tcp";
    }];
    extraFlags = [ "-U" ]; # Security

    config = { config, pkgs, ... }: {
      imports = [ inputs.minecraft-servers.module ];

      # Inherit overlays
      nixpkgs.overlays = host-config.nixpkgs.overlays;

      services.modded-minecraft-servers = {
        eula = true;

        instances = {
          e2es = {
            enable = true;

            jvmOpts =
              jvmOpts
              + " "
              + (concatStringsSep " " [
                "-javaagent:log4jfix/Log4jPatcher-1.0.0.jar"
                # "@libraries/net/minecraftforge/forge/1.18.2-40.1.84/unix_args.txt"
              ]);
            jvmPackage = pkgs.temurin-bin-17;
            jvmMaxAllocation = "8G";
            jvmInitialAllocation = "2G";

            serverConfig =
              defaults
              // {
                inherit server-port;
                motd = "Hewwo :3";
              };
          };
        };
      };

      # TODO: Link mods repo

      environment.etc."resolv.conf".text = "nameserver 8.8.8.8";

      system.stateVersion = "23.11";
    };
  };
}
