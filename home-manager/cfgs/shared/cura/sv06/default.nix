{ localPath, ... }:
{
  home.file = {
    "SV06 machine custom" = {
      target = "${localPath}/quality_changes/sovol_sv06_faupi.inst.cfg";
      source = ./quality_changes/faupi.inst.cfg;
      mutable = true;
      force = true;
    };
    "SV06 extruder 0 custom" = {
      target = "${localPath}/quality_changes/sovol_planetary_extruder_0_%232_faupi.inst.cfg";
      source = ./quality_changes/faupi_extruder.inst.cfg;
      mutable = true;
      force = true;
    };
    "SV06 machine" = {
      target = "${localPath}/definition_changes/Sovol+SV06_settings.inst.cfg";
      source = ./definition_changes/Sovol+SV06_settings.inst.cfg;
      mutable = true;
      force = true;
    };
  };
}
