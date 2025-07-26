{ ... }: {
  jovian.steamos = {
    useSteamOSConfig = false; # No automatic enabling of stuff in the steamos module
    enableProductSerialAccess = true;
    enableAutoMountUdevRules = true;
    enableEarlyOOM = true; # REVIEW: Early OOM, might be fucky
  };
}
