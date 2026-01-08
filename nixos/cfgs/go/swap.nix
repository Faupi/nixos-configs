# Swap setup - compress in RAM first, fall back to swapfile
{ ... }: {
  # Specifically disable zram - we're using zswap
  zramSwap.enable = false;

  boot = {
    initrd = {
      systemd.enable = true; # Needed for LZ4
      kernelModules = [ "lz4" ];
    };

    kernelParams = [
      "zswap.enabled=1"
      "zswap.compressor=lz4"
      "zswap.max_pool_percent=15" # ~2.4 GiB cap on 16 GiB (good for UMA - shared memory)
      "zswap.shrinker_enabled=1"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 20; # Swap less - more aggressive clearing
      "vm.page-cluster" = 0; # Supposedly helps latency - swaps only what's needed
    };
  };

  # Backing swap on NVMe
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
    discardPolicy = "once";
    priority = 0;
  }];
}
