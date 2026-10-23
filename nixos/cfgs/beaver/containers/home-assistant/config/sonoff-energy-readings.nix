# Practically a replacement for Sonoff's broken energy meter readings, as they require full connectivity to count properly.
# Here we get direct power readings and calculating the usage manually in HA.

{ lib, ... }:
let
  inherit (lib) concatMapAttrs mapAttrs' attrValues flip;

  plugs = {
    office = {
      name = "Office";
      powerSensor = "sensor.office_sonoff_10027b9602_power";
    };
    bedroomfan = {
      name = "Bedroom Fan";
      powerSensor = "sensor.bedroom_fan_sonoff_100270d86f_power";
    };
    ac = {
      name = "AC";
      powerSensor = "sensor.ac_sonoff_1002736af7_power";
    };
    printer = {
      name = "3D Printer";
      powerSensor = "sensor.3d_printer_sonoff_100270d378_power";
    };
  };

  integrationSensors = mapAttrs'
    (id: plug: {
      name = "sensor_${id}";
      value = {
        name = "${plug.name} Energy Total";
        unique_id = "${id}_energy_total";
        platform = "integration";
        source = plug.powerSensor;
        unit_prefix = "k";
        unit_time = "h";
        method = "left";
        round = 3;
      };
    })
    plugs;

  utilityMeters = flip concatMapAttrs plugs
    (id: plug: {
      "${id}_energy_daily" = {
        name = "${plug.name} Energy Daily";
        unique_id = "${id}_energy_daily";
        source = "sensor.${id}_energy_total";
        cycle = "daily";
      };

      "${id}_energy_monthly" = {
        name = "${plug.name} Energy Monthly";
        unique_id = "${id}_energy_monthly";
        source = "sensor.${id}_energy_total";
        cycle = "monthly";
      };
    });
in
{
  sensor = attrValues integrationSensors;
  utility_meter = utilityMeters;
}
