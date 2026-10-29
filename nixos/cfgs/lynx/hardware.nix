{ config, ... }:
{
  boot = {
    kernelParams = [
      "amd_pstate=active" # Should stabilize clocks (was boosting to max 4.2GHz)
    ];

    extraModulePackages = [
      (config.boot.kernelPackages.zenergy.overrideAttrs (old: {
        # Hopefully temporary workaround for zenergy adding modules.symbols
        postInstall = (old.postInstall or "") + /*sh*/''
          find "$out/lib/modules" -type f \
            \( -name 'modules.alias' \
            -o -name 'modules.alias.bin' \
            -o -name 'modules.dep' \
            -o -name 'modules.dep.bin' \
            -o -name 'modules.devname' \
            -o -name 'modules.softdep' \
            -o -name 'modules.symbols' \
            -o -name 'modules.symbols.bin' \
            -o -name 'modules.builtin.bin' \
            -o -name 'modules.builtin.alias.bin' \) \
            -delete
        '';
      }))
    ];
    kernelModules = [
      "zenergy"
    ];
  };

  hardware = {
    # firmware = [ pkgs.bleeding.linux-firmware ]; # Up to date drivers for GPU # NOTE: there was a regression in AV1, currently not fixed in nixpkgs (needs mesa 26.2.0+)
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
  };

  services.hardware.openrgb.enable = true;
}
