function getMonitorByWindow(window) {
  var windowClass = window.resourceClass;
  var windowTitle = window.caption;
  var isFullscreen = window.fullScreen;

  if (
    windowClass == "com.moonlight_stream.Moonlight" &&
    windowTitle != "Moonlight" && // Not the setup window
    isFullscreen == true
  ) {
    return "0x11"; // HDMI (streaming PC)
  }

  return "0x0f"; // DisplayPort (main Deck screen)
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
