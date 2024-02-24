// Subtitutes from Nix
var getSubstitute = (text) => (text.match(/^@.*@$/) ? null : text.split(",")); // Keep var so it can be redeclared if snippet gets used multiple times
hiddenItems = getSubstitute("@hiddenItems@");
shownItems = getSubstitute("@shownItems@");
extraItems = getSubstitute("@extraItems@");

// Find system tray config link in the panel, add the rules to it
panel.widgetIds.forEach((appletWidget) => {
  appletWidget = panel.widgetById(appletWidget);

  if (appletWidget.type === "org.kde.plasma.systemtray") {
    systemtrayId = appletWidget.readConfig("SystrayContainmentId");
    if (systemtrayId) {
      const systray = desktopById(systemtrayId);
      systray.currentConfigGroup = ["General"];
      if (hiddenItems != null) systray.writeConfig("hiddenItems", hiddenItems);
      if (shownItems != null) systray.writeConfig("shownItems", shownItems);
      if (extraItems != null) systray.writeConfig("extraItems", extraItems);
      systray.reloadConfig();
    }
  }
});
