{ ... }: {
  zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 60;
  };

  boot = {
    kernel.sysctl = {
      "vm.swappiness" = 5; # Swap less - more aggressive clearing
      "vm.page-cluster" = 0; # Supposedly helps latency - swaps only what's needed
      "vm.watermark_boost_factor" = 0; # Reduce sudden aggressive reclaim spikes

      # Reduce reclaim stalls
      "vm.dirty_background_ratio" = 5;
      "vm.dirty_ratio" = 10;
    };
  };
}
