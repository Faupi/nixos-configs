# HHD for EC calls + fan control
{ ... }: {
  services.handheld-daemon = {
    user = "faupi"; # TODO: Make main user
    enable = true;
    ui.enable = false; # Prevent force-loading of overlay
    adjustor = {
      enable = true;
      loadAcpiCallModule = true; # Shouldn't be needed, but might as well
    };

    config = {
      hhd = {
        settings = {
          amd_energy_enable = false; # Use steamos-manager + PPD instead
          amd_energy_ppd = false; # Use steamos-manager + PPD instead
          rgb = true;
          tdp_enable = true;
          fuse_mount = false; # Use steamos-manager instead
          enforce_limits = true; # TDP limits (steamos-manager is limited the same)
          powerbuttond = false; # Use Jovian powerbutton instead
        };
        http = {
          localhost = true; # Limit to localhost
          token = false; # No need on localhost (it didn't generate anyway)
        };
      };

      tdp.lenovo = {
        fan = {
          mode = "manual";
          manual = {
            st10 = 44;
            st20 = 48;
            st30 = 55;
            st40 = 60;
            st50 = 71;
            st60 = 79;
            st70 = 85;
            st80 = 95;
            st90 = 105;
            st100 = 105;
            enforce_limits = true;
          };
        };
        tdp_rgb = true; # Show TDP with controller RGB
        power_light = true;
        power_light_sleep = false;
      };

      rgb.handheld.mode = {
        mode = "solid";
        solid = {
          hue = 275;
          saturation = 100;
          brightness = 20;
        };
      };

      controllers.legion_go.xinput = {
        mode = "hidden";
        hidden.noob_mode = false;
      };

      gamemode.power.hibernate_auto = true;
    };
  };
}
