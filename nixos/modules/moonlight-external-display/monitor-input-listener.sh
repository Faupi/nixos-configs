#!@bash@/bin/bash

dbus-monitor "destination=@dbusDestination@,path=@dbusPath@,interface=@dbusInterface@" |
  while read -r line; do
    value="$(echo "$line" | grep -o "target-monitor: .*" | cut -c17-)"
    if [[ -n "$value" ]]; then
      "@monitorInputSwitcher@" "$value"
    fi
  done
