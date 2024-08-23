{ pkgs, ... }:
{
  home.packages = with pkgs; [
    prusa-slicer
  ];

  /*
    TODO: Add config for SV06:
        - Add configs for profile (`home-manager/cfgs/shared/prusa-slicer/print/TESTING-THING.ini`)
        - Add config for printer (only start and end gcode via crud preferably? `home-manager/cfgs/shared/prusa-slicer/printer/SV06 - Copy.ini`)
  */
}
