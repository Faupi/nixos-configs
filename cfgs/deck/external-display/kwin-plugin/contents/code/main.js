function getMonitorByWindow(window) {
  var windowClass = window.resourceClass;
  var windowTitle = window.caption;

  if (
    windowClass == "com.moonlight_stream.Moonlight" &&
    windowTitle != "Moonlight" // Not the setup window
  ) {
    return "0x11"; // HDMI (streaming PC)
  }

  return "0x0f"; // DisplayPort (main Deck screen)
}

workspace.clientActivated.connect(function (window) {
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
});
