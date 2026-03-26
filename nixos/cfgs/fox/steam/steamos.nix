{ lib, ... }: {
  jovian.steamos = {
    useSteamOSConfig = lib.mkForce false; # No automatic enabling of stuff in the steamos module
    enableProductSerialAccess = true;
    enableAutoMountUdevRules = true;
    enableSysctlConfig = true; # Latency optimizations from SteamOS
  };
}
