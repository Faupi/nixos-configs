{ ... }: {
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/plain" = "codium.desktop"; # TODO: Split to own config - do not set anything shared
    };
  };
}
