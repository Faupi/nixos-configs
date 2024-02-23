// Subtitutes from Nix
const getSubstitute = (text) => (text.match(/^@.*@$/) ? [] : text.split(","));
hiddenItems = getSubstitute("@hiddenItems@");
shownItems = getSubstitute("@shownItems@");

// Find system tray config link in the panel, add the rules to it
panel.widgetIds.forEach((appletWidget) => {
  appletWidget = panel.widgetById(appletWidget);

  if (appletWidget.type === "org.kde.plasma.systemtray") {
    systemtrayId = appletWidget.readConfig("SystrayContainmentId");
    if (systemtrayId) {
      const systray = desktopById(systemtrayId);
      systray.currentConfigGroup = ["General"];
      systray.writeConfig("hiddenItems", hiddenItems);
      systray.writeConfig("shownItems", shownItems);
      systray.reloadConfig();
    }
  }
});
