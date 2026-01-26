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
      "zswap.max_pool_percent=10" # ~1.6GiB cap on 16 GiB - low for hibernation headroom
      "zswap.shrinker_enabled=1"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 20; # Swap less - more aggressive clearing
      "vm.page-cluster" = 0; # Supposedly helps latency - swaps only what's needed
    };
  };

  # Backing swap on NVMe
  # NOTE: linux-swap partition, rec. 24GiB+, is used for hibernation too
  swapDevices = [
    {
      device = "/dev/disk/by-label/NIXSWAP";
      priority = 0;
    }
  ];
}
