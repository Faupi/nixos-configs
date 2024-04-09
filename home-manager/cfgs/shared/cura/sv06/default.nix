{ localPath, ... }:
{
  home.file = {
    "SV06 machine" = {
      target = "${localPath}/quality_changes/sovol_sv06_faupi.inst.cfg";
      source = ./faupi.inst.cfg;
      mutable = true;
      force = true;
    };
    "SV06 extruder 0" = {
      target = "${localPath}/quality_changes/sovol_planetary_extruder_0_%232_faupi.inst.cfg";
      source = ./faupi_extruder.inst.cfg;
      mutable = true;
      force = true;
    };
  };
}
