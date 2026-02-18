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
      "zswap.max_pool_percent=50" # yolo
      "zswap.shrinker_enabled=1"
    ];

    kernel.sysctl = {
      "vm.swappiness" = 10; # Swap less - more aggressive clearing
      "vm.page-cluster" = 0; # Supposedly helps latency - swaps only what's needed
      "vm.watermark_boost_factor" = 0; # Reduce sudden aggressive reclaim spikes

      # Reduce reclaim stalls
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
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
