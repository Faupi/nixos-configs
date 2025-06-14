function getMonitorByWindow(window) {
  var windowClass = window.resourceClass;
  var windowTitle = window.caption;
  var isFullscreen = window.fullScreen;

  if (
    windowClass == "com.moonlight_stream.Moonlight" &&
    windowTitle != "Moonlight" && // Not the setup window
    isFullscreen == true
  ) {
    return "0x11"; // HDMI 1 (streaming PC)
  }

  return "0x12"; // HDMI 2 (local)
}

function attemptSwitch(window) {
  if (!window) {
    return;
  }

  targetMonitor = getMonitorByWindow(window);

  callDBus(
    "@dbusDestination@",
    "@dbusPath@",
    "@dbusInterface@",
    "notifyOfFocus",
    // NOTE: Keep newlines for easier extraction of values!
    `
      target-monitor: ${targetMonitor}
    `
  );
}

// Workspace
workspace.windowActivated.connect(attemptSwitch);
