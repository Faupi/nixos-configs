{ pkgs, ... }:
{
  home.packages = with pkgs; [
    libgtop
    iotop
    pciutils
  ];

  dconf.settings = {
    "org/gnome/shell/extensions/astra-monitor" = {
      compact-mode = false;
      compact-mode-start-expanded = false;
      experimental-features = [ "ps_subprocess" ];
      gpu-header-show = true;
      gpu-indicators-order = [ "icon" "activity bar" "activity graph" "activity percentage" "memory bar" "memory graph" "memory percentage" "memory value" ];
      headers-height = 0;
      headers-height-override = 0;
      memory-header-bars-breakdown = true;
      memory-header-free = false;
      memory-header-tooltip-free = false;
      memory-indicators-order = [ "icon" "bar" "graph" "percentage" "value" "free" ];
      monitors-order = [ "processor" "gpu" "memory" "storage" "network" "sensors" ];
      network-header-show = false;
      network-indicators-order = [ "icon" "IO bar" "IO graph" "IO speed" ];
      panel-box = "left";
      panel-box-order = -1;
      processor-gpu = true;
      processor-header-bars = true;
      processor-header-bars-breakdown = false;
      processor-header-bars-core = false;
      processor-header-graph = false;
      processor-header-icon = true;
      processor-header-percentage = false;
      processor-header-percentage-core = false;
      processor-indicators-order = [ "icon" "bar" "graph" "percentage" "frequency" ];
      processor-menu-core-bars-breakdown = true;
      processor-menu-gpu-color = "";
      processor-update = 1.5;
      queued-pref-category = "";
      sensors-indicators-order = [ "icon" "value" ];
      shell-bar-position = "top";
      storage-header-show = false;
      storage-indicators-order = [ "icon" "bar" "percentage" "value" "free" "IO bar" "IO graph" "IO speed" ];
      storage-main = "root";
      theme-style = "dark";

      gpu-update = 2;
      memory-update = 3;
      network-update = 1.5;
      sensors-update = 3;
      storage-update = 3;
    };
  };
}
