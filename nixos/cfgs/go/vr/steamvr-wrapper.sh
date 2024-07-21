steamvr_settings="$HOME/.steam/steam/config/steamvr.vrsettings"

function start_steamvr() {
  "$HOME/.local/share/Steam/steamapps/common/SteamVR/bin/vrmonitor.sh" "$@"
}

function set_dashboard_resolution() {
  propagated_value=2000

  # Clear previous scoring
  jq '.GpuSpeed = (.GpuSpeed | walk(
    if type == "object" 
     then with_entries(select(.key | test("^gpuSpeed[0-9]") | not)) 
     else . end))' "$steamvr_settings" |
    sponge "$steamvr_settings"

  # Set one
  jq ".GpuSpeed.gpuSpeed0 = $propagated_value | .GpuSpeed.gpuSpeedHorsepower = $propagated_value | .GpuSpeed.gpuSpeedCount = 1" "$steamvr_settings" | sponge "$steamvr_settings"
}

function clear_preloads() {
  # https://github.com/ValveSoftware/SteamVR-for-Linux/issues/577

  # Set preload flags
  driver_overlay="$HOME/.local/share/Steam/steamapps/common/SteamVR/drivers/lighthouse/resources/webhelperoverlays.json"
  jq ".pairing.preload = false" "$driver_overlay" | sponge "$driver_overlay"

  steamvr_overlay="$HOME/.local/share/Steam/steamapps/common/SteamVR/resources/webhelperoverlays.json"
  jq ".settings_desktop.preload = false" "$steamvr_overlay" | sponge "$steamvr_overlay"

  # ~/.local/share/Steam/steamapps/common/SteamVR/drivers/vrlink/resources/webhelperoverlays.json
  # is missing on my machine?

  # Clear cached preload windows mappings
  jq "del(.DesktopUI)" "$steamvr_settings" | sponge "$steamvr_settings"
}

set_dashboard_resolution
clear_preloads
start_steamvr
