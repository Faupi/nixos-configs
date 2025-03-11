{ ... }: {
  programs.steam.platformOptimizations.enable = true; # SteamOS tweaks https://github.com/fufexan/nix-gaming/blob/64a949349294543a48b3f946c9fca84332d1398b/modules/platformOptimizations.nix

  jovian.steamos = {
    useSteamOSConfig = false; # No automatic enabling of stuff in the steamos module
    enableDefaultCmdlineConfig = false; # Already handled by hardware
    enableBluetoothConfig = true;
    enableProductSerialAccess = true;

    enableSysctlConfig = true; # Scheduling etc tweaks

    # These don't seem to do much than take forever to build
    enableVendorRadv = false;
    enableMesaPatches = false;
  };
}
